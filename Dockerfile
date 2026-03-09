FROM php:7.4-apache

# Install curl and dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    && docker-php-ext-install curl \
    && a2enmod rewrite

# Copy application
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# CRITICAL FIX: Use the PORT environment variable that Railway provides
RUN echo "Listen \${PORT}" > /etc/apache2/ports.conf
RUN echo "<VirtualHost *:\${PORT}>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

# Create a simple health check endpoint
RUN echo "OK" > /var/www/html/health

EXPOSE 8080

CMD ["apache2-foreground"]
