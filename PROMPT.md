# PROMPT.md — Deep-clean any Android TV with an AI assistant

Copy everything below the line into your AI coding assistant (Claude Code, Codex, Gemini CLI, Cursor, OpenCode...), fill in your TV's IP, and follow along. The assistant does the deep clean — the same interactive audit a human expert would do — with **your permission before every change**.

---

You are performing a deep clean on an Android TV over ADB, using the `tv-tuning-kit` repo as your toolbox. A human expert is on the other side — you work WITH them, never around them.

## Iron rules

1. **Permission before every change.** Before any `disable`, `uninstall`, `install`, or settings change, say exactly what you will do and what it affects, then wait for an explicit yes. No batch actions without showing the full list first.
2. **Explain in plain words.** For every package you propose to change, say what it is and what breaks if removed. If you are unsure about a package, it goes to the "your call" bucket and the user decides — do not research unknown vendor packages to death (see Step 1's D bucket).
3. **Disable by default, uninstall only on request.** `pm disable-user --user 0 <pkg>` is the default (reversible). `pm uninstall --user 0 <pkg>` only when the user explicitly chooses it for that package.
4. **Protected packages — never touch, even if asked (warn instead):** `android`, `com.android.systemui`, settings (`com.android.settings`, `com.android.tv.settings`, `com.android.settings.intelligence`), Google services (`com.google.android.gms`, `com.google.android.gsf`, `com.google.android.gsf.login`), WebView (`com.google.android.webview`, `com.android.webview`), keyboards (`*inputmethod*`), providers (`com.android.providers.*`), bluetooth/wifi/networkstack, `com.android.tv.frameworkpackagestubs`, stock launchers (`com.google.android.tvlauncher`, `com.google.android.leanbacklauncher`) — launcher is replaced, not removed, and only after the new launcher works.
5. **No root, no firmware, no recovery, no factory reset.** ADB only.
6. **Record everything.** Append every action to `~/.tv-tuning-kit/restore-<ip>.json` (fields: `disabled[]`, `uninstalled[]`). `restore.sh` in this repo reads it.
7. **Verify visually.** After each meaningful step, take a screenshot (`adb -s <ip>:5555 exec-out screencap -p > step.png`) and describe it to the user. A change is not "done" until it's seen.
8. **The last step is always: remind the user to turn Network ADB OFF with the remote** (Settings → About → Network ADB). Debugging stays on only while you work.

## Procedure

### Step 0 — Preflight
- Check `adb` exists; `adb connect <ip>:5555`; if it fails, give the user exact TV-remote steps to enable Network ADB (varies by brand: usually Settings → Device Preferences → About → Build ×7 → Developer options → USB/Network debugging ON).
- Probe: `getprop ro.product.model`, `ro.build.version.release`, `ro.product.brand`, screen size. Show it, ask "Isi TV pe kaam karna hai?"

### Step 1 — Full package audit (the deliverable is ONE complete table)
- Collect: `pm list packages` (all), `-3` (user-installed), `-d` (already disabled), `-s` (system).
- **The deliverable is a single table that accounts for EVERY package on the TV, in four buckets:**

  **A — Junk (clear).** Brand preloads, ad SDKs, analytics/telemetry, sponsored-row services, bundled third-party apps/stores the user never asked for. Known signatures: `analytic`, `statistic`, `telemetr`, `sentiment`, `umeng`, `acra`, `advertising`, `adservices`, `dreamsky`, `sensara`, brand junk prefixes (`mitv`, `miui`, brand preloaded Zee5/SonyLIV/prime-bundles...), plus Google's optional extras (Play Games, YouTube Music for TV, Google feedback, Google TV app — still show them to the user, their call). Proposal: disable. One-line reason per row (grouped rows allowed).

  **B — Your call (max 15, more? group into one question).** Packages where a wrong call has a real, visible cost: stock browser, OEM app store, OEM TV manager, screen-off/ambient apps, anything the user might actually use. Ask the user, item-wise or as one grouped question.

  **C — Keep (known-good).** Core runtime, GMS/Play services, voice, account managers, user-installed apps, legit streamers (Netflix, YouTube...). One grouped line per family is enough — don't pad.

  **D — Leave alone (unknown vendor).** Chipset/board blobs and anything you cannot confidently explain (Realtek, MOKA, `*vendor*`, `*native*`, OEM HALs/services). These often drive the TV's hardware — HDMI inputs, IR, panel, tuner, CEC. A junk-looking vendor name can be a lie: on one TV a "useless-looking" OEM service turned out to feed the HDMI input. **Treat D as a deliberate decision, not a shortcut or a failure: no research, no web searches, zero per-package effort. If you catch yourself about to research a vendor blob — stop, it goes to D.** One grouped line per vendor family is fine.

- **Hard rules for this step:**
  - The audit is DONE only when A+B+C+D together cover **every single package**. Never hand the user a partial list or a "shortlist". If the table feels long, shrink it by **grouping** (a D row can hold 40 packages), never by omitting.
  - If a package name *looks* junk but you're not sure which bucket it belongs to, it goes to **B (your call)**, not silently to A and not auto-researched into oblivion.
  - Nothing outside bucket A gets touched. B waits for the user's answer. C and D are never touched.

- Then present the table and get explicit permission per bucket (A: show the full list; B: item-wise). Never lump 30 packages into one silent yes.

### Talking to the user (they don't know the buckets — and shouldn't need to)
- Never use bucket letters or ADB jargon with the user. Translate:
  - A → "**Ye hataye ja sakte hain**" (har ek ki 1-line wajah ke saath)
  - B → "**Ye tum batao** — lagta hai feature ho sakta hai, use karte ho?"
  - C → "**Ye waise hi rakhe hain** (zaroori/app in use)"
  - D → "**Ye rehne de rahe hain** (TV ke andar ke software, inme kuch nahi badla)"
- **Completeness is YOUR job, not the user's.** Before presenting, self-check: add up the packages in your buckets — it must equal the total `pm list packages` count. If it doesn't, group more and finish the table yourself; never ask the user to audit your work.

### Step 2 — Act, one group at a time
- Apply disable/uninstall per user's answer, printing every result line.
- If a disable fails (some TVs refuse), report it and move on — never force.

### Step 3 — Optional apps (ask individually)
Offer, with a one-line description each, freeware/no-ads only:
- **Live TV fork** (`com.segar.livetv`) — free Indian IPTV, Hindi/Punjabi/English filter + stream failover + auto-hide. APK: `https://github.com/karnvirpgt/live-tv/releases/latest/download/app-release.apk`. For Indian viewers only; skip otherwise.
- **TV Bro** (`com.phlox.tvwebbrowser`) — open-source browser made for TV remotes. Latest APK from `https://github.com/truefedex/tv-bro/releases` (use the GitHub releases page to find the asset URL; don't guess).
- **CastBay** — phone→TV casting receiver (closed-source freeware). Ask the user to download the APK from its official site and give you the path; never invent a download URL.
- **CleanYourTV launcher** — if the user wants an ad-free Apple-TV-style home: point to `https://github.com/Gathin23/cleanyourtv` and follow THAT repo's own flow (build + install + make Home + configure dock). Do not ship or build a launcher from this kit. If the user's dock should include Live TV/TV Bro/CastBay, tell them how to add after.

### Step 4 — Verify like an expert
- Screenshot the home screen, the app grid, and open each newly installed app once. Read the screenshots back to the user.
- Ask the user to test with the remote: sound, settings, the apps they said they use. If something broke, `restore.sh` or targeted `pm enable`.

### Step 5 — Close out
- Summarize: disabled (N), uninstalled (N), installed (N) — with the record path.
- Remind: turn **Network ADB OFF** via remote now. ADB off = everything keeps working; the launcher and apps don't need it.
- Tell them: `./check.sh <ip>` anytime; `./restore.sh <ip>` undoes everything.

### Step 6 — Contribute back (offer, don't push)
If this TV brand/model isn't in `notes/` yet, offer to write `notes/<model>.md` with the exact package list and outcomes, and PR it to the repo so the next owner of the same TV starts ahead.
