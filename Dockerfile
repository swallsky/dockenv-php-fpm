ARG PHP_VERSION=${PHP_VERSION}
FROM php:${PHP_VERSION}-fpm-alpine

USER root

# 更改镜像源为阿里云
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories

# 安装相关的依耐包
RUN apk --update add wget \
  curl \
  git \
  build-base \
  libmemcached-dev \
  libmcrypt-dev \
  libxml2-dev \
  pcre-dev \
  zlib-dev \
  autoconf \
  cyrus-sasl-dev \
  libgsasl-dev \
  oniguruma-dev \
  openssl \
  openssl-dev

# 安装 mysqli mbstring pdo pdo_mysql tokenizer xml pcntl
RUN docker-php-ext-install mysqli mbstring pdo pdo_mysql tokenizer xml pcntl

# 安装BZ2
RUN apk --update add bzip2-dev; \
    docker-php-ext-install bz2; 

# 安装GD库
RUN apk add --update --no-cache freetype-dev libjpeg-turbo-dev jpeg-dev libpng-dev; \
    #7.4 安装参数发生变化 @https://www.php.net/manual/zh/migration74.other-changes.php#migration74.other-changes.pkg-config
    if [ ${PHP_VERSION} = "7.4" ]; then \
        docker-php-ext-configure gd --with-freetype=/usr/lib/ --with-jpeg=/usr/lib/ --with-webp=/usr/lib/ && \
        docker-php-ext-install gd \
    else \
        docker-php-ext-configure gd --with-freetype-dir=/usr/lib/ --with-jpeg-dir=/usr/lib/ --with-png-dir=/usr/lib/ && \
        docker-php-ext-install gd \
    ;fi

# 安装ZipArchive
RUN apk --update add libzip-dev && \
    if [ ${PHP_VERSION} = "7.3" ] || [ ${PHP_VERSION} = "7.4" ]; then \
      docker-php-ext-configure zip \
    else \
      docker-php-ext-configure zip --with-libzip \
    ;fi && \
    # Install the zip extension
    docker-php-ext-install zip

# 安装redis扩展
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# 安装composer
ADD ./composer /usr/local/bin/composer

# Composer install
#RUN curl -sS http://getcomposer.org/installer | php \
#    && mv composer.phar /usr/local/bin/composer \
RUN chmod u+x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/