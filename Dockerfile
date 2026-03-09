FROM php:7.4-apache

# Install curl and dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    && docker-php-ext-install curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# Create health check file
RUN echo "OK" > /var/www/html/health.php

# Runtime configuration - this runs when container starts
CMD ["/bin/bash", "-c", "\
    echo '=== FIXING APACHE MPM CONFIGURATION ===' && \
    echo 'Disabling conflicting MPM modules...' && \
    a2dismod -f mpm_event mpm_worker 2>/dev/null || true && \
    rm -f /etc/apache2/mods-enabled/mpm_event.* 2>/dev/null || true && \
    rm -f /etc/apache2/mods-enabled/mpm_worker.* 2>/dev/null || true && \
    echo 'Enabling prefork MPM...' && \
    a2enmod mpm_prefork 2>/dev/null || true && \
    echo 'Enabling rewrite module...' && \
    a2enmod rewrite 2>/dev/null || true && \
    echo 'Configuring port 8080...' && \
    echo 'Listen 8080' > /etc/apache2/ports.conf && \
    echo 'Testing Apache configuration...' && \
    apache2ctl -t && \
    echo '=== STARTING APACHE ===' && \
    exec apache2-foreground \
"]
