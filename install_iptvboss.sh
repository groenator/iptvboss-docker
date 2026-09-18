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
        CHANNEL="release"
        ;;
    beta)
        CHANNEL="beta"
        ;;
    *)
        echo "Unknown repo kind: $REPO_KIND" >&2
        exit 1
        ;;
esac

VERSION="${TAG#v}"
REPOSITORY_URL="https://getboss.iptvboss.pro/releases/${CHANNEL}/${VERSION}/debian"
DEB_FILE="iptvboss_${VERSION}_${CPU}.deb"
PACKAGES_FILE="/tmp/iptvboss-packages"

wget -q "${REPOSITORY_URL}/${DEB_FILE}"
wget -q -O "$PACKAGES_FILE" "${REPOSITORY_URL}/Packages"

EXPECTED_SHA=$(awk -v deb="$DEB_FILE" '
    /^Filename:[[:space:]]+/ {fn=$2}
    /^SHA256:[[:space:]]+/ {sha=$2}
    /^$/ {
        count=split(fn, path, "/")
        if (path[count]==deb && sha!="") {
            found=1
            print sha
            exit
        }
        fn=""
        sha=""
    }
    END {
        count=split(fn, path, "/")
        if (!found && path[count]==deb && sha!="") {
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
