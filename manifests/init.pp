# == Class: hp_spp
#
# This class handles installation of the HP Service Pack for ProLiant.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*smh_gid*]
#   The group ID of the SMH user.
#   Default: 490
#
# [*smh_uid*]
#   The user ID of the SMH user.
#   Default: 490
#
# [*install_smh*]
#   Whether to install the HP System Management Homepage.
#   Default: true
#
# === Actions:
#
# Wraps the installation of all HP SPP subcomponents except for the Agentless
# Monitoring Service.  Do not call this class if you just want AMS.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'hp_spp': }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class hp_spp (
  $ensure                    = $hp_spp::params::ensure,
  $autoupgrade               = $hp_spp::params::safe_autoupgrade,
  $service_ensure            = $hp_spp::params::service_ensure,
  $service_enable            = $hp_spp::params::safe_service_enable,
  $smh_gid                   = $hp_spp::params::gid,
  $smh_uid                   = $hp_spp::params::uid,
  $yum_server                = $hp_spp::params::yum_server,
  $yum_path                  = $hp_spp::params::yum_path,
  $gpg_path                  = $hp_spp::params::gpg_path,
  $spp_version               = $hp_spp::params::spp_version,
  $cmasyscontact             = undef,
  $cmasyslocation            = undef,
  $cmalocalhostrwcommstr     = undef,
  $cmamgmtstationrocommstr   = undef,
  $cmamgmtstationroipordns   = undef,
  $cmatrapdestinationcommstr = undef,
  $cmatrapdestinationipordns = undef,
  $manage_snmp               = true,
  $install_smh               = true
) inherits hp_spp::params {
  # Validate our booleans
  validate_bool($autoupgrade)
  validate_bool($service_enable)
  validate_bool($manage_snmp)
  validate_bool($install_smh)

  case $ensure {
    /(present)/: {
      $user_ensure = 'present'
    }
    /(absent)/: {
      $user_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::manufacturer {
    'HP': {
      case $::operatingsystem {
        'RedHat': {
          @group { 'hpsmh':
            ensure => $user_ensure,
            gid    => $smh_gid,
          }

          @user { 'hpsmh':
            ensure => $user_ensure,
            uid    => $smh_uid,
            gid    => 'hpsmh',
            home   => '/opt/hp/hpsmh',
            shell  => '/sbin/nologin',
          }

          anchor { 'hp_spp::begin': }
          anchor { 'hp_spp::end': }

          class { '::hp_spp::repo':
            ensure      => $ensure,
            yum_server  => $yum_server,
            yum_path    => $yum_path,
            gpg_path    => $gpg_path,
            spp_version => $spp_version,
          }
          class { '::hp_spp::hphealth':
            ensure         => $ensure,
            autoupgrade    => $autoupgrade,
            service_ensure => $service_ensure,
            service_enable => $service_enable,
          }
          class { '::hp_spp::hpsnmp':
            ensure                    => $ensure,
            autoupgrade               => $autoupgrade,
            service_ensure            => $service_ensure,
            service_enable            => $service_enable,
            cmasyscontact             => $cmasyscontact,
            cmasyslocation            => $cmasyslocation,
            cmalocalhostrwcommstr     => $cmalocalhostrwcommstr,
            cmamgmtstationrocommstr   => $cmamgmtstationrocommstr,
            cmamgmtstationroipordns   => $cmamgmtstationroipordns,
            cmatrapdestinationcommstr => $cmatrapdestinationcommstr,
            cmatrapdestinationipordns => $cmatrapdestinationipordns,
            manage_snmp               => $manage_snmp,
          }
          if $install_smh {
            class { '::hp_spp::hpsmh':
              ensure         => $ensure,
              autoupgrade    => $autoupgrade,
              service_ensure => $service_ensure,
              service_enable => $service_enable,
            }
            Anchor['hp_spp::begin'] ->
            Class['hp_spp::repo'] ->
            Class['hp_spp::hphealth'] ->
            Class['hp_spp::hpsnmp'] ->
            Class['hp_spp::hpsmh'] ->
            Anchor['hp_spp::end']
          } else {
            Anchor['hp_spp::begin'] ->
            Class['hp_spp::repo'] ->
            Class['hp_spp::hphealth'] ->
            Class['hp_spp::hpsnmp'] ->
            Anchor['hp_spp::end']
          }
        }
        # If we are not on a supported OS, do not do anything.
        default: { }
      }
    }
    # If we are not on HP hardware, do not do anything.
    default: { }
  }
}
