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
container_ch = $(project_name)_ch
container_php = $(project_name)_php
php_service = php
db_service = db
# Got it from docker-compose.yml ('Docker Volumes' section)
volume_db = $(project_name)_db-data
volume_redis = $(project_name)_redis-data
volume_ch = $(project_name)_ch-data


#####################################
###                               ###
###     Containers status         ###
###                               ###
#####################################

.PHONY: ps
ps: ## Show all started containers
	@docker ps

.PHONY: psa
psa: ## Show all enabled containers
	@docker ps -a

.PHONY: listen
listen: ## Show all listen ports
	@netstat -natp | grep LISTEN


#####################################
###                               ###
###     Actions on containers     ###
###                               ###
#####################################

.PHONY: build_nocache
build_nocache: ## Build containers NOT from cache
	@docker-compose build --no-cache

.PHONY: build
build: # Build containers
	@docker-compose build

.PHONY: rebuild
rebuild: down build up_d ## ReBuild && UP containers

.PHONY: up
up: up_d ## Load docker images and create containers and UP containers

.PHONY: down
down: ## Контейнеры стопаются и удаляются. Если БД не в волуме, то ВМЕСТЕ С БД!
	@docker-compose down

.PHONY: start
start: ## Starting of built containers
	@docker-compose start

.PHONY: stop
stop: ## Stopping of running containers without delete it
	@docker-compose stop

.PHONY: restart
restart: stop start ## ReStarting of built containers


#####################################
###                               ###
###    Entrance to containers     ###
###                               ###
#####################################

.PHONY: connect_nginx
connect_nginx: ## Connecting to nginx container
	@docker exec -it $(container_nginx) sh

.PHONY: connect_redis
connect_redis: ## Connecting to redis container
	@docker exec -it $(container_redis) sh

.PHONY: connect_db
connect_db: ## Connecting to DB container
	@docker exec -it $(container_db) bash

.PHONY: connect_ch
connect_ch: ## Connecting to Clickhouse container
	@docker exec -it $(container_ch) bash

.PHONY: connect_php
connect_php: ## Connecting to PHP container (APP)
	@docker exec -it $(container_php) bash


#####################################
###                               ###
###    Extra..............        ###
###                               ###
#####################################

.PHONY: ownership
ownership: ## Set ownership on folders and files
	@sudo chown -R $(USER):$(USER) ./
	@sudo find ./containers/* -type d -exec chmod 775 {} \;
	@sudo find ./containers/* -type f -exec chmod 664 {} \;
	@sudo find ./dumps/* -type d -exec chmod 775 {} \;
	@sudo find ./logs/* -type f -exec chmod 666 {} \;

.PHONY: up_d
up_d: ## Up containers with shell detach
	@docker-compose up -d

.PHONY: get_dump
get_dump: ## Create and save an archive with SQL Dump file of current state of DB
	@docker-compose exec $(db_service) get-dump.sh

.PHONY: drop_images
drop_images: ## Drop all images of current project
	@docker rmi $(container_redis) $(container_db) $(container_ch) $(container_nginx) $(container_php)

.PHONY: drop_volume_db
drop_volume_db: ## Drop DB volume
	@docker volume rm $(volume_db)

.PHONY: drop_volume_ch
drop_volume_ch: ## Drop ClickHouse volume
	@docker volume rm $(volume_ch)

.PHONY: drop_volume_redis
drop_volume_redis: ## Drop Redis volume
	@docker volume rm $(volume_redis)

.PHONY: drop_volumes
drop_volumes: drop_volume_db drop_volume_ch drop_volume_redis ## Drop all volumes

.PHONY: drop
drop: down drop_images ## Down all containers, Drop all images

.PHONY: clean
clean: down drop_images drop_volumes ## Down all containers, Drop all images and related volumes


#####################################
###                               ###
###    Laravel commands           ###
###                               ###
#####################################

.PHONY: drop_vendor
drop_vendor: ## Delete vendor folder
	@rm -rf ../app/vendor

.PHONY: composer_install
composer_install: ## Install composer dependency >> ./vendors
	@docker-compose exec $(php_service) composer install

.PHONY: composer_update
composer_update: ## Update composer dependency >> ./vendors
	@docker-compose exec $(php_service) composer update

.PHONY: artisan
artisan: ## Show artisan list
	@docker-compose exec $(php_service) php artisan

.PHONY: key_gen
key_gen: ## Generate APP key
	@docker-compose exec $(php_service) php artisan key:generate

.PHONY: run_migrations
run_migrations: ## Run migrations
	@docker-compose exec $(php_service) php artisan migrate

# Helpers
.PHONY: help
help: ## Show this message
	@printf "\nUse: make <command>\n"
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[44m%-18s\033[0m %s\n", $$1, $$2}'
	@printf "\n"
