#!/bin/sh
set -eu

REPO_KIND="${1:-}"
TAG="${2:-}"
CPU="${3:-$(dpkg --print-architecture)}"

if [ -z "$REPO_KIND" ]; then
    echo "Usage: install_iptvboss.sh <stable|beta> [tag] [cpu]" >&2
    exit 1
fi

if [ -z "$TAG" ]; then
    exit 0
fi

case "$REPO_KIND" in
    stable)
        REPO="iptvboss-release"
        ;;
    beta)
        REPO="iptvboss-beta"
        ;;
    *)
        echo "Unknown repo kind: $REPO_KIND" >&2
        exit 1
        ;;
esac

VERSION="${TAG#v}"
DEB_FILE="iptvboss_${VERSION}_${CPU}.deb"
RELEASE_URL="https://github.com/walrusone/${REPO}/releases/download/${TAG}"
PACKAGES_FILE="/tmp/iptvboss-packages"

wget -q "${RELEASE_URL}/${DEB_FILE}"
wget -q -O "$PACKAGES_FILE" "${RELEASE_URL}/Packages"

EXPECTED_SHA=$(awk -v deb="$DEB_FILE" '
    /^Filename:[[:space:]]+/ {fn=$2}
    /^SHA256:[[:space:]]+/ {sha=$2}
    /^$/ {
        if (fn==deb && sha!="") {
            print sha
            exit
        }
        fn=""
        sha=""
    }
    END {
        if (fn==deb && sha!="") {
            print sha
        }
    }
' "$PACKAGES_FILE")

if [ -z "$EXPECTED_SHA" ]; then
    echo "Could not find SHA256 for ${DEB_FILE} in Packages metadata" >&2
    exit 1
fi

echo "${EXPECTED_SHA}  ${DEB_FILE}" | sha256sum -c -
rm -f "$PACKAGES_FILE"

apt-get update
if ! apt-get install -y "./${DEB_FILE}"; then
    dpkg -i "./${DEB_FILE}" || true
    apt-get install -f -y
fi

rm -f "$DEB_FILE"
