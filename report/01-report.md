# Enterprise Linux Lab Report

- Student name: Thor Nicolaï
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-ThorNicolai>

Opzetten van een web-server door middel van Apache, MariaDB en wordpress.

## Test plan


 - [ ] On the host system, go to the local directory of your sme-project repository using git-bash

 - [ ] Use `vagrant status` to verify that no VM is created yet. If a VM already exists use `vagrant destroy -f`

 - [ ] Use `vagrant up pu004`, ensure that this command completes without any errors

 - [ ] Log in on the server using ssh `vagrant ssh pu004` and run the tests. These should all succeed.

		[vagrant@pu004 ~]$ sudo /vagrant/test/runbats.sh
		Running test /vagrant/test/common.bats
		 ✓ SELinux should be set to 'Enforcing'
		 ✓ Firewall should be enabled and running
		 ✓ EPEL repository should be available
		 ✓ Bash-completion should have been installed
		 ✓ bind-utils should have been installed
		 ✓ Git should have been installed
		 ✓ Nano should have been installed
		 ✓ Tree should have been installed
		 ✓ Vim-enhanced should have been installed
		 ✓ Wget should have been installed
		 ✓ Admin user thor should exist
		 ✓ An SSH key should have been installed for thor
		 ✓ Custom /etc/motd should have been installed

		13 tests, 0 failures
		Running test /vagrant/test/pu004/lamp.bats
		 ✓ The necessary packages should be installed
		 ✓ The Apache service should be running
		 ✓ The Apache service should be started at boot
		 ✓ The MariaDB service should be running
		 ✓ The MariaDB service should be started at boot
		 ✓ The SELinux status should be ‘enforcing’
		 ✓ Web traffic should pass through the firewall
		 ✓ Mariadb should have a database for Wordpress
		 ✓ The MariaDB user should have write
		 ✓ The website should be accessible through HTTP
		 ✓ The website should be accessible through HTTPS
		 ✓ The certificate should not be the default one
		 ✓ The Wordpress install page should be visible under http://192.0.2.50/wordpress/
		 ✓ MariaDB should not have a test database
		 ✓ MariaDB should not have anonymous users

		15 tests, 0 failures

 - [ ] After vagrant up (when the VM is not yet created), the install page of Wordpress should be visable if you use a browser from the host system to surf to https://192.0.2.50/wordpress/.

## Documentation

### site.yml changes

 - Add the roles `bertvv.httpd, bertvv.mariadb, bertvv.wordpress` in *site.yml*.

	![role add](https://i.imgur.com/gv7s221.png)

 - Install the role using the *scipts/role-deps.sh* command provided, this script should add a new roles folder inside your Ansible folder.

	![](https://i.imgur.com/UJXNwZN.png)

### pu004.yml changes

- Firstly we have to create a host_vars folder at the level of group_vars. In this folder we create the pu004.yml file.
- Our first lines will allow traffic to pass through the firewall

		rhbase_firewall_allow_services:
		  - http
		  - https

-  After this, we can start by implementing the mariadb role in this file . We start by assigning a root password, a user and his password.


		#Mariadb
		mariadb_databases:
		  - name: thordb

		mariadb_root_password: 'W2Fwwf'

		mariadb_users:
		  - name: thor
		    password: W2Fwwff
		    priv: 'thordb.*:ALL,GRANT'

- As follows we will implement the wordpress role.

		#Wordpress
		wordpress_database: thordb

		wordpress_user: thor

		wordpress_password: W2Fwwff
- For the httpd role we need to generate ssl_certificates, so our browser can connect over a safe https-connection.
We can generate these keys in our vm using `mod_ssl openssl`.


		# Generate private key
		openssl genrsa -out ca.key 2048

		# Generate CSR
		openssl req -new -key ca.key -out ca.csr

		# Generate Self Signed Key
		openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt

	![SSL certificaten genereren](https://i.imgur.com/Vb2Mo9c.png)

	> Note: We don't need the .csr file

	Now we can copy the created keys to new created files in the correct `files` folder on our host

	![enter image description here](https://i.imgur.com/CMF0lAH.png)

	 Now we can use the roles so that our host will be using these SSL certificates instead of the default ones. The first line allows `php` scripting, this is needed for wordpress.

		 #Apache
		httpd_scripting: 'php'

		httpd_ssl_certificate_file: lamp.crt

		httpd_ssl_certificate_key_file: lamp.key

- This should result in a *pu004.yml* file and a file structure like this
	![](https://i.imgur.com/cqmWsja.png)

### lamp.bats changes
- Lastly before you can run any of the tests, you need to modify the `rootpassword` for mariadb in the `lamp.bats` file, aswell as the `wordpress_database, wordpress_user, wordpress_password` for wordpress.

	![](https://i.imgur.com/kLGcxdJ.png)


## Test report


    vagrant status



![vagrant status](https://i.imgur.com/1nMhklr.png)

    vagrant up pu004

![Playbook complete](https://i.imgur.com/TqjiVOZ.png)

    vagrant ssh pu004

   ![ssh](https://i.imgur.com/tMBU3Jz.png)

	[vagrant@pu004 ~]$ sudo /vagrant/test/runbats.sh

![Succesvolle testen](https://i.imgur.com/MR097rf.png)

## Resources

 - [Anisble-Galaxy bertvv.rh-base](https://galaxy.ansible.com/bertvv/rh-base)
 - [Anisble-Galaxy bertvv.wordpress](https://galaxy.ansible.com/bertvv/wordpress)
 - [Anisble-Galaxy bertvv.httpd](https://galaxy.ansible.com/bertvv/httpd)
 - [Anisble-Galaxy bertvv.mariadb](https://galaxy.ansible.com/bertvv/mariadb)
 - [Github bertvv](https://github.com/bertvv/)
 - [Ansible - From Beginner To Pro.pdf](https://www.docdroid.net/P2tjiwb/ansible-from-beginner-to-pro.pdf)
