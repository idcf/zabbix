# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

if node['zabbix']['server']['install']
  include_recipe "zabbix::server_#{node['zabbix']['server']['install_method']}"
end

if node['zabbix']['web']['install']
  %w(vlgothic-p-fonts dejavu-sans-fonts).each do |pkg|
    package pkg do
      action :install
    end
  end
  include_recipe "zabbix::web"
end
