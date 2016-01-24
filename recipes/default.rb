#
# Cookbook Name:: luks_device
# Recipe:: default
#
# Copyright 2016, drchrono Inc.
#
# All rights reserved - Do Not Redistribute
#

package 'cryptsetup' do
  action :install
end
