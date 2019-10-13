# Enterprise Linux Lab Report
- Student name: Thor Nicolaï
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-ThorNicolai>
In this assignment, the goal is to complete the network we've been building with a DHCP server for workstations and a router.
## Test plan
- [ ] On the host system, go to the local directory of your sme-project repository using git-bash
- [ ] Gebruik: `vagrant status` om er zeker van te zijn dat nog geen VM's zijn gecreerd, anders kan je ze verwijderen met: `vagrant destroy -f`
- [ ] Gebruik: `vagrant up`, zorg ervoor dat dit commando uitgevoerd wordt zonder errors.
- [ ] Via de VM moeten we kunnen inloggen, files accessen via FTP en SMB en de juiste rules moeten actief zijn.
- [ ] Het moet mogelijk zijn om naar avalon.lan/wordpress te surfen, zo testen we dns & webserver.
- [ ] De host moet de juiste DHCP instellingen hebben voor de NIC's
- [ ] Als laatste kunnen we kijken of we internettoegang hebben.
## Documentation
- We gaan eerst pr001 toevoegen aan onze opstelling. We gaan dus eerst volgende lijn toevoegen aan `vagrant-hosts.yml`:

        - name: pr001
          ip: 172.16.0.2
- We voegen deze host ook toe aan de site.yml, DHCP role wordt toegewezen.
        - hosts: pr001
          become: true
          roles:
            - bertvv.rh-base
            - bertvv.dhcp
- We voegen de roles toe aan onze roles folder door middel van: `./scripts/role-deps.sh`
![](https://i.imgur.com/xfUKB88.png)
- Maak in de map host_vars het bestand pr001.yml aan.
- Zoals altijd: eerst de firewall rules toevoegen:
        rhbase_firewall_allow_services:
          - dhcp
- DHCP configuratie: we maken gebruik van enkele globale variabelen voor lease times en domein naam. De DNS server kan deze server terugvinden via de router interface waar ons netwerk lokaal op zit aangesloten.
        dhcp_global_domain_name_servers:
          - 172.16.255.254
        dhcp_global_default_lease_time: 43200
        dhcp_global_max_lease_time: 43200 # 12 hrs
        dhcp_global_domain_name: avalon.lan
- Nu moeten we het subnet meegeven en ook het ip-adres van de router interface. Daarna geven we ook de pools in zodat de DHCP server weet welke adressen uit te delen. Later komen we terug op de deny en allow variable.
        dhcp_subnets:
          - ip: 172.16.0.0
            netmask: 255.255.0.0
            range_begin: 172.16.128.1
            range_end: 172.16.191.254
            deny: 'members of "vbox"'
          - ip: 172.16.0.0
            netmask: 255.255.0.0
            range_begin: 172.16.192.1
            range_end: 172.16.255.253
            allow: 'members of "vbox"'
- Vervolgens maken we een lege VM aan in VirtualBox, die we later gaan gebruiken als workstation. We stellen volgende NIC adapters in. We bewaren het MAC adres van de eerste Adapter.
![](https://i.imgur.com/HhXewIq.png)
- We moeten nog enkele extra instellingen meegeven, we maken eerst een global class aan, die we later dan toevoegen aan de juiste pools.

        dhcp_global_routers: 172.16.255.254
        dhcp_global_classes:
        - name: vbox
        match: 'match if binary-to-ascii(16,8,":",substring(hardware, 1, 3)) = "8:0:27"'

        dhcp_hosts:
        - name: werkstation
        mac: '08:00:27:66:5D:AA'   (geef hier het mac adres van NIC 1 in)
        ip: 172.16.128.10
- Nu krijgt onze VM de juiste instellingen
- De volgende stap zijn de instellingen voor de router, deze moeten we configureren in het router-config.sh bestand. Alvorens we dit doen installeren we de plugion voor VyOs voor vagrant door: `vagrant plugin install vagrant-vyos`
-  We starten met de globale instellingen in router-config.sh, bijvoorbeeld de naam van de router + de ssh poort die we openzetten.

        # hostname definieren
        set system host-name 'Router'
        # poort openzetten voor ssh
        set service ssh port '22'
- Set de interfaces zoals gevraagd:
    set interfaces ethernet eth0 address dhcp
    set interfaces ethernet eth0 description "WAN link"
    set interfaces ethernet eth1 address 192.0.2.254/24
    set interfaces ethernet eth1 description "DMZ"
    set interfaces ethernet eth2 address 172.16.255.254/16
    set interfaces ethernet eth2 description "internal"
- NAT rules toevoegen, private to external en private to public.
        set nat source rule 10 description "Van Intern naar buiten"
        set nat source rule 10 outbound-interface 'eth0'
        set nat source rule 10 source address 172.16.0.0/16
        set nat source rule 10 translation address 'masquerade'
        set nat source rule 20 description "Van Intern naar DMZ"
        set nat source rule 20 outbound-interface 'eth1'
        set nat source rule 20 source address 172.16.0.0/16
        set nat source rule 20 translation address 'masquerade'
- Als volgende geven we de DNS instellingen mee:
        set service dns forwarding system
        set service dns forwarding domain avalon.lan server 192.0.2.10
        set service dns forwarding domain avalon.lan server 192.0.2.11
        set service dns forwarding name-server 10.0.2.3
        set service dns forwarding listen-on 'eth1'
        set service dns forwarding listen-on 'eth2'
- Als network time protocol deleten we de standaarden en stellen we de belgische configuratie in:
        delete system ntp server 0.pool.ntp.org
        delete system ntp server 1.pool.ntp.org
        delete system ntp server 2.pool.ntp.org
        set system ntp server 0.be.pool.ntp.org prefer
        set system ntp server 1.be.pool.ntp.org
        set system ntp server 2.be.pool.ntp.org
        set system ntp server 3.be.pool.ntp.org
        set system time-zone Europe/Brussels
- Na de up en provision van de router zouden alle instellingen moeten werken voor het werkstation.
## Test report
Alle servers moeten runnen om alles te testen op uw workstation.
        vagrant up
Deze up moet zonder errors completen.
Eens alle servers zijn gestart kan je uw workstation ook starten.
- Bekijk de ip's van beide NIC's deze moeten uit de DHCP pool komen van de dhcp server.
![](https://i.imgur.com/Ci068A9.png)

![](https://i.imgur.com/YntEeSG.png)

- Er is internet aanwezig op de workstation.

![](https://i.imgur.com/pSQrmAE.png)

- Mijn workstation laat mij toe om avalon.lan/wordpress te openen.

![](https://i.imgur.com/4xn3gb8.png)

- Op mijn host kan ik wel aan de ftp files, op mijn workstation niet.


- SMB werkt op beide niet zover ik weet.
