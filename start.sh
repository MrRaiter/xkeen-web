#!/bin/sh

# Load environment variables from .env file if it exists
if [ -f "$(dirname "$0")/.env" ]; then
    echo "Loading configuration from .env file..."
    export $(grep -v '^#' "$(dirname "$0")/.env" | xargs)
fi

# Start the server
cd "$(dirname "$0")"
exec node server.js
