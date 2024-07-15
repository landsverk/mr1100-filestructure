#!/bin/sh
#
# Start GUI
#
#

# If there isn't /dev/fb0 don't start, GUI cannot run
if [ ! -c /dev/fb0 ]; then
 echo GUI not started - no framebuffer > /dev/kmsg
 exit 1;
fi

HDATA_PART=`cat /proc/mtd | grep hdata | sed -e 's/mtd/\/dev\/mtdblock/' -e 's/://' | awk '{print $1}'`
USERDATA_PART=`cat /proc/mtd | grep userdata | sed -e 's/mtd/\/dev\/mtdblock/' -e 's/://' | awk '{print $1}'`
USERRW_PART=`cat /proc/mtd | grep userrw | sed -e 's/mtd/\/dev\/mtdblock/' -e 's/://' | awk '{print $1}'`

# NTGR_TBD
#mount ${USERDATA_PART} /usr
#mount ${HDATA_PART}    /mnt/hdata
#mount ${USERRW_PART}   /mnt/userrw

config() {
 CFG=$1
 DST=$2
 if [ -f ${CFG} ] ; then
   echo `hexdump -e '1/4 "0x%x"' ${CFG} ` > ${DST}
 fi
}
# We should find out what touchscreen is installed in the system. It is not
# clear at this time, how to do it, so hard-code it for now
MODULE=ntgr_msg2133
# Config calibration info for touchscreen - we need to do it before
# Gui starts as it reads it only once at the beginning.
config /mnt/userrw/ntgnv/LCD_MAX_X /sys/module/${MODULE}/parameters/max_x
config /mnt/userrw/ntgnv/LCD_MIN_X /sys/module/${MODULE}/parameters/min_x
config /mnt/userrw/ntgnv/LCD_MAX_Y /sys/module/${MODULE}/parameters/max_y
config /mnt/userrw/ntgnv/LCD_MIN_Y /sys/module/${MODULE}/parameters/min_y


LCDRESOURCES="/lcd"

export NETGEAR_WEBROOT="/mnt/hdata"
export BGIMAGE="${NETGEAR_WEBROOT}${LCDRESOURCES}/images/guibg.png"
export LCDUI="${LCDRESOURCES}/index.html"

# Temporarily block LCD updates to avoid flicker
# (there is boot splash in LCD memory we turn it black first and put new splash in.)
echo 1 > /sys/module/ntgr_st7789s/parameters/noupdate


# start Web Browser - drive LCD
/usr/sbin/restartGui &>/dev/null &

# turn LCD updates back on after a delay
( sleep 8;
  echo 0 > /sys/module/ntgr_st7789s/parameters/noupdate;
  echo 0 > /dev/fb0
) &

