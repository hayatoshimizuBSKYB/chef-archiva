#
# Cookbook Name:: chef-archiva
# Recipe:: default
# Author:: Jorge Espada <espada.jorge@gmail.com>
#

include_recipe "ark"

bash "Setup hostname" do
  code <<-EOH
    orig_hostname=`cat /etc/hostname`
    echo >> /etc/chef/client.rb
    echo node_name = \"$orig_hostname\" >> /etc/chef/client.rb
    echo Setting hostname: #{node[:archiva][:hostname]}
    echo #{node[:archiva][:hostname]} > /etc/hostname
    hostname #{node[:archiva][:hostname]}
  EOH
  only_if  { node[:archiva][:hostname].length > 0 rescue false }
end


#download, extract archiva in /opt and make the proper symblink

ark "archiva" do
  url node[:archiva][:url_version]
  version node[:archiva][:version]
  prefix_root node[:archiva][:install_path]
  home_dir node[:archiva][:home]
  checksum node[:archiva][:checksum]
  owner node[:archiva][:user_owner]
  action :install
end

file "#{ node[:archiva][:home]}/bin/wrapper-linux-x86-32" do
  action :delete
end

file "#{ node[:archiva][:home]}/lib/libwrapper-linux-x86-32.so" do
  action :delete
end


user "archiva" do
  comment "Archiva User"
  home "/home/archiva"
  shell "/bin/bash"
end


#create scripts(/etc/init.d/archiva <option>) for stop start, using symblinks

link "/etc/init.d/archiva" do
  to "#{ node[:archiva][:home]}/bin/archiva"
end

service "archiva" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [:enable, :start]
end
