#!/usr/bin/env bash
# tv-tuning-kit — universal Android TV setup: debloat + apps, permission at every step.
# Usage: ./setup.sh <tv-ip>          (e.g. ./setup.sh 192.168.1.50)
# Every change is shown first and happens only after you press y.
# Everything is recorded so restore.sh can undo it.

set -u
REC_DIR="$HOME/.tv-tuning-kit"
mkdir -p "$REC_DIR"

say()  { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!! %s\033[0m\n' "$*"; }
ask()  { printf '\033[1m=> %s [y/N] \033[0m' "$1"; read -r a; [ "${a:-}" = y ] || [ "${a:-}" = Y ]; }

record() { # $1 kind (disabled/uninstalled), $2 package
  python3 - "$REC" "$1" "$2" <<'EOF'
import json,sys
d=json.load(open(sys.argv[1]))
d.setdefault(sys.argv[2],[]).append(sys.argv[3])
json.dump(d,open(sys.argv[1],"w"),indent=1)
EOF
}

IP="${1:-}"
[ -z "$IP" ] && { printf 'TV ka IP address: '; read -r IP; }
IP="${IP%%:*}"   # user ne IP:5555 likha to port hata do — hum khud :5555 lagate hain
command -v adb >/dev/null || { warn "adb nahi mila. Mac: 'brew install android-platform-tools' | Linux: 'apt install adb'. Phir dobara chalao."; exit 1; }

say "Step 1: TV se connect"
adb connect "$IP:5555" >/dev/null 2>&1; sleep 2
MODEL=$(adb -s "$IP:5555" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
[ -z "$MODEL" ] && { warn "Connect nahi hua. TV pe Network ADB / USB debugging ON karo (Settings > Device Preferences > About), phir dobara chalao."; exit 1; }
echo "  TV: $MODEL | Android $(adb -s "$IP:5555" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r') | $IP:5555"
ask "Isi TV pe kaam karna hai?" || exit 0

REC="$REC_DIR/restore-$IP.json"
if [ -f "$REC" ]; then
  warn "Is TV ka purana record hai ($REC) — naye actions USI ME add honge, koi wipe nahi hoga. restore.sh purane+naye dono undo karega."
else
  echo '{"ip": "'"$IP"'", "disabled": [], "uninstalled": []}' > "$REC"
fi

# ---------- Step 2: bloat discovery ----------
say "Step 2: Bloat discovery (abhi kuch nahi badla)"
ALL_PKGS=$(adb -s "$IP:5555" shell pm list packages 2>/dev/null | tr -d '\r' | sed 's/package://' | sort)

# Packages this kit refuses to touch on ANY TV (breaks the TV or core features).
is_protected() {
  case "$1" in
    android|com.android.systemui|com.android.settings|com.android.tv.settings|\
    com.google.android.gms|com.google.android.gsf|com.google.android.gsf.login|\
    com.google.android.webview|com.android.webview|\
    com.android.inputmethod*|com.google.android.inputmethod*|\
    com.android.providers.*|com.android.bluetooth|com.android.wifi*|com.android.networkstack*|\
    com.android.tv.frameworkpackagestubs|com.google.android.tvlauncher|com.google.android.leanbacklauncher|\
    com.mitv.tvhome*|*tvhome*|com.android.settings.intelligence) return 0 ;;
    *) return 1 ;;
  esac
}

JUNK_PAT='analytic|statistic|telemetr|sentiment|acra|umeng|tracking|adservice|advertising|sponsored|datamine'
BRAND_PAT='com\.mitv\.|com\.miui\.|com\.xiaomi\.(statistic|mitv\.res|floatingframe|handbook|tvmanager|mimusic2|gallery)|com\.google\.android\.tvrecommendations|com\.google\.android\.leanbacklauncher\.recommendations|com\.google\.android\.youtube\.tvmusic|com\.google\.android\.videos|com\.google\.android\.music|com\.google\.android\.play\.games|com\.google\.android\.feedback|com\.tcl\.browser|com\.dreamsky|co\.sensara|\.webcontent|milegal'

CANDIDATES=""
for p in $(echo "$ALL_PKGS" | grep -E "$JUNK_PAT|$BRAND_PAT"); do
  is_protected "$p" || CANDIDATES="$CANDIDATES $p"
done

if [ -z "${CANDIDATES// /}" ]; then
  echo "  Koi bloat keyword match nahi hua — kuch change nahi kiya. (Brand-specific notes: notes/ folder.)"
else
  n=0
  echo "  Ye packages junk/analytics/ads jaise lagte hain. Disable = app delete NAHI hoti, wapas enable ho sakti hai (restore.sh):"
  for p in $CANDIDATES; do n=$((n+1)); printf '   %2d. %s\n' "$n" "$p"; done
  printf '  \033[1m=> [a]ll disable / [e]ach one puch ke / [s]kip \033[0m'; read -r mode
  case "$mode" in
    a|A|e|E)
      for p in $CANDIDATES; do
        if [ "$mode" = e ] || [ "$mode" = E ]; then ask "Disable: $p?" || continue; fi
        if adb -s "$IP:5555" shell pm disable-user --user 0 "$p" >/dev/null 2>&1; then
          echo "     disabled: $p"; record disabled "$p"
        else
          warn "     disable fail: $p (skip)"
        fi
      done ;;
    *) echo "     skipped — kuch nahi kiya." ;;
  esac
