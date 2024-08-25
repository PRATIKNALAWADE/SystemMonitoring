#!/bin/bash

# Function to display the top 10 most used applications by CPU and memory
function top_apps() {
    echo "Top 10 Applications by CPU and Memory Usage:"
    ps -eo pid,comm,%mem,%cpu --sort=-%cpu | head -n 11
    echo
}

# Function to monitor network connections, packet drops, and traffic
function network_monitor() {
    echo "Network Monitoring:"
    echo "Number of concurrent connections:"
    netstat -tun | grep ESTABLISHED | wc -l

    echo "Packet drops:"
    netstat -i | grep -v 'Iface' | awk '{print $1 ": " $4 " packets dropped"}'

    echo "Network traffic (MB in and out):"
    ifconfig | grep -A 1 'enp' | awk '/RX packets/ {print $3/1024/1024 " MB received"}; /TX packets/ {print $7/1024/1024 " MB transmitted"}'
    echo
}

# Function to monitor disk usage with highlighting for high usage
function disk_usage() {
    echo "Disk Usage:"
    df -h | grep -vE '^Filesystem|tmpfs|cdrom' | while read -r line; do
        usage=$(echo $line | awk '{print $5}' | tr -d '%')
        if [ $usage -ge 80 ]; then
            # Highlight in red if usage is 80% or more
            echo -e "\033[31m$line\033[0m"
        else
            echo "$line"
        fi
    done
    echo
}

# Function to display system load and CPU usage
function system_load() {
    echo "System Load:"
    uptime | awk '{print "Current load average: " $8 $9 $10}'

    echo "CPU Usage Breakdown:"
    if command -v mpstat > /dev/null; then
        mpstat | awk '$3 ~ /[0-9.]+/ {print "User: " $4 "%, System: " $6 "%, Idle: " $12 "%"}'
    else
        top -bn1 | grep "Cpu(s)" | awk '{print "User: " $2 "%, System: " $4 "%, Idle: " $8 "%"}'
    fi
    echo
}

# Function to display memory usage
function memory_usage() {
    echo "Memory Usage:"
    free -h | awk 'NR==2{printf "Total: %s, Used: %s, Free: %s\n", $2,$3,$4}'
    
    echo "Swap Memory Usage:"
    free -h | awk 'NR==3{printf "Total: %s, Used: %s, Free: %s\n", $2,$3,$4}'
    echo
}

# Function to monitor active processes and top 5 processes by CPU and memory usage
function process_monitor() {
    echo "Process Monitoring:"
    echo "Number of active processes:"
    ps aux | wc -l

    echo "Top 5 Processes by CPU and Memory Usage:"
    ps -eo pid,comm,%mem,%cpu --sort=-%cpu | head -n 6
    echo
}

# Function to monitor essential services
function service_monitor() {
    echo "Service Monitoring:"
    for service in sshd nginx iptables; do
        if systemctl is-active --quiet $service; then
            echo "$service is running."
        else
            echo "$service is not running!"
        fi
    done
    echo
}

# Display the full dashboard
function full_dashboard() {
    clear
    top_apps
    network_monitor
    disk_usage
    system_load
    memory_usage
    process_monitor
    service_monitor
}

# Main script to handle command-line arguments
while true; do
    case "$1" in
        -top)
            top_apps
            ;;
        -network)
            network_monitor
            ;;
        -disk)
            disk_usage
            ;;
        -load)
            system_load
            ;;
        -memory)
            memory_usage
            ;;
        -process)
            process_monitor
            ;;
        -services)
            service_monitor
            ;;
        *)
            full_dashboard
            ;;
    esac
    sleep 5
done
