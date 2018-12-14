#
# Cookbook:: pleroma
# Library:: helpers
#

module Pleroma
  module Helpers
    # based off etcd cookbook
    def self.included(base)
      base.class_eval do
        property :instance, String, name_property: true
        property :user, String, default: 'pleroma'
        property :group, String, default: 'pleroma'
        property :path, String, default: '/opt/pleroma'
        property :repo, String, default: 'https://git.pleroma.social/pleroma/pleroma.git'
        property :branch, String, default: 'develop'
        property :erlang_url, String, default: 'https://packages.erlang-solutions.com'
        property :erlang_deb_file, String, default: 'erlang-solutions_1.0_all.deb'
        property :erlang_deb_file_checksum, String, default: '490c3f30e215fb7771d9f1a8522f10ea8745dba544356748f7b94f44e0ce00bf'
        property :erlang_rpm_file, String, default: 'erlang-solutions-1.0-1.noarch.rpm'
        property :erlang_rpm_file_checksum, String, default: '1850d9915ab31d21c5f487d82d8dae08bbbba278d9be992487f5892e8987ade6'
        property :hostname, String, default: node['fqdn']
        property :db_hostname, String, default: 'localhost'
        property :db_username, String, default: 'pleroma'
        property :db_password, String, default: 'pleromachangeme!'
        property :db_database, String, default: 'pleroma'
        property :secret_key, String, default: lazy { secret_key }
        property :register, [true, false], default: true
        property :public, [true, false], default: true
        property :email, String, default: "pleroma@#{node['fqdn']}"
        property :vapid, Hash, default: lazy { vapid_keys }
      end
    end
  end
end

def secret_key
  require 'base64'
  require 'securerandom'
  secret_key = Base64.encode64(SecureRandom.hex(64)).gsub("\n", "")
  return secret_key
end

def vapid_keys
  require 'openssl'
  require 'base64'
  key = OpenSSL::PKey::EC.generate("prime256v1")
  private_key = Base64.encode64(key.private_key.to_s).gsub("\n", "")
  public_key = Base64.encode64(key.public_key.to_s).gsub("\n", "")
  hash = { public_key: public_key.to_s, private_key: private_key.to_s }
  return hash
end
