# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'json'

# Use this if you want to configure a local test environment only

# We need to make sure that your fixtures are in place for this to work:

system("
    if [ #{ARGV[0]} = 'up' ] || [ #{ARGV[0]} = 'provision' ]; then
        if [ ! -d ./spec/fixtures/modules ]; then
          echo 'It appears you have not yet run run \"bundle exec rake spec_prep\"'
          echo 'You must run this before this script runs'
          echo 'Sleeping for 10 seconds so that you can exit to fix this...'
          for i in {1..10}; do
            printf .
            sleep 1
          done
          echo .
        else
          echo 'You appear to have fixtures in place. Continuing.'
        fi
    fi
")

local_environment = {
  "servers" => [
    {"name" => "oel6",     "box" => "rvanider/oel67min"},
    {"name" => "centos6",  "box" => "puppetlabs/centos-6.6-64-nocm"},
    {"name" => "ubuntu14", "box" => "puppetlabs/ubuntu-14.04-64-nocm"}
  ]
}

VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.4.0"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  hosts = local_environment['servers']
  hosts.each do |server|
    config.vm.define "#{server['name']}" do |host|
      host.vm.provider "virtualbox" do |v|
        v.memory = 512
        v.cpus = 1
      end
      host.vm.box = server['box']
      host.vm.hostname = server['name']
      host.vm.provision :shell, :path => "./tests/vagrant_init.sh"

      # Configuration to mimic tmo's
      host.vm.provision "shell", inline: <<-SHELL
        puppet config set ordering random --section main
        puppet config set stringify_facts false --section main
        puppet config set immutable_node_data true --section main
        puppet config set trusted_node_data true --section main
      SHELL

      host.vm.provision :puppet do |puppet|
        puppet.manifests_path = "./tests"
        puppet.manifest_file  = "init.pp"
        puppet.options = "--verbose --debug"
        puppet.hiera_config_path = "tests/hiera.yaml"
        puppet.working_directory = "/vagrant/"
      end
    end
  end
end
