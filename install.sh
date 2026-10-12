#!/usr/bin/bash
set -euo pipefail

readonly script_dir="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"
readonly src="$script_dir/config/51-framework-internal-mic.conf"
readonly dst='/etc/wireplumber/wireplumber.conf.d/51-framework-internal-mic.conf'
readonly backup='/var/lib/framework-audio/pre-install/51-framework-internal-mic.conf'

# This configuration was validated only on this CachyOS/Framework platform.
source /etc/os-release
[[ ${ID:-} == cachyos ]] || { printf '%s\n' 'Expected CachyOS.' >&2; exit 1; }
read -r product < /sys/class/dmi/id/product_name
read -r board < /sys/class/dmi/id/board_name
[[ $product == 'Laptop 13 (AMD Ryzen AI 300 Series)' && $board == FRANMGCP05 ]] || {
    printf '%s\n' 'Unsupported Framework platform.' >&2
    exit 1
}
/usr/bin/spa-json-dump "$src" > /dev/null

# An unchanged configuration needs neither root access nor a disk write.
if [[ -f "$dst" ]] && cmp -s -- "$src" "$dst" && [[ $(stat -c '%u:%a' -- "$dst") == 0:644 ]]; then
    printf '%s\n' 'Native microphone configuration is already installed.'
    exit 0
fi
(( EUID == 0 )) || { printf '%s\n' 'Administrator authentication required.' >&2; exit 1; }

install -d -m 0755 /etc/wireplumber/wireplumber.conf.d
if [[ -f "$dst" && ! -e "$backup" ]]; then
    install -d -m 0700 "$(dirname -- "$backup")"
    cp -p -- "$dst" "$backup"
fi

# Replace the configuration atomically; leave ALSA state to its native service.
temp_config=$(mktemp '/etc/wireplumber/wireplumber.conf.d/.framework-mic.XXXXXX')
trap 'rm -f -- "$temp_config"' EXIT
install -o root -g root -m 0644 "$src" "$temp_config"
mv -fT -- "$temp_config" "$dst"
printf '%s\n' 'Installed native Framework microphone configuration.'
