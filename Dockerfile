# 使用 PHP 8.3 FPM 基础镜像
FROM php:8.3-fpm

# 设置工作目录
WORKDIR /var/www

# 安装系统依赖和 PHP 扩展
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql gd zip

# 安装 Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 复制项目文件到容器中
COPY . .

# 安装 Laravel 项目依赖
RUN composer install

# 复制环境配置文件并生成应用密钥
COPY .env.example .env
RUN php artisan key:generate

# 设置文件权限
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

# 暴露端口
EXPOSE 9000

# 启动 PHP-FPM 服务器
CMD ["php-fpm"]
