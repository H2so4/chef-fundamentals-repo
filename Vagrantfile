require 'chef'
require 'chef/config'
require 'chef/knife'
require 'vagrant/provisioners/chef'

current_dir = File.dirname(__FILE__)
Chef::Config.from_file(File.join(File.dirname(__FILE__), ".chef", "knife.rb"))

cookbook_testers = {
  :classroom => {
    :hostname => "workshop-classroom",
    :ipaddress => "172.16.13.100",
    :run_list => "role[classroom]"
  },
  :workstation => {
    :hostname => "workshop-workstation",
    :ipaddress => "172.16.13.101",
    :run_list => "role[workstation]"
  },
  :target => {
    :hostname => "workshop-target",
    :ipaddress => "172.16.13.102",
    :run_list => "role[target]"
  }
}

Vagrant::Config.run do |global_config|

  cookbook_testers.each_pair do |name, options|
    global_config.vm.define name do |config|
      vm_name = options[:hostname]
      ipaddress = options[:ipaddress]

      config.vm.share_folder("v-root", "/vagrant", ".", :disabled => true)

      config.vm.box = name.to_s
      config.vm.boot_mode = :headless
      config.vm.host_name = vm_name
      config.vm.network :hostonly, ipaddress

      config.vm.forward_port 80, 8000 if name == :classroom
      config.vm.forward_port 5901, 5901 if name == :workstation

      config.vm.provision :chef_client do |chef|
        chef.chef_server_url = Chef::Config[:chef_server_url]
        chef.validation_key_path = Chef::Config[:validation_key]
        chef.validation_client_name = Chef::Config[:validation_client_name]
        chef.node_name = options[:hostname]
        chef.provisioning_path = "/etc/chef"
        chef.log_level = :info
        run_list = []
        run_list << ENV['CHEF_RUN_LIST'].split(",") if ENV.has_key?('CHEF_RUN_LIST')
        chef.run_list = [options[:run_list].split(","), run_list].flatten
      end
    end
  end
end

module Vagrant
  module Provisioners
    class ChefClient < Chef
      def cleanup
        if env[:vm].config.vm.host_name
          puts `sh -c 'knife client delete #{env[:vm].config.vm.host_name} -y'`
          puts `sh -c 'knife node delete #{env[:vm].config.vm.host_name} -y'`
        else
          puts "No host_name was defined for the box... unable to remove it from chef"
        end
      end
    end
  end
end
