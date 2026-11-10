# Echo Spot (1st gen) changelog

All notable changes to the Echo Spot (1st gen) (`rook`) image are documented here. The [Echo Dot (2nd gen)](CHANGELOG-biscuit.md), [Echo Show 5 (1st gen)](CHANGELOG-checkers.md), [Echo Show 5 (2nd gen)](CHANGELOG-cronos.md) and [Echo Show 8 (1st gen)](CHANGELOG-crown.md) have their own.

## Unreleased

### Added
- **Echo Spot (1st gen) on LineageOS 18.1, not yet tested on hardware.** The repository carries the amazon-oss `rook` device and vendor trees by R0rt1z2 and bengris32 in `sources/`, with the Kiosk Satellite Edition layer on top: EchoService, Kiosk Satellite on first boot, pryond, system updates and the Kiosk Satellite boot animation. The model reads Echo Spot (KS). EchoService names the Spot `echo-spot-ks` and the end of its serial on the network.
- **The Spot's proprietary files come from a pinned commit.** `scripts/extract-rook-blobs.sh` downloads them from amazon-oss's `android_vendor_amazon_rook` and checks each against `blobs/rook/proprietary.sha256`.
- **The Broadcom Wi-Fi module.** `kernel/amazon/bcmdhd` joins the manifest, pinned in `lock.xml`.

### Not done yet
- The microphone and echo canceller values are the Echo Show 5 (2nd gen)'s and need tuning on a Spot.
- The button: how the Spot's privacy circuit reacts to a short and a long press is unknown, so neither `ro.echo.privacy_hold` nor `ro.echo.button_long_press` is set.
- Double tap to wake: the Spot's touch driver already has wake on touch. Whether a double tap is needed is untested.
- The guide, unlocking steps (amonet-rook) and the README entry.
