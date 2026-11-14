# tv-tuning-kit 📺

Universal Android TV tuning kit — **debloat + curated freeware apps, har step pe tumhari permission se**. Kisi ek TV model pe bound nahi: jo bhi TV ho, script pehle TV ke andar jhaank ke dikhayegi kya junk hai, aur kuch bhi badalne se pehle poochhegi.

Kya ye CleanYourTV se alag hai? CleanYourTV (github.com/Gathin23/cleanyourtv) launcher build + debloat karta hai — bada project hai, launcher ke liye wahi use karo. Ye kit uske **upar** hai: universal debloat discovery + hamari tested free apps (Live TV fork, TV Bro, CastBay) + full undo record — sab interactive, sab reversible.

## Rules (kit follows these on every TV)

1. **Har step pe kya ho raha hai wo screen pe dikhta hai** — koi silent action nahi.
2. **Kuch bhi delete/add karne se pehle permission poochhi jaati hai** — tum nahi bole to nahi hoga.
3. **Kuch bhi uninstall nahi hota by default** — packages `disable` hote hain (wapas enable ho sakte hain). Uninstall sirf tab jab tum kaho.
4. **Core TV packages ko haath nahi lagta** — hard-coded protected list (systemui, GMS, WebView, settings, bluetooth, wifi, launcher...).
5. **Sab kuch recorded** — `~/.tv-tuning-kit/restore-<ip>.json` me, taaki `restore.sh` sab undo kar sake.

## Quick start (5 min)

> **AI assistant ke saath kar rahe ho?** (Claude Code, Codex, Gemini, Cursor, OpenCode...)
> Repo clone karo aur assistant ko **`PROMPT.md` follow karne ko bolo** — wo proper deep clean karega (full package audit, har step pe permission). Scripts (neeche) quick clean ke liye hain.

```bash
# 1. adb install karo (Mac: brew install android-platform-tools | Linux: apt install adb)

# 2. TV pe debugging ON karo:
#    Settings > Device Preferences > About > "Build" pe 7 baar OK (developer mode)
#    > Developer options > USB debugging / Network ADB > ON.  TV ON rakho, same WiFi pe ho.

# 3. Kit chalao:
./setup.sh 192.168.1.50        # apne TV ka IP do

# 4. Sab kuch screen pe padho, har sawal ka jawab do. Done!
./check.sh 192.168.1.50        # verify

# 5. Sab sahi lage: TV ke remote se Settings > About > Network ADB > OFF (security)
```

## Apps jo kit offer karta hai (sab optional, sab puchh ke)

| App | Kya hai | Kahan se |
|---|---|---|
| **Live TV fork** | Free Indian TV (iptv-org streams): sirf Hindi/Punjabi/English, dead links pe auto-failover, 2 baar fail hone pe channel khud hide. No ads, no login. | [karnvirpgt/live-tv releases](https://github.com/karnvirpgt/live-tv/releases) |
| **TV Bro** | TV-remote ke liye bana free open-source browser. | [truefedex/tv-bro releases](https://github.com/truefedex/tv-bro/releases) |
| **CastBay** | Phone → TV casting receiver (closed-source freeware). APK manually download karke path dena hota hai. | official site |

**Home launcher** (Apple-TV style, ad-free) chahiye to [CleanYourTV](https://github.com/Gathin23/cleanyourtv) project use karo — wo launcher banata hai; ye kit use replace/ship nahi karta.

## Scripts

| Script | Kya karta hai |
|---|---|
| `setup.sh <ip>` | Connect → bloat discover → permission leke disable → apps puchh ke install → record save |
| `check.sh <ip>` | TV ki current state vs record — kya disabled hai, apps installed hain kya |
| `restore.sh <ip>` | Kit ke saare changes undo (har action wapas) — permission ke saath |

## Universal kaise?

Koi model-specific list copy-paste nahi hoti. Script TV ke andar installed packages scan karta hai aur **junk signatures** (analytics, telemetry, ads, sponsored-rows, tracking) match karta hai — jo mile wahi candidates dikhte hain. Core packages protected hain. Brand-specific junk (Xiaomi, TCL...) ke extra patterns built-in hain; apne TV pe kuch aur mila to `notes/` me likho aur PR bhejo.

## Risks (honest baat)

- ADB debugging TV pe **ON rehna chahiye jab tak setup chal raha hai** — last me OFF karna hi security hai. Setup ke dauran TV aur computer same WiFi pe hon.
- Disable kiye hue packages firmware update ke baad kabhi-kabhi wapas enable ho jate hain — `check.sh` ye pakad leta hai.
- Agar koi zaroori app disable ho gayi (sound/settings weird lage): `restore.sh` sab wapas la deta hai.
- Ye kit **root nahi karta, firmware nahi chhoota** — phir bhi apne risk pe chalao; TV #1 (Xiaomi MiTV-AXSO2) pe fully tested hai, baaki TVs pe junk-patterns generic hain.

## Tested on

- Xiaomi MiTV-AXSO2 (Android 9, 2 GB RAM) — full flow, notes: [`notes/xiaomi-mitv-axso2.md`](notes/xiaomi-mitv-axso2.md)

Apne TV ka record notes/ me add karke PR bhejo — agla user usi model pe asaani se karega. 🤝
