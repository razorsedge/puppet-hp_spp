#!/usr/bin/env rspec

require 'spec_helper'

describe 'hp_spp::hpsnmp', :type => 'class' do

  context 'on a non-supported operatingsystem' do
    let :facts do {
      :osfamily        => 'foo',
      :operatingsystem => 'foo',
      :operatingsystemrelease => '1'
    }
    end
    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /Unsupported osfamily: foo operatingsystem: foo, module hp_spp only support operatingsystem/)
      }
    end
  end

  redhatish = ['RedHat', 'CentOS']

  context 'on a supported operatingsystem, non-HP platform' do
    redhatish.each do |os|
      context "for operatingsystem #{os}" do
        let(:params) {{ :cmalocalhostrwcommstr => 'aString' }}
        let :facts do {
          :operatingsystem => os,
          :operatingsystemrelease => '6.0',
          :manufacturer    => 'foo'
        }
        end
        it { should_not contain_group('hpsmh') }
        it { should_not contain_user('hpsmh') }
        it { should_not contain_package('snmpd') }
        it { should_not contain_file('snmpd.conf') }
        it { should_not contain_service('snmpd') }
        it { should_not contain_exec('hpsnmpconfig') }
        it { should_not contain_package('hp-snmp-agents') }
        it { should_not contain_file('/opt/hp/hp-snmp-agents/cma.conf') }
        it { should_not contain_service('hp-snmp-agents') }
      end
    end
  end

  context 'on a supported operatingsystem, HP platform, default parameters' do
    redhatish.each do |os|
      context "for operatingsystem #{os} operatingsystemrelease 6.0" do
        let(:pre_condition) { ['user { "hpsmh": ensure => "present", uid => "490" }', 'group {"hpsmh": ensure => "present", gid => "490" }'].join("\n") }
        let(:params) {{ :cmalocalhostrwcommstr => 'aString' }}
        let :facts do {
          :operatingsystem        => os,
          :operatingsystemrelease => '6.0',
          :lsbmajdistrelease      => '6',
          :manufacturer           => 'HP'
        }
        end
        it { should contain_group('hpsmh').with_ensure('present').with_gid('490') }
        it { should contain_user('hpsmh').with_ensure('present').with_uid('490') }
        it { should contain_package('snmpd').with_ensure('present') }
        it { should contain_file('snmpd.conf').with_ensure('present') }
        it { should contain_service('snmpd').with(
          :ensure => 'running',
          :enable => true
        )}
        it { should contain_exec('hpsnmpconfig') }
        it { should contain_package('hp-snmp-agents').with_ensure('present') }
        it { should contain_file('/opt/hp/hp-snmp-agents/cma.conf').with_ensure('present') }
        it { should contain_service('hp-snmp-agents').with(
          :ensure => 'running',
          :enable => true
        )}
      end
    end
  end

  context 'on a supported operatingsystem, HP platform, custom parameters' do
    redhatish.each do |os|
      context "for operatingsystem #{os} operatingsystemrelease 6.0" do
        let(:pre_condition) { ['user { "hpsmh": ensure => "present", uid => "490" }', 'group {"hpsmh": ensure => "present", gid => "490" }'].join("\n") }
        let :params do {
          :cmalocalhostrwcommstr => 'aString',
          :autoupgrade           => true,
          :service_ensure        => 'stopped'
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
        it { should contain_package('snmpd').with_ensure('latest') }
        it { should contain_file('snmpd.conf').with_ensure('present') }
        it { should contain_service('snmpd').with_ensure('stopped') }
        it { should contain_exec('hpsnmpconfig') }
        it { should contain_package('hp-snmp-agents').with_ensure('latest') }
        it { should contain_file('/opt/hp/hp-snmp-agents/cma.conf').with_ensure('present') }
        it { should contain_service('hp-snmp-agents').with_ensure('stopped') }
      end
    end
  end

end
