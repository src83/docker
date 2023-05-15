#!/bin/bash

mkdir -p logs/{mysql,nginx,redis}
mkdir -p logs/php-fpm/{crontab,php,supervisor,xdebug}
ln -snf ../../app/storage/logs logs/project

touch logs/mysql/error.log
touch logs/mysql/slow.log

touch logs/nginx/app.access.log
touch logs/nginx/app.error.log
touch logs/nginx/error.log

touch logs/php-fpm/crontab/crontab.log
touch logs/php-fpm/php/php-fpm.log
touch logs/php-fpm/supervisor/supervisor-worker.log
touch logs/php-fpm/supervisor/supervisord.log
touch logs/php-fpm/xdebug/xdebug.log

touch logs/redis/redis-server.log

find ./logs/* -type f -exec chmod 666 {} \;
