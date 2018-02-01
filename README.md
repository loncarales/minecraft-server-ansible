# Minecraft Java Edition Server on Debian 9 (Stretch) with Ansible

> Papa, kannst du uns einen Minecraft-Server machen?

This is a repository of Ansible playbooks enabling me to create Minecraft Java Edition Server on Debian 9 (Stretch). The whole infrastructure is tested with Molecule and Vagrant.

[Molecule](https://molecule.readthedocs.io/en/latest/) is an open source infrastructure testing tool written in Python that can provision and test Ansible roles. 

It includes

* adding limited user account
* installing all required packages
* securing the server
    * automatic security updates
    * hardening SSH access
    * using Fail2Ban for SSH login protection (TODO)
    * configuring a Firewall with UFW
* installing and configuring Minecraft Server
* installing and configuring McMyAdmin for Minecraft

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

`git clone https://github.com/loncarales/minecraft-server-ansible.git`

### Prerequisites

#### Server Machine

My choice for server operating system these days is mostly Debian. You can choose from a lot of known hosting providers all over the world to run Debian Operating System on their Dedicated servers or VPS. Use provided links when registering with following Cloud Providers.

* [DigitalOcean](https://m.do.co/c/cf617a7a6bf7) You'll get free $10 in credit.
* [Linode](https://www.linode.com/?r=a78509d898e8eb5b065c6f5819ccc1c2086b1938)
* [Vultr](https://www.vultr.com/?ref=7319557)
* [Scaleway](https://www.scaleway.com/)
* [Hetzner Online](https://www.hetzner.de/)
* [Amazon Lighsail](https://aws.amazon.com/lightsail/)

#### Settin up SSH Keys

Generate a new SSH key which you'll use for authentication with the server machine.

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/minecraft_id_rsa
```

Take care of `minecraft_id_rsa` file it is your private key. After you'll add limited user account and secure your server (dissallow root logins over SSH, dissable SSH password authentication) this will be only way to access your server. If you overwrite or loose the local private key after using the matching public key to secure your server, you may lose your ability to access your server via SSH.
 
### Configuration

* hosts.ini under minecraft server group
    * change YourServerIP with your actual Public IP Address 
* roles/server-setup/defaults/main.yml
    * set `local_hostname` 
    * set `local_fqdn_name`
    * set `common_logwatch_email`
* roles/mcmyadmin-setup/defaults.main.yml
    * set `mcmyadmin.admin_password`

### Installing

#### Preferred way to install Ansible

Ansible 2 is the latest stable, so we don't need to do anything fancy to get it. I prefer a virtual environment up and running and install dependencies on it. To install virtual environment we'll use Pip, which lets us install Python libraries in their own little environment that won't affect others (nor force us to install tools globally).

##### Install Pip on Debian / Ubuntu
```bash
sudo apt-get install -y python-pip
```

##### Install Pip on Mac OS X
```bash
brew install python
```

##### Use Pip to install virtualenv
```bash
# -U updates it if the package is already installed
sudo pip install -U virtualenv
```

##### Create a python virtual environment
```bash
virtualenv .venv
```

##### Enable the virtual environment
```bash
source .venv/bin/activate
```

#####  Then anything we install with pip will be inside that virtual environment
```bash
pip install -U ansible
```

## Running the tests

To run Ansible test with molecule you need first install dependencies into virtual environment

```bash
pip install molecule==1.25
pip install python-vagrant
```

Now you can run test manually via molecule

```bash
molecule [target]
create       Creates all instances defined in...
converge     Provisions all instances defined in...
idempotence  Provisions instances and parses output to...
```
or you can run the whole suite with command
```bash
make test
```
## Deployment

### Test Ansible Connection

We will test connectivity to our server.

#### Check connection before running `make init`
```bash
# ‘-k’ to ask Ansible to prompt you for an SSH password.
ansible -m ping minecraft -u root -k
```
#### Check connection after you've run `make init`
```bash
ansible -m ping minecraft -u minecraft --private-key=~/.ssh/minecraft_id_rsa
```

### Running the Playbooks

Now that you’ve established that you can connect to the server with Ansible, it is time to run the playbooks.

#### Running Playbooks with Makefile

The glue for running Ansible Playbooks is the makefile. The Makefile itself takes only one argument:

* DRYRUN: This is used by Ansible, when argument is set it will run selected playbook with --check option

```bash
make [target] [arguments]
init                           Initialize remote user
setup-server                   Common server setup
install-minecraft              Install Minecraft server
install-mcmyadmin              Install Minecraft Control Panel (McMyAdmin)
test                           Runs a complete test suite with molecule
```

#### Running all playbooks with check mode ("Dry Run")

When ansible-playbook is executed with --check it will not make any changes on remote systems. 

`python-apt must be installed on remote host to use check mode. If run normally it will be auto-installed.`

To run all playbooks with --check mode use make [target] DRYRUN=1

## Run Minecraft

Log in to your server via SSH.

```bash
ssh minecraft@YourServerIP -i ~/.ssh/minecraft_id_rsa
```

There are two ways running minecraft server. You can eather start the server without graphical user interface or you can start McMyAdmin which is one of the most popular Minecraft server control panels available. It boasts compatibility with third party mods, heavy focus on security and a sleek web interface for managing your server.

### Starting server without graphical user interface

To ensure that the Minecraft server runs independent of an SSH connection, execute run-minecraft.sh from within a GNU Screen session.

```bash
screen ~/minecraft-server/run-minecraft.sh
```

> To disconnect from the screen session without stopping the game server, press CTRL+a and then d. To resume the running screen session, use the command screen -r.

### Start McMyAdmin

Start a screen session for the McMyAdmin client.

```bash
screen -S mcma
```

Change into the McMyAdmin installation directory and start the program.

```bash
cd ~/mcmyadmin
./MCMA2_Linux_x86_64
```

> To exit McMyAdmin and return to the command line, enter /quit.

Browse to the McMyAdmin web interface by visiting http://YourServerIP:8080.

Log in with the username admin and the password that you provided in the ansible playbook variable `mcmyadmin.admin_password`.

## Versioning

I am using [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/loncarales/minecraft-server-ansible/tags).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
