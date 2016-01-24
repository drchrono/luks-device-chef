luks_device Cookbook
====================

A resource for unlocking and mounting LUKS encrypted devices.

Requirements
------------
- A Linux based system (LUKS stands for *Linux Unified Key Setup*)

Resources/Providers
-------------------
#### luks_device

Map an encrypted drive. This will automatically set up the device for encryption if it's currently unused (no partition table is not already a LUKS device).

##### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>:create</tt></td>
    <td>(default) Set up and map the named drive for encrypted use with LUKS</td>
  </tr>
</table>

##### Parameters
<table>
  <tr>
    <th>Parameter</th>
    <th>Required?</th>
    <th>Description</th>
    <th>Example</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>locked_device</tt></td>
    <td>Yes</td>
    <td>The existing locked device to use</td>
    <td><tt>'/dev/sda'</tt></td>
    <td></td>
  </tr>
  <tr>
    <td><tt>unlocked_device</tt></td>
    <td>No</td>
    <td>The preferred basename of the unlocked device, as would be listed under <tt>/dev/mapper/</tt></td>
    <td><tt>'sda_decrypted'</tt></td>
    <td>(<tt>locked_device</tt> with <tt>'/'</tt> replaced with <tt>'_'</tt>) + <tt>'_unlocked'</tt></td>
  </tr>
  <tr>
    <td><tt>pass_phrase</tt></td>
    <td>Yes</td>
    <td>The pass phrase to unlock the device</td>
    <td><tt>'your really long secret passphrase here'</tt></td>
    <td></td>
  </tr>
</table>

Usage
-----

Include `luks_device` in your run list or recipe and use the `luks_device` resource like so:

```ruby
include_recipe 'luks_device'

luks_device '/dev/sdb' do
  # unlocked device will be available at /dev/mapper/decrypted_drive
  unlocked_name 'decrypted_drive'
  pass_phrase drive_passphrase_from_encrypted_databag
end
```

You can get the full path to the unlocked device later like this:

```ruby
mount '/mnt/decrypted' do
  device resources(luks_device: '/dev/sdb').unlocked_device
  fstype 'xfs'
  action :mount
end
```

License and Authors
-------------------

* Author: Nick Meharry <nick@drchrono.com>

Copyright 2016, drchrono Inc.

All rights reserved.
