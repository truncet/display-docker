#!/bin/sh

# Choose a unique display number for Xvfb
XVFB_DISPLAY=":100"

# Start Xvfb on the chosen display number
X :99 &
Xvfb :100 &
XVFB_PID=$!

# Export the DISPLAY environment variable

# Wait for Xvfb to start
sleep 2

# Execute the provided command
exec "$@"

# Cleanup
kill $XVFB_PID

