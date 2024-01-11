# LCMP Minimal : Debian - Caddy - MariaDB - PHP

Đây là các cài đặt và cấu hình mình đang áp dụng cho thèng bibica.net
## Cấu hình sử dụng
<ul>
 	<li><strong><span style="color: #993300;">Debian 11/12</span></strong></li>
 	<li><strong><span style="color: #993300;">Caddy v2.7.5</span></strong></li>
 	<li><strong><span style="color: #993300;">PHP 7.4.33</span></strong></li>
 	<li><strong><span style="color: #993300;">MariaDB 10.11.5</span></strong></li>
</ul>

<a href="https://go.bibica.net/upcloud" target="_blank" rel="noopener">UpCloud</a> 1 GB RAM - Singapore
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
Open source projects using 1Password Teams
