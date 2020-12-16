### 编译镜像
- 目前不支持php7.3、php7.4
```
# 编译 7.1
docker build --build-arg PHP_VERSION=7.1 -t ybluesky/php-fpm:7.1-v1 .
# 编译 7.2
docker build --build-arg PHP_VERSION=7.2 -t ybluesky/php-fpm:7.2-v1 .
```

