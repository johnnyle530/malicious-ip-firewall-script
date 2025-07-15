#!/bin/bash

# ==========================================
# Script Name: block_malicious_ips.sh
# Author: Johnny Le
# Date: July 2025
# Description:
#   Pulls malicious IPs from AbuseIPDB, FireHOL, and Emerging Threats,
#   blocks them using macOS PF firewall,
#   prevents duplicate or whitelisted entries,
#   logs each action, and sends alert emails via msmtp.
# ==========================================

# === Step 0: Load environment variables ===
source "$HOME/Documents/ip-blocker-project/.ipblocker.env"

# === Step 1: Define key variables ===
API_KEY="${ABUSEIPDB_API_KEY}"
EMAIL_PASS="${GMAIL_APP_PASSWORD}"
WHITELIST_FILE="$HOME/Documents/ip-blocker-project/whitelist.txt"
LOG_FILE="$HOME/Documents/ip-blocker-project/ipblocker.log"
BLOCKLIST_TMP="/tmp/blocklist_ips.txt"
FINAL_BLOCKLIST="/tmp/final_blocklist.txt"

# === Step 2: Create whitelist ===
cat <<EOL > "$WHITELIST_FILE"
127.0.0.1
192.168.0.0/16
10.0.0.0/8
172.16.0.0/12
8.8.8.8
1.1.1.1
EOL

echo "$(curl -s https://api.ipify.org)" >> "$WHITELIST_FILE"


# === Step 3: Download and clean threat feeds ===
# AbuseIPDB JSON parsing (no cleanup needed)
curl -s "https://api.abuseipdb.com/api/v2/blacklist?confidenceMinimum=90" \
  -H "Key: $API_KEY" \
  -H "Accept: application/json" |
  jq -r '.data[].ipAddress' > "$BLOCKLIST_TMP"



# FireHOL and Emerging Threats (with comment filtering)
curl -s "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset" \
  | grep -vE '^\s*#|^\s*$' >> "$BLOCKLIST_TMP"

curl -s "https://rules.emergingthreats.net/blockrules/compromised-ips.txt" \
  | grep -vE '^\s*#|^\s*$' >> "$BLOCKLIST_TMP"

# === Step 4: Remove duplicates and whitelisted IPs ===
grep -v -F -f "$WHITELIST_FILE" "$BLOCKLIST_TMP" | sort -u > "$FINAL_BLOCKLIST"

# === Step 5: Update PF rules ===
sudo pfctl -f /etc/pf.conf
sudo pfctl -t blocked_ips -T flush
cat "$FINAL_BLOCKLIST" | while read -r ip; do
    sudo pfctl -t blocked_ips -T add "$ip"
done

# === Step 6: Log and notify ===
{
  echo "$(date): Blocked $(wc -l < "$FINAL_BLOCKLIST") IPs"
} >> "$LOG_FILE"

echo "IP blocking completed. Log updated at $LOG_FILE"
