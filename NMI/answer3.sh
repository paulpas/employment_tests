#!/bin/bash
#  3) Write a script that will run from cron that accesses /server-status and parses out the following values:
# - CPU load %
# - Requests/sec
# - Idle workers
# - # Requests being processed

# Print these values using the following format:
# "cpu: <CPU Load> rps: <Requests Per Second> iw: <Idle workers> cr: <Current Requests Being Processed>"
#
# Paul Pasika
# 01/05/2014
# paulpas@petabit.net
#
# Scripts should be designed to be as easy to learn after you step away and forget
# it ever existed.  Humans are the bottleneck and we need all the help we can get.
#

# Make the script aware of itself, remove ".sh" because that's not important
BASE=`basename $0 | sed -e 's/\.sh//g'`

# tmp file
temp=`mktemp`

# We must know the date for today
today="`date +%Y%m%d`"

# Collect server-status output for parsing
curl http://localhost/server-status > $temp 2>/dev/null

# Parse CPU load %
CPUload=`awk '/CPU load/ {print $8}' $temp | sed -e 's/%//g'`


# Parse request/sec
ReqPerSec=`awk '/requests\/sec/ {print $1}' $temp | awk -F\> '{print $2}'`

# Parse idle workers
IdleWorkers=`awk '/idle\ workers/ {print $6}' $temp`

# Parse requests being processed
ReqProcessed=`awk '/requests\ currently\ being\ processed/ {print $1}' $temp | awk -F\> '{print $2}'`

# Print Output
# Outputting to STDOUT and receiving an email from cron is old-school.  I like to pipe to a common remote syslog server
echo "cpu: $CPUload rps: $ReqPerSec iw: $IdleWorkers cr: $ReqProcessed" #| logger -t $BASE

# Delete temp files
rm -f $temp
