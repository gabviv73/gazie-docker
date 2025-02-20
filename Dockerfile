FROM php:8.2-apache
ARG BUILD_VERSION
ENV VERSION=$BUILD_VERSION

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
    unzip 
    #libxml2 \
    #locales locales-all \
    #libkrb5-dev \

RUN docker-php-ext-install -j$(nproc) iconv
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) pdo
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-configure gd \
     --with-freetype \
     --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install xsl
RUN docker-php-ext-install -j$(nproc) zip
RUN docker-php-ext-install intl

RUN docker-php-ext-configure imap --with-imap-ssl # --with-kerberos
RUN docker-php-ext-install imap

RUN make -C /etc/mail

#RUN /etc/init.d/sendmail reload
#RUN echo "php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -X /var/log/sendmail/sendmail.log" >> /usr/local/etc/php-fpm.conf
#RUN echo -e "$(hostname -i)\t$(hostname) $(hostname).localhost" >> /etc/hosts

WORKDIR /var/www/html

RUN curl -fkSL -o gazie.zip https://downloads.sourceforge.net/project/gazie/gazie/${VERSION}/gazie${VERSION}.zip
RUN unzip -q gazie.zip
RUN rm -f gazie.zip
RUN /bin/bash -O dotglob -c 'mv gazie/* .'
RUN rmdir gazie

#RUN git clone -b v$VERSION https://github.com/danelsan/GAzie-mirror.git .
#RUN apt-get autoremove --purge -y git
RUN mv config/config/gconfig.myconf.default.php config/config/gconfig.myconf.php
RUN sed -i -e "s/define('Host', 'localhost');/define('Host', 'gazie-db');/"     config/config/gconfig.myconf.php
RUN sed -i -e "s/define('User', 'root');/define('User', 'gazie');/"             config/config/gconfig.myconf.php
RUN sed -i -e "s/define('Password', '');/define('Password', 'gaziePassword');/" config/config/gconfig.myconf.php
RUN mkdir -p data/files/1
RUN chown -R www-data:www-data .
RUN chmod -R 755 .
RUN chmod -R g+w data
RUN chmod -R g+w library;

# All extension  
#RUN sed -i "/^;security.limit_extensions =.*/asecurity.limit_extensions = " /usr/local/etc/php-fpm.d/www.conf

RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 100M;\npost_max_size = 100M;\nmax_execution_time = 3000;" >> /usr/local/etc/php/conf.d/uploads.ini
#ENV APACHE_DOCUMENT_ROOT /var/www

COPY php-mail.conf /usr/local/etc/php/conf.d/mail.ini

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

#VOLUME /var/www/html

#RUN /etc/init.d/sendmail start
RUN apt autoremove --purge unzip curl -y && \
    apt-get -y autoclean && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -r /var/lib/apt/lists/*

EXPOSE 80
