#!/bin/bash
# Set locale
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

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
# sudo fallocate -l 1G /swapfile
# sudo chmod 600 /swapfile
# sudo mkswap /swapfile
# sudo swapon /swapfile
# sudo cp /etc/fstab /etc/fstab.bak
# echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
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

# Setup mariadb 10.11
wget -qO mariadb_repo_setup.sh https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup.sh
./mariadb_repo_setup.sh --mariadb-server-version=mariadb-10.11
sudo apt install mariadb-server -y
db_pass_root="Thisisdbrootpassword"
mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${db_pass_root}\" with grant option;"
mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${db_pass_root}\" with grant option;"

# Setup php 7.4
sudo apt install -y apt-transport-https lsb-release ca-certificates wget 
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list 
sudo apt update && sudo apt install php7.4 -y
sudo apt install -y php7.4-cli php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath php7.4-opcache -y
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

# Optimization PHP, MariaDB
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/my.cnf -O /etc/mysql/my.cnf
systemctl restart mariadb
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/php.ini -O /etc/php/7.4/fpm/php.ini
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/www.conf -O /etc/php/7.4/fpm/pool.d/www.conf
systemctl restart php7.4-fpm
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/Caddyfile -O /etc/caddy/Caddyfile
systemctl restart caddy

# Auto start
systemctl enable mariadb
systemctl enable php7.4-fpm
systemctl enable caddy

# setup wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Monitor and restart PHP, Mysql, Caddy
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/bibica.net/monitor/lcmp-debian.sh -O /usr/local/bin/monitor_service_restart.sh
chmod +x /usr/local/bin/monitor_service_restart.sh
nohup /usr/local/bin/monitor_service_restart.sh >> ./out 2>&1 <&- &
crontab -l > monitor_service_restart
echo "@reboot nohup /usr/local/bin/monitor_service_restart.sh >> ./out 2>&1 <&- &" >> monitor_service_restart
crontab monitor_service_restart

# setup crontab cho wp_cron and simply-static
crontab -l > simply-static
echo "0 3 * * * /usr/local/bin/wp --path='/var/www/bibica.net/htdocs' simply-static run --allow-root" >> simply-static
echo "*/1 * * * * curl https://bibica.net/wp-cron.php?doing_wp_cron > /dev/null 2>&1" >> simply-static
crontab simply-static

# setup database
db_pass_root="Thisisdbrootpassword"
db_name="wordpress_database_name_99999"
db_user="wordpress_user_99999"
db_pass="password_pass_99999"
mysql -uroot -p${db_pass_root} -e "CREATE DATABASE ${db_name} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
mysql -uroot -p${db_pass_root} -e "GRANT ALL ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}'"

# setup ssl
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/bibica.net/ssl/bibica.net.key -O /etc/ssl/bibica.net.key
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/bibica.net/ssl/bibica.net.pem -O /etc/ssl/bibica.net.pem

# setup bibica.net and api.bibica.net
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/bibica.net/bibica.net.conf -O /etc/caddy/conf.d/bibica.net.conf
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/bibica.net/api.bibica.net.conf -O /etc/caddy/conf.d/api.bibica.net.conf
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/bibica.net/comment.bibica.net.conf -O /etc/caddy/conf.d/comment.bibica.net.conf
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/bibica.net/analytics.bibica.net.conf -O /etc/caddy/conf.d/analytics.bibica.net.conf
systemctl restart caddy
mkdir -p /var/www/bibica.net/htdocs
cd /var/www/bibica.net/htdocs
chown -R caddy:caddy /var/www/bibica.net/htdocs
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
cd

# Create symbolic link
ln -s /var/www /root/
ln -s /etc/caddy /root/

# setup docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $(whoami)
sudo systemctl start docker
sudo systemctl enable docker
sudo apt install docker-compose -y

# show info database
green() {
  echo -e '\e[32m'$1'\e[m';
}
green "Database Root Password: $db_pass_root\nDatabase Name: $db_name\nDatabase User: $db_user\nDatabase Pass: $db_pass"
