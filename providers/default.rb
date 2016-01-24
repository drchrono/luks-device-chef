require 'shellwords'

# Support whyrun
def whyrun_supported?
  true
end

provides :luks_device, os: 'linux'

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists"
  else
    converge_by("Decrypt device #{ @new_resource.locked_device }") do
      decrypt_device
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Close #{ @new_resource.unlocked_device }") do
      close_device
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist, can't remove"
  end
end

def load_current_resource
  @current_resource = Chef::Resource::LuksDevice.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.locked_device(@new_resource.locked_device)
  @current_resource.unlocked_name(@new_resource.unlocked_name)
  @current_resource.pass_phrase(@new_resource.pass_phrase)

  if unlocked_device_exists?
    @current_resource.exists = true
  end
end

private

# Tasks
def decrypt_device
  locked_device = @new_resource.locked_device
  escaped_locked_device = ::Shellwords.escape(locked_device)

  if not ::File.blockdev?(locked_device)
    Chef::Log.warn "No device #{ locked_device } on this node"
    return
  end

  unlocked_device = @new_resource.unlocked_device
  escaped_unlocked_device = ::Shellwords.escape(unlocked_device)

  unlocked_name = @new_resource.unlocked_name
  escaped_unlocked_name = ::Shellwords.escape(unlocked_name)

  pass_phrase = @new_resource.pass_phrase
  escaped_pass_phrase = ::Shellwords.escape(pass_phrase)

  bash "Format #{ locked_device } for LUKS" do
    code <<-EOF.gsub(/^ {6}/, '')
      yes YES | cryptsetup luksFormat \\
          --key-file <(echo #{ escaped_pass_phrase }) \\
          #{ escaped_locked_device }
      EOF

    only_if do
      is_luks_device = ! shell_out('cryptsetup', 'luksDump', locked_device).error?
      is_other_device = ! shell_out('blkid', '-p', 'filesystem,other', locked_device).error?

      !is_luks_device and !is_other_device
    end
  end

  bash "Decrypt #{ locked_device } with LUKS" do
    code <<-EOF.gsub(/^ {6}/, '')
      cryptsetup open --type luks \\
        --key-file <(echo #{ escaped_pass_phrase }) \\
        #{ escaped_locked_device } #{ escaped_unlocked_name }
      EOF

    creates unlocked_device
  end
end


def close_device
  execute "Close device #{ @new_resource.unlocked_device }" do
    command "cryptsetup close #{ @new_resource.unlocked_name }"
    only_if { unlocked_device_exists? }
  end
end

def unlocked_device_exists?
  ::File.blockdev?(@new_resource.unlocked_device)
end
