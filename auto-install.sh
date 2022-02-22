#!/bin/bash

DOMAIN=domain.tld
ADMIN_USER=admin
PASSWORD=password

echo "[+] Adding domain name"
sudo yunohost domain add ${DOMAIN}
sudo yunohost domain main-domain -n ${DOMAIN}
sudo yunohost domain add poll.${DOMAIN}
sudo yunohost domain add url.${DOMAIN}
sudo yunohost domain add paste.${DOMAIN}
sudo yunohost domain add git.${DOMAIN}
sudo yunohost domain add rss.${DOMAIN}
sudo yunohost domain add drop.${DOMAIN}
sudo yunohost domain add wiki.${DOMAIN}
sudo yunohost domain add kanban.${DOMAIN}
sudo yunohost domain add wall.${DOMAIN}
sudo yunohost domain add webmail.${DOMAIN}
sudo yunohost domain add notif.${DOMAIN}
sudo yunohost domain add cloud.${DOMAIN}
sudo yunohost domain add board.${DOMAIN}
sudo yunohost domain add office.${DOMAIN}
sudo yunohost domain add synapse.${DOMAIN}
sudo yunohost domain add element.${DOMAIN}

echo "[+] Installing certificate"
sudo yunohost domain cert-install --no-checks

echo "[+] Installing application"
sudo yunohost app install opensondage -a "domain=poll.${DOMAIN}&path=/&admin=${ADMIN_USER}&password=${PASSWORD}&language=fr&expiration=0&deletion=0&is_public=n"
sudo yunohost app install lstu -a "domain=url.${DOMAIN}&path=/&is_public=n&theme=miligram&password=${PASSWORD}"
sudo yunohost app install privatebin -a "domain=paste.${DOMAIN}&path=/&is_public=n"
# sudo yunohost app install gitea -a "domain=git.${DOMAIN}&path=/&admin=${ADMIN_USER}&is_public=y"
# gitlab
sudo yunohost app install freshrss -a "domain=rss.${DOMAIN}&path=/&admin=${ADMIN_USER}&language=en"
sudo yunohost app install jirafeau -a "domain=drop.${DOMAIN}&path=/&admin_user=${ADMIN_USER}&is_public=y"
sudo yunohost app install bookstack -a "domain=wiki.${DOMAIN}&path=/&language=fr&is_public=n"
sudo yunohost app install wekan -a "domain=kanban.${DOMAIN}&path=/&admin=${ADMIN_USER}&is_public=n"
sudo yunohost app install wallabag2 -a "domain=wall.${DOMAIN}&path=/&admin=${ADMIN_USER}"
sudo yunohost app install roundcube -a "domain=webmail.${DOMAIN}&path=/&language=fr_FR&with_carddav=y&with_enigma=y" #language=en_GB
sudo yunohost app install gotify -a "domain=notif.${DOMAIN}&admin=${ADMIN_USER}&password=${PASSWORD}"
sudo yunohost app install nextcloud -a "domain=cloud.${DOMAIN}&path=/&admin=${ADMIN_USER}&user_home=n"
# board -> focalboard
# office
sudo yunohost app install synapse -a "domain=synapse.${DOMAIN}&path=/&server_name=${DOMAIN}&is_public=n&jitsi_server=jitsi.riot.im" -f
sudo yunohost app install element -a "domain=element.${DOMAIN}&path=/&default_home_server=synapse.${DOMAIN}&is_public=y"

echo "[+] Hardening ssh and nginx"
sudo yunohost settings set security.nginx.compatibility -v modern
sudo yunohost settings set security.ssh.compatibility -v modern
# sudo yunohost settings set security.postfix.compatibility -v modern # TLS 1.3 not supported

echo "[+] Whitelisting ips in fail2ban" 
# https://yunohost.org/en/fail2ban
echo -e "[DEFAULT]\nignoreip = 127.0.0.1/8 10.10.150.1/24 172.16.100.1/24" | sudo tee /etc/fail2ban/jail.d/yunohost-whitelist.conf
sudo fail2ban-client reload

echo "[+] Limiting upload on Jirafeau to 20Go"
sudo sed -i 's/client_max_body_size.*;/client_max_body_size 20G;/g' /etc/nginx/conf.d/drop.${DOMAIN}.d/jirafeau.conf
sudo sed -i 's/client_body_timeout.*;/client_body_timeout 60m;/g' /etc/nginx/conf.d/drop.${DOMAIN}.d/jirafeau.conf
sudo sed -i 's/proxy_read_timeout.*;/proxy_read_timeout 60m;/g' /etc/nginx/conf.d/drop.${DOMAIN}.d/jirafeau.conf
sudo sed -i 's/upload_max_filesize.*/upload_max_filesize] = 20G/g' /etc/php/7.3/fpm/pool.d/jirafeau.conf
sudo sed -i 's/post_max_size.*/post_max_size] = 20G/g' /etc/php/7.3/fpm/pool.d/jirafeau.conf
sudo nginx -t
sudo nginx -s reload