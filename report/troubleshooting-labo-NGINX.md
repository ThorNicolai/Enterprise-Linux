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

### Phase 1: VM starten
Start de vm door het ova bestand in te laden in VirtualBox. Inloggen kan via vagrant/vagrant.

### Phase 2: Netwerktoegang laag

Test de kabels, zijn de netwerkadapters aangezet in de VM.
Het commando `ip link` toont of de ethernet interfaces up zijn.

### Phase 3: Internet laag

Check de ip's van de adapters met `ip a`

Check de default gateway met `ip r`

Check DNS-server met `cat /etc/resolv.conf`

Ping naar de DG met: `ping -c 4 10.0.2.2`
Ping naar de DNS server met: `ping -c 4 10.0.2.3`

### Phase 4 Transport & Application laag

Kijk of nginx is running met: `sudo systemctl status nginx`
Als die **Inactive (dead)** dan is deze niet running
Probeer nginx.service te starten door: `sudo systemctl start nginx.service`

We krijgen een fout, er is een verkeerde file meegegeven in de config.

Gebruik: `sudo vi /etc/nginx/nginx.conf` om deze config file te editen.
Verander hier: `ssl_certificate /etc/pki/tls/certs/nignx.pem` naar `ssl_certificate /etc/pki/tls/certs/nginx.pem`

Probeer de service nogmaals te starten met: `sudo systemctl start nginx`
Check de status: `systemctl status nginx`
Enable de service met: `sudo systemctl enable nginx`

Check of de juiste poorten open staan:
Gebruik `sudo ss -tulpn`
Nginx heeft poort 80 en 8443
Gebruik `sudo vi /etc/nginx/nginx.conf` om de poorten te veranderen:

```
listen 8443 ssl;
listen[::]:8443 ssl;

```
naar

```
listen 443 ssl;
listen[::]:443 ssl;

```

 herstart de nginx service met: `sudo systemctl restart nginx`
  Check de poorten opnieuw met `sudo ss -tulpn`

Voor de firewall settings:
Run `sudo firewall-cmd --addservice=https` om de regel toe te voegen en  `sudo firewall-cmd --addservice=https --permanent` om permanent toe te voegen.
Voeg ook nog de juiste poorten toe:
```
sudo firewall-cmd --add-port=80/tcp
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --add-port=443/tcp
sudo firewall-cmd --add-port=443/tcp --permanent
```
### Phase 5 SeLinux

Run `sudo setsebool httpd_can_network_connect on` om traffic toe te laten.

## End result
Surfen van de host geeft ons: `Keep calm and vagrant up`

Running `./runbats.sh` geeft volgende output:

	Running test /home/vagrant/01-	whitebox.bats
	¤ The SELinux status should be 'enforcing'
	¤ The firewall should be running
	¤ Apache should not be installed
	¤ Apache should not be running

	4 tests, 0 failures
	Running test /home//vagrant/02-blackbox.bats
	¤ The webserver host should be reachable
	¤ The website should be accessible through HTTP
	¤ The website should be accessible through HTTPS

	3 test, 0 failures

## Resources
[Basics commands Brussel for EL7 - Bert vv](https://bertvv.github.io/presentation-el7-basics/)
[Troubleshooting slides van Enterprise Linux](https://hogenttin.github.io/elnx-syllabus/troubleshooting/#/title-slide)
