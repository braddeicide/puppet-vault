# == Class vault::config
#
# This class is called from vault for service config.
#
class vault::config {
  file { $::vault::config_dir:
    ensure  => directory,
    purge   => $::vault::purge_config_dir,
    recurse => $::vault::purge_config_dir,
  } ->
  file { "${::vault::config_dir}/config.json":
    content => vault_sorted_json($::vault::config_hash),
  }

  case $::vault::service_provider {
    'upstart': {
      file { '/etc/init/vault.conf':
        ensure  => file,
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        content => template('vault/vault.upstart.erb'),
      }
      file { '/etc/init.d/vault':
        ensure  => link,
        target  => '/lib/init/upstart-job',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
      }
    }
    'init': {
       file { '/etc/init.d/vault':
         ensure  => file,
         owner   => 'root',
         group   => 'root',
         mode    => '0755',
         content => template('vault/vault.initd.erb'),
       }
    }
    default: {
      fail("vault::service_provider '${::vault::service_provider}' is not valid")
    }
  }

}
