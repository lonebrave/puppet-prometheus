# @summary This module manages prometheus pushprox_proxy
# @param arch
#  Architecture (amd64 or i386)
# @param bin_dir
#  Directory where binaries are located
# @param config_mode
#  The permissions of the configuration files
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
#  Name of the pushprox_proxy service (default 'pushprox_proxy')
# @param user
#  User which runs the service
# @param version
#  The binary release version
class prometheus::pushprox_proxy (
  String[1] $download_extension,
  Prometheus::Uri $download_url_base,
  Array[String[1]] $extra_groups,
  String[1] $group,
  String[1] $package_ensure,
  String[1] $package_name,
  String[1] $user,
  String[1] $version,
  Boolean $service_enable                 = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  String[1] $service_name                 = 'pushprox_proxy',
  Boolean $restart_on_change              = true,
  Boolean $purge_config_dir               = true,
  Prometheus::Initstyle $init_style       = $prometheus::init_style,
  String[1] $install_method               = $prometheus::install_method,
  Boolean $manage_group                   = true,
  Boolean $manage_service                 = true,
  Boolean $manage_user                    = true,
  String[1] $os_type                      = $prometheus::os_type,
  String $extra_options                   = '',
  Optional[String] $download_url          = undef,
  String[1] $config_mode                  = $prometheus::config_mode,
  String[1] $arch                         = $prometheus::real_arch,
  Stdlib::Absolutepath $bin_dir           = $prometheus::bin_dir,
) inherits prometheus {
  $real_download_url = pick($download_url,"${download_url_base}/download/v${version}/PushProx-${version}.${os_type}-${arch}.${download_extension}")

  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  prometheus::daemon { $service_name:
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    archive_bin_path   => "/opt/PushProx-${version}.${os_type}-${arch}/pushprox-proxy",
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
    options            => $extra_options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
  }
}
