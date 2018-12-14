include Pleroma::Helpers

resource_name :pleroma_install
provides :pleroma_install
default_action :install

# shortcuts
file_cache = Chef::Config[:file_cache_path]
# https://elixir-lang.org/install.html#unix-and-unix-like
ubuntu_pkgs = %w[erlang-nox erlang-dev erlang-parsetools erlang-xmerl erlang-tools elixir git]
bsd_pkgs = %w[git daemontools elixir-hex gmake ImageMagick7-nox11]
# chef does not do native yum package groups. "Development Tools"
yum_pkgs = %w[
  erlang epel-release git autoconf automake binutils bison flex gcc
  gdb gettext kexec-tools latrace libtool make patch pkgconfig
  rpm-build strace system-rpm-config systemtap-runtime byacc crash
  cscope ctags cvs diffstat doxygen elfutils gcc-gfortran git indent
  intltool ltrace patchutils rcs subversion swig systemtap texinfo valgrind
]

action :install do
  case node['platform_family']
  when 'freebsd'
    bsd_pkgs.each do |pkg|
      package pkg
    end

  when 'debian'
    remote_file "#{file_cache}/#{new_resource.erlang_deb_file}" do
      source "#{new_resource.erlang_url}/#{new_resource.erlang_deb_file}"
      checksum new_resource.erlang_deb_file_checksum.to_s
      mode 0o644
    end
    dpkg_package 'erlang' do
      source "#{file_cache}/#{new_resource.erlang_deb_file}"
      action :install
      notifies :run, 'execute[apt_get]', :immediately
    end
    execute 'apt_get' do
      command 'apt-get update'
      action :nothing
    end
    ubuntu_pkgs.each do |pkg|
      package pkg
    end

  when 'rhel'
    execute 'yum_erlang' do
      command "yum install -y #{file_cache}/erlang-solutions-1.0-1.noarch.rpm"
      action :nothing
    end
    remote_file "#{file_cache}/erlang-solutions-1.0-1.noarch.rpm" do
      source "http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm"
      checksum "1850d9915ab31d21c5f487d82d8dae08bbbba278d9be992487f5892e8987ade6"
      notifies :run, 'execute[yum_erlang]', :immediately
    end
    yum_pkgs.each do |pkg|
      package pkg
    end
    remote_file "#{file_cache}/Precompiled.zip" do
      source "https://github.com/elixir-lang/elixir/releases/download/v1.7.3/Precompiled.zip"
      checksum "219cc599cbb59aaece4347b1c4bb383c6e277f242ca88bc2e8a553aedaaa4c1c"
      mode 0o644
      notifies :run, 'execute[unzip_elixir]'
    end
    directory '/opt/elixir'
    execute 'unzip_elixir' do
      command 'unzip Precompiled.zip -d /opt/elixir'
      cwd "#{file_cache}/"
      action :nothing
    end
    %w[elixir elixirc iex mix].each do |sym|
      link "/usr/local/bin/#{sym}" do
        to "/opt/elixir/bin/#{sym}"
      end
    end
  end

  group new_resource.group

  user new_resource.user do
    gid new_resource.group
    shell '/bin/false'
    home new_resource.path
  end

  git new_resource.path do
    repository new_resource.repo
    checkout_branch new_resource.branch
    revision new_resource.branch
    enable_checkout false
    action :sync
    notifies :create, "directory[#{new_resource.path}]", :immediately
  end

  directory new_resource.path do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    action :nothing
    notifies :run, 'execute[mix]', :immediately
  end

  execute 'mix' do
    cwd new_resource.path
    user new_resource.user
    environment({
        'HOME' => new_resource.path, 
        'PATH' => '/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/bin:/sbin'
    })
    command 'mix local.rebar --force && mix local.hex --force && mix deps.get'
    action :nothing
  end
end
