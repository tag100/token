FROM php:7.4-apache

# Install curl
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    && docker-php-ext-install curl

# Remove ALL existing Apache configurations
RUN rm -rf /etc/apache2/sites-enabled/* \
    && rm -rf /etc/apache2/sites-available/* \
    && rm -rf /etc/apache2/mods-enabled/* \
    && rm -rf /etc/apache2/conf-enabled/*

# Copy application
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# Create completely new, minimal Apache configuration
RUN echo "ServerName localhost" > /etc/apache2/apache2.conf && \
    echo "PidFile \${APACHE_PID_DIR}/apache2.pid" >> /etc/apache2/apache2.conf && \
    echo "Timeout 300" >> /etc/apache2/apache2.conf && \
    echo "KeepAlive On" >> /etc/apache2/apache2.conf && \
    echo "MaxKeepAliveRequests 100" >> /etc/apache2/apache2.conf && \
    echo "KeepAliveTimeout 5" >> /etc/apache2/apache2.conf && \
    echo "User www-data" >> /etc/apache2/apache2.conf && \
    echo "Group www-data" >> /etc/apache2/apache2.conf && \
    echo "HostnameLookups Off" >> /etc/apache2/apache2.conf && \
    echo "ErrorLog \${APACHE_LOG_DIR}/error.log" >> /etc/apache2/apache2.conf && \
    echo "LogLevel warn" >> /etc/apache2/apache2.conf && \
    echo "EnableSendfile On" >> /etc/apache2/apache2.conf && \
    echo "Listen 8080" >> /etc/apache2/apache2.conf && \
    echo "" >> /etc/apache2/apache2.conf && \
    echo "<VirtualHost *:8080>" >> /etc/apache2/apache2.conf && \
    echo "    DocumentRoot /var/www/html" >> /etc/apache2/apache2.conf && \
    echo "    <Directory /var/www/html>" >> /etc/apache2/apache2.conf && \
    echo "        Options Indexes FollowSymLinks" >> /etc/apache2/apache2.conf && \
    echo "        AllowOverride All" >> /etc/apache2/apache2.conf && \
    echo "        Require all granted" >> /etc/apache2/apache2.conf && \
    echo "    </Directory>" >> /etc/apache2/apache2.conf && \
    echo "</VirtualHost>" >> /etc/apache2/apache2.conf

# Load only the essential modules directly
RUN echo "LoadModule mpm_prefork_module /usr/lib/apache2/modules/mod_mpm_prefork.so" >> /etc/apache2/apache2.conf && \
    echo "LoadModule authz_core_module /usr/lib/apache2/modules/mod_authz_core.so" >> /etc/apache2/apache2.conf && \
    echo "LoadModule dir_module /usr/lib/apache2/modules/mod_dir.so" >> /etc/apache2/apache2.conf && \
    echo "LoadModule alias_module /usr/lib/apache2/modules/mod_alias.so" >> /etc/apache2/apache2.conf && \
    echo "LoadModule rewrite_module /usr/lib/apache2/modules/mod_rewrite.so" >> /etc/apache2/apache2.conf

# Create health check file
RUN echo "OK" > /var/www/html/health.php

EXPOSE 8080

CMD ["apache2-foreground"]
