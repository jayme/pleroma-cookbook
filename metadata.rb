name 'pleroma'
maintainer 'jayme'
maintainer_email 'jayme@email.com'
license 'GPL-3.0'
description 'Installs/Configures pleroma'
long_description 'Installs/Configures pleroma'
version '1.0.3'
chef_version '>= 12.1' if respond_to?(:chef_version)

%w(ubuntu debian redhat centos freebsd).each do |os|
  supports os
end

issues_url 'https://github.com/jayme/pleroma-cookbook/issues'
source_url 'https://github.com/jayme/pleroma-cookbook'

depends 'application_git', '~> 1.2.0'
