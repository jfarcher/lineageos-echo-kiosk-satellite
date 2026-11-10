#!/usr/bin/env bash
# Publish a built image as a GitHub release of this repository's origin, in
# the form the Echos' updaters look for: tagged <device>-<release>, titled
# "<device name> <release>", with the zip (codename in its name), its .sig
# and its .sha256. The notes are the release's section of the device's
# changelog.
#
# It runs after the build, from a clean, pushed checkout:
#
#   1. Rename "## Unreleased" in CHANGELOG-<device>.md to the release, commit
#      and push.
#   2. CLEAN=1 make <device>, and wait for "build completed successfully".
#   3. DEVICE=<device> scripts/publish-release.sh
#
# The release is a draft unless PUBLISH=1. The updaters skip drafts, so a
# draft can be checked on GitHub first and published there, or with
# gh release edit <tag> --draft=false.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_DIR="$(realpath "${ECHO_WORKSPACE:-$REPO_ROOT/workspace}")"
TREE="$(realpath "${LINEAGE_TREE:-$WORKSPACE_DIR/lineage-18.1}")"
DEVICE="${DEVICE:-}"
PUBLISH="${PUBLISH:-0}"
OUT="$TREE/out/target/product/$DEVICE"
DIST="$WORKSPACE_DIR/releases"

fail() { echo "ERROR: $*" >&2; exit 1; }

case "$DEVICE" in
  biscuit|crown|cronos|checkers|rook) ;;
  *) fail "set DEVICE to biscuit, crown, cronos, checkers or rook" ;;
esac
for tool in gh git openssl sha256sum unzip; do
  command -v "$tool" >/dev/null || fail "required tool not found: $tool"
done
gh auth status >/dev/null 2>&1 || fail "gh is not logged in: run gh auth login"

# The release and the name the device's releases go by, as build.sh works
# them out.
eval "$(sed -n '/^device_name()/,/^}/p;/^release_version()/,/^}/p' "$REPO_ROOT/scripts/build.sh")"
RELEASE="$(release_version)"
NAME="$(device_name "$DEVICE")"
TAG="$DEVICE-$RELEASE"
[[ -n "$NAME" ]] || fail "build.sh has no device name for $DEVICE"
[[ "$RELEASE" != *-dev ]] ||
  fail "CHANGELOG-$DEVICE.md has an Unreleased heading on top ($RELEASE): rename it to the release and commit"

# The release is the commit it names, and that commit must be on GitHub.
[[ -z "$(git -C "$REPO_ROOT" status --porcelain)" ]] || fail "commit everything first"
git -C "$REPO_ROOT" fetch --quiet origin
HEAD_SHA="$(git -C "$REPO_ROOT" rev-parse HEAD)"
git -C "$REPO_ROOT" branch -r --contains "$HEAD_SHA" | grep -q 'origin/' ||
  fail "HEAD $HEAD_SHA is not pushed to origin: git push first"

# The GitHub repository behind origin, such as jfarcher/lineageos-echo-kiosk-satellite.
GH_REPO="${GH_REPO:-$(git -C "$REPO_ROOT" remote get-url origin | sed -E 's#^(git@github\.com:|https://github\.com/)##; s#\.git$##')}"
gh release view "$TAG" --repo "$GH_REPO" >/dev/null 2>&1 && fail "$GH_REPO already has a release $TAG"

# The newest build, checked the way a release must be. check-image.sh also
# fails when the image reports another release than the changelog's.
BUILT="$(ls -t "$OUT"/lineage-18.1-*-"$DEVICE".zip 2>/dev/null | head -n 1)"
[[ -f "$BUILT" ]] || fail "no built zip for $DEVICE in $OUT: run CLEAN=1 make $DEVICE"
# An empty first argument keeps check-image.sh's own target files zip.
DEVICE="$DEVICE" "$REPO_ROOT/scripts/check-image.sh" "" "$BUILT" ||
  fail "the image failed its checks, do not release it"

mkdir -p "$DIST"
ZIP="$DIST/lineageos-echo-kiosk-satellite-$RELEASE-$DEVICE.zip"
cp "$BUILT" "$ZIP"
"$REPO_ROOT/scripts/sign-release.sh" "$ZIP"
(cd "$DIST" && sha256sum "$(basename "$ZIP")" >"$(basename "$ZIP").sha256")

# The notes: the release's section of the changelog, without its heading.
NOTES="$DIST/$TAG-notes.md"
awk -v release="$RELEASE" '
  /^## / { if (found) exit; split(substr($0, 4), words, " "); if (words[1] == release) { found = 1; next } }
  found { print }
' "$REPO_ROOT/CHANGELOG-$DEVICE.md" >"$NOTES"
[[ -s "$NOTES" ]] || fail "CHANGELOG-$DEVICE.md has no notes for $RELEASE"

DRAFT=(--draft)
[[ "$PUBLISH" == 1 ]] && DRAFT=()
gh release create "$TAG" "$ZIP" "$ZIP.sig" "$ZIP.sha256" \
  --repo "$GH_REPO" \
  --target "$HEAD_SHA" \
  --title "$NAME $RELEASE" \
  --notes-file "$NOTES" \
  "${DRAFT[@]}"

if [[ "$PUBLISH" == 1 ]]; then
  echo "Published $TAG on $GH_REPO."
else
  echo "Created $TAG on $GH_REPO as a draft. The Echos skip drafts. Publish it with:"
  echo "  gh release edit $TAG --repo $GH_REPO --draft=false"
fi
