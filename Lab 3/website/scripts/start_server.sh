#!/bin/bash

# Start Apache service
sudo systemctl start apache2

# Enable Apache to start on boot
sudo systemctl enable apache2

# Display a message indicating successful installation
echo "Apache 2 has been successfully installed and started."
