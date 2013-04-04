include hp_spp
#include hp_spp::hpsnmp
class { 'hp_spp::hpsnmp': cmalocalhostrwcommstr => 'SomeSecureString', }
include hp_spp::hphealth
