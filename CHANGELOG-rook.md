# Echo Spot (1st gen) changelog

All notable changes to the Echo Spot (1st gen) (`rook`) image are documented here. The [Echo Dot (2nd gen)](CHANGELOG-biscuit.md), [Echo Show 5 (1st gen)](CHANGELOG-checkers.md), [Echo Show 5 (2nd gen)](CHANGELOG-cronos.md) and [Echo Show 8 (1st gen)](CHANGELOG-crown.md) have their own.

## Unreleased

### Changed
- **The guide explains Android's Private DNS** ([#63](https://github.com/jxlarrea/lineageos-echo-kiosk-satellite/issues/63)). When the router hands out a public DNS server such as 8.8.8.8 next to the local one, Android can send every lookup to the public server, and a Home Assistant name only the local server knows then resolves to its public address. The Network section of [docs/echo-spot.md](docs/echo-spot.md) shows how to check which servers Android picked and how to turn Private DNS off. From upstream.
- **The voice capture sources record the raw microphone** ([kiosk-satellite #1622](https://github.com/jxlarrea/kiosk-satellite/discussions/1622)). An app that recorded on Android's voice communication or voice recognition source got Amazon's VoIP or ASR pipeline instead of microphone 0. Android now opens both sources as a plain microphone capture, the raw microphone 0 that Kiosk Satellite records on. From upstream.

## 2026.11.3 - 2026-11-15

Improvements from  [Peter Meiser's](https://github.com/meiser79) [fork](https://github.com/meiser79/lineageos-echo-kiosk-satellite), where they were tested on a Spot.

### Fixed
- **The camera's colour.** The camera software, which comes from the Echo Show 5 (1st gen), never got the Spot's tuning, so pictures were grey and too bright by day and red in dim light. The camera now uses the Show 5's tuning with the Spot sensor's own gains, exposure and white balance. The black level is corrected, so a covered lens is black instead of red. Colour noise is lower, and exposures are longer in dim light.
- **Bluetooth stays up.** The Bluetooth chip went to sleep with no way to wake it, so Bluetooth restarted each time Kiosk Satellite's Bluetooth proxy started a scan. The chip now stays awake.
- **Bluetooth audio plays to headphones and speakers.** The Spot connected to them but kept playing through its own speaker, and could only receive audio from phones. It now does both.
- **No Bluetooth audio stutter while scanning.** Android's balanced scan holds back Bluetooth audio for a second at a time on the Spot's chip. EchoService now sets 30 ms scan windows every 120 ms on a fresh install.
- **Wi-Fi no longer drops every minute or two.** The Wi-Fi driver sends log data the Wi-Fi HAL did not expect, and the HAL crashed reading past it.

### Changed
- **Amazon's voice processing passes the microphones through.** Its ASR and Voice pipelines no longer change the audio before Kiosk Satellite hears it, as on the Echo Show 5. The noise suppression setting is no longer set, since the Spot has no EchoParts.
- **Android's usual button.** The Spot has no privacy chip, so a short press turns the screen on and off and holding it opens the power menu. `echo_service button` no longer mentions a privacy chip on the Spot.
- **The Echo Spot guide.** [docs/echo-spot.md](docs/echo-spot.md), with Spot sections in the unlocking and TWRP guides.

## 2026.11.2 - 2026-11-14

### Changed
- **The nightly storage trim runs.** Android's storage maintenance, which trims `/data` and `/cache`, waited for the device to be idle and charging, which an Echo never is. It now runs once a day at 3 AM, which helps the eMMC spread wear. From upstream.
- **No more error report every 30 minutes.** The kernel has no per-app network statistics, so Android's statistics poll failed and wrote an error report to storage each time. Android now reports empty statistics there. From upstream.
- **No lock sound.** With the lock screen off, Android still played its lock sound at every boot and each time the screen turned off. Settings > Sound turns it back on. From upstream.

## 2026.11.1 - 2026-11-10

### Added
- **Echo Spot (1st gen) on LineageOS 18.1, not yet tested on hardware.** The repository carries the amazon-oss `rook` device and vendor trees by R0rt1z2 and bengris32 in `sources/`, with the Kiosk Satellite Edition layer on top: EchoService, Kiosk Satellite on first boot, pryond, system updates and the Kiosk Satellite boot animation. The model reads Echo Spot (KS). EchoService names the Spot `echo-spot-ks` and the end of its serial on the network.
- **The Spot's proprietary files come from a pinned commit.** `scripts/extract-rook-blobs.sh` downloads them from amazon-oss's `android_vendor_amazon_rook` and checks each against `blobs/rook/proprietary.sha256`.
- **The Broadcom Wi-Fi module.** `kernel/amazon/bcmdhd` joins the manifest, pinned in `lock.xml`.

### Not done yet
- The microphone and echo canceller values are the Echo Show 5 (2nd gen)'s and need tuning on a Spot.
- The button: how the Spot's privacy circuit reacts to a short and a long press is unknown, so neither `ro.echo.privacy_hold` nor `ro.echo.button_long_press` is set.
- Double tap to wake: the Spot's touch driver already has wake on touch. Whether a double tap is needed is untested.
- The guide, unlocking steps (amonet-rook) and the README entry.
