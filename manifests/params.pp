# == Class: hp_spp::params
#
# This class handles OS-specific configuration of the hp_spp module.  It
# looks for variables in top scope (probably from an ENC such as Dashboard).  If
# the variable doesn't exist in top scope, it falls back to a hard coded default
# value.
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class hp_spp::params {
  $gid          = '490'
  $uid          = '490'

  # Customize these values if you (for example) mirror public YUM repos to your
  # internal network.
  $yum_priority = '50'
  $yum_protect  = '0'

  # If we have a top scope variable defined, use it, otherwise fall back to a
  # hardcoded value.
  $yum_server = $::hp_spp_yum_server ? {
    undef   => 'http://downloads.linux.hpe.com',
    default => $::hp_spp_yum_server,
  }

  $spp_version = $::hp_spp_spp_version ? {
    undef   => 'current',
    default => $::hp_spp_spp_version,
  }

### The following parameters should not need to be changed.

  $ensure = $::hp_spp_ensure ? {
    undef => 'present',
    default => $::hp_spp_ensure,
  }

  $service_ensure = $::hp_spp_service_ensure ? {
    undef => 'running',
    default => $::hp_spp_service_ensure,
  }

  # Since the top scope variable could be a string (if from an ENC), we might
  # need to convert it to a boolean.
  $autoupgrade = $::hp_spp_autoupgrade ? {
    undef => false,
    default => $::hp_spp_autoupgrade,
  }
  if is_string($autoupgrade) {
    $safe_autoupgrade = str2bool($autoupgrade)
  } else {
    $safe_autoupgrade = $autoupgrade
  }

  $service_enable = $::hp_spp_service_enable ? {
    undef => true,
    default => $::hp_spp_service_enable,
  }
  if is_string($service_enable) {
    $safe_service_enable = str2bool($service_enable)
  } else {
    $safe_service_enable = $service_enable
  }

  $gpg_path = '/SDR/'

  case $::operatingsystem {
    'RedHat': {
      $yum_path = '/SDR/repo/spp/RedHat/$releasever/$basearch/'
      case $::operatingsystemrelease {
        /^5.[0-2]$/: {
          $ipmi_package_name = 'hp-OpenIPMI'
          $ilo_package_ensure = 'present'
          $ilo_service_ensure = 'running'
          $ilo_service_enable = true
        }
        /^5.[3-4]$/: {
          $ipmi_package_name = 'hp-OpenIPMI'
          $ilo_package_ensure = 'absent'
          $ilo_service_ensure = undef
          $ilo_service_enable = undef
        }
        default: {
          $ipmi_package_name = 'OpenIPMI'
          $ilo_package_ensure = 'absent'
          $ilo_service_ensure = undef
          $ilo_service_enable = undef
        }
      }
      case $::operatingsystemrelease {
        /^6/: {
          $arrayweb_package_name = 'cpqacuxe'
          $arraycli_package_name = 'hpacucli'
        }
        /^7/: {
          $arrayweb_package_name = 'hpssa'
          $arraycli_package_name = 'hpssacli'
        }
        default: { }
      }
    }
    # If we are not on a supported OS, do not do anything.
    default: { }
  }
}
