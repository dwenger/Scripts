#!/bin/zsh
# Format needed for Google Sheet download: https://docs.google.com/spreadsheets/u/0/d/<documentID>/export?format=csv&id=<documentID>&gid=0

################### IMPORTANT - REQUIRED PARAMETERS ###################
# Pass the URL for your CSV in Parameter 4 in your JPS policy.
# Set Parameter 5 in your JPS policy to 0 if not all computers require a defined hostname. Set to 1 if all computers require a defined hostname.
#######################################################################

# Check Parameter 5. If empty or unexpected value, exit with an error.
if [[ "${5}" == "" ]]; then
    echo "ERROR: Nothing passed to Parameter 5. Make sure it matches one of the options specified in the script header comments."
    exit 1
elif [[ "${5}" == "0" ]]; then
    param5echo="The computer serial did not match any in the list."
elif [[ "${5}" == "1" ]]; then
    param5echo="ERROR: The computer serial did not match any in the list."
else echo "ERROR: Unexpected value passed to Parameter 5. Make sure it matches one of the options specified in the script header comments."
    exit 1
fi

csvURL="${4}"
csvPath='/var/tmp/computernames.csv'
serial="$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial/ {print $4}')"

downloadCSV() {
    if [[ "${csvURL}" != "" ]]; then
        if [[ -e "${csvPath}" ]]; then
            echo "CSV already in expected location. Cleaning up before continuing..."
            cleanUp
        fi
        echo "Downloading CSV..."
        /usr/bin/curl -L "${csvURL}" -o "${csvPath}"
    else
        echo "ERROR: No remote URL was supplied. The remote URL should be passed in Parameter 4."
        exit 1
    fi
}

cleanUp() {
    /bin/rm "${csvPath}"
}

serialCheck() {
    if [[ -e "${csvPath}" ]]; then
        # Check to see if computer serial is in the downloaded CSV
        if [[ "$(/usr/bin/grep -ciw "${serial}" "${csvPath}" )" == '1' ]]; then
            echo "Computer serial has a match in the CSV. We can move on to the rename."
        else
            echo "${param5echo}"
            exit "${5}"
        fi
    else
        echo "ERROR: CSV not found in expected location. Was a URL passed in Parameter 4, and if so, is it correct?"
        exit 1
    fi
}

renameComputer() {
    echo "Renaming computer..."
    rename="$('/usr/local/bin/jamf' setComputerName -fromFile "${csvPath}")"
    if [[ "$(/usr/bin/grep -ciw 'Set' <<<"${rename}")" == '1' ]]; then
        echo "Computer name successfully set to: $(/usr/bin/awk '/Set/ {print $NF}' <<<${rename})"
        "/usr/local/bin/jamf" recon
        "/usr/local/bin/jamf" policy -trigger restart2m
        exit 0
    else
        echo "ERROR: Computer hostname was not changed."
        echo "${rename}"
        exit 1
    fi
}

main() {
    downloadCSV
    serialCheck
    renameComputer
    cleanUp
}

main
