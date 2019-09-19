#!/bin/bash
###################################################
#                                                 #
#  Author: j.iacono@epsi.fr                       #
#                                                 #
#  iif-extract-json.sh                            #
#  Usage: iif-extract-json.sh <db> <table>        #
#    Known tables are "customer" and "orders"     #
#                                                 #
# This script extracts structure and content      #
#   out of database tables in iif.                #
#                                                 #
#                                                 #
# Version: 0.1                                    #
#                                                 #
###################################################
#
#
### Documentation used
# - http://sysadmin.cyklodev.com/script-et-guide-dinstallation-pour-informix-12-10-sur-ubuntu-14-04-lts-en-mode-silent/
# - https://www.ibm.com/support/knowledgecenter/en/SSGU8G_12.1.0/com.ibm.dba.doc/ids_dba_033.htm (scripting bash)
#
#
### Notes
# Since we're unsure at this point if either table structure or content is expected, we will retrieve both.
#
# Also, exporting to JSON format has not been understood so far, so we will extract data as Text in this version.
#
#
### Todo
# Actually Use the JSON format !



### Catching and using arguments

# Catch argument. If second argument not present, then...
if [ -z "$2" ]; then
    echo "Arguments expected : <db> <table>"
    echo "Known tables are \"customer\" and \"orders\""
    exit 1
fi

# Return help if asked
if [ $1 == "-h" ]; then
    echo "Usage: iif-extract-json.sh <db> <table>"; fi
if [ $1 == "--help" ]; then
    echo "Usage: iif-extract-json.sh <db> <table>"; fi

# Using arguments to set vars
db=$1
table=$2

structureFile="structure_$db-$table.txt"
dataFile="data_$db-$table.txt"



### Retrieving from base

# Retrieving structure
echo ">>>    Retrieving structure for table $table in db $db..."
# dbschema –d $db –t $table -ss > $structureFile &>/dev/null # returns empty file, to be investigated
dbschema –d $db –t $table -ss > $structureFile

# Check exit code of last command
exitcode=$?
if [ $exitcode -ne 0 ] ; then
        echo -e ">>>        [\033[31m\033[1mFAIL\033[0m]: Error retrieving structure for table $table in db $db"
	    echo ">>>            Error code : $exitcode"
        exit 1
fi

# /!\ Seems to return 0 even if table is not found, since dbschema would "successfully" returns an empty file containing "No table or view xxxx."
# So, inspecting file to test this case : If string present in the file, return error
# grep "No table or view" $structureFile &>/dev/null
grep "No table or view" $structureFile

if [ $? -eq 0 ] ; then # string is detected, table not found
        echo -e ">>>        [\033[31m\033[1mFAIL\033[0m]: Table or view $table not found"
        exit 1
else

        echo -e ">>>        [$structureFile] [\033[32m\033[1mSUCCESS\033[0m]"
        echo
fi


# Retrieving data
echo ">>>    Retrieving data for table $table in db $db..."

# echo "select * from $table" | dbaccess $db > $dataFile &>/dev/null
echo "select * from $table" | dbaccess $db > $dataFile

# Check exit code of last command
exitcode=$?
if [ $exitcode -eq 0 ] ; then
        echo -e ">>>        [$dataFile] [\033[32m\033[1mSUCCESS\033[0m]"
	    echo
else
        echo -e ">>>        [\033[31m\033[1mFAIL\033[0m]: Error retrieving data for table $table in db $db"
        echo ">>>            Error code : $exitcode"
        exit 1
fi


# EOF











