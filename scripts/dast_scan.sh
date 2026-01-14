#!/bin/bash

echo "Starting DAST Scan with OWASP ZAP..."

# 1. Start the App in background
echo "Starting Flask App..."
python3 app/backend/app.py &
APP_PID=$!

# Wait for app to be ready
echo "Waiting for app to be ready..."
sleep 5

# 2. Run ZAP Baseline Scan
# Using dockerized ZAP
echo "Running ZAP Baseline Scan..."
chmod 777 security/reports
docker run --rm \
    -v $(pwd)/security/reports:/zap/wrk/:rw \
    --network="host" \
    zaproxy/zap-stable zap-baseline.py \
    -t http://127.0.0.1:5000 \
    -r zap-report.html \
    -I 

# -I means ignore warnings and only fail on errors? actually zap-baseline returns 0/1/2.
# We might want to just capture the report.

# 3. Stop App
echo "Stopping App..."
kill $APP_PID
