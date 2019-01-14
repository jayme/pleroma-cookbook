include Pleroma::Helpers

resource_name :pleroma_configure
provides :pleroma_configure
default_action :create

action :create do
  extra_path = "#{new_resource.path}/config/extra/"
  directory extra_path
  template 'prod.secret.vapid.exs' do
    path "#{new_resource.path}/config/extra/prod.secret.vapid.exs"
    source 'prod.secret.vapid.exs.erb'
    cookbook 'pleroma'
    owner new_resource.username.to_s
    group new_resource.groupname.to_s
    mode '0640'
    variables(vapid: new_resource.vapid)
    action :create
    not_if { ::File.exist?("#{extra_path}/prod.secret.vapid.exs") }
  end
  
  pleroma_config = {
    hostname: new_resource.hostname,
    db_hostname: new_resource.db_hostname,
    db_username: new_resource.db_username,
    db_password: new_resource.db_password,
    db_database: new_resource.db_database,
    secret_key: new_resource.secret_key,
    register: new_resource.register,
    public: new_resource.public,
    email: new_resource.email
  }

  template 'prod.secret.exs' do
    path "#{new_resource.path}/config/prod.secret.exs"
    source "prod.secret.exs.erb"
    cookbook 'pleroma'
    owner new_resource.username.to_s
    group new_resource.groupname.to_s
    mode '0640'
    variables(pleroma: pleroma_config)
  end
end
