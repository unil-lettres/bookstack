FROM php:8.4-apache-trixie

ENV DOCKER_RUNNING=true

ENV COMPOSER_VERSION=2.8.12

# Install additional packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libldap2-dev \
    libtidy-dev \
    libxml2-dev \
    fontconfig \
    fonts-freefont-ttf \
    wget \
    tar \
    curl \
    libzip-dev \
    unzip

# Install needed extensions
RUN docker-php-ext-install -j$(nproc) dom pdo pdo_mysql zip tidy && \
    docker-php-ext-configure ldap && \
    docker-php-ext-install -j$(nproc) ldap && \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd

# Install specific version of Bookstack
COPY VERSION /tmp/BOOKSTACK_VERSION
RUN set -eux; \
    FULL_VERSION="$(tr -d ' \t\r\n' </tmp/BOOKSTACK_VERSION)"; \
    BOOKSTACK_TAG="${FULL_VERSION%%-rev*}"; \
    curl -SL -o bookstack.tar.gz "https://github.com/BookStackApp/BookStack/archive/v${BOOKSTACK_TAG}.tar.gz" && \
    mkdir -p /bookstack && \
    tar xvf bookstack.tar.gz -C /bookstack --strip-components=1 && \
    rm bookstack.tar.gz && \
    rm -f /tmp/BOOKSTACK_VERSION

# Replace the proxy IP with the real client IP
RUN a2enmod rewrite remoteip; \
    { \
    echo RemoteIPHeader X-Real-IP ; \
    echo RemoteIPTrustedProxy 10.0.0.0/8 ; \
    echo RemoteIPTrustedProxy 172.16.0.0/12 ; \
    echo RemoteIPTrustedProxy 192.168.0.0/16 ; \
    } > /etc/apache2/conf-available/remoteip.conf; \
    a2enconf remoteip

RUN sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf && \
    sed -i "s/VirtualHost *:80/VirtualHost *:8080/" /etc/apache2/sites-available/*.conf

# Copy Apache configuration file
COPY config/bookstack.conf /etc/apache2/sites-available/000-default.conf

RUN mv /bookstack /var/www/bookstack && chown -R 33:33 /var/www/bookstack

# Install specific version of Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php -- \
    --version=$COMPOSER_VERSION \
    --install-dir=/usr/local/bin --filename=composer

# Install php dependencies
RUN cd /var/www/bookstack && \
    composer install --optimize-autoloader --no-interaction --no-dev

# Change ownership of the application to www-data
RUN chown -R www-data:www-data /var/www/bookstack

# Copy PHP configuration file
COPY config/php.ini /usr/local/etc/php/php.ini

# Copy Kubernetes poststart script
COPY config/k8s-poststart.sh /var/www/bookstack/k8s-poststart.sh
RUN chmod +x /var/www/bookstack/k8s-poststart.sh

# Copy the entrypoint script
COPY config/docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +x /bin/docker-entrypoint.sh

WORKDIR /var/www/bookstack

# www-data
USER 33

ENV RUN_APACHE_USER=www-data \
    RUN_APACHE_GROUP=www-data

EXPOSE 8080

ENTRYPOINT ["/bin/docker-entrypoint.sh"]
