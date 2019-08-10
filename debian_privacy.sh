#!/bin/bash
# exim4 - https://www.exploit-db.com/exploits/46974
#       - it appears to be enabled by default on debian as a backdoor
# apt-daily and ntp are disabled to prevent any automatic connections
sudo timedatectl set-ntp false
sudo timedatectl set-timezone Etc/UTC
sudo systemctl stop apt-daily.service
sudo systemctl stop apt-daily-upgrade.service
sudo systemctl stop apt-daily.timer
sudo systemctl stop apt-daily-upgrade.timer
sudo systemctl stop exim4.service
sudo systemctl disable apt-daily.service
sudo systemctl disable apt-daily-upgrade.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl disable exim4.service
