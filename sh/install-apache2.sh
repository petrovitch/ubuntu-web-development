#!/bin/bash

#Install LAMP stack
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $USERPW"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $USERPW"
sudo apt-get --yes install lamp-server^

#update 000-default.conf
grep -v -i "/VirtualHost" /etc/apache2/sites-available/000-default.conf >/tmp/000-default.conf
echo '  <Directory /var/www/html>' >>/tmp/000-default.conf
echo '    AllowOverride All' >>/tmp/000-default.conf
echo '  </Directory>'  >>/tmp/000-default.conf
echo '</VirtualHost>'  >>/tmp/000-default.conf
sudo cp /tmp/000-default.conf /etc/apache2/sites-available

#update php.ini
grep -v -i "display_errors = Off" /etc/php/7.0/apache2/php.ini >/tmp/php.ini.tmp
grep -v -i "display_startup_errors = Off" /tmp/php.ini.tmp >/tmp/php.ini
echo 'display_errors = On' >> /tmp/php.ini
echo 'display_startup_errors = On' >> /tmp/php.ini
sudo cp /tmp/php.ini /etc/php/7.0/apache2/php.ini

#Preprare html directory for use with some test files.
sudo chmod 777 /var/www/html
cp ../php/imapClient.php /var/www/html
cp ../php/phpinfo.php    /var/www/html
sudo cp ../index.html    /var/www/html

#Install php imap extensions.
sudo apt-get --yes install php-imap
sudo phpenmod imap

#Install php curl extensions.
sudo apt-get --yes install php-curl

#Enable rewrites.
sudo a2enmod rewrite

#Install phpmyadmin
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $USERPW"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $USERPW"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $USERPW"
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
sudo apt-get --yes install phpmyadmin
