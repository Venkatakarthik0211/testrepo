sudo apt-get update && sudo apt-get install -y python3 python3-venv git python3-dev default-libmysqlclient-dev build-essential pkg-config libmysqlclient-dev

# Cloning the repository
git clone https://github.com/Venkatakarthik0211/testrepo.git

# Navigating to the project directory and setting up the virtual environment
cd /home/ubuntu/testrepo/three-tier/python/test/ && python3 -m venv venv && source venv/bin/activate

# Installing Gunicorn and other required packages
pip3 install gunicorn && pip3 install -r requirements.txt

# Installing apache 
sudo apt-get install apache2 libapache2-mod-wsgi-py3  -y && sudo systemctl enable apache2 && sudo systemctl start apache2 && sudo systemctl status apache2 && sudo a2enmod wsgi

# Write the apache configuration file
# Replace The Server IP

sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/flaskapp.conf
<VirtualHost *:80>
    ServerName 3.86.251.195
    ServerAdmin youemail@email.com

    WSGIScriptAlias / /home/ubuntu/testrepo/three-tier/python/test/flaskapp.wsgi

    <Directory /home/ubuntu/testrepo/three-tier/python/test/>
        Require all granted
    </Directory>

    Alias /static /home/ubuntu/testrepo/three-tier/python/test/static

    <Directory /home/ubuntu/testrepo/three-tier/python/test/static/>
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    LogLevel warn
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

sudo bash -c 'cat <<EOF > /home/ubuntu/testrepo/three-tier/python/test/flaskapp.wsgi
import sys
import logging
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0, "/home/ubuntu/testrepo/three-tier/python/test")

from app import app as application
EOF'

# Provide Execution Permissions to Directory
sudo chmod +x /home/ubuntu
sudo chmod +x /home/ubuntu/testrepo
sudo chmod +x /home/ubuntu/testrepo/three-tier
sudo chmod +x /home/ubuntu/testrepo/three-tier/python
sudo chmod +x /home/ubuntu/testrepo/three-tier/python/test

# Enable the configuration file & Restart Apache Server
sudo a2ensite flaskapp.conf && sudo systemctl restart apache2 
