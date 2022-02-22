# Seedbox docker

## Description

Run your own applications on yunohost.

## Start / Setup

To install yunohost, edit `auto-install.sh` with your parameter and run:

```bash
$ chmod +x auto-install.sh && ./auto-install.sh
```

Edit the file `/etc/nginx/nginx.conf` and add the following lines to enable logging of remote ip if you have a reverse proxy:

```bash
# https://serverfault.com/questions/896130/possible-to-log-x-forwarded-for-to-nginx-error-log
set_real_ip_from  10.0.0.0/8;
set_real_ip_from  172.16.0.0/12;
set_real_ip_from  192.168.0.0/16;
real_ip_header    X-Forwarded-For;
```