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
    protocol: new_resource.protocol,
    port: new_resource.port,
    db_hostname: new_resource.db_hostname,
    db_username: new_resource.db_username,
    db_password: new_resource.db_password,
    db_database: new_resource.db_database,
    db_pool_size: new_resource.db_pool_size,
    secret_key: new_resource.secret_key,
    register: new_resource.register,
    public: new_resource.public,
    email: new_resource.email,
    description: new_resource.description,
    limit: new_resource.limit,
    upload_limit: new_resource.upload_limit,
    registrations_open: new_resource.registrations_open,
    federating: new_resource.federating,
    rewrite_policy: new_resource.rewrite_policy,
    finmoji_enabled: new_resource.finmoji_enabled,
    extended_nickname_format: new_resource.extended_nickname_format,
    debug_errors: new_resource.debug_errors,
    code_reloader: new_resource.code_reloader,
    check_origin: new_resource.check_origin,
    url_scheme: new_resource.url_scheme,
    url_port: new_resource.url_port,
    chat_enabled: new_resource.chat_enabled,
    log_level: new_resource.log_level
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
