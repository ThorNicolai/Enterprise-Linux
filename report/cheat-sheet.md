# Cheat sheets and checklists

- Student name: Thor Nicolaï
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-ThorNicolai>

**Ik heb doorheen het jaar gebruik gemaakt van mijn handgeschreven commandoboekje.**

## Git workflow

Simple workflow for a personal project without other contributors:

| Task                                         | Command                   |
| :---                                         | :---                      |
| Current project status                       | `git status`              |
| Select files to be committed                 | `git add FILE...`         |
| Commit changes to local repository           | `git commit -m 'MESSAGE'` |
| Push local changes to remote repository      | `git push`                |
| Pull changes from remote repository to local | `git pull`                |
| Shortcut ALIAS voor GIT SSH | `vS [vmname]`  |
| Shortcut ALIAS voor GIT PULL + Rebase | `gp` |
| Shortcut ALIAS voor mijn Linux sme Directory | `linux` |
| Shortcut ALIAS voor mijn Linux Syllabus | `linux-syllabus` |

## Setting the systeminput to azerty:

```
sudo localectl set-keymap be
sudo localectl set-x11-keymap be
```


## SELinux

### Status, enabling and disabling

| Action                                  | Command        |
| :---                                    | :---           |
| Check status (detailed)                 | `sestatus`     |
| Check status (brief)                    | `getenforce`   |
| Enable (temporarily)                    | `setenforce 1` |
| Disable (temporarily - permissive mode) | `setenforce 0` |

### Booleans

| Action                     | Command                           |
| :---                       | :---                              |
| List all booleans          | `getsebool -a`                    |
| List specific booleans     | `getsebool -a \007C grep PATTERN` |
| Set boolean (until reboot) | `setsebool BOOLEAN VALUE`         |
|                            | `VALUE` can be 0/false or 1/true  |
| Set boolean permanently    | `setsebool -P BOOLEAN VALUE`      |

## VyOS
| Task                        | Command                                               |
| :---                        | :---                                                  |
| Keyboard layout             | `sudo dpkg-reconfigure keyboard-configuration`        |
| Set IP address on interface | `set interfaces ethernet eth0 address 192.168.0.1/24` |

```
vyos@vyos $ configure
vyos@vyos # [configuration commands]
vyos@vyos # commit
vyos@vyos # save
vyos@vyos # exit
vyos@vyos $
```

## Checklist network configuration

1. Is the IP-adress correct? `ip a`
2. Is the router/default gateway correct? `ip r -n`
3. Is a DNS-server available? `cat /etc/resolv.conf`

## Nginx hulp:

- Check DNS-server met `cat /etc/resolv.conf`
- Kijk of nginx is running met: `sudo systemctl status nginx`
- Service status checken: `sudo systemctl status [service]`
- Service herstarten: `sudo sytemctl restart [service]`
- Edit nginx config file: `sudo vi /etc/nginx/nginx.conf`
- Check of de juiste poorten open staan: `sudo ss -tulpn`

## Bind hulp:

- Configuratie van een NIC aanpassen of ONBOOT aanzetten: `sudo vi /etc/sysconfig/network-scripts/[ADAPTER]`
- Check firewall services die runnen: `sudo firewall-cmd --list-all`

