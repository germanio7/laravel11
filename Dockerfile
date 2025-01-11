FROM php:8.4-fpm

# Install common PHP extension dependencies and other tools in one layer to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    unzip \
    nodejs \
    npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip pdo_mysql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /var/www

# Copy application code
COPY . .

# Set correct permissions for Laravel
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copy composer.json and install dependencies (caching layer)
COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-autoloader --no-dev

# Copy and build front-end assets
COPY package.json package-lock.json ./
RUN npm install && npm run build

# Expose port 9000 and set the default command to run php-fpm
EXPOSE 9000
CMD ["php-fpm"]
