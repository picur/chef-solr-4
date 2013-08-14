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
package 'unzip' do
	action :install
end

# download solr source
remote_file node[:solr][:archive] do
	source node[:solr][:source]
	mode "0744"
	action :create_if_missing
	not_if { ::File.directory?(node[:solr][:home]) }
end

# extract solr archive
execute 'extract_archive' do
	cwd ::File.dirname(node[:solr][:archive])
	command "tar -xzvf #{node[:solr][:archive]}"
	not_if { ::File.exists?(node[:solr][:extract_path]) }
	only_if { ::File.exists?(node[:solr][:archive]) }
end

# create solr home
directory node[:solr][:home] do
	owner node[:solr][:user]
	group node[:solr][:group]
	mode "0755"
	not_if { ::File.directory?(node[:solr][:home]) }
end

# create log dir
directory node[:solr][:log_dir] do 
	owner node[:solr][:user]	
	group node[:solr][:group]
	mode "0755"
end

# unzip solr war to home dir
bash "install_solr" do
	cwd node[:solr][:home]
	user "root"
	code <<-EOH
		cp -a #{node[:solr][:extract_path]}/dist/solr-#{node[:solr][:version]}.war #{node[:jetty][:webapp_dir]}
		cp -a #{node[:solr][:extract_path]}/example/lib/ext/* #{node[:jetty][:home]}/lib/ext/
		cp -a #{node[:solr][:extract_path]}/{dist,contrib} #{node[:solr][:home]}
		EOH
end

template "#{node[:jetty][:webapp_dir]}/solr.xml" do
	owner node[:solr][:user]
	group node[:solr][:group]
	source "solr-jetty-context.xml.erb"
end

# add solr to jetty
link "#{node[:jetty][:webapp_dir]}/solr" do
	to node[:solr][:home]
end

# add mysql connector to solr
package "libmysql-java" do
	action :install
	only_if { node[:solr][:mysql_connector_enable] }
end

link "#{node[:jetty][:home]}/lib/ext/mysql-connector-java.jar" do
	to "/usr/share/java/mysql-connector-java.jar"
	only_if { node[:solr][:mysql_connector_enable] }
end

node[:solr][:nodes].each do |core_name|

	bash "create_core_dir" do
		user "root"
		code <<-EOH
			mkdir -p #{node[:solr][:home]}/#{core_name}
			mkdir -p #{node[:solr][:lib_dir]}/#{core_name}/data
			cp -R #{node[:solr][:extract_path]}/example/solr/collection1/conf #{node[:solr][:home]}/#{core_name}
			chown -R #{node[:solr][:user]}:#{node[:solr][:group]} #{node[:solr][:lib_dir]}
			chown -R #{node[:solr][:user]}:#{node[:solr][:group]} #{node[:solr][:home]}
			EOH
	end

	template "#{node[:solr][:home]}/solr.xml" do
		source "solr_xml.erb"
		owner node[:solr][:user]
		group node[:solr][:group]
		mode 0755
		variables({
			:node_name => core_name	
		})
		notifies :restart, resources(:service => 'jetty'), :delayed
	end

	template "#{node[:solr][:home]}/#{core_name}/conf/solrconfig.xml" do
		source "solrconfig.xml.erb"
		owner node[:solr][:user]
		group node[:solr][:group]
		mode 0644
	end

end