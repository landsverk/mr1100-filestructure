#!/bin/sh
# Copyright 2016 Netgear
#
# Script to start up Arlo Apps/Threads during boot

set -x

echo "Starting Arlo Startup" >> /tmp/system-log

export ARLO_BIN_DIR=/usr/bin
export ARLO_SCRIPT_DIR=/etc/init.d
export ARLO_CERTS_DIR=/mnt/userrw/certs
export ARLO_CONF_DIR=/mnt/userrw/ntgnv

export XAGENT_PIDFILE=/tmp/xagent.pid
export XAGENT=${ARLO_BIN_DIR}/xagent
export VZDAEMON=${ARLO_BIN_DIR}/vzdaemon
export VZWATCHDOG=${ARLO_BIN_DIR}/vzwatchdog

serialnumber=`dx Versions.FSN`

source ${ARLO_CONF_DIR}/vzdaemon.env

# remove warning message for openssl command line tool
touch /usr/lib/ssl/openssl.cnf

# Ensure Arlo Apps are not currently running, it will be run from swiapp
#${ARLO_SCRIPT_DIR}/arloshutdown.sh

# start the watchdog
# set START_WATCHDOG to yes or no to enable/disable watchdog
START_WATCHDOG=no

if [ "${START_WATCHDOG}" == "yes" ]; then
    echo $VZWATCHDOG
    $VZWATCHDOG daemons=vzdaemon,xagent &
    VZWATCHDOGPID=$!
fi

modelidfile=/mnt/userrw/ntgnv/ARLO_MODEL_ID
if [ -f $modelidfile ]
then
  MODEL_ID=`zstring $modelidfile`
else
  MODEL_ID=VMB3010
fi

# start vzdaemon
if [ "${START_WATCHDOG}" == "yes" ]; then
    export VZDAEMON_ARGS="$serialnumber ModelId=${MODEL_ID} WatchdogPid=${VZWATCHDOGPID} CameraInputIx=bridge0 BackendUrl=${vz_server_url} CertPath=${ARLO_CERTS_DIR}/ca-bundle-mega.crt MediaServerCertPath=${ARLO_CERTS_DIR}/wowza.netgear.com_Certificate_Only.pem LogLevel=${vz_log_level} HttpServerIx=bridge0 HttpServerPort=8080"
else
    if [[ ! -z "${vz_update_url/ //}" ]]; then
        export VZDAEMON_ARGS="SerialNum=$serialnumber ModelId=${MODEL_ID} UpdateUrl=${vz_update_url} CameraInputIx=bridge0 BackendUrl=${vz_server_url} CertPath=${ARLO_CERTS_DIR}/ca-bundle-mega.crt MediaServerCertPath=${ARLO_CERTS_DIR}/wowza.netgear.com_Certificate_Only.pem LogLevel=${vz_log_level} HttpServerIx=bridge0 HttpServerPort=8080"
    else
        export VZDAEMON_ARGS="SerialNum=$serialnumber ModelId=${MODEL_ID} CameraInputIx=bridge0 BackendUrl=${vz_server_url} CertPath=${ARLO_CERTS_DIR}/ca-bundle-mega.crt MediaServerCertPath=${ARLO_CERTS_DIR}/wowza.netgear.com_Certificate_Only.pem LogLevel=${vz_log_level} HttpServerIx=bridge0 HttpServerPort=8080"
    fi
fi
$VZDAEMON $VZDAEMON_ARGS &
# ${ARLO_SCRIPT_DIR}/launch_xagent.sh &
echo "Exiting Arlo Startup" >> /tmp/system-log

exit 0