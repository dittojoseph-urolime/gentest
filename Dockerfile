FROM php:7.0-apache  
RUN chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite \
    && chown -R 775 /var/www/html \

COPY . /var/www/html  
