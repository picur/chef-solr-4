# defines default solr settings
default.solr.version 	= '4.4.0'
default.solr.source 	= "http://mirrors.hostingromania.ro/apache.org/lucene/solr/#{node[:solr][:version]}/solr-#{node[:solr][:version]}.tgz"
default.solr.user		= node[:jetty][:user]
default.solr.group		= node[:jetty][:group]
default.solr.home 		= '/usr/share/solr'
default.solr.lib		= '/var/lib/solr'
default.solr.log_dir	= '/var/log/solr'

# defines OS default packages
default.packages		= %w(libmysql-java unzip)

# defines jetty options default
default.jetty.java_options 	= "-Dsolr.solr.home=#{node[:solr][:home]} -Xmx256m -Djava.awt.headless=true $JAVA_OPTIONS"
default.jetty.java_home 	= "/usr/lib/jvm/java-7-openjdk-amd64"