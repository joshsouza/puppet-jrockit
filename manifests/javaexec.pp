# javaexec
# run the silent install
# set the default java links
# set this java as default

define jrockit::javaexec (
  $version,
  $path          = undef,
  $fullversion   = undef,
  $jdkfile       = undef,
  $setDefault    = undef,
  $user          = undef,
  $group         = undef,
  $installDemos  = undef,
  $installSource = undef,
  $installJre    = undef,
  $installDir    = undef,
  $jreInstallDir = '/usr/java',
) {
  # install jdk
  case $::operatingsystem {
    'CentOS', 'RedHat', 'OracleLinux', 'Ubuntu', 'Debian': {

      $execPath     = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
      $silentfile   = "${path}/silent${version}.xml"

      Exec {
        logoutput   => true,
        path        => $execPath,
        user        => $user,
        group       => $group,
      }

      # check java install folder
      if ! defined(File[$jreInstallDir]) {
        file { $jreInstallDir:
          ensure => directory,
          path   => $jreInstallDir,
          mode   => '0755',
        }
      }

      # Variables used: installDir, installDemos, installSource, installJre, jreInstallDir
      # Create the silent install xml
      file { $silentfile:
        ensure  => present,
        path    => $silentfile,
        replace => true,
        content => template('jrockit/jrockit-silent.xml.erb'),
        require => File[$jreInstallDir],
      }

      # Do the installation but only if the directory doesn't exist
      exec { 'install jrockit':
        command   => "${jdkfile} -mode=silent -silent_xml=${silentfile}",
        cwd       => $path,
        path      => $path,
        logoutput => true,
        creates   => "${jreInstallDir}/${fullversion}",
        require   => File[$silentfile],
      }

      # java link to latest
      file { "${jreInstallDir}/latest":
        ensure  => link,
        target  => "${jreInstallDir}/${fullversion}",
        mode    => '0755',
        require => Exec['install jrockit'],
      }

      # java link to default
      file { "${jreInstallDir}/default":
        ensure  => link,
        target  => "${jreInstallDir}/latest",
        mode    => '0755',
        require => File["${jreInstallDir}/latest"],
      }

      # Add to alternatives and set as the default if required
      alternative_entry { "${jreInstallDir}/${fullversion}/bin/java":
        ensure   => present,
        altlink  => '/usr/bin/java',
        altname  => 'java',
        priority => 17065,
        require  => File["${jreInstallDir}/default"],
      }
      if str2bool($setDefault){
        alternatives { 'java':
          path    => "${jreInstallDir}/${fullversion}/bin/java",
          mode    => 'manual',
          require => [File["${jreInstallDir}/default"],
                      Alternative_entry["${jreInstallDir}/${fullversion}/bin/java"],
                      ],
        }
      }
    }
    default: {
      fail('Attempting to install JRockit on an unsupported OS.')
    }
  }
}
