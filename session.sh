#!/usr/bin/env bash
path_to_sessions="/var/lib/php/sessions/"
sessions_to_delete=$(find ${path_to_sessions} -mmin +60 | wc -l)

find /var/lib/php/sessions -mmin +60 -delete | echo "[$(date '+%d/%m/%Y %H:%M:%S')] crontab - Deleting ${sessions_to_delete} sessions in ${path_to_sessions}"