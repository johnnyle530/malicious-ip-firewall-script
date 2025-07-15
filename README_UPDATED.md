# macOS IP Blocker – Updated Version

This project blocks inbound and outbound network traffic from known malicious IPs using the macOS `pf` firewall. It fetches data from public threat intelligence feeds and automates blocking with logging and optional email alerts.

---

## 🔐 Features

- Automatically pulls from:
  - [AbuseIPDB](https://www.abuseipdb.com/)
  - [FireHOL Level 1](https://iplists.firehol.org/)
  - [Emerging Threats](https://rules.emergingthreats.net/)
- Blocks both inbound and outbound traffic via `pf`
- Maintains a whitelist (e.g., local IPs, current public IP)
- Logs blocked activity
- Sends email notifications using Gmail SMTP via `msmtp`
- Automatically runs on a schedule with `cron`

---

## 📂 Files

| File | Description |
|------|-------------|
| `block_malicious_ips_UPDATED.sh` | Main script to fetch, filter, and apply firewall rules |
| `blocklist.conf` | Contains final list of IPs to be blocked |
| `blocked_ips.txt` | Auto-generated list of malicious IPs |
| `whitelist.txt` | List of safe IPs to exclude from blocking |
| `pf_block.conf` | PF config snippet used by the main script |
| `ip_block_log.txt` | Output and debug logs |
| `README.md` | This file |

---

## 🛠️ Setup Instructions

### 1. Clone the repo or copy files locally
Put everything into a folder, e.g., `~/Documents/ip-blocker-project`.

### 2. Make your script executable
```bash
chmod +x block_malicious_ips_UPDATED.sh
```

### 3. Run the script manually
```bash
cd ~/Documents/ip-blocker-project
sudo ./block_malicious_ips_UPDATED.sh
```

This will:
- Create a whitelist with internal IPs and your current public IP (e.g., `192.168.1.1`, `192.168.1.25`, `73.202.33.80`)
- Fetch and merge IP threat data
- Write to `blocklist.conf`
- Reload PF firewall

---

## 🧪 Testing PF Rules

### To test configuration:
```bash
sudo pfctl -nf /etc/pf.conf
```

### To apply firewall rules:
```bash
sudo pfctl -f /etc/pf.conf
sudo pfctl -e
```

---

## ✉️ Email Alerts (Optional)

You can configure Gmail app password in `.ipblocker.env` like:

```bash
GMAIL_USER='your_email@gmail.com'
GMAIL_PASS='your_app_password'
```

Make sure `msmtp` is installed and configured for sending.

---

## ⏱️ Automate with Cron

To run every 6 hours:
```bash
crontab -e
```

Add:
```cron
0 */6 * * * /Users/johnnyle/Documents/ip-blocker-project/block_malicious_ips_UPDATED.sh
```

---

## 🔍 Notes

- Logs are saved to `ip_block_log.txt`
- Blocked IPs are stored in `blocked_ips.txt`
- Final IPs applied are saved in `blocklist.conf`
- Your IP is added to `whitelist.txt` using `curl https://api.ipify.org`

---

## ✅ Final Checklist

- [x] API Key integrated
- [x] Whitelist your IP: `192.168.1.1`, `192.168.1.25`, `73.202.33.80`
- [x] Uses macOS `pf` properly
- [x] Logging and alerting included
- [x] Ready for Kandji MDM deployment (planned)

---

Built with care by Johnny – secure, lightweight, and production-ready.
