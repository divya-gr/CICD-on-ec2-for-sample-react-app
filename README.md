for react-app script


resource "aws_instance" "main" {
  ami                  = var.ami
  instance_type        = var.instance_type
  associate_public_ip_address = true
  subnet_id            = var.subnet_id
  security_groups      = [var.security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              # Log output to /var/log/user-data.log for debugging
              exec > /var/log/user-data.log 2>&1
              set -x

              # Step 1: Update the server
              sudo apt update -y

              # Step 2: Install NGINX
              sudo apt install -y nginx
              # Verify NGINX installation
              nginx -v

              # Step 3: Install Node.js
              sudo apt install -y nodejs
              # Verify Node.js installation
              node -v

              # Step 4: Install npm
              sudo apt install -y npm
              # Verify npm installation
              npm -v

              # Step 5: Install Git
              sudo apt install -y git
              # Verify Git installation
              git --version

              # Step 6: Clone the React app repository
              sudo mkdir -p /var/www/html
              sudo git clone https://github.com/aditya-sridhar/simple-reactjs-app.git /var/www/html/simple-reactjs-app

              # Navigate to the app directory
              cd /var/www/html/simple-reactjs-app

              # Step 7: Install dependencies and build the React app
              sudo npm install --legacy-peer-deps
              sudo npm run build

              # Step 8: Configure NGINX
              sudo tee /etc/nginx/sites-available/rev-token.conf > /dev/null <<NGINXCONF
              server {
                  server_name rev-token.blockchainaustralia.link;
                  root /var/www/html/simple-reactjs-app/build;
                  index index.html;
                  client_max_body_size 900M;

                  location / {
                      try_files \$uri \$uri/ /index.html?\$args;
                  }

                  location /api {
                      proxy_pass http://0.0.0.0:3000;
                      proxy_http_version 1.1;
                      proxy_set_header Upgrade \$http_upgrade;
                      proxy_set_header Connection 'upgrade';
                      proxy_set_header Host \$host;
                      proxy_cache_bypass \$http_upgrade;
                      proxy_set_header X-Real-IP \$remote_addr;
                      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                      proxy_read_timeout 1000;
                      proxy_connect_timeout 1000;
                      proxy_send_timeout 1000;
                      proxy_buffers 4 256k;
                      proxy_buffer_size 128k;
                      proxy_busy_buffers_size 256k;
                  }

                  location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
                      expires 1d;
                  }
              }
              NGINXCONF

              # Enable the new NGINX configuration
              sudo ln -s /etc/nginx/sites-available/rev-token.conf /etc/nginx/sites-enabled
              sudo nginx -t
              sudo systemctl reload nginx

              # Step 9: Install Certbot and obtain SSL certificate
              sudo apt install -y certbot python3-certbot-nginx
              sudo certbot --nginx --non-interactive --agree-tos --email divya@example.com -d rev-token.blockchainaustralia.link

              # Final message
              echo "Deployment completed."
              EOF

  tags = {
    Name = "web-server"
  }
}
