ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm-alpine
LABEL maintainer="JackXu <xjz1688@163.com>"
ARG PHP_VERSION

USER root

# 更改镜像源为阿里云
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache bash

# 安装相关的依耐包
RUN apk --update add wget \
  curl \
  curl-dev \
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
  openssl-dev \
  g++ \
  libtool \
  make \
  linux-headers 

# 安装 mysqli mbstring pdo pdo_mysql xml pcntl
RUN docker-php-ext-install pdo pdo_mysql mysqli mbstring bcmath

# 安装GD库 7.4 安装参数发生变化 @https://www.php.net/manual/zh/migration74.other-changes.php#migration74.other-changes.pkg-config
RUN apk add --update --no-cache freetype-dev libjpeg-turbo-dev jpeg-dev libpng-dev; \
    if [ ${PHP_VERSION} = "7.4" ]; then \
        docker-php-ext-configure gd --with-freetype=/usr/lib/ --with-jpeg=/usr/lib/ && \
        docker-php-ext-install gd; \
    else \
        docker-php-ext-configure gd --with-freetype-dir=/usr/lib/ --with-jpeg-dir=/usr/lib/ --with-png-dir=/usr/lib/ && \
        docker-php-ext-install gd \
    ;fi


# 安装ZipArchive
RUN apk --update add libzip-dev && \
    if [ ${PHP_VERSION} = "7.3" ] || [ ${PHP_VERSION} = "7.4" ]; then \
      docker-php-ext-configure zip && \
      docker-php-ext-install zip; \
    else \
      docker-php-ext-configure zip --with-libzip && \
      docker-php-ext-install zip \
    ;fi

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


# Swoole install
RUN docker-php-ext-install -j 2 sockets \
    && wget https://github.com/swoole/swoole-src/archive/v4.6.2.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
    cd swoole \
    && phpize \
    && ./configure --enable-sockets --enable-swoole-json --enable-swoole-curl --enable-mysqlnd --enable-openssl --enable-http2 \
    && make -j$(nproc) \
    && make install \
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole

# Clean up
RUN rm /var/cache/apk/* \
    && mkdir -p /var/www \
    && rm -rf /usr/src/php
