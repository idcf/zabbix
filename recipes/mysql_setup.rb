# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: mysql_setup
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "database::mysql"


# generate the password
node.set_unless['zabbix']['server']['dbpassword'] = secure_password

mysql_connection_info = {
  host: node['zabbix']['server']['dbhost'], 
  username: node['zabbix']['server']['dbuser'],
  password: node['zabbix']['server']['dbpassword'],
  port: node['zabbix']['server']['dbport']
}

# create zabbix database
mysql_database node['zabbix']['server']['dbname'] do
  connection mysql_connection_info
  action :create
  notifies :run, "execute[zabbix_populate_schema]", :immediately
  notifies :run, "execute[zabbix_populate_image]", :immediately
  notifies :run, "execute[zabbix_populate_data]", :immediately
  notifies :create, "template[#{node['zabbix']['etc_dir']}/zabbix_server.conf]", :immediately
  notifies :restart, "service[zabbix_server]", :immediately
end

# populate database

resource_names = ["zabbix_populate_schema", "zabbix_populate_data", "zabbix_populate_image"]

sql_files = if node['zabbix']['server']['version'].to_f < 2.0
  Chef::Log.info "Version 1.x branch of zabbix in use"
  ["/create/schema/mysql.sql", "/create/data/data.sql", "/create/data/images_mysql.sql"]
else
  Chef::Log.info "Version 2.x branch of zabbix in use"
  ["/database/mysql/schema.sql", "/database/mysql/data.sql", "/database/mysql/images.sql"]
end

sql_files.each_with_index do |sql_file, i|
  execute resource_names[i] do
    cmd = "/usr/bin/mysql"
    cmd << " -u #{node['zabbix']['server']['dbuser']}"
    cmd << " -p'#{node['zabbix']['server']['dbpassword'].gsub("'","\\'")}'"
    cmd << " -h #{node['zabbix']['server']['dbhost']}"
    cmd << " -P #{node['zabbix']['server']['dbport']}"
    cmd << " #{node['zabbix']['server']['dbname']}"
    cmd << " < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}" + sql_file
    command cmd
    action :nothing
  end
end

# create and grant zabbix user
mysql_database_user node['zabbix']['server']['dbuser'] do
  connection mysql_connection_info
  password node['zabbix']['server']['dbpassword']
  database_name node['zabbix']['server']['dbname']
  host 'localhost'
  privileges [:select,:update,:insert,:create,:drop,:delete]
  action :nothing
end
