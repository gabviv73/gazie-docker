FROM php:8.2-apache
ARG BUILD_VERSION
ENV VERSION=${BUILD_VERSION}
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
WORKDIR /var/www/html
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update && \
  apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libxpm-dev \
    libxslt1-dev \
    libzip-dev \
    libc-client-dev \
    sendmail  \
    curl \
    unzip \
    locales-all && \
  docker-php-ext-install -j$(nproc) iconv && \
  docker-php-ext-install -j$(nproc) mysqli && \
  docker-php-ext-install -j$(nproc) pdo && \
  docker-php-ext-install -j$(nproc) pdo_mysql && \
  docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg && \
  docker-php-ext-install -j$(nproc) gd && \
  docker-php-ext-install xsl && \
  docker-php-ext-install -j$(nproc) zip && \
  docker-php-ext-install intl && \
  apt-get install -y libkrb5-dev && \
  docker-php-ext-configure imap \
    --with-imap-ssl \
    --with-kerberos && \
  docker-php-ext-install imap && \
  curl -fkSL -o gazie.zip https://downloads.sourceforge.net/project/gazie/gazie/${VERSION}/gazie${VERSION}.zip && \
  unzip -q gazie.zip && \
  rm -f gazie.zip && \
  /bin/bash -O dotglob -c 'mv gazie/* .' && \
  rmdir gazie && \
  mv config/config/gconfig.myconf.default.php config/config/gconfig.myconf.php && \
  sed -i -e "s/define('Host', 'localhost');/define('Host', 'gazie-db');/"     config/config/gconfig.myconf.php && \
  sed -i -e "s/define('User', 'root');/define('User', 'gazie');/"             config/config/gconfig.myconf.php && \
  sed -i -e "s/define('Password', '');/define('Password', 'gaziePassword');/" config/config/gconfig.myconf.php && \
  mkdir -p data/files/1 && \
  chown -R www-data:www-data . && \
  chmod -R 755 . && \
  chmod -R g+w data && \
  chmod -R g+w library && \
  touch /usr/local/etc/php/conf.d/uploads.ini && \
  echo "upload_max_filesize = 100M;\npost_max_size = 100M;\nmax_execution_time = 3000;" >> /usr/local/etc/php/conf.d/uploads.ini && \
  apt-get autoremove --purge -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libxpm-dev \
    libxslt1-dev \
    libzip-dev \
    libc-client-dev \
    curl \
    unzip \
    locales-all && \
  apt-get -y autoclean && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
  rm -r /var/lib/apt/lists/*

COPY php-mail.conf /usr/local/etc/php/conf.d/mail.ini

EXPOSE 80
