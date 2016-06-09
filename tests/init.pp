# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
File {
  backup => false,
}

$version        = '1.6.0_45-R28.2.7-4.1.0'
$download_dir   = '/data/install'
$jrockit_home   = '/opt/oracle/middleware/jrockit-jdk1.6.0_45-R28.2.7-4.1.0'
$install_user   = 'oracle'
$install_group  = 'dba'
$jrockit_source = 'file:///vagrant/'

group { $install_group:
  ensure => present,
}
user { $install_user:
  ensure     => present,
  groups     => $install_group,
  shell      => '/bin/bash',
  home       => "/home/${install_user}",
  comment    => 'Oracle user created by Puppet',
  managehome => true,
  require    => Group[$install_group],
}

file {['/data', '/opt/oracle', '/opt/oracle/middleware']:
  ensure => directory,
  owner  => $os_user,
  group  => $os_group,
}

jrockit::installrockit { $version:
  version        => $version,
  x64            => true,
  downloadDir    => $download_dir,
  puppetMountDir => $jrockit_source,
  installDemos   => false,
  installSource  => false,
  installJre     => true,
  setDefault     => true,
  jreInstallDir  => $jrockit_home,
  install_user   => $install_user,
  install_group  => $install_group,
  require        => [File['/data'],File['/opt/oracle/middleware']],
}
