
FROM php:8.3-cli

RUN apt-get update && apt-get install -y \
    git unzip curl \
    libpq-dev libzip-dev libicu-dev \
    libonig-dev libxml2-dev \
    && docker-php-ext-install \
    pdo pdo_pgsql mbstring bcmath \
    intl xml zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
RUN mkdir -p storage/logs bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache
    
COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN php artisan package:discover

RUN mkdir -p storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

CMD php artisan serve --host=0.0.0.0 --port=${PORT:-10000}
