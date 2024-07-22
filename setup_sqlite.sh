#!/bin/bash
# Set nameserver google, cloudflare
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf

# Enable TCP BBR congestion control
cat <<EOF > /etc/sysctl.conf
# TCP BBR congestion control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

# update 
sudo apt update -y
sudo apt install htop -y
sudo apt install nano -y
sudo apt install zip -y
sudo apt install unzip -y
sudo apt install screen -y
sudo apt install wget -y
sudo apt install curl -y
sudo apt install gpg -y

# Set time Viet Nam
timedatectl set-timezone Asia/Ho_Chi_Minh

# setup swapfile
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
cat <<EOF > /etc/sysctl.d/99-xs-swappiness.conf
vm.swappiness=10
EOF

# setup caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy -y
#caddy add-package github.com/sillygod/cdp-cache
mkdir -p /data/www/default
mkdir -p /var/log/caddy/
mkdir -p /etc/caddy/conf.d/
chown -R caddy:caddy /data/www/default
chown -R caddy:caddy /var/log/caddy/
chown -R caddy:caddy /etc/caddy/
chown -R caddy:caddy /etc/ssl

# Setup php 7.4
sudo apt install -y apt-transport-https lsb-release ca-certificates wget 
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list 
sudo apt update && sudo apt install php7.4 -y
sudo apt install -y php7.4-cli php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath php7.4-opcache -y
sudo apt-get install php7.4-sqlite -y
sudo apt install php7.4-fpm -y

# Delete Apache
sudo systemctl disable --now apache2
sudo service apache2 stop
sudo apt remove --autoremove apache2 -y
sudo apt purge apache2 apache2-utils -y
sudo apt remove apache2 apache2-utils -y
sudo apt autoremove apache2 apache2-utils -y
sudo rm -r /usr/sbin/apache2 
sudo rm -r /usr/lib/apache2
sudo rm -r /etc/apache2
sudo rm -r /usr/share/man/man8/apache2.8.gz
sudo rm -r /etc/php/7.4/apache2
systemctl restart php7.4-fpm

# Optimization PHP
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/php_sqlite3.ini -O /etc/php/7.4/fpm/php.ini
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/www.conf -O /etc/php/7.4/fpm/pool.d/www.conf
systemctl restart php7.4-fpm
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/Caddyfile -O /etc/caddy/Caddyfile
systemctl restart caddy

# Auto start
systemctl enable php7.4-fpm
systemctl enable caddy

# setup wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Create symbolic link
ln -s /var/www /root/
ln -s /etc/caddy /root/
