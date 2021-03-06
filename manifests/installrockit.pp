# jrockit::instalrockit

define jrockit::installrockit (
  $version,
  $x64            = true,
  $downloadDir    = '/install',
  $puppetMountDir = undef,
  $installDemos   = false,
  $installSource  = false,
  $installJre     = true,
  $setDefault     = true,
  $jreInstallDir  = '/usr/java',
  $install_user   = 'root',
  $install_group  = 'root',
) {

  $fullVersion = "jrockit-jdk${version}"
  $installDir  = "${jreInstallDir}/${fullVersion}"

  if str2bool($x64) {
    $type = 'x64'
  } else {
    $type = 'ia32'
  }

  case $::operatingsystem {
    'CentOS', 'RedHat', 'OracleLinux', 'Ubuntu', 'Debian': {
      $installVersion   = 'linux'
      $installExtension = '.bin'
      $user             = $install_user
      $group            = $install_group
    }
    'windows': {
      $installVersion   = 'windows'
      $installExtension = '.exe'
    }
    default: {
      fail('Unrecognized operating system')
    }
  }

  $jdkfile = "jrockit-jdk${version}-${installVersion}-${type}${installExtension}"

  File {
    replace => false,
  }

  # check install folder
  if ! defined(File[$downloadDir]) {
    file { $downloadDir :
      ensure => directory,
      mode   => '0777',
      path   => $downloadDir,
    }
  }

  # if a mount was not specified then get the install media from the puppet master
    if $puppetMountDir == undef {
      $mountDir = 'puppet:///modules/jrockit'
    } else {
      $mountDir = $puppetMountDir
    }

  # download jdk to client
  if ! defined(File["${downloadDir}/${jdkfile}"]) {
    file { "${downloadDir}/${jdkfile}":
      ensure  => present,
      path    => "${downloadDir}/${jdkfile}",
      source  => "${mountDir}/${jdkfile}",
      mode    => '0777',
      require => File[$downloadDir],
    }
  }

  # install on client
  jrockit::javaexec {"jdkexec ${title} ${version}":
    version       => $version,
    path          => $downloadDir,
    fullversion   => $fullVersion,
    jdkfile       => $jdkfile,
    setDefault    => $setDefault,
    user          => $user,
    group         => $group,
    jreInstallDir => $jreInstallDir,
    # These parameters must be passed due to potential scoping issues.
    installDir    => $installDir,
    installDemos  => $installDemos,
    installSource => $installSource,
    installJre    => $installJre,
    require       => File["${downloadDir}/${jdkfile}"],
  }
}
