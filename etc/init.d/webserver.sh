#!/bin/sh
#
# Start MHS
#
#

# WEB content root
export NETGEAR_WEBROOT="/mnt/hdata"

case "$1" in
    start)
                # SBM 02007 Stop mbimd and qti
                /etc/init.d/mbim stop
                /etc/init.d/qti stop

                # Set overcommit_memory flag
                echo 1 > /proc/sys/vm/overcommit_memory

                # start Web Server
                /usr/sbin/restartNetgearWebApp >/dev/null 2>/dev/null &

                # Mount file containing all s/w licenses
                mount -o loop /usr/web/lic.squash ${NETGEAR_WEBROOT}/licenses
                ;;
    stop)
                killall -HUP restartNetgearWebApp
                killall -HUP NetgearWebApp
        ;;
    *)
        exit 1
        ;;
esac

exit 0
