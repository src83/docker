#!/bin/bash

if [ $# -eq 0 ]; then
    cp .env.blank .env
    cp blank.Makefile Makefile
    cp containers/mysql/database.blank.env containers/mysql/database.env

    mkdir -p containers/nginx/configs
    cp containers/nginx/examples/1-main/domain/local.conf containers/nginx/configs
    cp containers/nginx/examples/2-parts/nginx-common-begin.conf containers/nginx/configs
    exit 1
fi


if [ "$1" = "-s" ]; then
    cp containers/nginx/examples/1-main/subdomain/local.conf containers/nginx/configs
    cp containers/nginx/examples/2-parts/nginx-common-begin.conf containers/nginx/configs
    cp containers/nginx/examples/3-snippets/mobile_subdomain.conf containers/nginx/configs
else
    echo "Invalid parameter."
    exit 1
fi