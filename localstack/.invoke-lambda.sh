#!/bin/bash

# Helper function to show usage
show_usage() {
    echo "Usage: $0 <function-name> [--payload <JSON payload>]"
    exit 1
}

# Arguments
FUNCTION_NAME=$1
PAYLOAD=""

# Check if the function name is provided
if [ -z "$FUNCTION_NAME" ]; then
    show_usage
fi

# Parse optional arguments
shift # Shift out the function name argument
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --payload) PAYLOAD="$2"; shift ;;
        *) show_usage ;; # Invalid option
    esac
    shift
done

# Debugging: Echo the current arguments
echo "Invoking Lambda with the following parameters:"
echo "Function Name: $FUNCTION_NAME"
if [ -n "$PAYLOAD" ]; then
    echo "Payload: $PAYLOAD"
else
    echo "No payload provided"
fi

# Build the payload flag if provided, else omit it
if [ -n "$PAYLOAD" ]; then
    awslocal lambda invoke \
      --function-name "$FUNCTION_NAME" \
      --region eu-west-2 \
      --cli-binary-format raw-in-base64-out \
      --payload "$PAYLOAD" \
      /tmp/output.txt
else
    awslocal lambda invoke \
      --function-name "$FUNCTION_NAME" \
      --region eu-west-2 \
      /tmp/output.txt
fi

# Display the output
echo "Run: cat /tmp/output.txt to see the output"

