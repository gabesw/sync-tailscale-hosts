# Sync Tailscale Hosts
This is a simple script intended to be used on a Pi-hole that listens on [Tailscale](https://tailscale.com/). I found it annoying to constantly update the `/etc/hosts` file on my Pi-hole every time I added or removed a device from my Tailnet. This script uses the `tailscale status` command and updates the hosts file of the Pi-hole with the IPv4 and IPv6 IPs of each device and their MagicDNS names.

# Customization/Setup
|Variable|Usage|Default|
|---|---|---|
|HOSTS_FILE|The path to the hosts file|'/etc/hosts'|
|START_MARKER|A comment in the hosts file to tell the script where to insert the tailscale hosts|'# Tailscale Start'|
|END_MARKER|The end of the tailscale IPs block|'# Tailscale End'|

You must add two lines to the hosts file for the script to work:
```
...
<START_MARKER>
<END_MARKER>
```
By default, this should be:
```
...
# Tailscale Start
# Tailscale End
```
All of the dynamically added hosts will be between these two comments.

# Usage
The script must be run with root privilege as the hosts file is owned by root. Create a cron job to run this script so that it will update consistantly. I have mine set to run every hour.
