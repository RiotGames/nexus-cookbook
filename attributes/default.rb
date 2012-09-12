default[:nexus][:version]                                      = '2.1.2'
default[:nexus][:user]                                         = 'nexus'
default[:nexus][:group]                                        = 'nexus'
default[:nexus][:url]                                          = "http://www.sonatype.org/downloads/nexus-#{node[:nexus][:version]}-bundle.tar.gz"
default[:nexus][:checksum]                                     = '32fcf0fcfb45e4ee8bc53149131d34257da62758515e7b9d24c92d6ad083dbc9'

default[:nexus][:port]                                         = '8081'
default[:nexus][:host]                                         = '0.0.0.0'
default[:nexus][:path]                                         = '/nexus'

default[:nexus][:name]                                         = 'nexus'
default[:nexus][:home]                                         = "/usr/local/#{node[:nexus][:name]}"
default[:nexus][:conf_dir]                                     = "#{node[:nexus][:home]}/conf"
default[:nexus][:bin_dir]                                      = "#{node[:nexus][:home]}/bin"
default[:nexus][:work_dir]                                     = "#{node[:nexus][:path]}/sonatype-work/nexus"

default[:nexus][:ssl_certificate][:key]                        = node[:fqdn]

default[:nexus][:nginx_proxy][:listen_port]                    = 8443
default[:nexus][:nginx_proxy][:server_name]                    = node[:fqdn]

default[:nexus][:plugins]                                      = ['nexus-custom-metadata-plugin']

default[:nginx][:configure_flags]                              = 'with-http_ssl_module'

default[:nexus][:nginx][:options][:client_max_body_size]       = '200M'
default[:nexus][:nginx][:options][:client_body_buffer_size]    = '512k'

default[:nexus][:cli][:url]                                    = "https://#{node[:nexus][:nginx_proxy][:server_name]}:#{node[:nexus][:nginx_proxy][:listen_port]}/nexus"
default[:nexus][:cli][:repository]                             = "releases"
default[:nexus][:cli][:packages]                               = ["libxml2-devel", "libxslt-devel"]

default[:nexus][:repository][:create_hosted]                   = ['Artifacts']
default[:nexus][:repository][:publishers]                      = ['Artifacts']

default[:nexus][:smart_proxy][:enable]                         = true
default[:nexus][:smart_proxy][:host]                           = nil
default[:nexus][:smart_proxy][:port]                           = nil