# Enterprise Linux Lab Report

- Student name: Thor Nicolaï
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-ThorNicolai>

Basis server setup, algemene host requirements implementeren en kick-off van het project.

## Test plan

 - [ ] On the host system, go to the local directory of your sme-project repository using git-bash

 - [ ] Use `vagrant status` to verify that no VM is created yet. If a VM already exists use `vagrant destroy -f`

 - [ ] Use `vagrant up pu004`, ensure that this command completes without any errors

 - [ ] Log in on the server using ssh `vagrant ssh pu004` and run the tests. These should all succeed.
		 ![ssh and testing](https://i.imgur.com/HmK5iZC.png)


> Any other test for the LAMP-stack might fail here, this is does not concern assignment-00

## Documentation

- Complete the setup described in the syllabus: [Syllabus Download](https://github.com/HoGentTIN/elnx-syllabus/releases/download/aj1819/syllabus-elnx.pdf)
 - Do general research about the rh-base role and ansible, use the resources at the bottom of this page.

 - Run vagrant up for the first time in your project repository

### site.yml changes

 - Add the role bertvv.rh-base in *site.yml*.

	![role add](https://i.imgur.com/VNnURNS.png)

 - Install the role using the *scipts/role-deps.sh* command provided, this script should add a new roles folder inside your Ansible folder.

![roles install](https://i.imgur.com/Z2wd7wf.png)

### all.yml changes
 - The EPEL repository must be installed


	    rhbase_repositories:
	      - epel-release


 - The following packages must be installed on all servers: bash-completion, bind-utils, git, nano, tree, vim-enhanced, wget


		rhbase_install_packages:
		  - bash-completion
		  - bind-utils
		  - git
		  - nano
		  - tree
		  - vim-enhanced
		  - wget

 - Add an admin user

		rhbase_users:
		  - name: thor
		    comment: Administrathor
		    password: PASSWORD
		    groups:
		      - wheel

 - Generate a user ssh-keypair using `ssh-keygen`, next take the generated public key and add it to *all.yml* under `rhbase_ssh_key` and assign the `rhbase_ssh_user` as your created user `thor`.

 - Finally we enable Message of the day using: `rhbase_motd: true`

	![](https://i.imgur.com/JpQ9VAp.png)

## Test report

    vagrant status



![vagrant status](https://i.imgur.com/1nMhklr.png)

    vagrant up pu004

![Playbook complete](https://i.imgur.com/TqjiVOZ.png)

    vagrant ssh pu004

   ![ssh](https://i.imgur.com/tMBU3Jz.png)

    sudo /vagrant/test/runbats.sh

   ![Succesvolle testen](https://i.imgur.com/PX2wlpW.png)

## Resources

 - [Anisble-Galaxy bertvv rh-base](https://galaxy.ansible.com/bertvv/rh-base)
 - [Github bertvv rh-base](https://github.com/bertvv/ansible-role-rh-base)
 - [Ansible - From Beginner To Pro.pdf](https://www.docdroid.net/P2tjiwb/ansible-from-beginner-to-pro.pdf)
