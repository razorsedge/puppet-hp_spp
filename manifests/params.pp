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
  $hp_spp_yum_server = getvar('::hp_spp_yum_server')
  if $hp_spp_yum_server {
    $yum_server = $::hp_spp_yum_server
  } else {
    $yum_server = 'http://downloads.linux.hpe.com'
  }

  $hp_spp_spp_version = getvar('::hp_spp_spp_version')
  if $hp_spp_spp_version {
    $spp_version = $::hp_spp_spp_version
  } else {
    $spp_version = 'current'
  }

### The following parameters should not need to be changed.

  $hp_spp_ensure = getvar('::hp_spp_ensure')
  if $hp_spp_ensure {
    $ensure = $::hp_spp_ensure
  } else {
    $ensure = 'present'
  }

  $hp_spp_service_ensure = getvar('::hp_spp_service_ensure')
  if $hp_spp_service_ensure {
    $service_ensure = $::hp_spp_service_ensure
  } else {
    $service_ensure = 'running'
  }

  # Since the top scope variable could be a string (if from an ENC), we might
  # need to convert it to a boolean.
  $hp_spp_autoupgrade = getvar('::hp_spp_autoupgrade')
  if $hp_spp_autoupgrade {
    $autoupgrade = $::hp_spp_autoupgrade
  } else {
    $autoupgrade = false
  }
  if is_string($autoupgrade) {
    $safe_autoupgrade = str2bool($autoupgrade)
  } else {
    $safe_autoupgrade = $autoupgrade
  }

  $hp_spp_service_enable = getvar('::hp_spp_service_enable')
  if $hp_spp_service_enable {
    $service_enable = $::hp_spp_service_enable
  } else {
    $service_enable = true
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
        default: {
          $arrayweb_package_name = unset
          $arraycli_package_name = unset
        }
      }
    }
    # If we are not on a supported OS, do not do anything.
    default: { }
  }
}
