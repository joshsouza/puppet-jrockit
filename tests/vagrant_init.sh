#!/bin/bash

create_modules_symlinks () {
  rm -rf /etc/puppet/modules || true 2>/dev/null
  mkdir /etc/puppet/modules
  ln -sfn /vagrant/spec/fixtures/modules/* /etc/puppet/modules/.
  to_fix=`find /etc/puppet/modules -xtype l | sed 's@/etc/puppet/modules/@@'`
  rm "/etc/puppet/modules/${to_fix}"
  ln -s /vagrant/ /etc/puppet/modules/${to_fix}
}

create_default_hiera_file() {
cat <<EOF > /etc/puppet/hiera.yaml
---
:backends: yaml
:yaml:
  :datadir: /vagrant/tests/hieradata
:hierarchy: common
:logger: console
EOF
}

STAGE='/tmp/initial_provision_complete'

if [ ! -e $STAGE ]; then
  YUM_CMD=$(which yum)
  APT_GET_CMD=$(which apt-get)
  if [[ ! -z $YUM_CMD ]]; then
    INSTALL="yum install -y"
    RUBYGEMS='rubygems'
  elif [[ ! -z $APT_GET_CMD ]]; then
    INSTALL="apt-get install -y"
    RUBYGEMS='rubygems-integration'
    apt-get update
  else
    echo "error can't install packages without a package provider"
    exit 1;
  fi
  echo "Initial provision, running the provisioner script..."

  $INSTALL ruby ${RUBYGEMS}
  gem install puppet -v '3.8.2' --no-rdoc --no-ri

  if [ ! -d '/etc/puppet' ]; then
    mkdir /etc/puppet
    chmod 755 /etc/puppet
  fi

  if [ -d '/etc/puppet/modules' ]; then
    mv /etc/puppet/modules /etc/puppet/modules.orig
  fi

  create_default_hiera_file

  touch $STAGE

else
  echo "Not initial provision, skipping the provisioner script..."
fi
echo "Putting fixtures in place"
create_modules_symlinks

exit 0
