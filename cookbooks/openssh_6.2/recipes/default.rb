#
# Cookbook Name:: openssh-6.6p1
# Recipe:: default
#

ssh_desiredversion = "openssh-6.6p1"

if ssh_desiredversion == "openssh-6.6p1"
  Chef::Log.info('[OpenSSH] Desired version is 6.6 - downloading')
  ssh_file = "openssh-6.6p1.tar.gz"
  ssh_dir = "openssh-6.6p1"
  ssh_url = "http://ftp3.usa.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.6p1.tar.gz"
end

remote_file "/data/#{ssh_file}" do
    source "#{ssh_url}"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0644
    backup 0
    not_if { FileTest.exists?("/data/#{ssh_file}") }
end
  
execute "unarchive ssh" do
  Chef::Log.info('[OpenSSH] Unarchive')
  command "cd /data && tar zxf #{ssh_file} && sync"
  Chef::Log.info("[OpenSSH] #{FileTest.directory?("/data/#{ssh_dir}")}")
  not_if { FileTest.directory?("/data/#{ssh_dir}") }
end
  
# execute "install ssh " do
#   command "cd /data/#{ssh_dir} && ./configure --prefix=/usr && make && make install"
# end

execute "install ssh " do
  Chef::Log.info('[OpenSSH] Installing')
  command "cd /data/#{ssh_dir} && ./configure --prefix=/usr && make && make install"
  Chef::Log.info("[OpenSSH] #{FileTest.directory?("/data/#{ssh_dir}")}")
  not_if { FileTest.directory?("/data/#{ssh_dir}") }
end