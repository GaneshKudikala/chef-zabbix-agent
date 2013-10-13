#
# Cookbook Name:: zabbix-agent
# Recipe:: default
#
# Copyright 2013, Pavel Safronov
#
# All rights reserved - Do Not Redistribute
#

# Install required packages
package "zabbix-agent"

service "zabbix-agent" do
  supports :status => true, :restart => true, :reload => false
  action [:enable, :start]
end

template "#{node['zabbix-agent']['config_file']}" do
  source "zabbix_agentd.conf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, "service[zabbix-agent]"
end

remote_directory node['zabbix-agent']['scripts_dir'] do
  cookbook "zabbix-agent"
  files_group "root"
  files_owner "root"
  files_mode  0755
  action :create
end
