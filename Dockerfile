FROM php:7.4-apache

# Install curl
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    && docker-php-ext-install curl

# Enable Apache rewrite module
RUN a2enmod rewrite

# CRITICAL FIX: Disable conflicting MPM modules and enable the correct one
RUN a2dismod mpm_event mpm_worker || true && \
    a2enmod mpm_prefork

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

# Create health check file
RUN echo "OK" > /var/www/html/health.php

EXPOSE 8080

CMD ["apache2-foreground"]
