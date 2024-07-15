#!/bin/sh
# Copyright 2016 Netgear
#
# Script to shutdown Arlo Apps/Threads/Drivers

set -x

echo "Starting Arlo ShutDown" >> /tmp/system-log

ARLO_SCRIPT_DIR=/etc/init.d
XAGENT_PIDFILE=/tmp/xagent.pid


# If one or more instance of vzdaemon is running stop them all
pid=$(pidof vzdaemon) && echo "Kill vzdaemon" >> /tmp/system-log && kill -9 $(pidof vzdaemon) && echo "Killed" >> /tmp/system-log

# If one or more instance of vzwatchdog is running stop them all
pid=$(pidof vzwatchdog) && echo "Kill vzwatchdog" >> /tmp/system-log && kill -9 $(pidof vzwatchdog) && echo "Killed" >> /tmp/system-log

# vzdamon launches  xagent so wait a second to check these
sleep 2

# If one or more instance of xagent is running stop them all
pid=$(pidof xagent) && echo "Kill xagent" >> /tmp/system-log && kill -9 $(pidof xagent) && echo "Killed" >> /tmp/system-log

# If one or more instance of xagent_control is running stop them all
pid=$(pidof xagent_control) && echo "Kill xagent_control" >> /tmp/system-log && kill -9 $(pidof xagent_control) && echo "Killed" >> /tmp/system-log

if [ -e $XAGENT_PIDFILE ]; then
  rm -f $XAGENT_PIDFILE
fi


echo "Exiting Arlo ShutDown" >> /tmp/system-log

exit 0
