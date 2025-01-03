FROM php:8.4-fpm

# Install common php extension dependencies
RUN apt-get update && apt-get install -y \
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
    && docker-php-ext-install zip pdo pdo_mysql

# Set the working directory
COPY . /var/www
WORKDIR /var/www

RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# copy composer.json to workdir & install dependencies
COPY composer.json ./
RUN composer install

COPY package.json ./
RUN npm install && npm run build

EXPOSE 9000

# Set the default command to run php-fpm
CMD ["php-fpm"]