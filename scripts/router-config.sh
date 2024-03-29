#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

configure

# Fix for error "INIT: Id "TO" respawning too fast: disabled for 5 minutes"
delete system console device ttyS0

#
# Basis instellingen
#
set system host-name 'Router'
set service ssh port '22'

#
# IP instellingen
#

set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 description "WAN link"
set interfaces ethernet eth1 address 192.0.2.254/24
set interfaces ethernet eth1 description "DMZ"
set interfaces ethernet eth2 address 172.16.255.254/16
set interfaces ethernet eth2 description "internal"

#
# NAT
#

set nat source rule 10 description "Buitenwereld"
set nat source rule 10 outbound-interface 'eth0'
set nat source rule 10 source address 172.16.0.0/16
set nat source rule 10 translation address 'masquerade'

set nat source rule 20 description "DMZ"
set nat source rule 20 outbound-interface 'eth1'
set nat source rule 20 source address 172.16.0.0/16
set nat source rule 20 translation address 'masquerade'

#
# DNS
#

set service dns forwarding system

# stel de dns forwarding servers in voor het resolven in het domein
set service dns forwarding domain avalon.lan server 192.0.2.10
set service dns forwarding domain avalon.lan server 192.0.2.11

# dns forwarding voor internettoegang in privenetwerk
set service dns forwarding name-server 10.0.2.3

# 2 'interne' interfaces instellen als input poorten voor naar het internet te gaan
set service dns forwarding listen-on 'eth1'
set service dns forwarding listen-on 'eth2'

#
# NTP (Netwerk time protocol)
#
delete system ntp server 0.pool.ntp.org
delete system ntp server 1.pool.ntp.org
delete system ntp server 2.pool.ntp.org
set system ntp server 0.be.pool.ntp.org prefer
set system ntp server 1.be.pool.ntp.org
set system ntp server 2.be.pool.ntp.org
set system ntp server 3.be.pool.ntp.org
set system time-zone Europe/Brussels

# Make configuration changes persistent
commit
save

# Fix permissions on configuration
sudo chown -R root:vyattacfg /opt/vyatta/config/active

# vim: set ft=sh
