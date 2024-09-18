resource "aws_instance" "main" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address  = true
  subnet_id                   = var.subnet_id
  security_groups             = [var.security_group_id]

  user_data = <<-EOF
    #!/bin/bash
    # AUTOMATIC WORDPRESS INSTALLER IN AWS Ubuntu Server 20.04 LTS (HVM)
    # CHANGE DATABASE VALUES BELOW AND PASTE IT TO USERDATA SECTION IN ADVANCED SECTION WHILE LAUNCHING EC2
    # USE ELASTIC IP ADDRESS AND ALLOW SSH, HTTP, AND HTTPS REQUESTS IN SECURITY GROUP
    # by Dev Bhusal

    # MySQL and WordPress configuration variables
    db_root_password="PassWord4-root"
    db_username="wordpress_user"
    db_user_password="PassWord4-user"
    db_name="wordpress_db"

    # Update system packages and upgrade
    apt update -y && apt upgrade -y

    # Install software-properties-common for adding PPA
    apt install -y software-properties-common

    # Add repository for PHP 8.1
    add-apt-repository ppa:ondrej/php
    apt update

    # Install LEMP Stack (Nginx, PHP 8.1, MySQL)
    apt install -y nginx
    apt install -y php8.1-fpm php8.1-mysql php8.1-cli php8.1-curl php8.1-gd php8.1-xml php8.1-mbstring
    apt install -y mysql-server

    # Start and enable Nginx and MySQL services
    systemctl enable nginx
    systemctl start nginx
    systemctl enable mysql
    systemctl start mysql

    # MySQL configuration
    systemctl stop mysql
    mkdir -p /var/run/mysqld
    chown mysql:mysql /var/run/mysqld
    mysqld_safe --skip-grant-tables &

    sleep 5  # Give MySQL time to start in safe mode

    # Reset root password and create new user/database
    mysql -uroot -e "UPDATE mysql.user SET authentication_string=null WHERE User='root';"
    mysql -uroot -e "UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root'; FLUSH PRIVILEGES;"

    killall -v mysqld
    systemctl start mysql

    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$db_root_password'; FLUSH PRIVILEGES;"
    mysql -uroot -p$db_root_password -e "DELETE FROM mysql.user WHERE User='';"
    mysql -uroot -p$db_root_password -e "CREATE DATABASE $db_name;"
    mysql -uroot -p$db_root_password -e "CREATE USER '$db_username'@'localhost' IDENTIFIED BY '$db_user_password';"
    mysql -uroot -p$db_root_password -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_username'@'localhost'; FLUSH PRIVILEGES;"

    # Install WordPress
    cd /tmp
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* /var/www/html/

    # Configure WordPress
    cd /var/www/html
    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/$db_name/g" wp-config.php
    sed -i "s/username_here/$db_username/g" wp-config.php
    sed -i "s/password_here/$db_user_password/g" wp-config.php

    # Set appropriate permissions for WordPress files
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html

    # Additional WordPress configurations
    cat <<EOT >>/var/www/html/wp-config.php
    define('FS_METHOD', 'direct');
    define('WP_MEMORY_LIMIT', '256M');
    EOT

    # Configure Nginx for WordPress
    cat <<EOT >/etc/nginx/sites-available/wordpress
    server {
        listen 80;
        server_name localhost;
        root /var/www/html;
        index index.php index.html index.htm;

        location / {
            try_files \$uri \$uri/ /index.php?\$args;
        }

        location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }

        location ~ /\.ht {
            deny all;
        }

        location ~* \.(jpg|jpeg|png|gif|ico|css|js)\$ {
            expires 365d;
        }
    }
    EOT

    # Enable the new Nginx configuration and reload the service
    ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
    rm /etc/nginx/sites-enabled/default
    nginx -t
    systemctl reload nginx
    systemctl restart php8.1-fpm

    echo "WordPress installed successfully!"
  EOF

  tags = {
    Name = "web-server"
  }
}
