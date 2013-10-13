#
# Cookbook Name:: zabbix-agent
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node['platform_family']

when "debian"
  include_recipe "apt"

  apt_preference '00zabbix' do
    glob         '*'
    pin          'origin repo.zabbix.com'
    pin_priority '1001'
  end

  apt_repository "zabbix" do
    uri 'http://repo.zabbix.com/zabbix/2.0/ubuntu/'
    distribution node['lsb']['codename']
    components [ "main" ]
    key "http://repo.zabbix.com/zabbix-official-repo.key"
    action :add
  end

end
