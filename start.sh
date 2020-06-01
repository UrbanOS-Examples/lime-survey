#!/bin/sh
set -e

# start cron service
service cron start

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid

# start apache in the foreground
exec httpd -DFOREGROUND