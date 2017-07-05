#
# Cookbook:: collect_metrics
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

cookbook_file '/home/centos/instance_data.sh' do
  source 'instance_data.sh'
  user   'centos'
  group  'centos'
  mode   '0755'
  notifies :run, 'execute[populate-instance-info]', :immediately 
end

execute 'populate-instance-info' do
  command '/home/centos/instance_data.sh'
  action :nothing
end
