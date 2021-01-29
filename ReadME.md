### 编译镜像
```
# 编译 7.2
docker build --build-arg PHP_VERSION=7.2 -t ybluesky/php-fpm:7.2-v1.2.1 .
# 编译 7.3
docker build --build-arg PHP_VERSION=7.3 -t ybluesky/php-fpm:7.3-v1.2.1 .
# 编译 7.4
docker build --build-arg PHP_VERSION=7.4 -t ybluesky/php-fpm:7.4-v1.2.1 .
```

### 提交镜像
```
docker push ybluesky/php-fpm:7.2-v1.2.1
docker push ybluesky/php-fpm:7.3-v1.2.1
docker push ybluesky/php-fpm:7.4-v1.2.1
```

### 功能说明
- 支持php7.2、php7.3、php7.4
- 支持mysqli mbstring pdo pdo_mysql tokenizer xml pcntl bz2 gd zip
- 支持composer
- 支持swoole
