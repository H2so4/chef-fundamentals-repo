#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: knife-workstation
# Recipe:: vnc
#
# Copyright 2012, Opscode, Inc <legal@opscode.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

directory "/tmp" do
  mode 01777
end

directory "/home/ubuntu/.vnc" do
  owner "ubuntu"
end

cookbook_file "/home/ubuntu/.vnc/xstartup" do
  source "xstartup"
  owner "ubuntu"
  mode 00755
end

execute "chown -R ubuntu:ubuntu /home/ubuntu"

template "/etc/init/vncserver.conf" do
  source "vncserver.upstart.erb"
  mode 00755
end

execute "x11vnc -storepasswd #{node['workstation']['password']} /home/ubuntu/.vnc/passwd" do
  user "ubuntu"
  creates "/home/ubuntu/.vnc/passwd"
end

service "vncserver" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true
  ignore_failure true
  action [:enable, :start]
end
