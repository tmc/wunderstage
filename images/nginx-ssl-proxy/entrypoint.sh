#!/bin/sh
exec 2>&1
cp /etc/config/nginx.conf.tmpl /etc/nginx/nginx.conf.tmpl || echo '/etc/config/nginx.conf.tmpl not found, falling back to default nginx.conf.tmpl'
cat /etc/nginx/nginx.conf.tmpl | tmpl > /etc/nginx/nginx.conf
while true; do
  date
  nginx -c /etc/nginx/nginx.conf -g "daemon off;"
  sleep 5
done
