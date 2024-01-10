#!/bin/bash

# Update the package index
apt update

# Install Apache 2
apt install -y apache2

# Remove default index.html
rm -f /var/www/html/index.html
