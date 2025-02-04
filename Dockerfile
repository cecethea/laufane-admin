# Use official PHP image as the base
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    nano \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libzip-dev \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd intl mysqli pdo_mysql zip bcmath \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy project files
COPY --chown=www-data:www-data . ./

# Copy Composer configuration before running install to leverage caching
COPY composer.json composer.lock ./

# Install PHP dependencies using Composer
RUN composer install --optimize-autoloader --no-scripts --no-interaction --prefer-dist

RUN chmod 777 -R .env.example

# Setup .env file
RUN cp .env.example .env \
    && chown www-data:www-data .env \
    && chmod 777 -R .env


# Permissions for storage and bootstrap/cache
RUN mkdir -p storage/logs/ storage/debugbar/ storage/framework/cache/ storage/framework/sessions/ storage/framework/views/ bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache \
    && chmod 777 -R storage \
    && chmod 777 -R resources/lang

RUN php artisan websockets:serve