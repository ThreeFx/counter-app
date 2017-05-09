#!/bin/bash

docker run --rm --link redis:redis --name="counter-1" -d bfiedler/haskell-http
docker run --rm --link redis:redis --name="counter-2" -d bfiedler/haskell-http
docker run --rm --link redis:redis --name="counter-3" -d bfiedler/haskell-http

docker run -d -p 5000:80 \
    --name nginx \
    --link counter-1:counter-1 \
    --link counter-2:counter-2 \
    --link counter-3:counter-3 \
    -v `pwd`/resources/nginx/nginx.conf:/etc/nginx/nginx.conf \
    nginx
