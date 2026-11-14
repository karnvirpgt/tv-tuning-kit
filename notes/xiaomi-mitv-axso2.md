# Tested TV: Xiaomi MiTV-AXSO2 (Android 9, 2 GB RAM, armeabi-v7a)

Full kit flow, tested 14 Nov 2026. Exact packages found junk on this model (setup.sh in-me se milta hai):

## Removed (humein uninstall kiya — user permission se)

android.autoinstalls.config.xiaomi.amelie, android.autoinstalls.config.xioami.dangal,
co.sensara.tv.mitv, com.google.android.leanbacklauncher.recommendations,
com.google.android.music, com.google.android.play.games, com.google.android.videos,
com.google.android.youtube.tvmusic, com.mitv.gallery, com.mitv.tvhome.atv,
com.mitv.tvhome.mitvplus, com.miui.tv.analytics, com.tcl.browser,
com.xiaomi.floatingframe, com.xiaomi.mimusic2, com.xiaomi.mitv.handbook,
com.xiaomi.mitv.tvmanager, com.xiaomi.statistic, com.xiaomitv.sonyliv,
com.xiaomo.tv.milegal, com.xm.webcontent, com.zee5.xiaomiTV

(restore: `pm install-existing <pkg>` — restore.sh yahi karta hai)

## Model-specific baatein

- `com.xiaomi.mitv.updateservice` (OTA update) — user ne disabled rakha hai (roka nahi is kit ne; auto-update rokna personal choice hai).
- TV provider (com.android.providers.tv) ka ad-DB bhi clear kiya gaya tha — CleanYourTV tools se.
- Home launcher: CleanYourTV (Aurora theme) — uske apne repo tools se (Gathin23/cleanyourtv). Dock: YouTube | Play Store | Live TV | CastBay.
- Network ADB 5555 — setup ke baad user ne khud OFF kiya (remote se).

## Apps installed

| App | Package | Source |
|---|---|---|
| Live TV fork | com.segar.livetv | karnvirpgt/live-tv releases |
| TV Bro | com.phlox.tvwebbrowser | truefedex/tv-bro v2.1.6 (Android 9 compatible) |
| CastBay | (receiver) | official site, v1.10.0 |
| Brave browser | — | **removed** (phone UI, remote-friendly nahi; TV Bro better) |
