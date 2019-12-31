#!/bin/bash

if [[ ! -d /src/easyepg  ]]; then
  git clone --depth 1 https://github.com/sunsettrack4/easyepg.git /src/easyepg
fi

cd /src/easyepg && "$@"

# run via cron
if [[ -n "${CRON}" ]]; then
  echo "# setting up cronjob: ${CRON}"
  ( echo "PATH=${PATH}"; echo "${CRON} /bin/bash -c \"cd /src/easyepg && /src/easyepg/epg.sh\"" ) |crontab -
  cron -f
else
  echo "No con schedule specified, exiting..."
fi
