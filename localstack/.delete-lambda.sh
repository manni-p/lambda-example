#!/bin/bash

# Arguments
FUNCTION_NAME=$1

# Ensure the function name is provided
if [ -z "$FUNCTION_NAME" ]; then
  echo "Usage: ./delete-lambda.sh <function-name>"
  exit 1
fi

# deleting lambda
awslocal lambda delete-function \
  --function-name "$FUNCTION_NAME" \
  --region eu-west-2

echo "Deleted lambda called: $FUNCTION_NAME"

