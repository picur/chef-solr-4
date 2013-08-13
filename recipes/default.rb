#
# Cookbook Name:: chef-solr-4
# Recipe:: default
#
# Copyright 2013, Botond Dani
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

include_recipe 'jetty'

# install default packages
node[:packages].each do |pkg|
	package pkg
end

# download solr source
remote_file node[:solr][:solr_archive] do
	source node[:solr][:source]
	mode "0744"
	not_if { ::File.directory?(node[:solr][:home]) }
end

# extract solr archive
execute 'extract_solr_archive' do
	cwd ::File.dirname(node[:solr][:solr_archive])
	command "tar -xzvf #{node[:solr][:solr_archive]}"
	not_if { ::File.exists?(node[:solr][:extract_path]) }
	only_if { ::File.exists?(node[:solr][:solr_archive]) }
end

# create solr home
directory node[:solr][:home] do
	user node[:solr][:user]
	mode "0755"
end

# create log dir
directory node[:solr][:log_dir] do 
	user node[:solr][:user]
	mode "0755"
end

# unzip solr war to home dir
bash "install_solr" do
	cwd node[:solr][:home]
	user node[:solr][:user]
	code <<-EOH
		unzip #{node[:solr][:extract_path]}/dist/solr-#{node[:solr][:version]}.war
		cp -R #{node[:solr][:extract_path]}/example/lib/ext/* #{node[:jetty][:home]}/lib/ext/
		EOH
end

# add solr to jetty
link "#{node[:jetty][:webapp_dir]}/solr" do
	to node[:solr][:home]
end

# add mysql connector to solr
package "libmysql-java" do
	action :install
	only_if node[:solr][:mysql_connector_enable]
end

link "#{node[:solr][:home]}/WEB-INF/lib/mysql-connector-java.jar" do
	to "/usr/share/java/mysql-connector-java.jar"
	only_if node[:solr][:mysql_connector_enable]
end