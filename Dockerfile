FROM php:8.1-cli-alpine

RUN apk update \
    && apk add --no-cache \
    $PHPIZE_DEPS \
    git \
    acl \
    file \
    gettext \
    git \
    gnu-libiconv \
    openssh \
    gnupg \
    docker \
    docker-compose \
    ;

RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN apk update \
    && apk add libzip-dev \
    && docker-php-ext-install zip

RUN docker-php-ext-install opcache

COPY --from=composer:2.2 /usr/bin/composer /usr/local/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
# install Symfony Flex globally to speed up download of Composer packages (parallelized prefetching)
RUN set -eux; \
composer global config --no-plugins allow-plugins.symfony/flex true; \
composer global require "symfony/flex" --prefer-dist --no-progress --classmap-authoritative; \
composer clear-cache
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /app

# build for production
ARG APP_ENV=prod

# prevent the reinstallation of vendors at every changes in the source code
COPY composer.json composer.lock symfony.lock ./
RUN set -eux; \
composer install --prefer-dist --no-dev --no-scripts --no-progress; \
composer clear-cache

# do not use .env files in production
COPY .env ./
RUN composer dump-env prod; \
rm .env

# copy only specifically what we need
COPY bin bin/
COPY config config/
COPY src src/

RUN set -eux; \
mkdir -p var/cache var/log; \
composer dump-autoload --classmap-authoritative --no-dev; \
composer run-script --no-dev post-install-cmd; \
chmod +x bin/console; sync
VOLUME /app/var

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
COPY docker/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini

COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

CMD ["/app/bin/console"]