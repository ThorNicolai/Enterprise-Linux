
# Enterprise Linux: Actualiteit - Nieuwe techniek

- Student name: Thor Nicolaï
- [Github repo](https://github.com/HoGentTIN/elnx-1819-sme-ThorNicolai)


### Fail2Ban
**Fail2ban** scans log files (e.g. /var/log/apache/error_log) and bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc. Generally Fail2Ban is then used to update firewall rules to reject the IP addresses for a specified amount of time, although any arbitrary other **action** (e.g. sending an email) could also be configured. Out of the box Fail2Ban comes with **filters** for various services (apache, courier, ssh, etc).

Fail2Ban is able to reduce the rate of incorrect authentications attempts however it cannot eliminate the risk that weak authentication presents. Configure services to use only two factor or public/private authentication mechanisms if you really want to protect services.

## Test Plan

### Ansible versnellen:
Om de versnelling in ansible te testen kan je de playbooken timen eens ze pipelining en control persist aan hebben staan vs wanneer ze dit niet hadden aanstaan.

### Fail2ban
- [ ] On the host system, go to the local directory of your sme-project repository using git-bash
- [ ] Gebruik: `vagrant status` om er zeker van te zijn dat nog geen VM's zijn gecreerd, anders kan je ze verwijderen met: `vagrant destroy -f`
- [ ] Gebruik: `vagrant up pu004`, zorg ervoor dat dit commando uitgevoerd wordt zonder errors.

open een terminal en voer volgend commando uit:

    sudo tail -f /var/log/fail2ban.log

open nog een terminal en probeer ssh request te doen falen door een verkeerd wachtwoord in te geven.

	ssh stevenh@192.0.2.50



## Procedure
## Ansible versnellen


Door in de **ansible.cfg** file een wijzig aan te brengen kunnen we timen hoe lang elke stap duurt.

DISCLAIMER: DIT WERKTE VOOR MIJ NIET CONSISTENT.

![Profile tasks](https://i.imgur.com/ZnD6qHA.png)
Door pipelining op true te zetten in **ansible.cfg** kunnen we ervoor zorgen dat er maar een beperkt aantal ssh verbindingen tegelijkertijd aanwezig zijn op onze host.

	[ssh_connection]
	pipelining = True

ControlPersist is een SSH-functie die de verbinding met de server open houdt als een socket, klaar voor hergebruik tussen aanroepen. Als deze functie is ingeschakeld, kan Ansible voorkomen dat voor elke taak de verbinding met de hosts wordt hersteld.

	[ssh_connection]
	pipelining = True
	control_path = /tmp/ansible-ssh-%%h-%%p-%%r


## Fail2Ban

In de site.yml werd de role fail2ban van nbigot toegevoegd.

	# site.yml
	---
	- hosts: pu004 #WEB
	  become: true
	                    #Assign the needed roles for this VM
	  roles:
	    - bertvv.rh-base
	    - bertvv.mariadb
	    - bertvv.httpd
	    - bertvv.wordpress
	    - nbigot.fail2ban

Hun het script om roles lokaal binnen te halen: scripts/role-deps.sh

In pu004.yml kan je nu al de mogelijke parameters meegeven die fail2ban ondersteund:


	#fail2ban config
	fail2ban_bantime: 60
	fail2ban_findtime: 60
	fail2ban_maxretry: 5




**Findtime** wordt er gecontrolleerd of de ssh request binnen de 60 seconden de maxretry waarde heeft bereikt, hier 5 pogingen. Als dat zo is dan zal het IP addres geblokkeerd worden voor 60 seconden (de **bantime**).


## Test report
### Ansible versnellen:
De versnelling van ssh_pipelining is duidelijk voelbaar in de uitvoeringstijd.

### Fail2ban

Als men een fout wachtwoord ingeeft bij een ssh reques wordt men effectief gebanned voor de aangegeven tijd in de ansible role van fail2ban.

![Fail2ban DEMO](https://i.imgur.com/WZLZYrY.png)


## Resources

[Profile Ansible Playbook](https://sketchingdev.co.uk/blog/profiling-ansible-playbooks-to-csv.html)

[Fail2Ban](https://www.fail2ban.org/wiki/index.php/Main_Page)

[Using Fail2Ban](https://www.linode.com/docs/security/using-fail2ban-for-security/)
