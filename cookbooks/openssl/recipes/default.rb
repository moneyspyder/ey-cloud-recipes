#
# Cookbook Name:: openssl
# Recipe:: default
#

ssl_desiredversion = "openssl-0.9.8za"
installed = "#{ssl_desiredversion}-installed"

if ssl_desiredversion == "openssl-0.9.8za"
  Chef::Log.info('[OpenSSL] Desired version is 0.9.8za - downloading')
  ssl_file = "openssl-0.9.8za.tar.gz"
  ssl_dir = "openssl-0.9.8za"
  ssl_url = "https://www.openssl.org/source/openssl-0.9.8za.tar.gz"
end

remote_file "/data/#{ssl_file}" do
    source "#{ssl_url}"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0644
    backup 0
    not_if { FileTest.exists?("/data/#{ssl_file}") }
end
  
execute "unarchive ssl" do
  Chef::Log.info('[OpenSSL] Unarchive')
  command "cd /data && tar zxf #{ssl_file} && sync"
  Chef::Log.info("[OpenSSL] #{FileTest.directory?("/data/#{ssl_dir}")}")
  not_if { FileTest.directory?("/data/#{ssl_dir}") }
end

execute "install ssl" do
  Chef::Log.info('[OpenSSL] Installing')
  command "cd /data/#{ssl_dir} && sudo ./config --prefix=/usr && sudo make && sudo make install && touch /data/#{installed}"
  Chef::Log.info("[OpenSSL] #{FileTest.file?("/data/#{installed}")}")
  not_if { FileTest.file?("/data/#{installed}") }
end
