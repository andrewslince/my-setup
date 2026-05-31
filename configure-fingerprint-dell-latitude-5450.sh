#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Dell Latitude 5450 - Fingerprint setup for Ubuntu/Linux
# Sensor tested: Broadcom Corp. 58200 - USB ID 0a5c:5865
#
# What this script does:
# 1. Checks if the expected Broadcom fingerprint sensor exists
# 2. Installs fprintd/libfprint/PAM dependencies
# 3. Removes the older Broadcom TOD driver, if present
# 4. Downloads and installs the Broadcom CV3+ driver from Dell/Canonical
# 5. Reloads udev and restarts fprintd
# 6. Enables fingerprint authentication in PAM
# 7. Starts fingerprint enrollment for the current user
# ============================================================

EXPECTED_USB_ID="0a5c:5865"
WORKDIR="${HOME}/Downloads/dell-fingerprint"
CV3PLUS_DEB_PATTERN="libfprint-2-tod1-broadcom-cv3plus_*~24.04*_amd64.deb"

CV3PLUS_URL_HTTP="http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-broadcom-cv3plus/libfprint-2-tod1-broadcom-cv3plus_6.4.342-6.4.058.0-0ubuntu1~24.04.1~oem1_amd64.deb"

CV3PLUS_URL_FALLBACK="https://www.pt.archive.canonical.com/pool/public/libf/libfprint-2-tod1-broadcom-cv3plus/libfprint-2-tod1-broadcom-cv3plus_6.4.342-6.4.058.0-0ubuntu1~24.04.1~oem1_amd64.deb"

echo
echo "============================================================"
echo " Dell Latitude 5450 - Fingerprint setup"
echo " Expected sensor: ${EXPECTED_USB_ID} Broadcom Corp. 58200"
echo "============================================================"
echo

if ! command -v lsb_release >/dev/null 2>&1; then
  echo "[INFO] Installing lsb-release..."
  sudo apt update
  sudo apt install -y lsb-release
fi

DISTRO="$(lsb_release -ds || true)"
echo "[INFO] Detected system: ${DISTRO}"
echo

echo "[INFO] Checking fingerprint sensor..."
if ! lsusb | grep -qi "${EXPECTED_USB_ID}"; then
  echo "[ERROR] Expected fingerprint sensor ${EXPECTED_USB_ID} was not found."
  echo
  echo "Detected USB devices that may be relevant:"
  lsusb | grep -Ei 'finger|fprint|goodix|broadcom|0a5c|27c6' || true
  echo
  echo "Aborting to avoid installing the wrong driver."
  exit 1
fi

echo "[OK] Expected fingerprint sensor found:"
lsusb | grep -i "${EXPECTED_USB_ID}"
echo

echo "[INFO] Creating working directory: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo
echo "[INFO] Installing base fingerprint packages..."
sudo apt update
sudo apt install -y \
  wget \
  ca-certificates \
  fprintd \
  libpam-fprintd \
  libfprint-2-tod1

echo
echo "[INFO] Removing older/generic Broadcom TOD driver if installed..."
sudo apt remove -y libfprint-2-tod1-broadcom || true

echo
echo "[INFO] Downloading Broadcom CV3+ driver..."
if ls ${CV3PLUS_DEB_PATTERN} >/dev/null 2>&1; then
  echo "[OK] CV3+ .deb already exists locally. Skipping download."
else
  echo "[INFO] Trying Dell/Canonical HTTP URL first..."
  if ! wget -4 --timeout=20 --tries=3 "${CV3PLUS_URL_HTTP}"; then
    echo "[WARN] Primary download failed. Trying fallback mirror..."
    wget -4 --timeout=20 --tries=3 "${CV3PLUS_URL_FALLBACK}"
  fi
fi

echo
echo "[INFO] Installing Broadcom CV3+ driver..."
sudo apt install -y ./${CV3PLUS_DEB_PATTERN}

echo
echo "[INFO] Fixing dependencies if needed..."
sudo apt --fix-broken install -y

echo
echo "[INFO] Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo
echo "[INFO] Restarting fprintd..."
sudo systemctl restart fprintd

echo
echo "[INFO] Current fingerprint-related packages:"
dpkg -l | grep -Ei 'fprint|broadcom|cv3' || true

echo
echo "[INFO] Checking udev rule for sensor ${EXPECTED_USB_ID}..."
grep -R "5865" /usr/lib/udev/rules.d /etc/udev/rules.d 2>/dev/null || true

echo
echo "[INFO] Enabling fingerprint authentication in PAM..."
if sudo pam-auth-update --enable fprintd; then
  echo "[OK] PAM fingerprint authentication enabled."
else
  echo "[WARN] Could not enable PAM fingerprint authentication automatically."
  echo "      Run manually later with: sudo pam-auth-update"
  echo "      Then mark: Fingerprint authentication"
fi

echo
echo "============================================================"
echo " Driver installation finished."
echo " Now the script will start fingerprint enrollment."
echo
echo " IMPORTANT:"
echo " - Touch the fingerprint sensor."
echo " - Lift your finger completely."
echo " - Touch again with a slightly different angle."
echo " - Repeat until you see: enroll-completed"
echo "============================================================"
echo

fprintd-enroll -f right-index-finger

echo
echo "============================================================"
echo " Testing fingerprint verification..."
echo " Touch the fingerprint sensor when requested."
echo "============================================================"
echo

fprintd-verify || true

echo
echo "============================================================"
echo " Setup finished."
echo
echo " To test sudo authentication, run:"
echo "   sudo -k"
echo "   sudo true"
echo
echo " If fingerprint stops being detected after installation,"
echo " try:"
echo "   sudo systemctl restart fprintd"
echo "============================================================"
