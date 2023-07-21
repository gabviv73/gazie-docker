FROM php:8.2-apache

MAINTAINER Gabriele Vivinetto

RUN apt-get update && apt-get install -y \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      libxml2 \
      libxml2-dev \
      libxpm-dev \
      libxslt1-dev \
      libzip-dev \
      locales locales-all \
      sendmail  \
      unzip \ 
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-install -j$(nproc) mysqli pdo pdo_mysql \
    && docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg \
    && docker-php-ext-install xsl \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install intl

RUN apt-get install -y libc-client-dev libkrb5-dev \
    && make -C /etc/mail

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install imap

RUN /etc/init.d/sendmail reload
#RUN echo "php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -X /var/log/sendmail/sendmail.log" >> /usr/local/etc/php-fpm.conf
#RUN echo -e "$(hostname -i)\t$(hostname) $(hostname).localhost" >> /etc/hosts

WORKDIR /var/www/html
RUN apt-get install -y git
RUN git clone -b v9.05 https://github.com/danelsan/GAzie-mirror.git .
RUN apt-get autoremove --purge -y git
COPY gconfig.myconf.php config/config/gconfig.myconf.php

RUN apt-get -y autoclean \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -r /var/lib/apt/lists/*

RUN   set -ex; \
  chown -R www-data:www-data .; chmod -R 755 .; chmod -R 777 data; chmod -R 777 library;

# All extension  
#RUN sed -i "/^;security.limit_extensions =.*/asecurity.limit_extensions = " /usr/local/etc/php-fpm.d/www.conf

RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 100M;\npost_max_size = 100M;\nmax_execution_time = 3000;" >> /usr/local/etc/php/conf.d/uploads.ini
#ENV APACHE_DOCUMENT_ROOT /var/www

COPY php-mail.conf /usr/local/etc/php/conf.d/mail.ini

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

#VOLUME /var/www/html

RUN /etc/init.d/sendmail start

EXPOSE 80
