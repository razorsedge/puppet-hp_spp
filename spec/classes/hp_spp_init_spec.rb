#!/usr/bin/env rspec

require 'spec_helper'

describe 'hp_spp', :type => 'class' do

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

  redhatish = ['RedHat']

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
        it { should_not contain_anchor('hp_spp::begin') }
        it { should_not contain_class('hp_spp::repo') }
        it { should_not contain_class('hp_spp::hphealth') }
        it { should_not contain_class('hp_spp::hpsnmp') }
        it { should_not contain_class('hp_spp::hpsmh') }
        it { should_not contain_anchor('hp_spp::end') }
        it { should_not contain_class('hp_spp::hpams') }
      end
    end
  end

  context 'on a supported operatingsystem, HP platform, default parameters' do
    redhatish.each do |os|
      context "for operatingsystem #{os}" do
        let(:params) {{ :cmalocalhostrwcommstr => 'aString' }}
        let :facts do {
          :operatingsystem => os,
          :operatingsystemrelease => '6.0',
          :manufacturer    => 'HP'
        }
        end
        it { should contain_anchor('hp_spp::begin') }
        it { should contain_class('hp_spp::repo') }
        it { should contain_class('hp_spp::hphealth') }
        it { should contain_class('hp_spp::hpsnmp') }
        it { should contain_class('hp_spp::hpsmh') }
        it { should contain_anchor('hp_spp::end') }
        it { should_not contain_class('hp_spp::hpams') }
      end
    end
  end

end
