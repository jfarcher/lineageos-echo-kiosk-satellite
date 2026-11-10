#!/usr/bin/env bash
# Put the Echo Spot's proprietary files into vendor/amazon/rook in the tree.
# sources/vendor/amazon/rook holds the makefiles. The files themselves come
# from amazon-oss's android_vendor_amazon_rook at the commit named here, each
# checked against blobs/rook/proprietary.sha256, so they stay out of this
# repository and an upstream rewrite cannot change them.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_DIR="${ECHO_WORKSPACE:-$REPO_ROOT/workspace}"
TREE="${LINEAGE_TREE:-$WORKSPACE_DIR/lineage-18.1}"
COMMIT="de1f065a15cf4d9fe68c8e83faf9219a31626161"
URL="https://codeload.github.com/amazon-oss/android_vendor_amazon_rook/tar.gz/$COMMIT"
SUMS="$REPO_ROOT/blobs/rook/proprietary.sha256"
OUT="$TREE/vendor/amazon/rook"
TARBALL="$WORKSPACE_DIR/downloads/android_vendor_amazon_rook-$COMMIT.tar.gz"

for tool in curl tar sha256sum; do
  command -v "$tool" >/dev/null || { echo "ERROR: required tool not found: $tool" >&2; exit 1; }
done

# Already there and intact: nothing to do.
if [[ -d "$OUT" ]] && (cd "$OUT" && sha256sum -c --quiet "$SUMS" >/dev/null 2>&1); then
  echo "SKIP vendor/amazon/rook blobs already match blobs/rook/proprietary.sha256"
  exit 0
fi

mkdir -p "$(dirname "$TARBALL")" "$OUT"
[[ -f "$TARBALL" ]] || curl --fail --location --progress-bar -o "$TARBALL" "$URL"
tar -xzf "$TARBALL" -C "$OUT" --strip-components=1 --wildcards '*/proprietary/*'

if ! (cd "$OUT" && sha256sum -c --quiet "$SUMS"); then
  echo "ERROR: the Echo Spot's blobs do not match blobs/rook/proprietary.sha256" >&2
  rm -rf "$OUT/proprietary" "$TARBALL"
  exit 1
fi
echo "Extracted the Echo Spot's blobs to $OUT"
