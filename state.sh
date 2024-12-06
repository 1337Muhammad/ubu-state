#!/bin/bash

# Set TERM for tput to work
export TERM=xterm

export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin

# setting absolute path used tools to avoid cronjob fails
AWK="/usr/bin/awk"
DF="/usr/bin/df"
SED="/usr/bin/sed"
GREP="/usr/bin/grep"
HEAD="/usr/bin/head"

# Take LOG_FILE and THRESHOLD as parameters with fallback defaults
LOG_FILE=${1:-"/home/ubu/Desktop/odc/tasks/1_bash/system_stat.log"}   # First parameter or default to "system_stat.log"
THRESHOLD=${2:-80}                # Second parameter or default to 80

#defining some colors variables using tput
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

#defining date time vars
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%H:%M")

echo "******************************************* ${current_date} ${current_time} *******************************************" >> $LOG_FILE

#flag to ensure headers are printed once
headers_printed=false

#iterating through each line of (df -h) to warn user if a disk exceeded THRESHOLD
while read -r line; do
        #storing header lines of (df -h) to print it if a warning will be printed
        if [[ $line =~ "Filesystem" ]];then
                df_header_line="$line"
                continue
        fi

        #checking the field number 5 (usage percent), replacing % with empty to perform the greater-than operation
        if [[ `echo $line | $AWK '{print $5}' | $SED 's/%//'` -gt ${THRESHOLD} ]];then

                #if headers printed before then escape
                if [[ $headers_printed == false ]];then
                        echo "         $df_header_line" >> $LOG_FILE
                        headers_printed=true
                fi
                #printing the warning about exceeded disk usage of THRESHOLD
                echo "${red}Warning:${reset} $line ${red}disk is almost full!${reset}" >> $LOG_FILE

		#sending warning mail
		echo -e "Subject: Disk Usage Alert: $HOSTNAME\n\nWarning: Disk usage exceeded ${THRESHOLD}%.\n\nDetails:\n$line" | msmtp --from=default -t mohamedsoudy999@gmail.com

        fi
done <<< "$(df -h)"
#****************************************************************************************#


#printing current cpu usage %
#calculating the total cpu usage from the /proc/stat file
echo >> $LOG_FILE
CPU=`$GREP 'cpu ' /proc/stat | $AWK '{cpu_usage=($2+$4)*100/($2+$4+$5)} END {print cpu_usage}'`

#if cpu usage is above 75 print in red
if [[ $CPU > 75 ]];then
        echo "CPU usage: ${red}${CPU}%${reset}" >> $LOG_FILE
else
        echo "CPU usage: ${green}${CPU}%${reset}" >> $LOG_FILE
fi
#***************************************************************************************#
#Memory usage
echo >> $LOG_FILE
echo "Memory:" >> $LOG_FILE
free -h | $GREP Mem: | $AWK '{totMem=$2; usedMem=$3; freeMem=$4} END {print "Total Memory: " totMem; print "Used Memory: " usedMem; print "Free Memory: " freeMem}'  >> $LOG_FILE
#***************************************************************************************#



## top 5 processes using memory
echo >> $LOG_FILE
echo "Top 5 Process using memory: " >> $LOG_FILE
ps aux --sort=-%mem | $HEAD -n 6 | $AWK '{print $1,$2,$3,$4,$11}' >> $LOG_FILE
