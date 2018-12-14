include Pleroma::Helpers

resource_name :service_manager_systemd

provides :service_manager, os: 'linux' do |_node|
  Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
end

default_action :start

action :start do
  template 'pleroma.service' do
    source 'pleroma.service.erb'
    path '/etc/systemd/system/pleroma.service'
    cookbook 'pleroma'
    owner 'root'
    group 'root'
    mode 0644
    variables(path: new_resource.path.to_s)
    action :create
  end

  service 'pleroma' do
    provider Chef::Provider::Service::Systemd
    supports status: true
    ignore_failure true if new_resource.ignore_failure
    action [:enable, :start]
  end
end

action :stop do
end

action :restart do
  action_stop
  action_start
end
