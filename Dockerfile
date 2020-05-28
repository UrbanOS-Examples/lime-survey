FROM httpd:2.4.37

ARG lime_version=3.15.5-181115

RUN apt-get update \
 && apt-get install -y \
    curl \
    php7.0 \
    php7.0-cli \
    php7.0-common \
    php7.0-mbstring \
    php7.0-xml \
    php7.0-mysql \
    php7.0-gd \
    php7.0-json \
    php7.0-ldap \
    php7.0-zip \
    php7.0-pgsql \
    php7.0-imap \
    cron \
 && apt-get -yqq clean \
 && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

RUN mkdir -p /var/www

RUN mkdir -p /app/html \
 && curl -L "https://s3.us-east-2.amazonaws.com/scos-third-party-repository/lime-survey/LimeSurvey-${lime_version}.tar.gz" \
  | tar xzf - --strip-components=1 -C '/app/html'

COPY limesurvey.conf /usr/local/apache2/conf/httpd.conf

COPY /session.sh /usr/bin/

COPY /php/sessions /var/lib/php/sessions

COPY /cron/session-cron /etc/cron.d/session-cron

RUN chmod 0644 /etc/cron.d/session-cron

RUN chmod 0744 /usr/bin/session.sh

RUN crontab /etc/cron.d/session-cron

CMD ["cron", "-f"]
