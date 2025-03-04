#!/bin/sh

REPORT_PATH=$1
INSTANCE=$2
IS_GROUP=$3

# Convert IS_GROUP to lowercase for case-insensitive comparison
IS_GROUP_LOWER=$(echo "$IS_GROUP" | tr '[:upper:]' '[:lower:]')

# Check if IS_GROUP is true (not empty and not "false")
if [ -n "$IS_GROUP" ] && [ "$IS_GROUP_LOWER" != "false" ]; then
  # Run with the -g flag for GROUP
  echo "Processing as a group with -g flag"
  java -jar /app/wrs-doc-app.jar "$REPORT_PATH" "$INSTANCE" -g
else
  # Run without the -g flag for INSTANCE
  echo "Processing as an instance without -g flag"
  java -jar /app/wrs-doc-app.jar "$REPORT_PATH" "$INSTANCE"
fi
