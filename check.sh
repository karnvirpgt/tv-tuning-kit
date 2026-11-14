#!/usr/bin/env bash
# tv-tuning-kit — check what state the TV is in vs the kit's record.
# Usage: ./check.sh <tv-ip>

set -u
REC_DIR="$HOME/.tv-tuning-kit"
IP="${1:-}"
[ -z "$IP" ] && { printf 'TV ka IP address: '; read -r IP; }
REC="$REC_DIR/restore-$IP.json"
[ -f "$REC" ] || { echo "Is TV ka record nahi mila ($REC) — shayad setup.sh abhi chala hi nahi."; exit 1; }
command -v adb >/dev/null || { echo "adb install karo pehle."; exit 1; }
adb connect "$IP:5555" >/dev/null 2>&1; sleep 2

say() { printf '\n== %s\n' "$*"; }
say "TV: $(adb -s "$IP:5555" shell getprop ro.product.model 2>/dev/null | tr -d '\r')"

say "Disabled packages (record me jo tune kiye the):"
python3 - "$REC" <<'EOF'
import json,subprocess,sys
d=json.load(open(sys.argv[1]))
out=subprocess.run(["adb","-s",f"{d['ip']}:5555","shell","pm","list","packages","-d"],capture_output=True,text=True).stdout
still_disabled={l.replace("package:","").strip() for l in out.splitlines() if l.strip()}
for p in d.get("disabled",[]):
    print(f"  still disabled: {p}" if p in still_disabled else f"  enabled again (firmware ne undo kiya?): {p}")
if not d.get("disabled"): print("  (kuch nahi)")
EOF

say "Our apps installed?"
for p in com.segar.livetv com.phlox.tvwebbrowser; do
  adb -s "$IP:5555" shell pm path "$p" >/dev/null 2>&1 && echo "  OK: $p" || echo "  MISSING: $p"
done

say "Reminder"
echo "  Agar sab sahi hai: TV remote se Settings > About > Network ADB > OFF (security)."
