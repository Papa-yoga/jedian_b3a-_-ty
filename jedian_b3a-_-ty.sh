#!/data/data/com.termux/files/usr/bin/bash
# Jedian B3a--ty v1.0 - Unified Smart Defense Shell
# Designed for: Redmi Note 12 (No Root)

##########################
# SECTION 1: PREP CHECKS
##########################

echo "[+] Initializing environment..."
pkg update -y && pkg install curl net-tools iputils termux-api grep -y >/dev/null 2>&1

##########################
# SECTION 2: VPN CHECK
##########################

echo "[+] Please activate your VPN now (any app)..."
sleep 5
attempts=0
vpn_ok=false

while [ $attempts -lt 10 ]; do
    echo "[*] Checking VPN connection... Attempt $((attempts+1))"
    ip=$(curl -s ifconfig.me)
    isp=$(curl -s ipinfo.io/org)

    if [[ "$isp" != *"Omantel"* && "$isp" != *"Ooredoo"* ]]; then
        echo "[✓] VPN is active: $ip ($isp)"
        vpn_ok=true
        break
    fi

    sleep 4
    attempts=$((attempts+1))
done

if ! $vpn_ok; then
    echo "[!] VPN check failed after 10 attempts."
    echo "    (1) Retry"
    echo "    (2) Continue without VPN"
    echo "    (3) Exit"
    read -p "Choose: " opt
    case $opt in
        1) bash $0 ;;
        2) echo "[!] Continuing without VPN..." ;;
        *) echo "[-] Exiting..."; exit 1 ;;
    esac
fi

##########################
# SECTION 3: DNS & TRACE
##########################

echo "[+] Analyzing DNS leaks..."
dns_info=$(getprop net.dns1)
echo "[✓] DNS in use: $dns_info"

echo "[+] Running traceroute..."
traceroute google.com | tee /sdcard/b3aty_logs/traceroute.txt

##########################
# SECTION 4: NETWORK SCAN
##########################

echo "[+] Scanning local network..."
ip addr show wlan0 | grep "inet " | awk '{print $2}'
arp -a | tee /sdcard/b3aty_logs/devices.txt

##########################
# SECTION 5: MALICIOUS APPS
##########################

echo "[+] Checking installed suspicious apps..."
pm list packages | grep -E "spy|hack|track|monitor" | tee /sdcard/b3aty_logs/suspicious_apps.txt

##########################
# SECTION 6: FINALIZE
##########################

echo "[✓] System scan complete. Logs saved to /sdcard/b3aty_logs/"
termux-toast "B3a--ty scan complete ✅"

exit 0
