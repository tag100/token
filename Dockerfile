FROM php:7.4-apache

# Remove all existing MPM configurations
RUN rm -f /etc/apache2/mods-enabled/mpm*.load
RUN rm -f /etc/apache2/mods-available/mpm*.load

# Install curl
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    && docker-php-ext-install curl

# Enable Apache modules - using correct names from the debug output
RUN a2enmod mpm_prefork
RUN a2enmod rewrite

# Copy application
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# Configure Apache for port 8080
RUN echo "Listen 8080" > /etc/apache2/ports.conf
RUN echo "<VirtualHost *:8080>" > /etc/apache2/sites-available/000-default.conf
RUN echo "    DocumentRoot /var/www/html" >> /etc/apache2/sites-available/000-default.conf
RUN echo "    <Directory /var/www/html>" >> /etc/apache2/sites-available/000-default.conf
RUN echo "        Options Indexes FollowSymLinks" >> /etc/apache2/sites-available/000-default.conf
RUN echo "        AllowOverride All" >> /etc/apache2/sites-available/000-default.conf
RUN echo "        Require all granted" >> /etc/apache2/sites-available/000-default.conf
RUN echo "    </Directory>" >> /etc/apache2/sites-available/000-default.conf
RUN echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf

# Create health check file
RUN echo "OK" > /var/www/html/health.php

EXPOSE 8080

CMD ["apache2-foreground"]
