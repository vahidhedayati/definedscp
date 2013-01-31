#!/bin/bash

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
