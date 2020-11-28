#!/bin/bash
#Update packages and upgrade system
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt update -y
sudo apt upgrade -y
# Install Apache web server
sudo apt-get -y install apache2
sudo systemctl start apache2
sudo systemctl enable apache2

# Modify firwall
sudo ufw allow 'Apache'
sudo systemctl status apache2