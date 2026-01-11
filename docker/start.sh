#!/bin/sh

NGINX_VERSION=$(nginx -v 2>&1 | cut -d"/" -f2)
OS_VERSION=$(grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '"')
DATETIME=$(date '+%d/%m/%Y %H:%M:%S')

sed -i "s|__HOSTNAME__|$(hostname)|g" /usr/share/nginx/html/index.html
sed -i "s|__IP__|$(hostname -i)|g" /usr/share/nginx/html/index.html
sed -i "s|__NGINX_VERSION__|$NGINX_VERSION|g" /usr/share/nginx/html/index.html
sed -i "s|__OS_VERSION__|$OS_VERSION|g" /usr/share/nginx/html/index.html
sed -i "s|__DATETIME__|$DATETIME|g" /usr/share/nginx/html/index.html

nginx -g "daemon off;" &

while true; do
  if [ -f /etc/load_flag/flag ] && [ "$(cat /etc/load_flag/flag)" = "true" ]; then
    stress --cpu 1 --timeout 5
  else
    sleep 1
  fi
done