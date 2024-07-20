# LCMP Minimal : Debian - Caddy - MariaDB - PHP

Đây là các cài đặt và cấu hình mình đang áp dụng cho thèng bibica.net
## Cấu hình sử dụng
* Debian 11/12
* Caddy v2.8.4
* PHP 7.4.33
* MariaDB 10.11.8

<a href="https://go.bibica.net/upcloud" target="_blank" rel="noopener">UpCloud</a> 1 GB RAM - Developer plans - €4.5/mo
## Cài đặt DCMP Minimal
### Cập nhập OS
```shell
sudo apt update && sudo apt upgrade -y && sudo reboot
```
### Chạy trên x86_64, ARM64
```shell
sudo wget https://go.bibica.net/lcmp-minimal -O server.sh && sudo chmod +x server.sh && sudo ./server.sh
```
### Chạy trên IPv6
```shell
sudo wget https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/setup_ip6.sh -O server.sh && sudo chmod +x server.sh && sudo ./server.sh
```
### Speedtest loader.io
<img class="aligncenter size-full wp-image-27267" src="https://bibica.net/wp-content/uploads/2023/10/2024-07-20-18-02-31.jpg" alt="2024 07 20 18 02 31" width="1174" height="816" />
