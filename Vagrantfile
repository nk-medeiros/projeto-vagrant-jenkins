Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/jammy64"

  # VM 1: Jenkins
  config.vm.define "jenkins" do |jenkins|
    jenkins.vm.hostname = "jenkins-server"
    jenkins.vm.network "private_network", ip: "192.168.56.10"
    #jenkins.vm.network "forwarded_port", guest: 8080, host: 8081

    jenkins.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
      v.name = "jenkins-server"
    end

    jenkins.vm.provision "shell", path: "scripts/setup-jenkins.sh"
  end

  # VM 2: Produção (Prod)
  config.vm.define "prod" do |prod|
    prod.vm.hostname = "prod-server"
    prod.vm.network "private_network", ip: "192.168.56.20"

    # Extra: pasta sincronizada para testar o app em produção
    prod.vm.synced_folder "./app", "/var/www/app"

    prod.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
      v.name = "prod-server"
    end

    prod.vm.provision "shell", path: "scripts/setup-prod.sh"
  end

end