#!/usr/bin/env bash

NOTIFY_ICON=/usr/share/icons/Qogir-dark/32/apps/system-software-update.svg
LOGPATH=`dirname $(readlink -f ${0})`
LOGFILE=updates.log
PAGFILE=package.log
LOGFULL=$LOGPATH/logs/$LOGFILE
PACKAGETXT=$LOGPATH/logs/$PAGFILE
VER=$(hostnamectl | grep "Operating System:" | awk '{printf "%s %s",$3,$4}')
TNOW=$(date "+%s");
ICON=" "
STATUS=0
MAXALTER=86400;      # ---- Berechnet sich wie folgt 24*60*60=86400 Sekunden

function Get_Updates {
            apt-get update > /dev/null 2> /dev/null
            AVUP=`apt-get dist-upgrade -qq -y -s |  grep -c '^Inst '`
            AVPACK=`apt-get dist-upgrade -qq -y -s |  awk '/^Inst / { print $2 }' | sed ':a;N;$!ba;s/\n/ /g'`
            AVUPA=$(($AVUP + 1));
            AVUP=$(($AVUPA - 1));
            if [ $AVUP != 0 ]; then
                STATUS=1
                #STATUSTXT="$AVUP Updates ($AVPACK)"
                STATUSTXT="$AVUP"
                PACKAGES="$AVPACK"
            else
                STATUS=0
                STATUSTXT="0"
                PACKAGES=""
            fi

        echo "$STATUSTXT" > $LOGFULL
        echo "$PACKAGES" > $PACKAGETXT
        output_to_polybar
}

function output_to_bar {
    found_updates=$(cat $LOGFULL)
    if [ "${found_updates}" != "0" ]; then
        echo '<span foreground="#8c5257">'${ICON}'</span>'
    else
        echo '<span foreground="#3a7634">'${ICON}'</span>'
    fi
}

function output_to_polybar {
    found_updates=$(cat $LOGFULL)
    UPDATES=$(cat $PACKAGETXT)

    if [ "${found_updates}" != "0" ]; then
        echo " ${found_updates}"
    else
        echo " 0"
    fi
    
}

case $BLOCK_BUTTON in
    1)
        apt_upd=$(cat $PACKAGETXT)
        notify-send -u normal -i "Updates" "$apt_upd"
        ;;
    3)
        rm ${LOGFULL}
        Get_Updates
        i3-msg reload
esac

mkdir -p ${LOGPATH}/logs

if [ -e $LOGFULL ]; then
TDATEI=$(stat -c %Z $LOGFULL)
ALTER=$(($TNOW - $TDATEI))
MAXALTER=86400     # ---- Berechnet sich wie folgt 24*60*60=86400 Sekunden
    if [ $ALTER -gt $MAXALTER ]; then
        Get_Updates
    else
        output_to_polybar
        exit
    fi
else
    Get_Updates
fi

exit



