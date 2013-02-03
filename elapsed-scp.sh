#!/bin/bash

##############################################################################
# Bash script written by Vahid Hedayati Feb 2013
##############################################################################
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#
##############################################################################

LOGFILE=$1;
## Minutes - before getting latest log file
ELAPSED_TIME=10;
ELAPSED_SECONDS=$(echo $ELAPSED_TIME|awk '{ $3 = $1 * 60; print $3}')
DAY_IN_SECONDS=86400;
HOUR_IN_SECONDS=3600;

WORKING_DIR="/tmp/test-delay-scp";

COMPAREDATE=$(date +%Y-%m-%d -d "0 days ago")


function copyfiles() {
  local LOGFILE=$LOGFILE
  # Build environment
	if [ ! -d "$WORKINGDIR" ]; then
        	mkdir $WORKINGDIR
	fi
	# Get log file
	    	if  [ -f $WORKINGDIR/$LOGFILE ]; then 
			lastcopy=$(stat $WORKINGDIR/$LOGFILE |grep Mod|awk -F"Modify:" '{print $2 " "$3}'|awk -F" " '{print $1}')
			if [ "$lastcopy" == "$COMPAREDATE" ]; then
				if [ "$DAYS" == "0" ]; then
					ptime=$(stat $WORKINGDIR/$LOGFILE|grep Mod|awk -F"Modify:" '{print $2 " "$3}'|awk -F"." '{print $1}'|sed -e "s/^ //g;")
					psec=$(date +%s --date="$ptime")
					csec=$(date +%s)
					dtime=$(echo $csec|awk -v psec=$psec '{$3 = $1 - 'psec'; print $3}')
					runningtime="";
					if [ $dtime -lt $DAY_IN_SECONDS ]; then
						if [ $dtime -le 60 ]; then	
							runningtime="$dtime seconds"
						else
							if [ $dtime -lt $HOUR_IN_SECONDS ]; then
								ntime=$(expr $dtime / 60)
								runningtime="$ntime minutes"
							else
								ntime=$(expr $dtime / $HOUR_IN_SECONDS)
								runningtime="$ntime hours"
							fi
						fi
					else
		 				ntime=$(expr $dtime / $DAY_IN_SECONDS)
                 				runningtime="$ntime days"
					fi
					rtime="Todays log, last copied : $runningtime"; 
					echo $rtime
					if [ $dtime -ge $ELAPSED_SECONDS ]; then
						echo "Over $ELAPSED_TIME minutes ago - will copy logs again -- "
						go=1;
					else
						echo "Copy action cancelled due to last copy period being with 30 minutes"
			   			go=0;
					fi

				else
					echo "$WORKINGDIR/$LOGFILE last copied $lastcopy copy action not necessary"
			   		go=0;
				fi
			else
				echo "File $WORKINGDIR/$LOGFILE was last copied:  $lastcopy Today:  $COMPAREDATE -- missmatch - getting log file "
				go=1;
			fi
	    	fi

	    	if [ $go -ge 1 ]; then
	      		scp $server:${LOGPATH}/$LOGFILE $WORKINGDIR/$LOGFILE
	    	fi
}



copyfiles;
