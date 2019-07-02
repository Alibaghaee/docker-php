FROM php:7.1-fpm
MAINTAINER memed <gabriel.couto@memed.com.br>

# Installing packages
RUN apt-get update && apt-get upgrade -y
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y --force-yes xorg libssl-dev libxrender-dev fontconfig xfonts-75dpi curl mariadb-client-10.1 libcurl4-gnutls-dev libxml2-dev libpng-dev libicu-dev libmcrypt-dev libjpeg62-turbo-dev libfreetype6-dev libjpeg62-turbo zlib1g-dev libmemcached11 libmemcached-dev git libgmp-dev psmisc xpdf libmagickwand-dev imagemagick xfonts-utils cabextract wget supervisor nginx

# Using alternative NodeJS Repository
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y --force-yes nodejs

# Install ttf-mscorefonts using DEB
RUN wget http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb && dpkg -i ttf-mscorefonts-installer_3.6_all.deb && rm -f ttf-mscorefonts-installer_3.6_all.deb

# Building memcached extension
RUN git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git && cd php-memcached && phpize && ./configure && make install

# Creating symlink for libgmb
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h

# Install PHP Imagick extension
RUN yes "" | pecl install imagick xdebug

# Adding PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install pdo curl gd intl pdo_mysql mcrypt dom mbstring gmp bcmath zip opcache sysvsem
RUN docker-php-ext-enable memcached
RUN docker-php-ext-enable imagick
RUN docker-php-ext-enable sysvsem
RUN docker-php-ext-enable xdebug
RUN pecl install mongodb
RUN docker-php-ext-enable mongodb

# Cleaning
RUN apt-get clean && apt-get autoremove -y

# Upgrading Node
RUN npm cache clean -f
RUN npm install -g n
RUN n stable

# Adding composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && php composer-setup.php && php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer

# Adding npm-cache
RUN npm install -g npm-cache

# Adding Grunt
RUN npm install -g grunt-cli

# Adding Bower
RUN npm install -g bower

# Adding Gulp
RUN npm install -g gulp gulp-cli

# Default command
CMD ["php-fpm"]
