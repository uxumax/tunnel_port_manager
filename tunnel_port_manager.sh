#!/bin/bash

# Path to the FIFO file
FIFO_FILE="/path/to/ports_to_open.fifo"

# Time that port be closed
CLOSE_AFTER="+5 minute"

# Function to add a job to cron
add_cron_job() {
    local port=$1
    local cmd="/usr/sbin/iptables -D INPUT -p tcp --dport $port -j ACCEPT"
    # Add a command to remove the rule after 5 minutes
    (crontab -l 2>/dev/null; echo "$(date -d "$CLOSE_AFTER" "+%M %H %d %m *") $cmd") | crontab -
}

# Main daemon loop
while true; do
    # Check for new ports in the FIFO file
    if read port <&3; then
        # If a port is provided, open it and add a job to close it later
        if [ ! -z "$port" ]; then
            /usr/sbin/iptables -A INPUT -p tcp --dport $port -j ACCEPT
            add_cron_job $port
        fi
    fi
    sleep 1
done 3<"$FIFO_FILE"

