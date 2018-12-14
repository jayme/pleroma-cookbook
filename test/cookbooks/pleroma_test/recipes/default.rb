#
# Cookbook:: pleroma
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#
Chef::Log.warn('*** TEST MODE: YOU MUST PROVIDE THE POSTGRES DATABASE ***')

pleroma_install 'testing' 

pleroma_instance 'testing' do
  ignore_failure true
  hostname 'kitchen.chef.social'
  db_username 'pleroma'
  db_password 'pleroma'
  db_hostname 'localhost'
  db_database 'pleroma'
  secret_key 'q5Q6Dc40N2B5py3jn8jxwb+2LqXJUhYcLN/IJ+Gty4xVSETv6dH4CakQ8wL9ya2CyAQutx8UkWTgPa8U9DlOeg=='
  register true
  public true
  email "pleroma@#{node['fqdn']}"
  action :create
end
