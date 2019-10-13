# Enterprise Linux Lab Report

- Student name: Thor Nicolaï
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-ThorNicolai>

Een DNS-server opzetten en testen door middel van BIND.

## Test plan pu001 (Master)

- [ ] On the host system, go to the local directory of your sme-project repository using git-bash

- [ ] Use `vagrant status` to verify that no VM is created yet. If a VM already exists use `vagrant destroy -f`

- [ ] Use `vagrant up`, ensure that this command completes without any errors

- [ ] Log in on the server using ssh `vagrant ssh pu001` and run the tests. These should all succeed.

		[vagrant@pu001 ~]$ sudo /vagrant/test/runbats.sh
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
		Running test /vagrant/test/pu001/masterdns.bats
		 ✓ The
		 ✓ The main config file should be syntactically correct
		 ✓ The forward zone file should be syntactically correct
		 ✓ The reverse zone files should be syntactically correct
		 ✓ The service should be running
		 ✓ Forward lookups public servers
		 ✓ Forward lookups private servers
		 ✓ Reverse lookups public servers
		 ✓ Reverse lookups private servers
		 ✓ Alias lookups public servers
		 ✓ Alias lookups private servers
		 ✓ NS record lookup
		 ✓ Mail server lookup

		13 tests, 0 failures

## Test plan pu002 (Slave)

- [ ] On the host system, go to the local directory of your sme-project repository using git-bash

- [ ] Use `vagrant status` to verify that no VM is created yet. If a VM already exists use `vagrant destroy -f`

- [ ] Use `vagrant up`, ensure that this command completes without any errors

- [ ] Log in on the server using ssh `vagrant ssh pu002` and run the tests. These should all succeed.

		[vagrant@pu002 ~]$ sudo /vagrant/test/runbats.sh
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
		Running test /vagrant/test/pu002/slavedns.bats
		 ✓ The
		 ✓ The main config file should be syntactically correct
		 ✓ The server should be set up as a slave
		 ✓ The server should forward requests to the master server
		 ✓ There should not be a forward zone file
		 ✓ The service should be running
		 ✓ Forward lookups public servers
		 ✓ Forward lookups private servers
		 ✓ Reverse lookups public servers
		 ✓ Reverse lookups private servers
		 ✓ Alias lookups public servers
		 ✓ Alias lookups private servers
		 ✓ NS record lookup
		 ✓ Mail server lookup

		14 tests, 0 failures

## Documentatie

- Begin met de DNS servers te initialiseren in de vagrant-hosts.yml file zodat ze ook zullen gestart worden bij vagrant up:

		- name: pu001 #Primary DNS
		  ip: 192.0.2.10

		- name: pu002 #Secondary DNS
		  ip: 192.0.2.11

- Voeg de rollen `bertvv.rh-base, bertvv.bind` toe aan pu001 en pu002 in de master-playbook (site.yml).

![pu001 & pu002 in site.yml](https://i.imgur.com/rY050aO.png)
- We voegen de roles toe aan onze roles folder doormiddel van het commando: `./scripts/role-deps.sh`

![roles installeren](https://i.imgur.com/bt1hIr0.png)
- Voor onze MASTER dns, pu001, zullen we de noodzakelijke dingen eerst instellen zoals het domein, de zone-netwerken, de name servers en mail servers aanwijzen en alle hosts oplijsten met aliases.

		bind_zone_domains:
		 - name: avalon.lan
		   hosts:
		     - name: pu001
		       ip: 192.0.2.10
		       aliases:
		         - ns1
		     - name: pu002
		       ip: 192.0.2.11
		       aliases:
		         - ns2
		     - name: pu003
		       ip: 192.0.2.20
		       aliases:
		         - mail
		     - name: pu004
		       ip: 192.0.2.50
		       aliases:
		         - www
		     - name: pr001
		       ip: 172.16.0.2
		       aliases:
		         - dhcp
		     - name: pr002
		       ip: 172.16.0.3
		       aliases:
		         - directory
		     - name: pr010
		       ip: 172.16.0.10
		       aliases:
		         - inside
		     - name: pr011
		       ip: 172.16.0.11
		       aliases:
		         - files
		   networks:
		     - '192.0.2'
		     - '172.16'
		   name_servers:
		     - pu001
		     - pu002
		   mail_servers:
		     - name: pu003
		       preference: 10

- We zorgen ervoor dat onze DNS server ook luistert naar alle ipv4-adressen:

		bind_listen_ipv4:
		    - any

- We zorgen ervoor da Queries zijn toegelaten naar onze DNS server

		bind_allow_query:
		    - any

- We zorgen dat de juiste poort open staat voor de firewall:

		rhbase_firewall_allow_services:
		 - dns

- We specificeren het ip adres van onze master:

		bind_zone_master_server_ip: 192.0.2.10

- We voegen nog een ACL list toe:

		bind_acls:
		 - name: acl1
		   match_list:
		     - 192.0.2.0/24
		     - 172.16.0.0/16


## Test report pu001

    vagrant up
    vagrant ssh pu001
    [vagrant@pu001 ~]$ sudo /vagrant/test/runbats.sh

![](https://i.imgur.com/lK1ksC9.png)

## Test report pu002
Een extra `vagrant provision` na `vagrant up` kan nodig zijn om de bind zones helemaal goed over te nemen van onze master DNS.

    vagrant up
    *vagrant provision*
    vagrant ssh pu002
    [vagrant@pu002 ~]$ sudo /vagrant/test/runbats.sh
   ![](https://i.imgur.com/HxpY0gh.png)

Als beide goed ingesteld zijn dan zouden deze testen zonder fouten moeten kunnen slagen.
