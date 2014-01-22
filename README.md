Puppet HP Service Pack for ProLiant Module
==========================================

master branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-hp_spp.png?branch=master)](http://travis-ci.org/razorsedge/puppet-hp_spp)
develop branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-hp_spp.png?branch=develop)](http://travis-ci.org/razorsedge/puppet-hp_spp)

Introduction
------------

This module manages the installation of the hardware monitoring aspects of the HP
[Service Pack for ProLiant](http://www.hp.com/go/spp/)
from the [Software Delivery Repository](http://downloads.linux.hp.com/SDR/).  It
does not support the HP kernel drivers.

This module currently only works on Red Hat Enterprise Linux.

Actions:

* Installs the SPP YUM repository.
* Installs the HP Health packages and services.
* Installs the HP SNMP Agent package, service, and configuration.
* Installs the HP Systems Management Homepage packages, service, and configuration.

OS Support:

* RedHat - tested on RHEL 6.4
* CentOS - tested on CentOS 6.5
* SuSE   - presently unsupported (patches welcome)

Class documentation is available via puppetdoc.

Examples
--------

      include hp_spp

      # Parameterized Class:
      class { 'hp_spp':
        install_smh               => true,
        smh_gid                   => 1000,
        smh_uid                   => 2000,
        cmamgmtstationrocommstr   => 'community',
        cmamgmtstationroipordns   => 'hpsim.example.com workstation.example.com',
        cmatrapdestinationcommstr => 'public',
        cmatrapdestinationipordns => 'hpsim.example.com',
      }

Notes
-----

* Tested on RedHat 6.4 x86_64 on a HP DL360 G5.
* Tested on Centos 6.6 x86_64 on a HP ProLiant BL685c G1.

Issues
------

* None

TODO
----

* None

License
-------

Please see LICENSE file.

Copyright
---------

Copyright (C) 2013 Mike Arnold <mike@razorsedge.org>

[razorsedge/puppet-hp_spp on GitHub](https://github.com/razorsedge/puppet-hp_spp)

[razorsedge/hp_spp on Puppet Forge](http://forge.puppetlabs.com/razorsedge/hp_spp)

