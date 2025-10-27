#!/bin/bash

set -e  # Exit on error

# Check if all required environment variables are set
if [ -z "$BUGSNAG_ENV" ] || [ -z "$BUGSNAG_APP_VERSION" ] || [ -z "$BUGSNAG_API_KEY" ]; then
  echo "Warning: One or more required Bugsnag environment variables are not set. Skipping deployment notification."
  echo "Required: BUGSNAG_ENV, BUGSNAG_APP_VERSION, BUGSNAG_API_KEY"
  exit 0
fi

echo "Notifying Bugsnag of deployment: $BUGSNAG_APP_VERSION to $BUGSNAG_ENV"

# Notify BugSnag about the deployment
if curl -X POST https://build.bugsnag.com/ \
  --retry 2 \
  --fail \
  --silent \
  --show-error \
  -H "Content-Type: application/json" \
  -d '{
    "apiKey": "'"$BUGSNAG_API_KEY"'",
    "appVersion": "'"$BUGSNAG_APP_VERSION"'",
    "releaseStage": "'"$BUGSNAG_ENV"'",
    "builderName": "Deployer"
  }'; then
  echo "Successfully notified Bugsnag"
  exit 0
else
  echo "Warning: Failed to notify Bugsnag (exit code: $?). Continuing anyway..."
  exit 0
fi
