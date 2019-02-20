#!/bin/bash
cd node_fetch/vars/

###### First Function Starts  Here

root_final ()
{
##### This step will list all the report_*csv and make header  module-name,dit1,dit2,sit1,sit2 for final csv file 


ls report_*.csv|tr "\n" ","|sed "s|report_||g"|sed "s|.csv||g"|sed "s|.$|\n|g"|sed "s|^|module-name,|g"


## This step will list all the module names and setting them in $line
cat report_*csv| cut -d, -f1|sort| uniq | while read line ;
do
# starting the for loop below for each report_*csv file i.e report_dit1.csv , report_dit2.csv report_sit1.csv 

        for i in `ls  report_*csv `;
        do
                # This step verifies that x module is present on which env and if its not present it will be placed as - in final csv file. 
                cat $i | grep "$line" 2>/dev/null 1>/dev/null
                
                if [[ $? -eq 0 ]]; then
                
                        var1=$(grep $line $i |cut -d, -f2); 
                        echo -n "$var1,"
                
                else
                
                        echo -n "-,"
                
                fi
        done  |sed "s|^|$line,|g"| sed "s|.$|\n|g" ;
         
done
}
###### First Function Ended  Here





###### Second Function Starts  Here
root_master_compare()
{

#Comparision between source and Destination Env for module version 

# setting the DEST variable with  cloumn number for Dest env in final_report.csv

DEST=$(cat   final_report.csv |grep 'module-name'| tr ',' "\n"| nl | grep "$dest_node"| awk '{print $1}')

# setting the Source variable with  cloumn number for Dest env in final_report.csv
SOURCE=$(cat   final_report.csv |grep 'module-name'| tr ',' "\n"|nl | grep "$src_node"| awk '{print $1}')


# report_final1.csv file is being created like  module1,1.1.10
cat final_report.csv | grep -v "module-name"|cut -d, -f1,$SOURCE >  report_final1.csv
# report_final1.csv file is being created like  1.1.10
cat final_report.csv | grep -v "module-name"|cut -d, -f$DEST >  report_final2.csv

# Now we are putting above to files content side by side and now they will appear like "module1,1.1.10,1.1.10"  in Report_finalR.csv

paste -d,  report_final1.csv  report_final2.csv > Report_finalR.csv

# Remvoing Temp files
rm -rf report_final1.csv  report_final2.csv




##### this  logic Defines which version needs to be deployed on destination when Source Version is high.

cat Report_finalR.csv | grep -v "module-name" |while read line
do
        Name=$(echo $line|cut -d, -f1)
        Ver1=$(echo $line|cut -d, -f2)
        Ver2=$(echo $line|cut -d, -f3)

                if [[ $Ver1 == "-" ]]; then
                        echo "No action to be taken" 2>/dev/null 1>/dev/null
                elif [[ $Ver1 > $Ver2  ]]; then
                        echo "$Name,$Ver1"
                elif [[ "-" == "$Ver2" ]]; then
                        echo "$Name,$Ver1"
                elif [[ $Ver1 < $Ver2  ]]; then
                        echo "No Action to be taken" 2>/dev/null 1>/dev/null
                elif [[ $Ver1 == $Ver2  ]]; then
                        echo "No Action to be taken" 2>/dev/null 1>/dev/null
                else
                        echo "No Action to be taken" 2>/dev/null 1>/dev/null
                fi

done
rm -rf Report_finalR.csv
}

###### Second Function Ended  Here





#Scripts Starts Execution from here 




root_final > final_report.csv


dest_node=$1
src_node=$2



root_master_compare > Filter_Report.csv

cat Filter_Report.csv | sed "s|^|'|g"|sed "s|,|': '|g"|sed "s|$|',|g"|tr '\n' ' '|sed "s|^|{ |g"|sed "s|, $|}|g"|sed "s|^|  Version_dict : |g"

