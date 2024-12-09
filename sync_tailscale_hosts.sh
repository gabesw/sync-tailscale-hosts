#!/bin/bash

# Define the hosts file
HOSTS_FILE="/etc/hosts"

# Define the start and end markers
START_MARKER="# Tailscale Start"
END_MARKER="# Tailscale End"

# Get the Tailscale status in JSON format
TAILSCALE_STATUS=$(tailscale status --json)

# Parse the Self and Peer Tailscale IPs and DNS hostnames using jq
TAILSCALE_ENTRIES=$(echo "$TAILSCALE_STATUS" | jq -r '
  (.Peer[] | "\(.TailscaleIPs[])\t\(.DNSName)") ,
  (.Self | "\(.TailscaleIPs[])\t\(.DNSName)")
')

# Remove the tailnet suffix from the DNS names and replace with '-ts' or '-ts6' based on IP type
TAILSCALE_ENTRIES=$(echo "$TAILSCALE_ENTRIES" | awk '
{
    if ($1 ~ /^fd7a/) {
        sub(/\..*\.ts\.net\.$/, ".ts6", $2);
    } else {
        sub(/\..*\.ts\.net\.$/, ".ts4", $2);
    }
    print $1, $2;
}')

# Create a temporary file for the updated hosts file
TEMP_FILE=$(mktemp)

# Copy everything before the start marker into the temp file
awk -v start_marker="$START_MARKER" '{
    if ($0 == start_marker) { exit }
    print
}' "$HOSTS_FILE" > "$TEMP_FILE"

# Add the start marker
echo "$START_MARKER" >> "$TEMP_FILE"

# Add the Tailscale entries
echo "$TAILSCALE_ENTRIES" >> "$TEMP_FILE"

# Add the end marker
echo "$END_MARKER" >> "$TEMP_FILE"

# Copy everything after the end marker into the temp file
awk -v end_marker="$END_MARKER" 'found { print }
    $0 == end_marker { found = 1 }
' "$HOSTS_FILE" >> "$TEMP_FILE"

# Replace the original hosts file with the updated temp file
sudo mv "$TEMP_FILE" "$HOSTS_FILE"

# Ensure proper permissions
sudo chmod 644 "$HOSTS_FILE"

echo "$(date): Hosts file updated with Tailscale IPs."
