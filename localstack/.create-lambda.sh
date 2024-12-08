#!/bin/bash

FUNCTION_NAME=$1
shift

ENV_VARS=()
API_RESOURCE=""
HTTP_METHOD="GET" # Default method

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENV_VARS+=("$2")
      shift
      shift
      ;;
    --api-resource)
      API_RESOURCE="$2"
      shift
      shift
      ;;
    --http-method)
      HTTP_METHOD="$2"
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

echo "Parsed environment variables: ${ENV_VARS[@]}"
echo "API resource: $API_RESOURCE"
echo "HTTP method: $HTTP_METHOD"

if [ -z "$FUNCTION_NAME" ]; then
  echo "Usage: ./create-lambda.sh <function-name> --env \"<env-var-name>=<value>\" --api-resource \"<api-resource-path>\" --http-method \"<HTTP-method>\""
  exit 1
fi



ENV_VARIABLES="{\"Variables\": {"
for env_var in "${ENV_VARS[@]}"; do
  IFS="=" read -r VAR_NAME VAR_VALUE <<< "$env_var"
  if [[ -z "$VAR_NAME" || -z "$VAR_VALUE" ]]; then
    echo "Invalid environment variable format: $env_var. Expected format is VAR_NAME=VAR_VALUE"
    exit 1
  fi
  ENV_VARIABLES+="\"$VAR_NAME\":\"$VAR_VALUE\","
done

if [[ "$ENV_VARIABLES" == *, ]]; then
  ENV_VARIABLES="${ENV_VARIABLES%,}"
fi

ENV_VARIABLES+="}}"

echo "Final environment variables JSON: $ENV_VARIABLES"

if ! echo "$ENV_VARIABLES" | jq empty; then
  echo "Error: Generated JSON is not valid."
  echo "Invalid JSON: $ENV_VARIABLES"
  exit 1
fi

# Create the Lambda function
awslocal lambda create-function \
  --function-name "$FUNCTION_NAME" \
  --runtime "nodejs20.x" \
  --region eu-west-2 \
  --role arn:aws:iam::123456789012:role/lambda-ex \
  --code S3Bucket="hot-reload",S3Key="$(pwd)/dist" \
  --handler handler.handler \
  --environment "$ENV_VARIABLES"

echo "Created lambda called: $FUNCTION_NAME"

# Set up API Gateway if API_RESOURCE is provided
if [ -n "$API_RESOURCE" ]; then
  echo "Setting up API Gateway for $FUNCTION_NAME"

  # Create REST API
  API_ID=$(awslocal apigateway create-rest-api --name "${FUNCTION_NAME}" --query 'id' --output text)
  echo "Created REST API with ID: $API_ID"

  # Get the root resource ID
  ROOT_ID=$(awslocal apigateway get-resources --rest-api-id $API_ID --query 'items[?path==`/`].id' --output text)
  echo "Root resource ID: $ROOT_ID"

  # Create the specified resource (e.g., /my-resource)
  RESOURCE_ID=$(awslocal apigateway create-resource --rest-api-id $API_ID --parent-id $ROOT_ID --path-part "$API_RESOURCE" --query 'id' --output text)
  echo "Created resource /$API_RESOURCE with ID: $RESOURCE_ID"

  # Set up the method (e.g., GET, DELETE)
  awslocal apigateway put-method --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method "$HTTP_METHOD" --authorization-type "NONE"
  echo "Added $HTTP_METHOD method to /$API_RESOURCE"

  # Integrate the method with the Lambda function
  awslocal apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $RESOURCE_ID \
    --http-method "$HTTP_METHOD" \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-2:000000000000:function:$FUNCTION_NAME/invocations
  echo "Integrated $HTTP_METHOD method with Lambda function $FUNCTION_NAME"

  # Deploy the API
  awslocal apigateway create-deployment --rest-api-id $API_ID --stage-name dev
  echo "Deployed API to 'dev' stage"

  echo "API setup complete. You can access it at: http://localhost:4566/restapis/$API_ID/dev/_user_request_/$API_RESOURCE"
else
  echo "API resource not specified, skipping API Gateway setup."
fi
