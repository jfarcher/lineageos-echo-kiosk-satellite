# CLAUDE.md

This repository is a fork of [jxlarrea/lineageos-echo-kiosk-satellite](https://github.com/jxlarrea/lineageos-echo-kiosk-satellite), kept at [jfarcher/lineageos-echo-kiosk-satellite](https://github.com/jfarcher/lineageos-echo-kiosk-satellite). Its one addition is the **Echo Spot (1st gen), `rook`**, which upstream does not support. Changes are not sent back upstream: the fork takes upstream's work and keeps its own Rook work on top.

## Remotes

| Remote | Repository | What it is for |
| --- | --- | --- |
| `origin` | `jfarcher/lineageos-echo-kiosk-satellite` | This fork. Releases and the Echo Spot's system updates come from here. |
| `upstream` | `jxlarrea/lineageos-echo-kiosk-satellite` | The project this fork follows. |
| `meiser79` | `meiser79/lineageos-echo-kiosk-satellite` | Peter Meiser's own Rook port, tested on a Spot. Most of the Rook fixes come from it. |

The Rook device and vendor trees come from [amazon-oss](https://github.com/amazon-oss) (R0rt1z2 and bengris32) and are copied into `sources/`, not synced. [sources/device/amazon/rook/UPSTREAM.md](sources/device/amazon/rook/UPSTREAM.md) records the commits they come from and the edits made to them.

Add a missing remote with `git remote add <name> https://github.com/<repository>.git`.

## Where the Rook work lives

- `sources/device/amazon/rook/`: amazon-oss's device tree with this repository's edits. Its `lineage_rook.mk` inherits the Kiosk Satellite Edition layers directly, where the other Shows do it through a patch.
- `sources/vendor/amazon/rook/`: the vendor tree's makefiles only. `scripts/extract-rook-blobs.sh` downloads the proprietary files from a pinned commit and checks them against `blobs/rook/proprietary.sha256`.
- `device/rook/device.mk`: the Spot's Kiosk Satellite settings.
- `patches/rook/`: patches to other projects. `frameworks/base/0001` and `0002` are copies of `patches/cronos/frameworks/base/`.
- `manifest/local.xml` and `manifest/lock.xml`: `kernel/amazon/bcmdhd`, the Spot's Wi-Fi driver.
- `rook` in each device list: `Makefile`, `scripts/build.sh` (`device_name`), `scripts/stage-tree.sh`, `scripts/check-image.sh`, `scripts/sign-release.sh`, `scripts/publish-release.sh` and `tests/test-device-layers.sh`.
- `CHANGELOG-rook.md`, `docs/echo-spot.md`.

## What must stay as the fork has it

- **Update URL.** `RELEASES` in `common/echo-service/src/me/jxl/echo/service/SystemUpdate.java` points at `jfarcher`. Upstream's has `jxlarrea`. A merge must keep `jfarcher`, or the Shows and the Spot built here look for updates in upstream's releases. The Echo Dots' `common/dot/biscuit-service/.../SystemUpdate.java` still points at `jxlarrea`: the fork does not build the Dots.
- **Public keys.** `common/ota/release-key.pem` and `common/dot/ota/release-key.pem` are this fork's public key, fingerprint `3919fb2e4466389d`. Upstream's are jxlarrea's. Keep ours. Check a key with `openssl pkey -pubin -in <file> -outform DER | shasum -a 256 | cut -c1-16`.
- **No private keys in the repository.** The signing key lives at `~/.config/biscuit-ota/release-key.pem`, on the Mac and the build box. `.gitignore` keeps out every key and certificate except the two public keys.

## Taking upstream's changes

Check first:

```sh
git fetch upstream
git log --oneline main..upstream/main
```

Look at each commit for whether it reaches the Spot:

- **Reaches the Spot:** `common/` (the shared layer, EchoService, show.mk, common.mk), `patches/common/`, `scripts/`, the manifests and the docs the Spot's guide shares (`unlocking.md`, `twrp.md`, `building.md`).
- **Needs copying by hand:** a change to `patches/cronos/frameworks/base/0001` or `0002`. Compare with `diff -r patches/cronos/frameworks/base patches/rook/frameworks/base` and carry it into `patches/rook/`. A change upstream makes to every Show's `device.mk` may belong in `device/rook/device.mk` too.
- **Does not reach the Spot:** another device's tree, changelog, docs or release.

Merge on a branch, never rebase, since releases are made from `main`'s commits:

```sh
git switch -c upstream-merge-<date> main
git merge --no-ff upstream/main
```

- **Conflicts** are mostly device lists where both sides added a device. Keep both, with `rook` in each.
- **Commit the merge as a merge commit.** Do not squash it or copy upstream's files into an ordinary commit. Either way git loses track of what was merged, and the next merge brings back every conflict again.

After the merge:

1. `git log --oneline HEAD..upstream/main` prints nothing.
2. `git diff --name-only upstream/main HEAD` lists only the fork's own files: the Rook files above, `SystemUpdate.java`, the two public keys and `.gitignore`.
3. Run the tests. `tests/test-stage-tree.sh` needs Linux, the others run on macOS:

   ```sh
   bash tests/test-device-layers.sh
   bash tests/test-echo-system-update.sh
   bash tests/test-biscuit-system-update.sh
   ```

4. Add an `## Unreleased` entry to `CHANGELOG-rook.md` for what the Spot gains, marked "From upstream".
5. Push the branch, open a pull request into `main` on `origin` and merge it there.

## Taking amazon-oss's changes to the Rook trees

```sh
git ls-remote https://github.com/amazon-oss/android_device_amazon_rook refs/heads/lineage-18.1
git ls-remote https://github.com/amazon-oss/android_vendor_amazon_rook refs/heads/lineage-18.1
git ls-remote https://github.com/amazon-oss/android_kernel_amazon_amzn-bcmdhd refs/heads/lineage-18.1
```

Compare each with the commit in `UPSTREAM.md`, or with `lock.xml` for `bcmdhd`, and follow `UPSTREAM.md` to apply a change. Keep the edits it lists, including Peter Meiser's camera, Bluetooth and A2DP changes.

## Taking Peter Meiser's changes

```sh
git fetch meiser79
git log --oneline main..meiser79/main
```

Their fork keeps the Rook tree as patches against amazon-oss (`patches/rook/device/amazon/rook/`). Here the tree is in `sources/`, so apply a patch of theirs there with `git apply --directory=sources/device/amazon/rook`, and add the file it changes to the list in `UPSTREAM.md`. Commit each change with `--author="Peter Meiser <peter.meiser@gmx.com>"` and the commit it came from. Leave out their release scripts, keys and `SystemUpdate.java`, and `persist.echo.pm.allow_resign`.

## Building and releasing

The build runs on a separate Linux box in Docker (`make docker`, `make sync`, `CLEAN=1 make rook`). The macOS checkout cannot build. `make rook` starts a detached container and returns at once. The build is done at `#### build completed successfully` in `docker logs -f lineage-18.1-rook-build`, which takes hours on a clean build.

To release:

1. Rename `## Unreleased` in `CHANGELOG-rook.md` to `## <release> - <date>`, commit and push.
2. `CLEAN=1 make rook` on the build box, and wait for it.
3. `make release DEVICE=rook`. It refuses a dirty, unpushed or still-building tree, a release tag that exists and a key that does not match the public key. The release is a draft until `gh release edit rook-<release> --draft=false`, or run it with `PUBLISH=1`.

A published release reaches every Spot as a system update, so a release is the owner's call after testing on a Spot. Do not commit to `main`, push or publish a release without being asked.
