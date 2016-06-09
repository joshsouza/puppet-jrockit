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
#          it { is_expected.to compile.and_raise_error(/error message match/) }
        end
        context 'with sane defaults' do
          let(:title) { '1.6.0_45-R28.2.7-4.1.0' }
          let(:params) do
            {
              'version'        => '1.6.0_45-R28.2.7-4.1.0',
              'x64'            => 'true',
              'puppetMountDir' => 'file:///vagrant',
            }
          end

          it { is_expected.to compile.with_all_deps }
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
            is_expected.to contain_jrockit__javaexec('jdkexec 1.6.0_45-R28.2.7-4.1.0 1.6.0_45-R28.2.7-4.1.0').with({
              :version       => '1.6.0_45-R28.2.7-4.1.0',
              :path          => '/install',
              :fullversion   => 'jrockit-jdk1.6.0_45-R28.2.7-4.1.0',
              :jdkfile       => 'jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin',
              #:setDefault    => 'true',
              :user          => 'root',
              :group         => 'root',
              #:jreInstallDir => '/usr/java',
              #:installDir    => '/usr/java/jrockit-jdk1.6.0_45-R28.2.7-4.1.0',
              #:installDemos  => 'false',
              #:installSource => 'false',
              #:installJre    => 'true',
            }).that_requires('File[/install/jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin]')
          end
        end
      end
    end
  end
end
