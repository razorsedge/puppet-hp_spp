# == Class: hp_spp::repo
#
# This class handles installing the SPP software repositories.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*yum_server*]
#   URI of the YUM server.
#   Default: http://downloads.linux.hp.com
#
# [*yum_path*]
#   The path to add to the $yum_server URI.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*spp_version*]
#   The version of SPP to install.
#   Default: current
#
# === Actions:
#
# Installs YUM repository configuration files.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'hp_spp::repo':
#     spp_version => '9.10',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class hp_spp::repo (
  $ensure      = $hp_spp::params::ensure,
  $yum_server  = $hp_spp::params::yum_server,
  $yum_path    = $hp_spp::params::yum_path,
  $gpg_path    = $hp_spp::params::gpg_path,
  $spp_version = $hp_spp::params::spp_version
) inherits hp_spp::params {
  case $ensure {
    /(present)/: {
      $enabled = '1'
    }
    /(absent)/: {
      $enabled = '0'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::manufacturer {
    'HP': {
      case $::operatingsystem {
        'RedHat': {
          yumrepo { 'HP-spp':
            descr    => 'HP Software Delivery Repository for Service Pack for ProLiant',
            enabled  => $enabled,
            gpgcheck => 1,
            # gpgkey has to be a string value with an indented second line
            # per http://projects.puppetlabs.com/issues/8867
            gpgkey   => "${yum_server}${gpg_path}hpPublicKey1024.pub\n    ${yum_server}${gpg_path}hpPublicKey2048.pub",
            baseurl  => "${yum_server}${yum_path}${spp_version}/",
            priority => $hp_spp::params::yum_priority,
            protect  => $hp_spp::params::yum_protect,
          }

          file { '/etc/yum.repos.d/HP-spp.repo':
            ensure => 'file',
            owner  => 'root',
            group  => 'root',
            mode   => '0644',
          }
        }
        default: { }
      }
    }
    # If we are not on HP hardware, do not do anything.
    default: { }
  }
}
