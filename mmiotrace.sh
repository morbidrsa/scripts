#!/bin/sh

TRACEDIR=/sys/kernel/debug/tracing
MODULE=""

if [ $UID -ne 0 ]; then
	echo "Need to be run as root";
	exit 1;
fi

if [ $# -ne 1 ]; then
	echo "Usage: $(basename $0) driver"
	exit 1
fi

MODULE=$1

if ! grep -q mmiotrace ${TRACEDIR}/available_tracers; then
	echo "MMIOTRACE unavailable";
	exit 1;
fi

echo 64000 > ${TRACEDIR}/buffer_size_kb

echo mmiotrace > ${TRACEDIR}/current_tracer
cat ${TRACEDIR}/trace_pipe > mydump.txt &
sleep 10
echo "Probing ${MODULE}" > ${TRACEDIR}/trace_marker
modprobe ${MODULE}
echo "Probing ${MODULE} done" > ${TRACEDIR}/trace_marker
echo nop > ${TRACEDIR}/current_tracer

cp mydump.txt mmiotrace-$(uname -r).txt
