include Pleroma::Helpers

resource_name :service_daemontools

default_action :start

action :start do
  svscan_dir = "#{new_resource.path}/svscan"
  require 'chef/provider/service/daemontools'

  directory '/var/service' do
    owner 'root'
    group 'wheel'
    mode 0755
    action :create
  end

  service 'svscan' do
    action [:enable, :start]
  end

  directory svscan_dir.to_s do
    owner 'root'
    group 'wheel'
    mode 0755
    action :create
  end

  template 'run' do
    source 'run.erb'
    cookbook 'pleroma'
    path "#{svscan_dir}/run"
    owner 'root'
    group 'wheel'
    mode '0700'
    variables(path: new_resource.path, user: new_resource.username)
  end

  cookbook_file 'erl_inetrc' do
    source 'erl_inetrc'
    cookbook 'pleroma'
    path "#{new_resource.path}/erl_inetrc"
    owner 'root'
    group 'wheel'
    mode '0644'
    action :create
  end

  service 'pleroma' do
    provider Chef::Provider::Service::Daemontools
    service_dir '/var/service'
    directory svscan_dir
    supports(restart: true, reload: true)
    action [:enable, :start]
    not_if { ::Dir.exist?("/var/service/pleroma") }
  end
end
