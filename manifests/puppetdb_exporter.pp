# @summary This module manages prometheus node puppetdb_exporter
# @param arch
#  Architecture (amd64 or i386)
# @param bin_dir
#  Directory where binaries are located
# @param download_extension
#  Extension for the release binary archive
# @param download_url
#  Complete URL corresponding to the where the release binary archive can be downloaded
# @param download_url_base
#  Base URL for the binary archive
# @param extra_groups
#  Extra groups to add the binary user to
# @param extra_options
#  Extra options added to the startup command
# @param group
#  Group under which the binary is running
# @param init_style
#  Service startup scripts style (e.g. rc, upstart or systemd)
# @param install_method
#  Installation method: url or package (only url is supported currently)
# @param manage_group
#  Whether to create a group for or rely on external code for that
# @param manage_service
#  Should puppet manage the service? (default true)
# @param manage_user
#  Whether to create user or rely on external code for that
# @param os_type
#  Operating system (linux is the only one supported)
# @param package_ensure
#  If package, then use this for package ensure default 'latest'
# @param package_name
#  The binary package name - not available yet
# @param purge_config_dir
#  Purge config files no longer generated by Puppet
# @param restart_on_change
#  Should puppet restart the service on configuration change? (default true)
# @param service_enable
#  Whether to enable the service from puppet (default true)
# @param service_ensure
#  State ensured for the service (default 'running')
# @param service_name
#  Name of the puppetdb exporter service (default 'puppetdb_exporter')
# @param user
#  User which runs the service
# @param version
#  The binary release version
# @param puppetdb_url
#  The URI to PuppetDB with http/https protocol at the beginning and `/pdb/query` at the end
class prometheus::puppetdb_exporter (
  String $download_extension              = 'tar.gz',
  Prometheus::Uri $download_url_base      = 'https://github.com/camptocamp/prometheus-puppetdb-exporter/releases',
  Array[String] $extra_groups             = [],
  String[1] $group                        = 'puppetdb-exporter',
  String[1] $package_ensure               = 'present',
  String[1] $package_name                 = 'puppetdb_exporter',
  String[1] $user                         = 'puppetdb-exporter',
  String[1] $version                      = '1.1.0',
  Boolean $purge_config_dir               = true,
  Boolean $restart_on_change              = true,
  Boolean $service_enable                 = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  String[1] $service_name                 = 'puppetdb_exporter',
  Prometheus::Initstyle $init_style       = $facts['service_provider'],
  Prometheus::Install $install_method     = $prometheus::install_method,
  Boolean $manage_group                   = true,
  Boolean $manage_service                 = true,
  Boolean $manage_user                    = true,
  String[1] $os_type                      = downcase($facts['kernel']),
  String $extra_options                   = '',
  Optional[Prometheus::Uri] $download_url = undef,
  String[1] $arch                         = $prometheus::real_arch,
  String[1] $bin_dir                      = $prometheus::bin_dir,
  Boolean $export_scrape_job              = false,
  Optional[Stdlib::Host] $scrape_host     = undef,
  Stdlib::Port $scrape_port               = 9635,
  String[1] $scrape_job_name              = 'puppetdb',
  Optional[Hash] $scrape_job_labels       = undef,
  Optional[String[1]] $bin_name           = undef,
  Stdlib::HTTPUrl $puppetdb_url           = 'http://127.0.0.1:8080/pdb/query',
) inherits prometheus {
  $real_download_url = pick($download_url,"${download_url_base}/download/${version}/prometheus-puppetdb-exporter-${version}.${os_type}-${arch}.${download_extension}")

  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  $real_puppetdb_url = "--puppetdb-url=${puppetdb_url}"
  $options = join([$extra_options, $real_puppetdb_url], ' ')

  prometheus::daemon { $service_name:
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os_type            => $os_type,
    arch               => $arch,
    real_download_url  => $real_download_url,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    group              => $group,
    manage_group       => $manage_group,
    purge              => $purge_config_dir,
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    export_scrape_job  => $export_scrape_job,
    scrape_host        => $scrape_host,
    scrape_port        => $scrape_port,
    scrape_job_name    => $scrape_job_name,
    scrape_job_labels  => $scrape_job_labels,
    bin_name           => $bin_name,
    archive_bin_path   => "/opt/prometheus-puppetdb-exporter-${version}.${os_type}-${arch}/prometheus-puppetdb-exporter",
  }
}
