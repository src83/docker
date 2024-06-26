## Очень краткая инструкция

### О сборке

Прежде всего, эта сборка - для Laravel, но также подойдёт и для иных фреймворков и самописных решений.

Сборка представляет собой Docker StarterKit для быстрого запуска проектов на LEMP-стеке.
Работающая система распределена по пяти контейнерам и соответствующим сервисам:
* `db` - последние версии `MariaDB` или `MySQL` (на выбор)
* `redis` - noSQL-хранилище под кеш или иные цели
* `nginx` - фронт-сервер с настроенным `fastcgi_cache` и настройками под три окружения (local, test, prod).
* `php-fpm` - текущая поддержка версий: 7.2 - 8.3 (ряд легко расширяется). В контейнере также запущен `supervisor` с задачей по обработке очередей, `cron` и `xDebug`.
* `clickhouse` - последняя версия `Clickhouse`

Наиболее часто используемые команды для работы с контейнерами вынесены в самодокументируемый `Makefile`. Это ускоряет и упрощает работу с контейнерами, минимизируя вероятность опечатки. Смотрите подробности внутри `Makefile`. 

Все контейнеры работают в единой `TimeZone`, указанной в `.env` файле самой сборки. Если ничего не указано - по умолчанию будет `UTC`.

Все сервисы, запущенные в контейнерах, пишут логи. См. папку `logs`.

Одной лишь командой делается дамп базы, пакуется в архив и сохраняется в папке `dumps`.

Приятной работы! ;)

### Требования к окружению текущего хоста - должно быть установлено:
* git
* docker
* docker-compose (подробности в разделе 'Примечания')
* make

### Структура каталогов или как добавить сборку к проекту
* Проект и сборка должны быть расположены в соседних папках. Для этого, где-нибудь на диске создаём верхнеуровневую папку-обёртку, например `myProject`.
* Внутри неё создаём только две папки: `app` и `docker`:
   1. В `app` клонируем код проекта на Laravel.
   2. В `docker` клонируем текущую сборку.
* Важно, чтобы корень проекта был в самой папке `app`. Таким образом, правильный путь к индексному файлу будет `myProject/app/public/index.php`

### Настроить (или проверить) конфиги сборки
* Запустить `init.sh` - будут созданы каталоги `dumps` и `logs` с подкаталогами и добавлены некоторые конфиги. Также, появятся базовые настройки nginx.

* Настроить `.env`. Можно указать только параметры `PROJECT_NAME`, `PROJECT_DOMAIN` и `COMPOSE_PROJECT_NAME`, остальное оставить как есть.

* Настроить `Makefile` В `Configure section` указать параметр `project_name`. Значение то же самое, что и в предыдущем пункте.

* Настроить `containers/mysql/database.env`
 
* Настроить `containers/clickhouse/database.env`

* Для настройки Nginx: нужные конфиги уже скопированы в папку `containers/nginx/configs`. По умолчанию, в них предусмотрена поддержка проекта с одним доменом. В этом случае ничего дополнительно делать не нужно. В файле `local.conf` параметр `server_name` по умолчанию указан как универсальный `_`. Но, в случае, когда на проекте предполагается использование поддомена (например `m.domain.loc`), базовые конфиги nginx нужно заменить расширенными, а также, настроить их:
  1. Запустите скрипт `init_ext_nginx.sh`. Он пересоздаст рабочие конфиги nginx для поддержки поддомена. См. папку в папку `containers/nginx/configs`.
  2. Укажите нужные домены в файлах `local.conf` и `mobile_subdomain.conf`.
  3. В файле `nginx-common-begin.conf` раскоментируйте строку `include configs/mobile_subdomain.conf;` 

* cd containers/php-fpm
* Создать симлинк `ln -s Dockerfile-php8.1 Dockerfile` на 8.1 или иную доступную версию PHP.

* cd containers/mysql
* Создать симлинк на одну из СУБД: `ln -s Dockerfile-mariadb Dockerfile` or `ln -s Dockerfile-mysql Dockerfile`

* cd containers/clickhouse
* Создать симлинк для clickhouse: `ln -s Dockerfile-ch Dockerfile`

### Настроить (или проверить) конфиги проекта Laravel
* В папку myProject/app склонировать (или развернуть иным способом) проект.
* cd myProject/app
* cp .env.example .env
* Настроить `.env`
* Into file `/etc/hosts` - append alias `127.0.0.1 project_name.loc`

