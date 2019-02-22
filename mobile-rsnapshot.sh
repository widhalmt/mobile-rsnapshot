#!/bin/bash

VERSION=0.1

VARDIR=/var/lib/mobile-rsnapshot
LOG=${VARDIR}/logfile
RSNAPSHOT_BIN=$(which rsnapshot)
SNAPDIR=/root/snap
if [ -f /etc/rsnapshot.conf ]
then
  RSNAPSHOT_ROOT=$(grep snapshot_root /etc/rsnapshot.conf | grep -v ^[[:space:]]*# | cut -f2)
else
  echo "rsnapshot configuration missing - exiting" 
  exit 1
  fi

  echo "mobile-rsnapshot ${VERSION} run on $(hostname) at $(date)" > ${LOG}

  if [ -d ${RSNAPSHOT_ROOT} ]
  then
    echo "rsnapshot root is available" >> ${LOG}
  else
    # fail silently to keep logs clean
    exit 1
    fi
    if [ -d ${SNAPDIR} ]
    then
      echo "Snapdir exists" >> ${LOG}
    else
      mkdir -p ${SNAPDIR} || exit 1
      fi

      CURRENTDATE=$(date +%Y%m%d%H%M)
      HOURLYDATE=$(date +%Y%m%d%H%M -d now-1hour)
      DAILYDATE=$(date +%Y%m%d%H%M -d now-1day)
      WEEKLYDATE=$(date +%Y%m%d%H%M -d now-1week)
      MONTHLYDATE=$(date +%Y%m%d%H%M -d now-1month)
      YEARLYDATE=$(date +%Y%m%d%H%M -d now-1year)

      if [ -d ${VARDIR} ]
      then
        echo "VARDIR exists" >> ${LOG}
      else
        mkdir -p ${VARDIR}
        for i in hourly daily weekly monthly yearly
        do
          echo "0" > ${VARDIR}/$i
        done
        fi

        LASTHOURLY=$(cat ${VARDIR}/hourly)
        LASTDAILY=$(cat ${VARDIR}/daily)
        LASTWEEKLY=$(cat ${VARDIR}/weekly)
        LASTMONTHLY=$(cat ${VARDIR}/monthly)
        LASTYEARLY=$(cat ${VARDIR}/yearly)

        if [ ${HOURLYDATE} -gt ${LASTHOURLY} ]
        then
          echo "doing hourly snapshot" >> ${LOG}
          /bin/date > ${SNAPDIR}/timestamp
          ${RSNAPSHOT_BIN} hourly || exit 1
          echo "${CURRENTDATE}" > ${VARDIR}/hourly
        else
          echo "hourly snapshot not old enough" >> ${LOG}
          fi

          if [ ${DAILYDATE} -gt ${LASTDAILY} ]
          then
            echo "doing daily snapshot" >> ${LOG}
            ${RSNAPSHOT_BIN} daily || exit 1
            echo "${CURRENTDATE}" > ${VARDIR}/daily
          else
            echo "daily snapshot not old enough" >> ${LOG}
            fi

            if [ ${WEEKLYDATE} -gt ${LASTWEEKLY} ]
            then
              echo "doing weekly snapshot" >> ${LOG}
              ${RSNAPSHOT_BIN} weekly || exit 1
              echo "${CURRENTDATE}" > ${VARDIR}/weekly
            else
              echo "weekly snapshot not old enough" >> ${LOG}
              fi

              if [ ${MONTHLYDATE} -gt ${LASTMONTHLY} ]
              then
                echo "doing monthly snapshot" >> ${LOG}
                ${RSNAPSHOT_BIN} monthly || exit 1
                echo "${CURRENTDATE}" > ${VARDIR}/monthly
              else
                echo "monthly snapshot not old enough" >> ${LOG}
                fi

                if [ ${YEARLYDATE} -gt ${LASTYEARLY} ]
                then
                  echo "doing yearly snapshot" >> ${LOG}
                  ${RSNAPSHOT_BIN} yearly || exit 1
                  echo "${CURRENTDATE}" > ${VARDIR}/yearly
                else
                  echo "yearly snapshot not old enough" >> ${LOG}
                  fi

                  cat ${LOG}
