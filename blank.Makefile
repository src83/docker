# Use:  $ make <target>
# All targets are described below starting from 'Containers status' section.
# Example: target name is 'ps:' and your shell-command is '$ make ps'. Easy.

#####################################
###                               ###
###     Configure section         ###
###                               ###
#####################################

# Set the project name in accordance with .env file in this folder
project_name =


#####################################
###                               ###
###    Auto-Configure section     ###
###    Don't touch this stuff     ###
###                               ###
#####################################

container_nginx = $(project_name)_nginx
container_redis = $(project_name)_redis
container_db = $(project_name)_db
container_php = $(project_name)_php
php_service = php
db_service = db
# Got it from docker-compose.yml ('Docker Volumes' section)
volume_db = $(project_name)_db-data
volume_redis = $(project_name)_redis-data


#####################################
###                               ###
###     Containers status         ###
###                               ###
#####################################

# Show all started containers
ps:
	@docker ps

# Show all enabled containers
psa:
	@docker ps -a

# Show all listen ports
listen:
	@netstat -natp | grep LISTEN


#####################################
###                               ###
###     Actions on containers     ###
###                               ###
#####################################

build_nocache:  # Build containers NOT from cache
	@docker-compose build --no-cache

build:  # Build containers
	@docker-compose build

rebuild: down build up_d init_logs    # ReBuild && UP containers

up: up_d init_logs    # Load docker images and create containers and UP containers

down:   # Контейнеры стопаются и удаляются. Если БД не в волуме, то ВМЕСТЕ С БД!
	@docker-compose down

start:  # Starting of built containers
	@docker-compose start

stop:   # Stopping of running containers without delete it
	@docker-compose stop

restart: stop start    # ReStarting of built containers


#####################################
###                               ###
###    Entrance to containers     ###
###                               ###
#####################################

connect_nginx:  # Connecting to nginx container
	@docker exec -it $(container_nginx) sh

connect_redis:  # Connecting to redis container
	@docker exec -it $(container_redis) sh

connect_db:  # Connecting to DB container
	@docker exec -it $(container_db) bash

connect_php:  # Connecting to PHP container (APP)
	@docker exec -it $(container_php) bash


#####################################
###                               ###
###    Extra..............        ###
###                               ###
#####################################

ownership: # Set ownership on folders and files
	@sudo chown -R $(USER):$(USER) ./
	@sudo find ./containers/* -type d -exec chmod 775 {} \;
	@sudo find ./containers/* -type f -exec chmod 664 {} \;
	@sudo find ./dumps/* -type d -exec chmod 775 {} \;
	@sudo find ./logs/* -type f -exec chmod 666 {} \;

init_logs:  # Create symlink to framework logs folder
	@cd ./logs/ && ln -snf ../../app/storage/logs project
	@docker-compose exec $(db_service) init-logs.sh

up_d:  # Up containers with shell detach
	@docker-compose up -d

get_dump:  # Create and save an archive with SQL Dump file of current state of DB
	@docker-compose exec $(db_service) get-dump.sh

drop_images:  # Drop all images of current project
	@docker rmi $(container_redis) $(container_db) $(container_nginx) $(container_php)

drop_volume_db:  # Drop DB volume
	@docker volume rm $(volume_db)

drop_volume_redis:  # Drop Redis volume
	@docker volume rm $(volume_redis)

drop_volumes: drop_volume_db drop_volume_redis  # Drop DB and Redis volumes

clean: down drop_volumes drop_images  # Drop DB, Redis volumes and related images


#####################################
###                               ###
###    Laravel commands           ###
###                               ###
#####################################

drop_vendor:  # Delete vendor folder
	@rm -rf ../app/vendor

composer_install: # Install composer dependency >> ./vendors
	@docker-compose exec $(php_service) composer install

composer_update: # Update composer dependency >> ./vendors
	@docker-compose exec $(php_service) composer update

artisan: # Show artisan list
	@docker-compose exec $(php_service) php artisan

key_gen: # Generate APP key
	@docker-compose exec $(php_service) php artisan key:generate

run_migrations: # Run migrations
	@docker-compose exec $(php_service) php artisan migrate

