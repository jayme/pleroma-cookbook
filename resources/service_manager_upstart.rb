include Pleroma::Helpers

resource_name :service_manager_upstart

provides :service_manager, platform_family: 'debian' do |_node|
  Chef::Platform::ServiceHelpers.service_resource_providers.include?(:upstart) &&
    !Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
end

default_action :start

action :start do
  template 'upstart.sh' do
    source 'upstart/upstart.sh.erb'
    path "#{new_resource.path.to_s}/upstart.sh"
    cookbook 'pleroma'
    mode 0755
    variables(
      config: {
        path: new_resource.path.to_s
    })
    action :create
  end

  template 'pleroma.conf' do
    source 'upstart/pleroma.conf.erb'
    path '/etc/init/pleroma.conf'
    cookbook 'pleroma'
    owner 'root'
    group 'root'
    mode 0644
    variables(
      config: {
        path: new_resource.path.to_s, 
        user: new_resource.user.to_s, 
        group: new_resource.group.to_s
    })
    action :create
  end

  service 'pleroma' do
    provider Chef::Provider::Service::Upstart
    supports status: true
    ignore_failure true if new_resource.ignore_failure
    action [:enable, :start]
  end
end

action :stop do
  service etcd_name do
    provider Chef::Provider::Service::Upstart
    supports status: true
    action :stop
  end
end

action :restart do
  action_stop
  action_start
end
