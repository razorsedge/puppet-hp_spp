#!/usr/bin/env rspec

require 'spec_helper'

describe 'hp_spp::hpsmh', :type => 'class' do
  context 'on a non-supported operatingsystem' do
    let :facts do {
      :osfamily        => 'foo',
      :operatingsystem => 'foo'
    }
    end
    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /Unsupported osfamily: foo operatingsystem: foo, module hp_spp only support operatingsystem/)
      }
    end
  end

  context 'on a supported operatingsystem, non-HP platform' do
    (['RedHat']).each do |os|
      context "for operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :operatingsystem => os,
          :manufacturer    => 'foo'
        }
        end
        it { should_not contain_group('hpsmh') }
        it { should_not contain_user('hpsmh') }
        it { should_not contain_package('cpqacuxe') }
        it { should_not contain_package('hpssa') }
        it { should_not contain_package('hpdiags') }
        it { should_not contain_package('hp-smh-templates') }
        it { should_not contain_package('hpsmh') }
        it { should_not contain_file('hpsmhconfig') }
        it { should_not contain_service('hpsmhd') }
      end
    end
  end

  context 'on a supported operatingsystem, HP platform, default parameters' do
    (['RedHat']).each do |os|
      context "for operatingsystem #{os} operatingsystemrelease 5.0" do
        let(:pre_condition) { ['user { "hpsmh": ensure => "present", uid => "490" }', 'group {"hpsmh": ensure => "present", gid => "490" }'].join("\n") }
        let :facts do {
          :operatingsystem        => os,
          :operatingsystemrelease => '5.0',
          :lsbmajdistrelease      => '5',
          :manufacturer           => 'HP'
        }
        end
        it { should contain_group('hpsmh').with_ensure('present').with_gid('490') }
        it { should contain_user('hpsmh').with_ensure('present').with_uid('490') }
        it { should_not contain_package('cpqacuxe') }
        it { should_not contain_package('hpssa') }
        it { should contain_package('hpdiags').with_ensure('present') }
        it { should contain_package('hp-smh-templates').with_ensure('present') }
        it { should contain_package('hpsmh').with_ensure('present') }
        it { should contain_file('hpsmhconfig').with_ensure('present') }
        it 'should populate File[hpsmhconfig] with default values' do
          verify_contents(catalogue, 'hpsmhconfig', [
            '  <admin-group></admin-group>',
            '  <operator-group></operator-group>',
            '  <user-group></user-group>',
            '  <allow-default-os-admin>true</allow-default-os-admin>',
            '  <anonymous-access>false</anonymous-access>',
            '  <localaccess-enabled>false</localaccess-enabled>',
            '  <localaccess-type>Anonymous</localaccess-type>',
            '  <trustmode>TrustByCert</trustmode>',
            '  <xenamelist></xenamelist>',
            '  <ip-binding>false</ip-binding>',
            '  <ip-binding-list></ip-binding-list>',
            '  <ip-restricted-logins>false</ip-restricted-logins>',
            '  <ip-restricted-include></ip-restricted-include>',
            '  <ip-restricted-exclude></ip-restricted-exclude>',
            '  <autostart>false</autostart>',
            '  <timeoutsmh>30</timeoutsmh>',
            '  <port2301>true</port2301>',
            '  <iconview>false</iconview>',
            '  <box-order>status</box-order>',
            '  <box-item-order>status</box-item-order>',
            '  <session-timeout>15</session-timeout>',
            '  <ui-timeout>120</ui-timeout>',
            '  <httpd-error-log>false</httpd-error-log>',
            '  <multihomed></multihomed>',
            '  <rotate-logs-size>5</rotate-logs-size>',
          ])
        end
        it { should contain_service('hpsmhd').with(
          :ensure => 'running',
          :enable => true
        )}
      end

      context "for operatingsystem #{os} operatingsystemrelease 6.0" do
        let(:pre_condition) { ['user { "hpsmh": ensure => "present", uid => "490" }', 'group {"hpsmh": ensure => "present", gid => "490" }'].join("\n") }
        let :facts do {
          :operatingsystem        => os,
          :operatingsystemrelease => '6.0',
          :lsbmajdistrelease      => '6',
          :manufacturer           => 'HP'
        }
        end
        it { should contain_group('hpsmh').with_ensure('present').with_gid('490') }
        it { should contain_user('hpsmh').with_ensure('present').with_uid('490') }
        it { should contain_package('cpqacuxe').with_ensure('present') }
        it { should_not contain_package('hpssa') }
        it { should contain_package('hpdiags').with_ensure('present') }
        it { should contain_package('hp-smh-templates').with_ensure('present') }
        it { should contain_package('hpsmh').with_ensure('present') }
        it { should contain_file('hpsmhconfig').with_ensure('present') }
        it 'should populate File[hpsmhconfig] with default values' do
          verify_contents(catalogue, 'hpsmhconfig', [
            '  <admin-group></admin-group>',
            '  <operator-group></operator-group>',
            '  <user-group></user-group>',
            '  <allow-default-os-admin>true</allow-default-os-admin>',
            '  <anonymous-access>false</anonymous-access>',
            '  <localaccess-enabled>false</localaccess-enabled>',
            '  <localaccess-type>Anonymous</localaccess-type>',
            '  <trustmode>TrustByCert</trustmode>',
            '  <xenamelist></xenamelist>',
            '  <ip-binding>false</ip-binding>',
            '  <ip-binding-list></ip-binding-list>',
            '  <ip-restricted-logins>false</ip-restricted-logins>',
            '  <ip-restricted-include></ip-restricted-include>',
            '  <ip-restricted-exclude></ip-restricted-exclude>',
            '  <autostart>false</autostart>',
            '  <timeoutsmh>30</timeoutsmh>',
            '  <port2301>true</port2301>',
            '  <iconview>false</iconview>',
            '  <box-order>status</box-order>',
            '  <box-item-order>status</box-item-order>',
            '  <session-timeout>15</session-timeout>',
            '  <ui-timeout>120</ui-timeout>',
            '  <httpd-error-log>false</httpd-error-log>',
            '  <multihomed></multihomed>',
            '  <rotate-logs-size>5</rotate-logs-size>',
          ])
        end
        it { should contain_service('hpsmhd').with(
          :ensure => 'running',
          :enable => true
        )}
      end

      context "for operatingsystem #{os} operatingsystemrelease 7.0" do
        let(:pre_condition) { ['user { "hpsmh": ensure => "present", uid => "490" }', 'group {"hpsmh": ensure => "present", gid => "490" }'].join("\n") }
        let :facts do {
          :operatingsystem        => os,
          :operatingsystemrelease => '7.0',
          :lsbmajdistrelease      => '7',
          :manufacturer           => 'HP'
        }
        end
        it { should contain_group('hpsmh').with_ensure('present').with_gid('490') }
        it { should contain_user('hpsmh').with_ensure('present').with_uid('490') }
        it { should_not contain_package('cpqacuxe') }
        it { should contain_package('hpssa').with_ensure('present') }
        it { should contain_package('hpdiags').with_ensure('present') }
        it { should contain_package('hp-smh-templates').with_ensure('present') }
        it { should contain_package('hpsmh').with_ensure('present') }
        it { should contain_file('hpsmhconfig').with_ensure('present') }
        it 'should populate File[hpsmhconfig] with default values' do
          verify_contents(catalogue, 'hpsmhconfig', [
            '  <admin-group></admin-group>',
            '  <operator-group></operator-group>',
            '  <user-group></user-group>',
            '  <allow-default-os-admin>true</allow-default-os-admin>',
            '  <anonymous-access>false</anonymous-access>',
            '  <localaccess-enabled>false</localaccess-enabled>',
            '  <localaccess-type>Anonymous</localaccess-type>',
            '  <trustmode>TrustByCert</trustmode>',
            '  <xenamelist></xenamelist>',
            '  <ip-binding>false</ip-binding>',
            '  <ip-binding-list></ip-binding-list>',
            '  <ip-restricted-logins>false</ip-restricted-logins>',
            '  <ip-restricted-include></ip-restricted-include>',
            '  <ip-restricted-exclude></ip-restricted-exclude>',
            '  <autostart>false</autostart>',
            '  <timeoutsmh>30</timeoutsmh>',
            '  <port2301>true</port2301>',
            '  <iconview>false</iconview>',
            '  <box-order>status</box-order>',
            '  <box-item-order>status</box-item-order>',
            '  <session-timeout>15</session-timeout>',
            '  <ui-timeout>120</ui-timeout>',
            '  <httpd-error-log>false</httpd-error-log>',
            '  <multihomed></multihomed>',
            '  <rotate-logs-size>5</rotate-logs-size>',
          ])
        end
        it { should contain_service('hpsmhd').with(
          :ensure => 'running',
          :enable => true
        )}
      end
    end
  end

  context 'on a supported operatingsystem, HP platform, custom parameters' do
    (['RedHat']).each do |os|
      context "for operatingsystem #{os} operatingsystemrelease 6.0" do
        let(:pre_condition) { ['user { "hpsmh": ensure => "present", uid => "490" }', 'group {"hpsmh": ensure => "present", gid => "490" }'].join("\n") }
        let :params do {
          :autoupgrade            => true,
          :service_ensure         => 'stopped',
          :admin_group            => 'administrators',
          :operator_group         => 'operators',
          :user_group             => 'users',
          :allow_default_os_admin => 'false',
          :anonymous_access       => 'true',
          :localaccess_enabled    => 'true',
          :localaccess_type       => 'Anonymous',
          :trustmode              => 'TrustByCert',
          :xenamelist             => 'somevalue',
          :ip_binding             => 'true',
          :ip_binding_list        => '1.2.3.4',
          :ip_restricted_logins   => 'true',
          :ip_restricted_include  => '2.3.4.5/24',
          :ip_restricted_exclude  => '6.7.8.9/24',
          :autostart              => 'true',
          :timeoutsmh             => '4000',
          :port2301               => 'false',
          :iconview               => 'true',
          :box_order              => 'status',
          :box_item_order         => 'status',
          :session_timeout        => '1000',
          :ui_timeout             => '5000',
          :httpd_error_log        => 'true',
          :multihomed             => 'true',
          :rotate_logs_size       => '2000'
        }
        end
        let :facts do {
          :operatingsystem        => os,
          :operatingsystemrelease => '6.0',
          :lsbmajdistrelease      => '6',
          :manufacturer           => 'HP'
        }
        end
        it { should contain_group('hpsmh').with_ensure('present').with_gid('490') }
        it { should contain_user('hpsmh').with_ensure('present').with_uid('490') }
        it { should contain_package('cpqacuxe').with_ensure('latest') }
        it { should contain_package('hpdiags').with_ensure('latest') }
        it { should contain_package('hp-smh-templates').with_ensure('latest') }
        it { should contain_package('hpsmh').with_ensure('latest') }
        it { should contain_file('hpsmhconfig').with_ensure('present') }
        it 'should populate File[hpsmhconfig] with custom values' do
          verify_contents(catalogue, 'hpsmhconfig', [
            '  <admin-group>administrators</admin-group>',
            '  <operator-group>operators</operator-group>',
            '  <user-group>users</user-group>',
            '  <allow-default-os-admin>false</allow-default-os-admin>',
            '  <anonymous-access>true</anonymous-access>',
            '  <localaccess-enabled>true</localaccess-enabled>',
            '  <localaccess-type>Anonymous</localaccess-type>',
            '  <trustmode>TrustByCert</trustmode>',
            '  <xenamelist>somevalue</xenamelist>',
            '  <ip-binding>true</ip-binding>',
            '  <ip-binding-list>1.2.3.4</ip-binding-list>',
            '  <ip-restricted-logins>true</ip-restricted-logins>',
            '  <ip-restricted-include>2.3.4.5/24</ip-restricted-include>',
            '  <ip-restricted-exclude>6.7.8.9/24</ip-restricted-exclude>',
            '  <autostart>true</autostart>',
            '  <timeoutsmh>4000</timeoutsmh>',
            '  <port2301>false</port2301>',
            '  <iconview>true</iconview>',
            '  <box-order>status</box-order>',
            '  <box-item-order>status</box-item-order>',
            '  <session-timeout>1000</session-timeout>',
            '  <ui-timeout>5000</ui-timeout>',
            '  <httpd-error-log>true</httpd-error-log>',
            '  <multihomed>true</multihomed>',
            '  <rotate-logs-size>2000</rotate-logs-size>',
          ])
        end
        it { should contain_service('hpsmhd').with_ensure('stopped') }
      end
    end
  end

end
