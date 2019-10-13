# Enterprise Linux Lab Report

- Student name: Thor Nicolaï
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-ThorNicolai>


The goal of this lab assignment is to set up a file share suitable for an SME. It can be accessed through two separate network protocols:

- SMB (Windows network neighbourhood)
- FTP

## Test plan
- [ ] On the host system, go to the local directory of your sme-project repository using git-bash

- [ ] Gebruik: `vagrant status` om er zeker van te zijn dat nog geen VM's zijn gecreerd, anders kan je ze verwijderen met: `vagrant destroy -f`

- [ ] Gebruik: `vagrant up`, zorg ervoor dat dit commando uitgevoerd wordt zonder errors.

- [ ] Log in op de server door middel van ssh: `vagrant ssh pr011` en run de test (zorg ervoor dat alle 'skips' verwijderd zijn uit de testfile). Deze zouden allemaal moeten slagen:

		[vagrant@pr011 ~]$ sudo /vagrant/test/runbats.sh
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
		Running test /vagrant/test/pr011/samba.bats
		✓ The ’nmblookup’ command should be installed
		✓ The ’smbclient’ command should be installed
		✓ The Samba service should be running
		✓ The Samba service should be enabled at boot
		✓ The WinBind service should be running
		✓ The WinBind service should be enabled at boot
		✓ The SELinux status should be ‘enforcing’
		✓ Samba traffic should pass through the firewall
		✓ Check existence of users
		✓ Checks shell access of users
		✓ Samba configuration should be syntactically correct
		✓ NetBIOS name resolution should work
		✓ read access for share ‘public’
		✓ write access for share ‘public’
		✓ read access for share ‘management’
		✓ write access for share ‘management’
		✓ read access for share ‘technical’
		✓ write access for share ‘technical’
		✓ read access for share ‘sales’
		✓ write access for share ‘sales’
		✓ read access for share ‘it’
		✓ write access for share ‘it’

		22 tests, 0 failures
		Running test /vagrant/test/pr011/vsftp.bats
		✓ VSFTPD service should be running
		✓ VSFTPD service should be enabled at boot
		✓ The ’curl’ command should be installed
		✓ The SELinux status should be ‘enforcing’
		✓ FTP traffic should pass through the firewall
		✓ VSFTPD configuration should be syntactically correct
		✓ Anonymous user should not be able to see shares
		✓ read access for share ‘public’
		✓ write access for share ‘public’
		✓ read access for share ‘management’
		✓ write access for share ‘management’
		✓ read access for share ‘technical’
		✓ write access for share ‘technical’
		✓ read access for share ‘sales’
		✓ write access for share ‘sales’
		✓ read access for share ‘it’
		✓ write access for share ‘it’

		17 tests, 0 failures

- [ ] Test de mogelijkheid om naar de bestanden te surfen en je in te loggen met user en password voor zowel ftp als smb.


## Documentatie

-  We voegen pr011 toe aan de `vagrant-hosts.yml`.

		- name: pr011
		  ip: 172.16.0.11

-  We gaan terug in de site.yml deze host toevoegen, en de juiste rollen toevoegen.

		- hosts: pr011
		  become: true
		  roles:
		    - bertvv.rh-base
		    - bertvv.samba
		    - bertvv.vsftpd

- We voegen de roles toe aan onze roles folder door middel van: `./scripts/role-deps.sh`

