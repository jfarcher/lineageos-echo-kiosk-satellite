# Where the Echo Spot trees come from

This repository carries its own copies of R0rt1z2's and bengris32's Echo Spot (`rook`) trees from [amazon-oss](https://github.com/amazon-oss), with the Kiosk Satellite Edition changes made in place.

| Copy | Upstream | Branch | Commit |
| --- | --- | --- | --- |
| `sources/device/amazon/rook/` | [android_device_amazon_rook](https://github.com/amazon-oss/android_device_amazon_rook) | `lineage-18.1` | `b27dbfaf90155404c16bde2c26b2aefd74abd426` (2026-11-03, "rook: Re-enable secure services") |
| `sources/vendor/amazon/rook/` (makefiles only) | [android_vendor_amazon_rook](https://github.com/amazon-oss/android_vendor_amazon_rook) | `lineage-18.1` | `de1f065a15cf4d9fe68c8e83faf9219a31626161` (2026-09-27) |

The vendor tree's `proprietary/` files are not copied. `scripts/extract-rook-blobs.sh` downloads them from the vendor commit above and checks them against `blobs/rook/proprietary.sha256`.

## Changes made here

- `lineage_rook.mk` inherits the Kiosk Satellite Edition layers (`vendor/kiosk-satellite/config/common.mk`, `show.mk` and `device/kiosk-satellite/rook/device.mk`), and the model is `Echo Spot (KS)`.
- `BoardConfig.mk` sets `TARGET_RELEASETOOLS_EXTENSIONS := vendor/kiosk-satellite/releasetools`.
- This file.

## Checking for upstream fixes

```sh
git clone -b lineage-18.1 https://github.com/amazon-oss/android_device_amazon_rook /tmp/rook
git -C /tmp/rook log --oneline b27dbfaf90155404c16bde2c26b2aefd74abd426..HEAD
```

To take a fix, apply its commit here with `git -C /tmp/rook format-patch -1 <commit> --stdout | git apply --directory=sources/device/amazon/rook`, then update the commit in the table above.

For the vendor tree, a new commit means new blobs: update `COMMIT` in `scripts/extract-rook-blobs.sh`, regenerate `blobs/rook/proprietary.sha256` from that commit's `proprietary/` and copy any makefile changes into `sources/vendor/amazon/rook/`.
