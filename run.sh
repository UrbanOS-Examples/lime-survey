#!/bin/bash

cp -r /app/html /var/www
chown -R daemon:daemon /var/www/html
httpd-foreground
