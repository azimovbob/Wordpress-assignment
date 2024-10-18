#!/bin/bash

DB_NAME=${db_name}
DB_USERNAME=${db_username}
DB_PASSWORD=${db_password}
RDS_ENDPOINT=${rds_endpoint}

# Update the system
sudo dnf update -y

# Install Apache, PHP, and MariaDB
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel mariadb105-server

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Add ec2-user to the apache group
sudo usermod -a -G apache ec2-user

# Adjust permissions for /var/www
sudo chown -R apache:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

# Remove default phpinfo.php if exists
rm -f /var/www/html/phpinfo.php

# Start and enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Create MySQL user and database for WordPress
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USERNAME'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USERNAME'@'%';
FLUSH PRIVILEGES;
EOF

# Download and extract WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# Copy WordPress files to /var/www/html
cp -r wordpress/* /var/www/html/

# Configure WordPress settings
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$DB_USERNAME/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/$RDS_ENDPOINT/" /var/www/html/wp-config.php

# Update .htaccess for /blog/ path
sudo mkdir /var/www/html/blog
sudo mv /var/www/html/* /var/www/html/blog/

# Restart Apache
sudo systemctl restart httpd
