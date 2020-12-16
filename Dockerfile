ARG PHP_VERSION=${PHP_VERSION}
FROM php:${PHP_VERSION}-fpm-alpine

USER root

# CHANGE SOURCE && apk upgrade
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache openssl \
    && apk add --no-cache bash

# Install the PHP gd zip pdo_mysql extention
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} gd \
    && docker-php-ext-install pdo_mysql zip mysqli bcmath \
    && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

# 安装redis扩展
ADD ./phpredis-3.1.6 /usr/src/php/ext/redis
RUN docker-php-ext-install redis \
    # 如果这段不加构建的镜像将大100M,删除源代码文件
    && rm -rf /usr/src/php
