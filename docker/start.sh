#!/bin/sh

# Substitui hostname, IP, versão do nginx e versão do SO no index.html
NGINX_VERSION=$(nginx -v 2>&1 | cut -d"/" -f2)
OS_VERSION=$(grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '"')

sed -i "s/__HOSTNAME__/$(hostname)/g" /usr/share/nginx/html/index.html
sed -i "s/__IP__/$(hostname -i)/g" /usr/share/nginx/html/index.html
sed -i "s/__NGINX_VERSION__/$NGINX_VERSION/g" /usr/share/nginx/html/index.html
sed -i "s#__OS_VERSION__#$OS_VERSION#g" /usr/share/nginx/html/index.html

# Inicia o Nginx em background
nginx -g "daemon off;" &

# Loop para load dinâmico via ConfigMap
while true; do
  if [ -f /etc/load_flag/flag ] && [ "$(cat /etc/load_flag/flag)" = "true" ]; then
    # Gera carga de CPU quando ENABLED
    stress --cpu 1 --timeout 5
  else
    sleep 1
  fi
done