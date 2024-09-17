resource "aws_instance" "main" {
  ami                  = var.ami
  instance_type        = var.instance_type
  associate_public_ip_address = true
  subnet_id            = var.subnet_id
  security_groups      = [var.security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              # Update the server
              sudo apt update -y
              sudo apt install -y nginx nodejs npm git

              # Clone the React app repository
              sudo mkdir -p /var/www/html
              sudo git clone https://gitlab.com/decrypt-development/rev-token.git /var/www/html/rev-token

              # Navigate to the app directory
              cd /var/www/html/rev-token

              # Install dependencies and build the app
              sudo npm install --legacy-peer-deps
              sudo npm run build

              # Configure Nginx
              sudo tee /etc/nginx/sites-available/rev-token.conf > /dev/null <<NGINXCONF
              server {
                  server_name rev-token.blockchainaustralia.link;
                  root /var/www/html/rev-token/build;
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

              # Enable the new Nginx configuration
              sudo ln -s /etc/nginx/sites-available/rev-token.conf /etc/nginx/sites-enabled
              sudo nginx -t
              sudo systemctl reload nginx

              # Install Certbot and obtain SSL certificate
              sudo apt install -y certbot python3-certbot-nginx
              sudo certbot --nginx --non-interactive --agree-tos --email divya@example.com -d rev-token.blockchainaustralia.link

              # Clean up
              # sudo rm -rf /var/www/html/rev-token/package-lock.json  

              EOF

  tags = {
    Name = "web-server"
  }
}
