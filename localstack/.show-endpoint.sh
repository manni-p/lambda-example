#!/bin/bash

# Get the package name from the arguments
PACKAGE_NAME=$1

# Fetch the REST API ID
REST_API_ID=$(awslocal apigateway get-rest-apis --query "items[?name=='$PACKAGE_NAME'].id" --output text)

# Check if the REST_API_ID was found
if [[ -z "$REST_API_ID" ]]; then
  echo "Error: No API Gateway found for package '$PACKAGE_NAME'."
  exit 1
fi

# Construct the API Gateway endpoint URL
API_ENDPOINT="http://localhost:4566/restapis/$REST_API_ID/dev/_user_request_/$PACKAGE_NAME"

# Output the endpoint URL
echo "API Gateway endpoint URL: $API_ENDPOINT"
