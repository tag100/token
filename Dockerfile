FROM php:7.4-apache

# Install required extensions and tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd curl && \
    docker-php-ext-enable curl

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure PHP for better performance
RUN echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "max_execution_time = 60" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "max_input_time = 60" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "post_max_size = 32M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "upload_max_filesize = 32M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "session.gc_maxlifetime = 7200" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "session.save_path = /tmp/sessions" >> /usr/local/etc/php/conf.d/custom.ini

# Create session directory
RUN mkdir -p /tmp/sessions && \
    chmod 777 /tmp/sessions

# Copy application files
COPY . /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 777 /tmp/sessions

# Configure Apache to allow .htaccess overrides
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Expose port 8080 (Railway uses 8080 by default)
EXPOSE 8080

# Use port 8080 for Apache
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf && \
    sed -i 's/:80/:8080/g' /etc/apache2/sites-available/000-default.conf

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start Apache
CMD ["apache2-foreground"]