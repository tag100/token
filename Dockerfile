FROM php:7.4-apache

# Install curl and debugging tools
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    curl \
    net-tools \
    && docker-php-ext-install curl

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy application
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# Configure Apache for port 8080
RUN echo "Listen 8080" > /etc/apache2/ports.conf && \
    cat > /etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:8080>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Create comprehensive test files
RUN echo "OK" > /var/www/html/health
RUN echo "<?php echo 'HEALTH CHECK PASSED'; ?>" > /var/www/html/health.php
RUN echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Create a startup script with diagnostics
RUN cat > /usr/local/bin/start-apache.sh <<EOF
#!/bin/bash
echo "========================================="
echo "Starting Apache with diagnostics"
echo "========================================="
echo "Current directory: \$(pwd)"
echo "Directory listing:"
ls -la /var/www/html/
echo "========================================="
echo "Apache config test:"
apache2ctl -S
echo "========================================="
echo "Ports being listened on:"
netstat -tulpn | grep LISTEN
echo "========================================="
echo "Testing localhost connection:"
curl -I http://localhost:8080/health
echo "========================================="
echo "Starting Apache..."
apache2-foreground
EOF

RUN chmod +x /usr/local/bin/start-apache.sh

EXPOSE 8080

CMD ["/usr/local/bin/start-apache.sh"]
