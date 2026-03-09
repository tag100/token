FROM php:7.4-apache

# Install curl
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    && docker-php-ext-install curl

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy application
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# Configure Apache for port 8080 (simpler approach)
RUN echo "Listen 8080" > /etc/apache2/ports.conf && \
    echo "<VirtualHost *:8080>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

# Create health check endpoint
RUN echo "OK" > /var/www/html/health

EXPOSE 8080

CMD ["apache2-foreground"]
