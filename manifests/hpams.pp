# == Class: hp_spp::hpams
#
# This class handles installation of the HP Agentless Monitoring Service.  This
# service will only run on HP ProLiant Gen8 or newer platforms.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*autoupgrade*]
#   Upgrade package automatically, if there is a newer version.
#   Default: false
#
# [*service_ensure*]
#   Ensure if service is running or stopped.
#   Default: running
#
# [*service_enable*]
#   Start service at boot.
#   Default: true
#
# === Actions:
#
# Installs the HP Agentless Monitoring Service.
#
# === Requires:
#
# === Sample Usage:
#
#   class { 'hp_spp::hpams': }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class hp_spp::hpams (
  $ensure         = 'present',
  $autoupgrade    = false,
  $service_ensure = 'running',
  $service_enable = true
) inherits hp_spp::params {
  # Validate our booleans
  validate_bool($autoupgrade)
  validate_bool($service_enable)

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }

      if $service_ensure in [ running, stopped ] {
        $service_ensure_real = $service_ensure
        $service_enable_real = $service_enable
      } else {
        fail('service_ensure parameter must be running or stopped')
      }
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $service_ensure_real = 'stopped'
      $service_enable_real = false
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::manufacturer {
    'HP': {
      Class['hp_spp::repo'] -> Class['hp_spp::hpams']

      package { 'hp-ams':
        ensure => $package_ensure,
      }

      service { 'hp-ams':
        ensure     => $service_ensure_real,
        enable     => $service_enable_real,
        hasrestart => true,
        hasstatus  => true,
        require    => Package['hp-ams'],
      }
    }
    # If we are not on HP hardware, do not do anything.
    default: { }
  }
}
