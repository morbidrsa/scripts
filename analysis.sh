#!/bin/sh

dir="randread"

if [ $# -eq 1 ]; then
	dir="$1"
fi

PATTERN="bw=[0-9.]+[KM]B/s, iops=[0-9]+"

echo "$dir"
for bs in 4 8 16 32 64; do 
	echo -ne "${bs}k "; grep -oP "$PATTERN" "fio-${bs}k-${dir}.txt" \
		| sed 's/iops=//' | sed 's/bw=//' | sed 's/,//g' 
done | awk 'BEGIN { print "BS IOPS BW" } { print $1 " " $3 " " $2}' | column -t --output-separator " | "
