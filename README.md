# Lambda Example

# Setup

Before running any commands, ensure that Docker is running on your system.

Start Docker services:

```bash
docker-compose up -d
```

Build the project locally:

```bash
npm run build:local
```

**Create lambda**

- create the lambda function within localstack

```bash
npm run create:lambda \
  --env "NODE_ENV=development"
```

**Invoke lambda**

Invoke the lambda by running:

```bash
npm run invoke:lambda -- --payload '{ "body": "{\"email\": \"test@test.com\"}", "httpMethod": "POST", "isBase64Encoded": false, "headers": { "Content-Type": "application/json" } }'
```

**Tail the local cloudwatch logs (must be invoked once for the log group to be created)**

- `awslocal logs tail /aws/lambda/example --follow`

### Running the tests

From this directory, we can run: `npm test` and this will run the tests for this lambda function.
