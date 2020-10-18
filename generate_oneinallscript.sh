#!/bin/sh
#generate chinadns_chnroute.txt
wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > chnip.txt
echo >chnip.sh
for i in `cat chnip.txt`
do 
  echo ipset -A chnip $i >> chnip.sh
done
cat chnip.sh >> enable_transparent_proxy.sh
