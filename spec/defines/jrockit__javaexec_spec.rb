require 'spec_helper'

supported_oses = {}.merge!(on_supported_os)

describe 'jrockit::javaexec' do
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
          let(:title) { 'jdkexec 1.6.0_45-R28.2.7-4.1.0 1.6.0_45-R28.2.7-4.1.0' }
          let(:params) do
            {
              'version'       => '1.6.0_45-R28.2.7-4.1.0',
              'path'          => '/install',
              'fullversion'   => 'jrockit-jdk1.6.0_45-R28.2.7-4.1.0',
              'jdkfile'       => 'jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin',
              'setDefault'    => 'true',
              'user'          => 'root',
              'group'         => 'root',
              'installDemos'  => 'false',
              'installSource' => 'false',
              'installJre'    => 'true',
              'installDir'    => '/usr/java/jrockit-jdk1.6.0_45-R28.2.7-4.1.0',
              'jreInstallDir' => '/usr/java',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it do
            is_expected.to contain_file('/usr/java').with({
              :ensure => 'directory',
              :path   => '/usr/java',
              :mode   => '0755',
            })
          end
          it do
            is_expected.to contain_file('/install/silent1.6.0_45-R28.2.7-4.1.0.xml').with({
              :ensure  => 'present',
              :path    => '/install/silent1.6.0_45-R28.2.7-4.1.0.xml',
              :replace => 'true',
              #:content => template('jrockit/jrockit-silent.xml.erb'),
            }).that_requires('File[/usr/java]')
          end
          it do
            is_expected.to contain_exec('install jrockit').with({
              :command   => 'jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin -mode=silent -silent_xml=/install/silent1.6.0_45-R28.2.7-4.1.0.xml',
              :cwd       => '/install',
              :path      => '/install',
              :logoutput => 'true',
              :creates   => '/usr/java/jrockit-jdk1.6.0_45-R28.2.7-4.1.0',
            }).that_requires('File[/install/silent1.6.0_45-R28.2.7-4.1.0.xml]')
          end
          it do
            is_expected.to contain_file('/usr/java/latest').with({
              :ensure => 'link',
              :target => '/usr/java/jrockit-jdk1.6.0_45-R28.2.7-4.1.0',
              :mode   => '0755',
            }).that_requires('Exec[install jrockit]')
          end
          it do
            is_expected.to contain_file('/usr/java/default').with({
              :ensure => 'link',
              :target => '/usr/java/latest',
              :mode   => '0755',
            }).that_requires('File[/usr/java/latest]')
          end
          it do
            is_expected.to contain_alternative_entry('/usr/java/jrockit-jdk1.6.0_45-R28.2.7-4.1.0/bin/java').with({
              :ensure   => 'present',
              :altlink  => '/usr/bin/java',
              :altname  => 'java',
              :priority => '17065',
            }).that_requires('File[/usr/java/default]')
          end
          it do
            is_expected.to contain_alternatives('java').with({
              :path => '/usr/java/jrockit-jdk1.6.0_45-R28.2.7-4.1.0/bin/java',
              :mode => 'manual',
            }).that_requires(['File[/usr/java/default]','Alternative_entry[/usr/java/jrockit-jdk1.6.0_45-R28.2.7-4.1.0/bin/java]'])
          end
        end
      end
    end
  end
end
