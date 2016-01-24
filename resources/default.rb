actions :create
default_action :create

attribute :locked_device, kind_of: String, required: true, name_attribute: true
attribute :unlocked_name, kind_of: String, default: lazy {|r| r.locked_device.gsub(/\A\/+/, '').gsub(/\//, '_') + '_unlocked' }
attribute :pass_phrase, kind_of: String, required: true

def unlocked_device
  "/dev/mapper/#{ unlocked_name }"
end

attr_accessor :exists
