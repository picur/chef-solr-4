#
# Cookbook Name:: chef-solr-4
# Definition:: solr_core
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

define :solr_core, :template => "solr_xml.erb" do

	core_name = params[:name]

	include_recipe "solr"

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
		source params[:template]
		user node[:solr][:user]
		group node[:solr][:group]
		mode 0755
		if params[:cookbook]
      		cookbook params[:cookbook]
    	end
		variables({
			:node_name => core_name	
		})

		if ::File_exists?("#{node[:solr][:home]}/solr.xml")
			notifies :reload, resources(:service => 'jetty'), :delayed
		end
	end
end