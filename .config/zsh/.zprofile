# Brave/Chromium password store
export CHROME_FLAGS="--password-store=kwallet6"
export CHROMIUM_FLAGS="--password-store=kwallet6"

# Recommended for Wayland users (makes Brave/Electron apps run natively)
export ELECTRON_OZONE_PLATFORM_HINT=auto

# Kill any inherited LC_ALL which breaks everything
unset LC_ALL

# Force English day names and European dots
export LANG="en_US.UTF-8"
export LC_TIME="en_DK.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_NUMERIC="en_DK.UTF-8"
