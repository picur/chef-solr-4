#
# Cookbook Name:: chef-solr-4
# Attributes:: default
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


# defines default solr settings
default['solr']['version'] 	= '4.4.0'
default['solr']['source'] 	= "http://archive.apache.org/dist/lucene/solr/#{node['solr']['version']}/solr-#{node['solr']['version']}.tgz"
default['solr']['checksum']	= ''

default['solr']['user']		= node['jetty']['user']
default['solr']['group']	= node['jetty']['group']
default['solr']['war']		= 'solr.war'
default['solr']['home'] 	= '/usr/share/solr'
default['solr']['lib_dir']	= '/var/lib/solr'
default['solr']['log_dir']	= '/var/log/solr'
default['solr']['nodes']	= ["solr"]

default['solr']['archive'] 		= "#{Chef::Config[:file_cache_path]}/apache-solr-#{node['solr']['version']}.tgz"
default['solr']['extract_path'] = "#{Chef::Config[:file_cache_path]}/solr-#{node['solr']['version']}"

# defines dataimport handler defaults
default['solr']['dataimport_handler'] = {
	'enabled' => true,
	'data_config' => 'data-config.xml',
}

# defines mongo importer defaults
default['solr']['dataimport_handler']['mongo_importer'] = {
	'enabled' => true,
	'version' => '1.0.0',
	'link' => "https://github.com/downloads/james75/SolrMongoImporter/solr-mongo-importer-#{node['solr']['dataimport_handler']['mongo_importer']['version']}.jar",
	'java_driver_version' => '2.10.1',
	'java_driver_link' => "https://github.com/downloads/mongodb/mongo-java-driver/mongo-#{node['solr']['dataimport_handler']['mongo_importer']['java_driver_version']}.jar",
}

# overrides jetty options default
override['jetty']['port']			= 8000
override['jetty']['java_options'] 	= "-Dsolr.solr.home=#{node['solr']['home']} -Xmx256m -Djava.awt.headless=true $JAVA_OPTIONS"

# override java defaults
override['java']['jdk_version']		= 7