# Enterprise Linux: Docker Proof-of-Concept

- Student name: Thor Nicolaï
- [Github repo](https://github.com/HoGentTIN/elnx-1819-sme-ThorNicolai/tree/solution)

## Test plan

- [ ] On the host system, go to the local directory of your sme-project repository using git-bash
- [ ] Gebruik: `vagrant status` om er zeker van te zijn dat nog geen VM's zijn gecreerd, anders kan je ze verwijderen met: `vagrant destroy -f`
- [ ] Gebruik: `vagrant up dockerhost`, zorg ervoor dat dit commando uitgevoerd wordt zonder errors.

- [ ] **Kijk of de nodige onderdelen zijn geïntegreerd:**

	 - Database-container met MariaDB of MySQL
	 - Webapplicatie-container(s) met Drupal
	-  Een monitoringsysteem voor het opvolgen van wat er gebeurt in de containers (bv. cAdvisor)
	- (Optioneel): Een load-balancer (bv. HAProxy) die het netwerkverkeer verdeelt over meerdere webapplicatiecontainers
	-  (Optioneel): Kan je er voor zorgen dat de Drupal site persistent is? D.w.z. dat als je de database- én webapplicatiecontainers vernietigt, je de site toch kan reproduceren? Je zal hiervoor wellicht volumes moeten gebruiken voor de storage van de database.

Dit kunnen we doen door naar de verschillende ip's/poorten te surfen vanaf ons hostsysteem.

http://192.0.2.51:9000/#/containers --> Portainer Interface (admin/admin123)

http://192.0.2.51:9090/ --> Cockpit interface

http://192.0.2.51:8000 --> Drupal landingpage

http://192.9.2.51:8080 --> cAdvisor

Voor onze database kunnen we dit doen door de drupal page te doorlopen en hier de database mee te geven. Dit zal enkel lukken als de database correct werkt.

## Procedure

We gaan eerst dockerhost toevoegen aan onze opstelling. We gaan dus eerst volgende lijn toevoegen aan vagrant-hosts.yml:

	- name: dockerhost
	  ip: 192.0.2.51
	  box: bento/fedora-29

We maken gebruik van de volgende repository als basis voor onze docker containers en omgeving: [BERTVV DOCKER SANDBOX](https://github.com/bertvv/docker-sandbox).
Hiervan nemen we de provisioning folder en plaatsen we er een docker-compose.yml file in. Deze zullen we gebruiken om alle services te initialiseren.

**docker-compose**

	 version: '3'

	services:

	  Drupal:
	    image: drupal
	    container_name: "Drupal"
	    environment: #SETTING DRUPAL
	      DRUPAL_PROFILE: standard
	      DRUPAL_SITE_NAME: DRUPAL
	      DRUPAL_USER: admin
	      DRUPAL_PASS: admin
	    ports:
	      - "8000:80"
	    links:
	      - database:database
	    restart: always

	  database:
	    image: mariadb
	    container_name: "Mariadb"
	    environment: #SETTING MARIADB
	      MYSQL_USER: admin
	      MYSQL_PASSWORD: admin
	      MYSQL_DATABASE: drupaldb
	      MYSQL_ROOT_PASSWORD: admin
	    ports:
	      - "3306:3306"
	    restart: always

	  cadvisor:
	    image: google/cadvisor:latest
	    container_name: "cAdvisor"
	    ports:
	      - "8080:8080"
	    volumes:
	    - /:/rootfs:ro
	    - /var/run:/var/run:rw
	    - /sys:/sys:ro
	    - /var/lib/docker/:/var/lib/docker:ro

	#Initial setup with portainer
	  portainer:
	    image: portainer/portainer
	    restart: always
	    container_name: "Portainer"
	    volumes:
	      - /var/run/docker.sock:/var/run/docker.sock
	      - /opt/portainer/data:/data
	    ports:
	      - "9000:9000"


Bij de Vagrantfile verwijzen we naar de provisioningfolder om daar het .sh script te runnen dat de naam heeft van onze host:

	if node.vm.hostname == "dockerhost"
	         node.vm.provision 'shell', path: 'provisioning/' + host['name']+ '.sh'
	  end

Bij de dockerhost.sh file voegen we nog een automatisatie regel toe zodat docker-compose wordt uitgevoerd nadat dit script is aangeroepen van de vagrantfile (hierboven).

	info "Executing Docker-compose up"

	cd /vagrant/provisioning
	docker-compose up -d
	cd



### Loadtesting with Artillery

We use a **loadtest.yml** file to test our Drupal webapplication.

    config:
	  target: 'http://192.0.2.51:8000'
	  phases:
	    - duration: 60
	      arrivalRate: 20
	  defaults:
	    headers:
	      x-my-service-auth: '987401838271002188298567'
	scenarios:
	  - flow:
	    - get:
	        url: "/docs"

We can start this test by installing Artillery on our host system and running the loadtest.yml file I created.

    artillery run loadtest.yml

The output will be along the lines of this picture:

![Artillery running](https://i.imgur.com/YjC4i2m.png)


**Extra info:**

-   `Scenarios launched` is the number of virtual users created in the preceding 10 seconds (or in total)
-   `Scenarios completed` is the number of virtual users that completed their scenarios in the preceding 10 seconds (or in the whole test). Note: this is the number of completed sessions, not the number of sessions started and completed in a 10 second interval.
-   `Requests completed` is the number of HTTP requests and responses or WebSocket messages sent
-   `RPS sent` is the average number of requests per second completed in the preceding 10 seconds (or throughout the test)
-   `Request latency` is in milliseconds, and p95 and p99 values are the 95th and 99th [percentile](https://en.wikipedia.org/wiki/Percentile) values (a request latency `p99` value of 500ms means that 99 out of 100 requests took 500ms or less to complete).
-   `Codes` provides the breakdown of HTTP response codes received.

## Test Report

vagrant up:

![enter image description here](https://i.postimg.cc/W12qhKG8/DOCKERHOST-FINAL.png)

Cockpit:
![enter image description here](https://i.postimg.cc/q7W7XZ39/COCKPIT.png)
cAdvisor:

![enter image description here](https://i.imgur.com/S1CGu5k.png)

Portainer:

![Portainer](https://i.imgur.com/lX60qH6.png)

Drupal & mariadb:

![enter image description here](https://i.postimg.cc/BbKD92q8/DRUPAL-1.png)
![enter image description here](https://i.postimg.cc/6TxZ9T3M/DRUPAL-2.png)
![enter image description here](https://i.postimg.cc/YqFz1Jmw/DRUPAL-3.png)
![enter image description here](https://i.postimg.cc/XNp8vZjq/DRUPAL-4.png)
![enter image description here](https://i.postimg.cc/y8zXnvF3/DRUPAL-5.png)
![enter image description here](https://i.postimg.cc/DfHc420g/DRUPAL-6.png)

![mariadb](https://i.imgur.com/8Q98DEr.png)

## Resources

[Bertvv docker sandbox](https://github.com/bertvv/docker-sandbox)

[Docker Hub](https://hub.docker.com/)

[Google cAdvisor](https://github.com/google/cadvisor)

[Ansible configure](https://docs.ansible.com/ansible/latest/installation_guide/intro_configuration.html)

[Artillery Loadtesting tool](https://artillery.io/docs/getting-started/#what-our-test-does)
