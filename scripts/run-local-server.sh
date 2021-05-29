#!/bin/sh

sed -i 's/^name/#name/' docker-compose.yml
docker-compose up
sed -i 's/^#name/name/' docker-compose.yml