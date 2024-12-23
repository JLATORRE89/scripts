#!/bin/bash
# Date: 23DEC2024
# Description: This will pull in the main proxy configuration file and build one
# in the local directory for use with apps. You must save your proxy list as 
# proxies.csv in order to be picked up by this script and have it autoconfigure them.

# Input CSV file
input_file="proxies.csv"

# Temporary output file for Proxychains
temp_output_file="temp_proxychains.conf"
proxychains_conf="/etc/proxychains4.conf"

# Function to determine proxy type
get_proxy_type() {
    anonymity=$1
    result_http=$2
    result_ssl=$3
    time_socks4=$4
    time_socks5=$5

    if [ "$anonymity" != "none" ] && [ "$result_http" != "none" ]; then
        echo "http"
    elif [ "$anonymity" != "none" ] && [ "$result_ssl" != "none" ]; then
        echo "http"  # Default to http as Proxychains doesn't use https type
    elif [ "$time_socks4" != "none" ]; then
        echo "socks4"
    elif [ "$time_socks5" != "none" ]; then
        echo "socks5"
    else
        echo "http"  # Default to http if no specific type is found
    fi
}

# Remove the header row, extract columns, determine proxy type, and sort based on time values
tail -n +2 "$input_file" | while IFS=';' read -r host port country_code country_name city time_http time_ssl time_socks4 time_socks5 anonymity result_http result_ssl; do
    proxy_type=$(get_proxy_type "$anonymity" "$result_http" "$result_ssl" "$time_socks4" "$time_socks5")
    # Choose the minimum non-empty time value for sorting and ensure it's numeric
    time_value=$(echo -e "$time_http\n$time_ssl\n$time_socks4\n$time_socks5" | grep -v "none" | sort -n | head -n 1)
    if ! [ "$time_value" -eq "$time_value" ] 2>/dev/null; then
        time_value=999999999
    fi
    printf "%09d %s %s %s  # %s, %s\n" "$time_value" "$proxy_type" "$host" "$port" "$country_name" "$city"
done | sort -n | awk '{$1=""; print $0}' | sed 's/^ *//' > "$temp_output_file"

# Copy /etc/proxychains4.conf to proxychains.conf
cp "$proxychains_conf" proxychains.conf

# Append results to proxychains.conf
cat "$temp_output_file" >> proxychains.conf

echo "Extraction, sorting by time values, proxy type determination, and appending complete. Check the proxychains.conf for the updated data."
