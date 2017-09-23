#!/usr/bin/env rspec

require 'spec_helper'

describe 'hp_spp::hpams', :type => 'class' do

  context 'on a non-supported operatingsystem' do
    let :facts do {
      :osfamily        => 'foo',
      :operatingsystem => 'foo',
      :operatingsystemrelease => '1'
    }
    end
    it 'should fail' do
      expect {
       should raise_error(Puppet::Error, /Module hp_spp is not supported on foo/)
      }
    end
  end

  redhatish = ['RedHat', 'CentOS']

  context 'on a supported operatingsystem, non-HP platform' do
    redhatish.each do |os|
      context "for operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :operatingsystem => os,
          :operatingsystemrelease => '6.0',
          :manufacturer    => 'foo'
        }
        end
        it { should_not contain_package('hp-ams') }
        it { should_not contain_service('hp-ams') }
      end
    end
  end

  context 'on a supported operatingsystem, HP platform, default parameters' do
    redhatish.each do |os|
      context "for operatingsystem #{os}" do
        let(:pre_condition) { 'class {"hp_spp::repo":}' }
        let :facts do {
          :operatingsystem => os,
          :operatingsystemrelease => '6.0',
          :manufacturer    => 'HP'
        }
        end
        it { should contain_class('hp_spp::repo') }
        it { should contain_package('hp-ams').with_ensure('present') }
        it { should contain_service('hp-ams').with_ensure('running') }
      end
    end
  end

  context 'on a supported operatingsystem, HP platform, custom parameters' do
    redhatish.each do |os|
      context "for operatingsystem #{os}" do
        let(:pre_condition) { 'class {"hp_spp::repo":}' }
        let :params do {
          :autoupgrade    => true,
          :service_ensure => 'stopped'
        }
        end
        let :facts do {
          :operatingsystem => os,
          :operatingsystemrelease => '6.0',
          :manufacturer    => 'HP'
        }
        end
        it { should contain_class('hp_spp::repo') }
        it { should contain_package('hp-ams').with_ensure('latest') }
        it { should contain_service('hp-ams').with_ensure('stopped') }
      end
    end
  end

end
