#!/bin/bash

# === Configuration ===
WEBSITE_URL="https://naturedreamwallpapers.com"   # Change to your public URL if needed
LOG_FILE="/var/www/html/status.html"  # So it can be viewed via browser
MAX_RESPONSE_TIME=2              # in seconds

# === Timestamp ===
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# === Check website status and response time ===
RESPONSE=$(curl -o /dev/null -s -w "%{http_code} %{time_total}" $WEBSITE_URL)
STATUS_CODE=$(echo $RESPONSE | awk '{print $1}')
RESPONSE_TIME=$(echo $RESPONSE | awk '{print $2}')

# === Determine status ===
if [ "$STATUS_CODE" -eq 200 ]; then
    STATUS_MSG="Website is UP"
else
    STATUS_MSG="Website might be DOWN (HTTP $STATUS_CODE)"
fi

# === Highlight slow response ===
if (( $(echo "$RESPONSE_TIME > $MAX_RESPONSE_TIME" | bc -l) )); then
    SPEED_MSG="Slow response: ${RESPONSE_TIME}s"
else
    SPEED_MSG="Fast response: ${RESPONSE_TIME}s"
fi

# === Output ===
echo "<html><body>" > $LOG_FILE
echo "<h2>Website Monitor Status</h2>" >> $LOG_FILE
echo "<p><strong>Timestamp:</strong> $TIMESTAMP</p>" >> $LOG_FILE
echo "<p><strong>Status:</strong> $STATUS_MSG</p>" >> $LOG_FILE
echo "<p><strong>Response Time:</strong> $SPEED_MSG</p>" >> $LOG_FILE
echo "</body></html>" >> $LOG_FILE

# === Optional: Log to console ===
echo "[$TIMESTAMP] $STATUS_MSG - $SPEED_MSG"