### Первый запуск (из корневой папки сборки)
* `make build_nocache` - запустить сборку
* `make up` - старт контейнеров
* `make ps` - проверить запустились ли контейнеры
* `make composer_update` - обновляем зависимости - собираем папку vendor
* если параметр `APP_KEY` в файле `.env` пуст - генерим ключ лары - запускаем `make key_gen` из корневой папки сборки
* `make run_migrations` - выполнить миграции (без данных) (или через выполнение команды фреймворка из контейнера) 
* накатить данные миграций 
* Open in browser http://example.loc

#### Всё, должно работать. Теперь можно открывать папку проекта в IDE и работать над кодом.

### Последующие запуски (из корневой папки сборки)
* `make build` - если требуется запустить сборку (или `make rebuild` для пересборки)
* `make up` - старт контейнеров
* Open in browser http://example.loc

### Полное удаление проекта из системы
* `make clean` - стоп контейнеров, удаление контейнеров, образов, волумов

---

**Важно!** Полный список **make**-команд и их описания см. в **Makefile**

---

**Add SSL certificate for test and production environment:**
```bash
sudo docker run -it --rm --name certbot \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
    -p 80:80  certbot/certbot certonly
```

---

**Необходимый минимум, чтобы заработал xDebug**

1. PHP > Debug > Debug port: `9003,9001`
2. PHP > Debug > DBGp Proxy > IDE key: `пусто`, Host: `пусто`, Port: `9001`
3. PHP > Servers > Добавляем сервер:
   * Name: `Docker`, 
   * Host: `_` , 
   * `(v)` Use path mappings (включаем checkbox). 
   * Напротив `Project Files` рабочей папки проекта указываем Absolute path `/srv/app`
4. Перезапускаем трубку (Start Listening for PHP Debug Connections) и всё... должно работать. Если что, смотрим лог.

---

### Примечания

**Установка docker-compose**

1. Идём сюда:
`https://github.com/docker/compose/releases`

2. Берём версию последнего релиза, качаем:
`wget https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-linux-x86_64`

3. Edit `.bashrc` in your home directory and add the following line:
`export PATH="/usr/libexec/docker/cli-plugins:$PATH"`

4. Делаем бинарник запускаемым и кладём в папку:
`/usr/libexec/docker/cli-plugins`

5. Перезапускаем текущий shell-сеанс (выход/вход)

6. Проверяем версию:
`docker-compose -v`
Ожидаемый ответ - что-то вроде: 
`Docker Compose version v2.5.1`

7. Добавляем группу:
`sudo usermod -a -G docker user`

...

**Для переключения проекта на другие версии PHP или DB**
* `make get_dump` - не забываем забекапить базу
* `make down` - удаляем текущие контейнеры
* `make drop_vendor` - удаляем папку vendor из проекта (только при необходимости, при смене версии PHP)
* `make drop_volume_db` - удаляем volume с базой (если нужно перейти на движок другой базы)
* `make drop_volume_redis` - удаляем volume с redis-ом (если нужно)
* `make drop_images` - удаляем образы текущего проекта
* меняем версию `php` в `composer.json` проекта (при смене версии PHP)
* меняем симлинк на Dockerfile с нужной версией PHP (при смене версии PHP)
* меняем симлинк на Dockerfile с нужной версией БД (при смене версии или движка БД)
* если в качестве движка БД используется связка "MySQL и PHP с версией ниже 7.4" - нужно проверить наличие параметра `default_authentication_plugin` в конфиге `docker/mysql/mysqld_custom.cnf`
* удобный момент, чтобы почистить логи (См. папку logs)
* `make build_nocache` - собираем новые образы
* `make up` - создаём и запускаем наши новые контейнеры
* `make ps` - проверяем, что контейнеры успешно запустились
* `make composer_update` - обновляем зависимости для новой версии проекта
* `make run_migrations` - выполняем миграции
#### Важно: если перед сборкой была удалена из проекта папка vendors, то после выполнения `make composer_update` нужно перезапустить контейнеры `make restart`, поскольку без этой папки не стартует `supervisor` внутри контейнера с проектом.  

...

**Кеширование на nginx**
* Если нужно включить fastcgi-кеширование на стороне nginx - нужно раскомментировать строчку `fastcgi_cache microcache;` в файле `docker/nginx/nginx-common-begin.conf`

---
