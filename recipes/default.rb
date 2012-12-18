#
# Cookbook Name:: chef-archiva
# Recipe:: default
# Author:: Jorge Espada <espada.jorge@gmail.com>
#




include_recipe "ark"

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
