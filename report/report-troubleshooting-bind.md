# Enterprise Linux Lab Report - Troubleshooting

- Student name: Thor Nicolaï
- Class/group: TIN-TI-3B (Gent)

## Instructions

- Write a detailed report in the "Report" section below (in Dutch or English)
- Use correct Markdown! Use fenced code blocks for commands and their output, terminal transcripts, ...
- The different phases in the bottom-up troubleshooting process are described in their own subsections (heading of level 3, i.e. starting with `###`) with the name of the phase as title.
- Every step is described in detail:
    - describe what is being tested
    - give the command, including options and arguments, needed to execute the test, or the absolute path to the configuration file to be verified
    - give the expected output of the command or content of the configuration file (only the relevant parts are sufficient!)
    - if the actual output is different from the one expected, explain the cause and describe how you fixed this by giving the exact commands or necessary changes to configuration files
- In the section "End result", describe the final state of the service:
    - copy/paste a transcript of running the acceptance tests
    - describe the result of accessing the service from the host system
    - describe any error messages that still remain

## Report

login: vagrant
pass: vagrant

![Inloggen en keyboard lay-out veranderen](https://i.imgur.com/sX824nF.png)


### Phase 1: Netwerk toegang

De host only adapter moet verbonden worden met het juiste Host only adapter netwerk.

Met `ip link` kijken we of alle interfaces juist staan en de UP state hebben.
De host only staat op down, deze zullen we moeten upbrengen.
Dit doen we aan de hand van het command: `sudo vi /etc/sysconfig/network-scripts/ifcfg-enp0s8`
Hier veranderen we ONBOOT naar  yes.

Reboor de VM met `reboot`

### Phase 2: Internet

Gebruik `ip r` om de adapters te controleren op ip addressen en voor gateways.
Hier zien we dat 10.0.2.2 alles naar buiten zal sturen van de VM, zoals verwacht.

DNS controleren van de NAT adapter doet je via: `sudo cat /etc/resolv.conf` hier zien we dat 10.0.2.3 voor onze NAT adapter klopt.

We kunnen pingen van onze host naar onze VM in de command promt met het commando: `ping 192.168.56.42`

Deze ping moet werken.

![ping](https://i.imgur.com/UMebQBH.png)
### Phase 3: Transport

Welke services draaien correct, named / network en firewalld controleren.

Commando: `sudo systemctl status named/network/firewalld`

Bij het commando voor named services krijgen we een fail terug. Dit wil zeggen dat in de /etc/named.conf file of de zonebestanden nog fouten staan van syntax.
Dit lossen we op in Phase 4: Applicatie

Eens de bovenstaande problemen opgelost zijn, herstart je de service van named: `sudo sytemctl restart named`

Controleren of de juiste poorten open staan.
met het commando: `sudo ss -tulpn`
Hier moeten we zeker 53 zien die openstaat, ssh kan je ook controleren.

Firewall instellingen controleren met `sudo firewall-cmd --list-all`, hier moeten de 2 interfaces en dns (53/tcp) in staan.
Als dit niet compleet juist is kan je de dns service activeren en permanent aanzetten met: `sudo firewalld-cmd --add-serice=dns` en `sudo firewalld-cmd --add-serice=dns --permanent`

herstart de service `sudo systemctl restart firewalld`

### Phase 4: Applicatie

We kijken eerst naar het bestand `sudo vi /etc/named.conf`, `listen-on port 53 { 127.0.0.1; };` moet `listen-on port 53 { any; };` worden.

Ook is er een zone verkeerd gedefinieerd deze kunnen we veranderen naar
```
zone "56.168.192.in-addr.arpa" IN {
  type master;
  file "192.168.56.in-addr.arpa";
  notify yes;
  allow-update { none; };
};
```
In vi kan je je wijzigingen opslaan met `ESC ; :wq ; ENTER`

Als 2e kijken we naar `sudo vi /var/named/cynalco.com`. Hier voegen we de tweede nameserver toe:  `IN NS tamatama.cynalco.com.` alsook
```
butterfree           IN  A      192.168.56.12
db1                  IN  CNAME  butterfree
beedle               IN  A      192.168.56.13
db2                  IN  CNAME  beedle
``` 
en
`files IN CNAME mankey`

Hieronder zie je een screenshot van hoe de syntax eruit moet zien:
![cynalco.com](https://i.imgur.com/UUkVqBA.png)
  
Als laatste passen we de `sudo vi /var/named/192.168.56.in-addr.arpa` file aan.

Hieronder zie je hoe de juiste file eruit ziet: ![192.168.56.in-addr.arpa](https://i.imgur.com/92nielF.png)
  
Met `sudo named-checkconf` 'file' kan je steeds de configuratie checken.

Keer nu terug naar phase 3 om de named service te herstarten.


## End result

Run de acceptatietesten met: `./acceptance_test.bats`

Hier is het resultaat:
  
![](https://i.imgur.com/9r28olZ.png)
  
Toon aan dat je DNS requests vanop je host naar de VM beantwoord worden:

![](https://i.imgur.com/tBDDEEi.png)



## Resources

List all sources of useful information that you encountered while completing this assignment: books, manuals, HOWTO's, blog posts, etc.
