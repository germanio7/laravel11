# Usar una imagen base oficial de PHP
FROM php:8.4-fpm

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    git \
    unzip \
    curl \
    nodejs \
    npm \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones de PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql

# Configurar el directorio de trabajo
WORKDIR /var/www

# Copiar los archivos del proyecto al contenedor
COPY . .

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instalar dependencias de Composer
RUN composer install --optimize-autoloader --no-dev

# Instalar dependencias de NPM (si las tienes en package.json)
RUN npm install && npm run build

# Exponer el puerto en el que el servidor de PHP correrá
EXPOSE 9000

# Copiar configuración de Nginx al contenedor
COPY ./nginx.conf /etc/nginx/sites-available/laravel
RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Exponer puerto de Nginx (puerto 80)
EXPOSE 80

# Ejecutar Nginx y PHP-FPM en paralelo
CMD service nginx start && php-fpm
