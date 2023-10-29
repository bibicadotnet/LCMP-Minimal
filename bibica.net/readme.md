# LCMP Minimal : Debian - Caddy - MariaDB - PHP

Phiên bản cài đặt nhanh cho bibica.net (cấu hình tương tự bản public)
## Cấu hình sử dụng
OS: Debian GNU/Linux 11/12

UpCloud 1 GB RAM - Singapore
## Cài đặt DCMP Minimal
### Cập nhập OS
```shell
sudo apt update && sudo apt upgrade -y && sudo reboot
```
### Chạy trên x86_64, ARM64
```shell
sudo wget https://raw.githubusercontent.com/bibicadotnet/LCMP-Minimal/main/bibica.net/setup.sh -O server.sh && sudo chmod +x server.sh && sudo ./server.sh
```
