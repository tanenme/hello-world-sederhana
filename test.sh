#!/bin/bash
# Test script for hello-world-sederhana

# Start the server in the background
python3 server.py &
SERVER_PID=$!

# Give the server a moment to start
sleep 2

# Test the health endpoint
HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)
if [ "$HEALTH_RESPONSE" -ne 200 ]; then
    echo "Health check failed with status $HEALTH_RESPONSE"
    kill $SERVER_PID
    exit 1
fi

# Test the main page
MAIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
if [ "$MAIN_RESPONSE" -ne 200 ]; then
    echo "Main page check failed with status $MAIN_RESPONSE"
    kill $SERVER_PID
    exit 1
fi

# Check that the main page contains "Hello World"
MAIN_CONTENT=$(curl -s http://localhost:8080/)
if echo "$MAIN_CONTENT" | grep -q "Hello World"; then
    echo "Main page contains 'Hello World'"
else
    echo "Main page does not contain 'Hello World'"
    kill $SERVER_PID
    exit 1
fi

# Check for security headers (basic check)
HEADERS=$(curl -s -I http://localhost:8080/)
if echo "$HEADERS" | grep -q "Content-Security-Policy"; then
    echo "Content-Security-Policy header present"
else
    echo "Content-Security-Policy header missing"
fi

# Stop the server
kill $SERVER_PID

echo "All tests passed"
exit 0