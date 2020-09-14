FROM alpine:3.12.0
ARG WORK_DIR=/tmp/src/
WORKDIR ${WORK_DIR}

ARG DB_HOST 
ARG DB_NAME
ARG DB_PASSWORD
ARG DB_USER

ENV HOST ${DB_HOST}
ENV DB ${DB_NAME}
ENV PASSWORD ${DB_PASSWORD}
ENV USER ${DB_USER}

RUN apk update && apk --no-cache upgrade && \
    apk add --no-cache openrc apache2 php7-apache2 libmcrypt-dev php7 php7-fpm php7-opcache php7-pdo_mysql php7-xml \
 php7-xmlrpc php7-json php7-soap php7-mbstring php7-pecl-mcrypt php7-pecl-memcache php7-mysqli php7-ctype git && \
    rc-update add php-fpm7 default && \
    git clone https://github.com/OlehKuryshko/dtapi.git /tmp/src/ && \
    rm -rf /var/www/localhost/htdocs/index.html && \
    mv /tmp/src/conf/httpd.conf /etc/apache2/httpd.conf && \
    cp -r /tmp/src/conf/api /var/www/localhost/htdocs/api && \
    cp -r ${WORK_DIR}/application /var/www/localhost/htdocs/api/ && \
    sed -i "/'dsn'/ s|mysql:host=localhost;dbname=dtapi2|mysql:host=${HOST};dbname=${DB}|" /var/www/localhost/htdocs/api/application/config/database.php && \
    sed -i "/'password'/ s|'dtapi'|'${PASSWORD}'|" /var/www/localhost/htdocs/api/application/config/database.php && \
    sed -i "/'username'/ s|'dtapi'|'${USER}'|" /var/www/localhost/htdocs/api/application/config/database.php && \
    mkdir /var/www/localhost/htdocs/api/application/cache /var/www/localhost/htdocs/api/application/logs && \
    chmod 733 /var/www/localhost/htdocs/api/application/cache && \
    chmod 722 /var/www/localhost/htdocs/api/application/logs && \
    chown apache. -R /var/www/localhost/htdocs/ && \
    mkdir -p /etc/apache2/sites-available/ && \
    mv /tmp/src/conf/dtapi.conf  /etc/apache2/sites-available/dtapi.conf

CMD ["-D","FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]
