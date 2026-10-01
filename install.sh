#!/usr/bin/env bash
# ==============================================================================
# Lunaris OS Mobile — Automated Build & Device Installer
# ==============================================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}             LUNARIS OS // MOBILE DECK INSTALLER                ${NC}"
echo -e "${CYAN}================================================================${NC}"

# 1. Verify Prerequisites
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}[ERROR] 'flutter' command not found. Please install the Flutter SDK.${NC}"
    exit 1
fi

if ! command -v adb &> /dev/null; then
    echo -e "${RED}[ERROR] 'adb' command not found. Please install Android Platform Tools.${NC}"
    exit 1
fi

# 2. Check for Connected Android Devices
echo -e "\n${YELLOW}[1/4] Checking connected Android devices via ADB...${NC}"
DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device$" | wc -l)

if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${RED}[!] No authorized Android device detected via ADB.${NC}"
    echo -e "    1. Connect your phone via USB."
    echo -e "    2. Enable 'Developer Options' and 'USB Debugging' in Android Settings."
    echo -e "    3. Authorize the USB debugging prompt on your phone screen."
    echo -e "    Run 'adb devices' to verify."
    exit 1
fi

DEVICE_ID=$(adb devices | grep -v "List" | grep "device$" | head -n 1 | awk '{print $1}')
echo -e "${GREEN}[✓] Target device identified: ${DEVICE_ID}${NC}"

# 3. Build Flutter APK
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${SCRIPT_DIR}/aetheris_control"

echo -e "\n${YELLOW}[2/4] Fetching dependencies in ${APP_DIR}...${NC}"
cd "${APP_DIR}"
flutter pub get

echo -e "\n${YELLOW}[3/4] Compiling Lunaris OS Android Launcher APK...${NC}"
flutter build apk --debug

APK_PATH="${APP_DIR}/build/app/outputs/flutter-apk/app-debug.apk"
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}[ERROR] Build failed: APK file not found at ${APK_PATH}${NC}"
    exit 1
fi

# 4. Streamed Installation via ADB
echo -e "\n${YELLOW}[4/4] Installing Lunaris OS APK onto device [${DEVICE_ID}]...${NC}"
adb -s "${DEVICE_ID}" install -r -d -t "${APK_PATH}"

# 5. Launch the Activity
echo -e "\n${CYAN}Launching Lunaris OS Cockpit Bridge...${NC}"
adb -s "${DEVICE_ID}" shell am start -n com.aetheris.aetheris_control/.MainActivity

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}[✓] Lunaris OS successfully deployed to your phone!              ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "${CYAN}Next Steps on your device:${NC}"
echo -e "  1. Go to ${YELLOW}Settings -> Apps -> Default Apps -> Home app${NC}"
echo -e "  2. Select ${YELLOW}Lunaris OS (Aetheris Control)${NC} as your default launcher."
echo -e "  3. Enjoy your sci-fi spacecraft bridge, gyrocompass HUD & dynamic capsule!"