![](https://i.imgur.com/xfUKB88.png)

- Maak een `pr011.yml` bestand aan in de map host_vars
-  Eerst zullen we de regels voor de firewall daemon toevoegen:

		rhbase_firewall_allow_services:
		  - samba
		  - samba-client
		  - ftp

- Voor de basis-instellingen van Samba voegen we een NETBIOS naam (FILES) toe en de workgroup (AVALON). We specificeren waar de directories van de shares worden aangemaakt. We laten ook toe dat alle gebruikers hun home-map kunnen zien. Ook worden printers niet geshared over het netwerk.

		samba_netbios_name: FILES
		samba_workgroup: AVALON
		samba_shares_root: /srv/shares
		samba_load_home: true
		samba_load_printers: false

- Vervolgens maken we alle shares aandie moeten bestaan op de server voor samba. We stellen de naam in, een optionele comment, de bijhorende groep users en welke users er read en write toegang hebben. Directory mode zorgt ervoor dat enkel de user en groepen aan deze share kunnen en niet de other-group.

		samba_shares:
		    - name: public
		      comment: 'publieke share'
		      public: yes
		      write_list: +users
		      valid_users: +users
		      group: users
		      setype: public_content_t
		    - name: management
		      comment: 'Only readable/writeable by management'
		      valid_users: +management
		      write_list: +management
		      group: management
		      directory_mode: '0770'
		    - name: technical
		      comment: 'visible for employees outside of their unit'
		      group: technical
		      valid_users: +management,+sales,+it,+technical
		      write_list: +technical
		      directory_mode: '0770'
		    - name: sales
		      comment: 'visible to management, but not writeable'
		      group: sales
		      valid_users: +sales, +management
		      write_list: +sales
		      directory_mode: '0770'
		    - name: it
		      comment: 'visible to management, but not writeable'
		      group: it
		      valid_users: +management, +it
		      write_list: +it
		      directory_mode: '0770'

- Als laatste voor SAMBA zullen we de users aanmaken, zoals gevraag voor dit bedrijfsnetwerk.

		samba_users:
		    - name: stevenh
		      password: stevenh
		    - name: stevenv
		      password: stevenv
		    - name: leend
		      password: leend
		    - name: svena
		      password: svena
		    - name: nehirb
		      password: nehirb
		    - name: alexanderd
		      password: alexanderd
		    - name: krisv
		      password: krisv
		    - name: benoitp
		      password: benoitp
		    - name: anc
		      password: anc
		    - name: elenaa
		      password: elenaa
		    - name: evyt
		      password: evyt
		    - name: christophev
		      password: christophev
		    - name: stefaanv
		      password: stefaanv
		    - name: thor
		      password: thor

 Om samba deze users nu te kunnen laten gebruiken moeten we de echte users hier voor aanmaken, want de samba users zijn hieraan gekoppeld. Zorg ervoor dat ze een secure password hebben.
Dit kan door de rhbase_users te definiëren:

	rhbase_users:
	  - name: alexanderd
	    comment: 'Alexander De Coninck'
	    groups:
	       - technical
	       - users
	    password: '$6$G.S6QQnyZoZoBBl9$MHM/u/6Zo0U1IoIKfCaGv1yF.f4GV.dIqThHahGERYfXyJix5dZQ5i75cHSrPx0RogRfaWR5FA4AmsDmpHIp.1'
	    shell: /sbin/nologin

	  - name: anc
	    comment: 'An Coppens'
	    groups:
	       - technical
	       - users
	    password: '$6$7FUVRzkNOXNFtXr9$pL0h4ja9SryCH8W.nGM1EPtM99tpSWMWQHQUWbYtyChHc8s.TkEbE5AinRf.qz3Ak43yj0V5YqNMMkH5yNPgQ0'
	    shell: /sbin/nologin

	  - name: benoitp
	    comment: 'Benoit Pluquet'
	    groups:
	       - sales
	       - users
	    password: '$6$MHhla0oiq3oWrGWD$QYDy/CRlMq31hzzLzrByII0YHz7fSc4aswm9KXkMcM2xz9Xv4VQ8/v95N8tkrKaz/LUYx5zy9tSBlclAYhxbC0'
	    shell: /sbin/nologin
	    .....
	    ...



- Nu werkt onze samba-server en kunnen we over naar de configuratie van `VSFTPD`.

- Voor vsftpd zorgen we ervoor dat de root dezelfde is als de Samba-share zodat ze dezelfde directories aanspreken. Ook laten we geen gasten toe tot de shares door anonymous op false te zetten.

		vsftpd_anonymous_enable: false
		vsftpd_local_enable: true
		vsftpd_local_root: /srv/shares

- Vervolgens zullen we doormiddel van ACL's zorgen dat iedere afdeling aan de juiste shares kan, beeindigd door een restart van vsftpd. (dit doe je bij pr011 in site.yml)

		post_tasks:
		    - name: ACL 4 Management
		      acl:
		        path: /srv/shares/management
		        entity: management
		        etype: group
		        permissions: r-x
		        state: present
		    - name: ACL 4 technical management
		      acl:
		        path: /srv/shares/technical
		        entity: sales
		        etype: group
		        permissions: r-x
		        state: present
		        ....
		        ...


## Test report

	vagrant up
	vagrant ssh pr011
	[vagrant@pr011 ~]$ sudo /vagrant/test/runbats.sh

![](https://i.imgur.com/WalQzsh.png)


Ook op onze client kunnen we de files bereiken met de admin user:  thor

![enter image description here](https://i.imgur.com/MnYlxmF.png)
