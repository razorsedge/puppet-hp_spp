# == Class: hp_spp::hpsnmp
#
# This class handles installation of the HP Service Pack for ProLiant SNMP
# Agent.
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
# [*cmasyscontact*]
#   The value for the SNMP system contact.
#   Default: none
#
# [*cmasyslocation*]
#   The value for the SNMP system location.
#   Default: none
#
# [*cmalocalhostrwcommstr*]
#   Community string for Compaq Management Agents to talk to the SNMP server.
#   Default: none
#
# [*cmamgmtstationrocommstr*]
#   Community string for HP SIM to talk to the SNMP server.
#   Default: none
#
# [*cmamgmtstationroipordns*]
#   IP(s) or hostname(s) of the HP SIM server(s).
#   Default: none
#
# [*cmatrapdestinationcommstr*]
#   Community string for the SNMP server to talk to HP SIM.
#   Default: none
#
# [*cmatrapdestinationipordns*]
#   IP(s) or hostname(s) of the HP SIM server(s).
#   Default: none
#
# [*manage_snmp*]
#   Whether to allow this module to manage the SNMP installation.
#   Default: true
#
# === Actions:
#
# Installs and configures the HP SNMP Agents.
# Installs and configures the SNMP server to work with the HP SNMP Agents.
#
# === Requires:
#
# Class['hp_spp']
# Class['hp_spp::repo']
# Class['hp_spp::hphealth']
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class hp_spp::hpsnmp (
  $ensure                    = 'present',
  $autoupgrade               = false,
  $service_ensure            = 'running',
  $service_enable            = true,
  $cmasyscontact             = '',
  $cmasyslocation            = '',
  $cmalocalhostrwcommstr     = '',
  $cmamgmtstationrocommstr   = '',
  $cmamgmtstationroipordns   = '',
  $cmatrapdestinationcommstr = '',
  $cmatrapdestinationipordns = '',
  $manage_snmp               = true
) inherits hp_spp::params {
  # Validate our booleans
  validate_bool($autoupgrade)
  validate_bool($service_enable)
  validate_bool($manage_snmp)

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
      $file_ensure = 'present'
      if $service_ensure in [ running, stopped ] {
        $service_ensure_real = $service_ensure
        $service_enable_real = $service_enable
      } else {
        fail('service_ensure parameter must be running or stopped')
      }
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $file_ensure = 'absent'
      $service_ensure_real = 'stopped'
      $service_enable_real = false
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::manufacturer {
    'HP': {
      #Class['hp_spp'] -> Class['hp_spp::repo'] -> Class['hp_spp::snmp'] ->
      #Class['hp_spp::hphealth'] -> Class['hp_spp::hpsnmp']

      realize Group['hpsmh']
      realize User['hpsmh']

      if $manage_snmp {
        package { 'snmpd':
          ensure => $package_ensure,
          name   => 'net-snmp',
        }

        file { 'snmpd.conf':
          ensure  => $file_ensure,
          mode    => '0660',
          owner   => 'root',
          group   => 'hpsmh',
          path    => '/etc/snmp/snmpd.conf',
          notify  => Exec['hpsnmpconfig'],
        }

        service { 'snmpd':
          ensure     => $service_ensure_real,
          enable     => $service_enable_real,
          hasrestart => true,
          hasstatus  => true,
          require    => Package['snmpd'],
        }

        exec { 'hpsnmpconfig':
          command     => '/sbin/hpsnmpconfig',
          environment => [
            'CMASILENT=yes',
            "CMASYSCONTACT=${cmasyscontact}",
            "CMASYSLOCATION=${cmasyslocation}",
            "CMALOCALHOSTRWCOMMSTR=${cmalocalhostrwcommstr}",
            "CMAMGMTSTATIONROCOMMSTR=${cmamgmtstationrocommstr}",
            "CMAMGMTSTATIONROIPORDNS=${cmamgmtstationroipordns}",
            "CMATRAPDESTINATIONCOMMSTR=${cmatrapdestinationcommstr}",
            "CMATRAPDESTINATIONIPORDNS=${cmatrapdestinationipordns}",
          ],
#          creates => '/etc/hp-snmp-agents.conf',
          refreshonly => true,
          require     => Package['hp-snmp-agents'],
          notify      => [ Service['hp-snmp-agents'], Service['snmpd'], ],
        }
      } else {
        # TODO: require snmp
      }

      package { 'hp-snmp-agents':
        ensure   => $package_ensure,
#        require  => Package['hphealth'],
        require  => Package['snmpd'],
      }

      file { '/opt/hp/hp-snmp-agents/cma.conf':
        ensure  => $file_ensure,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        content => template('hp_spp/cma.conf.erb'),
        require => Package['hp-snmp-agents'],
        notify  => Service['hp-snmp-agents'],
      }

      service { 'hp-snmp-agents':
        ensure     => $service_ensure_real,
        enable     => $service_enable_real,
        hasrestart => true,
        hasstatus  => true,
        require    => Package['hp-snmp-agents'],
      }
    }
    # If we are not on HP hardware, do not do anything.
    default: { }
  }
}
