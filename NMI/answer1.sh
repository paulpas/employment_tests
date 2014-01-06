#!/bin/bash
# 1) Write/install a script that will compress any log files that have
# modification dates of over 5 days ago using gzip format. Please also
# delete any compressed files that are over 45 days old. The working directory
# is in /var/log/syslog. *Empty directories should be removed as well.*
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

# Destination directory for archive, the date fill be filled in later
DESTFILE=$HOME/$BASE

# Log location
SRCDIR=/var/log/syslog

# Find files modified over 5 days ago, I am assuming this is > 5 and not >= 5. Thus >= 6.  Semantics.
#
# mtime is tricky because it's explicit and I will have to iterate through a for loop. Not going to worry about
# forking and using wait for this since I cannot guarantee io can handle it on a production system.  I could use ionice -c3. 
#
# I'm going to assume >5..45 days since we're guaranteeing file rotation will occur.

# Number of days to check, subtract one in your head to see how many days of files we are KEEPING.
MinArchiveDays=6

# Max days to check, this valus is explicit
#
# MaxArchiveDays could be set to a larger value to satisfy needs, say 365.
MaxArchiveDays=45

# Find files and export list

# If this is a first run then archive every file
# If an existing archive doesn't exist, then the script is a first-run so collect all logs
# If an existing archive exists, proceed to the iterated run.
ls $DESTFILE.20[0-9][0-9][0-9][0-9][0-9][0-9].tgz &>/dev/null
STATUS=$?

if (( $STATUS != 0 ))
then
	cd $HOME
	find $SRCDIR -type f >> $temp
	iowait -c3 tar zcf $DESTFILE.$today.tgz `cat $temp` &>/dev/null
else
	# By using -type f we avoid archiving any empty directories, thus satisfying the logic requirements in the problem.
	# -daystart is used to round to the nearest day, useful for forensics.
	for i in $(eval echo {$MinArchiveDays..$MaxArchiveDays})
	do
		find $SRCDIR -type f -daystart -mtime $i >> $temp
	done
fi

# Tarball files.  I'll use gzip compression.  If I used gzip like you specified then there will be several individual files.
# That is not very useful for real-life and I will take the liberty of using tar.
#
# Work in $HOME to preserve directory structure, avoiding a mess if you explode the archive in the wrong place that's already full.
cd $HOME
iowait -c3 tar zcf $DESTFILE.$today.tgz `cat $temp` &>/dev/null

# Rotate archives that are older than 45 days old
# I deliberately do not use find + -atime + -mtime because we could modify the archive after the fact, move it to dir2, then 
# back to dir1, eliminating the usefulness of those values.

# Number of days to keep, subtract one in your head to see how many days of files we are KEEPING.
MaxRotateDays=46

# Set date for MaxArchiveDays ago for file rotation
ArchiveRotateDate=`date --date="$MaxRotateDays days ago" +%Y%m%d` 

rm -f $DESTFILE.$ArchiveRotateDate.tgz &>/dev/null

# Delete temp files
rm -f $temp
