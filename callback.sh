#!/bin/sh

# env
# TOKEN for bearer token
# URL for request url
# RETRY_INTERVAL for request fail retry interval
# MAX_RETRIES for maximum reqeust retries

# Check if at least five arguments are provided
if [ "$#" -lt 5 ]; then
    echo "This script requires at least five arguments."
    exit 1
fi

# Concatenate the fourth and fifth arguments with a colon
address="$4:$5"

# Initialize retry count
retry_count=0

# Function to send POST request
send_request() {
    response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$URL" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"value\": \"$address\"}")

    echo $response
}

# Send request and handle retries if necessary
while true; do
    # Send the request
    status_code=$(send_request)

    # Check if status code is not a 2xx success code
    if echo "$status_code" | grep -q "^2"; then
        echo "Request succeeded with status code $status_code"
        break
    else
        echo "Request failed with status code $status_code"
        retry_count=$((retry_count + 1))

        # Check if maximum retries reached
        if [ "$retry_count" -lt "$MAX_RETRIES" ]; then
            echo "Waiting $RETRY_INTERVAL seconds before retrying..."
            sleep "$RETRY_INTERVAL"
        else
            echo "Maximum retries reached ($MAX_RETRIES), exiting."
            exit 1
        fi
    fi
done
