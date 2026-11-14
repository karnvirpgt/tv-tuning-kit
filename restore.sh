#!/usr/bin/env bash
# tv-tuning-kit — undo everything the kit did on this TV (asks permission first).
# Usage: ./restore.sh <tv-ip> [--yes]

set -u
REC_DIR="$HOME/.tv-tuning-kit"
IP="${1:-}"; YN="${2:-}"
[ -z "$IP" ] && { printf 'TV ka IP address: '; read -r IP; }
REC="$REC_DIR/restore-$IP.json"
[ -f "$REC" ] || { echo "Is TV ka record nahi mila ($REC) — kuch restore karne ko nahi."; exit 1; }
command -v adb >/dev/null || { echo "adb install karo pehle."; exit 1; }
adb connect "$IP:5555" >/dev/null 2>&1; sleep 2

say() { printf '\n== %s\n' "$*"; }
agree(){ [ "$YN" = "--yes" ] && return 0; printf '=> %s [y/N] ' "$1"; read -r a; [ "${a:-}" = y ] || [ "${a:-}" = Y ]; }

say "TV: $(adb -s "$IP:5555" shell getprop ro.product.model 2>/dev/null | tr -d '\r')"
agree "Is TV pe kit ke saare changes wapas laaun?" || exit 0

python3 - "$REC" "$IP" "$YN" <<'EOF'
import json,subprocess,sys
rec,ip,yn=sys.argv[1],sys.argv[2],sys.argv[3]
d=json.load(open(rec))
def adb(*a): subprocess.run(["adb","-s",f"{ip}:5555","shell",*a],capture_output=True)
for p in d.get("disabled",[]):
    adb("pm","enable",p)
    r=subprocess.run(["adb","-s",f"{ip}:5555","shell","pm","path",p],capture_output=True,text=True).stdout.strip()
    print(f"  enabled: {p}" if r else f"  FAIL/absent: {p}")
for p in d.get("uninstalled",[]):
    adb("pm","install-existing",p)
    print(f"  reinstalled from system copy: {p}")
if not d.get("disabled") and not d.get("uninstalled"): print("  (record khala tha)")
EOF

say "Ho gaya. Agar sab wapas aa gaya hai, ye record ab hata sakta hoon."
agree "Record file delete karun ($REC)?" && rm -f "$REC" && echo "  deleted."
echo "  Note: ye script kit ke changes undo karta hai. Launcher (CleanYourTV) stock pe wapas lane ke liye us project ka restore tool use karo."
