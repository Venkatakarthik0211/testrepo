#!/bin/bash -xe

# Update package lists
sudo apt-get update -y

# Install necessary packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 \
    python3-venv \
    git \
    python3-dev \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config \
    libmysqlclient-dev \
    awscli \
    mysql-client \
    apache2 \
    libapache2-mod-wsgi-py3 \
    mysql-server

# Enable and start MySQL service
sudo systemctl enable mysql
sudo systemctl start mysql
sudo systemctl status mysql

# Clone the repository
cd ~
git clone https://github.com/Venkatakarthik0211/testrepo.git

# Export the current directory into s bash variable
export CURRENT_DIR=$(pwd)

# Change directory to the project folder
cd $CURRENT_DIR/testrepo/three-tier/python/test

# Fetch parameters from AWS SSM Parameter Store
DBPassword=$(aws ssm get-parameters --region us-east-1 --names /P4L/Python/DBPassword --with-decryption --query 'Parameters[0].Value' --output text)
DBRootPassword=$(aws ssm get-parameters --region us-east-1 --names /P4L/Python/DBRootPassword --with-decryption --query 'Parameters[0].Value' --output text)
DBUser=$(aws ssm get-parameters --region us-east-1 --names /P4L/Python/DBUser --query 'Parameters[0].Value' --output text)
DBName=$(aws ssm get-parameters --region us-east-1 --names /P4L/Python/DBName --query 'Parameters[0].Value' --output text)
DBEndpoint=$(aws ssm get-parameters --region us-east-1 --names /P4L/Python/DBEndpoint --query 'Parameters[0].Value' --output text)

# Get the public IP of the server
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
SERVER_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4 -H "X-aws-ec2-metadata-token: $TOKEN")

# Setup MySQL database and user
echo "CREATE DATABASE $DBName;" | sudo mysql -u root --password=$DBRootPassword
echo "CREATE USER '$DBUser'@'localhost' IDENTIFIED BY '$DBPassword';" | sudo mysql -u root --password=$DBRootPassword
echo "GRANT ALL ON $DBName.* TO '$DBUser'@'localhost';" | sudo mysql -u root --password=$DBRootPassword
echo "FLUSH PRIVILEGES;" | sudo mysql -u root --password=$DBRootPassword

# Setup Python virtual environment and install requirements
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# Enable and start Apache service
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl status apache2

# Enable WSGI module
sudo a2enmod wsgi

# Create the Apache configuration file
sudo tee /etc/apache2/sites-available/flaskapp.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $SERVER_IP
    ServerAdmin youremail@example.com
    WSGIScriptAlias / $CURRENT_DIR/testrepo/three-tier/python/test/flaskapp.wsgi
    <Directory $CURRENT_DIR/testrepo/three-tier/python/test/>
        Require all granted
    </Directory>
    Alias /static $CURRENT_DIR/testrepo/three-tier/python/test/static
    <Directory $CURRENT_DIR/testrepo/three-tier/python/test/static/>
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    LogLevel warn
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Write the WSGI file
sudo tee $CURRENT_DIR/testrepo/three-tier/python/test/flaskapp.wsgi > /dev/null <<EOF
import sys
import logging
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0, "~/testrepo/three-tier/python/test")
from app import app as application
EOF

# Set directory permissions
sudo chmod +x $CURRENT_DIR
sudo chmod +x $CURRENT_DIR/testrepo
sudo chmod +x $CURRENT_DIR/testrepo/three-tier
sudo chmod +x $CURRENT_DIR/testrepo/three-tier/python
sudo chmod +x $CURRENT_DIR/testrepo/three-tier/python/test

# Enable the new site and restart Apache
sudo a2ensite flaskapp.conf
sudo systemctl restart apache2

# Log script completion
echo "Setup script completed" | sudo tee /var/log/user-data.log