fi

# ---------- Step 3: optional apps ----------
say "Step 3: Optional apps (har app alag se puch ke install hoga)"

echo "  Live TV fork — free Indian TV, sirf Hindi/Punjabi/English, failover + auto-hide (hamari build, open fork)."
ask "Install karna hai?" && {
  curl -fsSL https://github.com/karnvirpgt/live-tv/releases/latest/download/app-release.apk -o /tmp/tvk_livetv.apk \
    && adb -s "$IP:5555" install /tmp/tvk_livetv.apk 2>&1 | tail -1
  rm -f /tmp/tvk_livetv.apk
}

echo "  TV Bro — TV-remote ke liye bana free browser (open source, github.com/truefedex/tv-bro)."
ask "Install karna hai?" && {
  # v2.1.6 pinned: Android 8/9 pe verified; v3.x unverified on Android 9
  URL=$(curl -fsSL "https://github.com/truefedex/tv-bro/releases/expanded_assets/v2.1.6" | grep -oE 'href="[^"]*\.apk' | head -1 | sed 's|href="|https://github.com|')
  if [ -n "$URL" ]; then
    curl -fsSL "$URL" -o /tmp/tvk_tvbro.apk && adb -s "$IP:5555" install /tmp/tvk_tvbro.apk 2>&1 | tail -1
    rm -f /tmp/tvk_tvbro.apk
  else
    warn "link nahi mila — https://github.com/truefedex/tv-bro/releases se manually download karke 'adb install <file.apk>'"
  fi
}

echo "  CastBay — casting receiver (phone se cast). Closed-source freeware, APK uske official site se aata hai."
ask "Install karna hai?" && {
  printf '  CastBay APK ka local path (ya Enter to skip): '; read -r ap
  if [ -n "${ap:-}" ] && [ -f "$ap" ]; then adb -s "$IP:5555" install "$ap" 2>&1 | tail -1
  else warn "file nahi mili — skip. Baad me: adb install castbay.apk"; fi
}

# ---------- Step 4: launcher ----------
say "Step 4: Home launcher (optional, sabse bada change)"
echo "  CleanYourTV launcher (Apple-TV style home, no ads) ek alag open-source project hai —"
echo "  is kit me ship nahi hota. Akele karne ke liye: https://github.com/Gathin23/cleanyourtv#readme"
ask "Link dobara print karun?" && echo "  https://github.com/Gathin23/cleanyourtv#readme"

say "Done!"
echo "  Record: $REC"
echo "  Verify:   ./check.sh $IP"
echo "  Undo:     ./restore.sh $IP"
echo "  Sab sahi lage to TV ke remote se: Settings > About > Network ADB > OFF (security)."
