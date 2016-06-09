require 'spec_helper'

supported_oses = {}.merge!(on_supported_os)

describe 'jrockit::installrockit' do
   context 'supported operating systems' do
     supported_oses.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
           facts
        end

        context 'without any parameters' do
          let(:title) { 'fail intentionally' }
          it do
            expect { is_expected.to contain_jrockit__installrockit('fail intentionally') }.to raise_error(Puppet::Error, /Must pass version to Jrockit::Installrockit/)
          end
        end
        context 'with sane defaults' do
          let(:title) { '1.6.0_45-R28.2.7-4.1.0' }
          let(:params) do
            {
              :version        => '1.6.0_45-R28.2.7-4.1.0',
              :x64            => 'true',
              :puppetMountDir => 'file:///vagrant',
              :jreInstallDir => '/usr/java',
            }
          end

          it { is_expected.to compile.with_all_deps }
          # Self-test for coverage completion
          it { is_expected.to contain_jrockit__installrockit('1.6.0_45-R28.2.7-4.1.0') }
          it do
            is_expected.to contain_file('/install').with({
              :ensure => 'directory',
              :mode   => '0777',
              :path   => '/install',
            })
          end
          it do
            is_expected.to contain_file('/install/jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin').with({
              :ensure => 'present',
              :path   => '/install/jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin',
              :source => 'file:///vagrant/jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin',
              :mode   => '0777',
            }).that_requires('File[/install]')
          end
          it do
            expect catalogue.resource('jrockit::javaexec')
          end
          it do
            is_expected.to contain_jrockit__javaexec('jdkexec 1.6.0_45-R28.2.7-4.1.0 1.6.0_45-R28.2.7-4.1.0').with({
              # Note: All of these parameters, due to how rspec-puppet works
              #       must be lowercased. Yes, this is insane. No, you can't change it.
               :version       => '1.6.0_45-R28.2.7-4.1.0',
               :path          => '/install',
               :fullversion   => 'jrockit-jdk1.6.0_45-R28.2.7-4.1.0',
               :jdkfile       => 'jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin',
               #:setDefault    => 'true',
               :user          => 'root',
               :group         => 'root',
               :jreinstalldir => '/usr/java',
               :installdir    => '/usr/java/jrockit-jdk1.6.0_45-R28.2.7-4.1.0',
               :installdemos  => 'false',
               :installsource => 'false',
               :installjre    => 'true',
             }).that_requires('File[/install/jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin]')
          end
        end
      end
    end
  end
end
