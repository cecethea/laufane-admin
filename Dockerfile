# Official PHP image as base
FROM php:8.2-fpm

# Working directory
WORKDIR /var/www/html

# Dependencies and PHP extensions
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
    && docker-php-ext-install gd intl mysqli pdo_mysql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json composer.lock ./

# PHP dependencies using composer
RUN composer install --optimize-autoloader --no-scripts --no-interaction --prefer-dist

# Copy files with ownership set during copy
COPY --chown=www-data:www-data . ./

# Setup .env file
RUN rm -rf .env \
    && cp .env.example .env

# Permissions for storage and bootstrap/cache
RUN mkdir -p storage/logs/ storage/debugbar/ storage/framework/cache/ storage/framework/sessions/ storage/framework/views/ bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache \
    && chmod 777 -R storage \
    && chmod 777 -R resources/lang



