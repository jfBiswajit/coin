#!/bin/sh
set -e

cd /var/www/html

if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "" ]; then
    php artisan key:generate --force
fi

php artisan migrate --force

php artisan config:cache
php artisan route:cache
php artisan view:cache

# Sync public/ to shared volume so nginx can serve static assets
cp -r /var/www/html/public/. /var/www/html/public-volume/

exec php-fpm
