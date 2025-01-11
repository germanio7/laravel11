# Stage 1: Build the application
FROM php:8.4-fpm-alpine as build

# Install dependencies
RUN apk add --no-cache \
    freetype-dev \
    jpeg-dev \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    nodejs \
    npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo_mysql

# Set the working directory
WORKDIR /var/www

# Copy application code
COPY . .

# Set correct permissions for Laravel
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Install Composer dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Install Node.js dependencies and build assets
COPY package.json package-lock.json ./
RUN npm install && npm run build

# Stage 2: Create the final image
FROM php:8.4-fpm-alpine

# Copy the application files from the build stage
COPY --from=build /var/www /var/www

# Expose port 9000 and set the default command to run php-fpm
EXPOSE 9000
CMD ["php-fpm"]
