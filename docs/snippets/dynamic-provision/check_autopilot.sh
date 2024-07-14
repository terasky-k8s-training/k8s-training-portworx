#!/bin/bash

# Timeout duration in seconds (7 minutes = 420 seconds)
timeout_duration=420
start_time=$(date +%s)

# Function to check if the desired message appears in kubectl events output
check_event_message() {
    kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=nginx-pvc-volume-resize -A | grep "transition from ActiveActionsInProgress => ActiveActionsTaken"
}

# Loop to continuously check the event messages until timeout
while : ; do
    check_event_message
    if [ $? -eq 0 ]; then
        break
    fi

    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [ $elapsed_time -ge $timeout_duration ]; then
        echo "Timeout of 7 minutes reached. Exiting..."
        exit 1
    fi

    sleep 2   # Adjust the sleep duration (in seconds) as needed
done
