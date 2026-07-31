#!/usr/bin/env bash
#
# install-pve-cpu-temp.sh
#
# Adds CPU/sensor temperature display to the Proxmox VE node "Summary" page,
# based on the widely-shared method from:
#   https://www.reddit.com/r/homelab/comments/rhq56e/
#
# It does two things:
#   1. Installs lm-sensors and patches /usr/share/perl5/PVE/API2/Nodes.pm
#      to expose `sensors` output as a new "thermalstate" field.
#   2. Patches /usr/share/pve-manager/js/pvemanagerlib.js to add a
#      "Thermal State" row to the node Status panel.
#
# NOTE: These are stock Proxmox files. A `pve-manager` package upgrade
# WILL overwrite pvemanagerlib.js and undo the JS change (Nodes.pm is a
# Perl file and is also subject to being overwritten on upgrade). Re-run
# this script after PVE updates if the temperature display disappears.
# Backups of the original files are kept, and you can restore with --uninstall.
#
# Run as root on the Proxmox VE host (not inside a container/VM).

set -euo pipefail

NODES_PM="/usr/share/perl5/PVE/API2/Nodes.pm"
JS_FILE="/usr/share/pve-manager/js/pvemanagerlib.js"
BACKUP_DIR="/root/pve-cpu-temp-backup"

log()  { echo -e "\e[32m[+]\e[0m $*"; }
warn() { echo -e "\e[33m[!]\e[0m $*"; }
err()  { echo -e "\e[31m[-]\e[0m $*" >&2; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    err "This script must be run as root."
    exit 1
  fi
}

require_files() {
  for f in "$NODES_PM" "$JS_FILE"; do
    if [[ ! -f "$f" ]]; then
      err "Expected Proxmox file not found: $f"
      err "Are you running this on a Proxmox VE host?"
      exit 1
    fi
  done
}

backup_files() {
  mkdir -p "$BACKUP_DIR"
  ts=$(date +%Y%m%d-%H%M%S)
  if [[ ! -f "$BACKUP_DIR/Nodes.pm.orig" ]]; then
    cp -a "$NODES_PM" "$BACKUP_DIR/Nodes.pm.orig"
    log "Saved original Nodes.pm to $BACKUP_DIR/Nodes.pm.orig"
  fi
  if [[ ! -f "$BACKUP_DIR/pvemanagerlib.js.orig" ]]; then
    cp -a "$JS_FILE" "$BACKUP_DIR/pvemanagerlib.js.orig"
    log "Saved original pvemanagerlib.js to $BACKUP_DIR/pvemanagerlib.js.orig"
  fi
  # Also keep a timestamped copy of current state before every run
  cp -a "$NODES_PM" "$BACKUP_DIR/Nodes.pm.$ts"
  cp -a "$JS_FILE" "$BACKUP_DIR/pvemanagerlib.js.$ts"
}

install_lmsensors() {
  if ! command -v sensors >/dev/null 2>&1; then
    log "Installing lm-sensors..."
    apt-get update -qq
    apt-get install -y lm-sensors
  else
    log "lm-sensors already installed."
  fi

  log "Running sensors-detect (auto-accept safe defaults)..."
  yes | sensors-detect --auto >/tmp/sensors-detect.log 2>&1 || true
  log "sensors-detect output saved to /tmp/sensors-detect.log"

  if ! sensors >/dev/null 2>&1; then
    warn "The 'sensors' command produced no output. You may need to load a"
    warn "kernel module manually (e.g. 'modprobe coretemp' or 'modprobe k10temp')."
  fi
}

patch_nodes_pm() {
  if grep -q "thermalstate" "$NODES_PM"; then
    log "Nodes.pm already patched, skipping."
    return
  fi

  log "Patching $NODES_PM ..."
  # Insert a thermalstate field right after the pveversion assignment line.
  perl -0pi -e '
    s/(\$res->\{pveversion\}\s*=\s*PVE::pvecfg::package\(\)\s*\.\s*"\/"\s*\.\s*PVE::pvecfg::version_text\(\);)/$1\n\t$res->{thermalstate} = `sensors -j 2>\/dev\/null`;/s
  ' "$NODES_PM"

  if ! grep -q "thermalstate" "$NODES_PM"; then
    err "Failed to patch Nodes.pm automatically (file layout may have changed)."
    err "Restoring from backup and aborting."
    cp -a "$BACKUP_DIR/Nodes.pm.orig" "$NODES_PM"
    exit 1
  fi
  log "Nodes.pm patched successfully."
}

patch_js() {
  if grep -q "itemId: 'thermal'" "$JS_FILE"; then
    log "pvemanagerlib.js already patched, skipping."
    return
  fi

  log "Patching $JS_FILE ..."
  # Insert a new grid item for thermal state right before the "Manager Version" item.
  perl -0pi -e '
    s/(\{\s*itemId:\s*.version.\s*,\s*colspan:\s*2,\s*printBar:\s*false,\s*title:\s*gettext\(.Manager Version.\),\s*textField:\s*.pveversion.\s*,\s*value:\s*.\s*.\s*,\s*\},)/{\n\t\t\titemId: 'thermal',\n\t\t\tcolspan: 2,\n\t\t\tprintBar: false,\n\t\t\ttitle: gettext('"'"'CPU Thermal State'"'"'),\n\t\t\ttextField: '"'"'thermalstate'"'"',\n\t\t\trenderer: function(value) {\n\t\t\t\ttry {\n\t\t\t\t\tvar data = JSON.parse(value);\n\t\t\t\t\tvar parts = [];\n\t\t\t\t\tObject.keys(data).forEach(function(dev) {\n\t\t\t\t\t\tvar section = data[dev];\n\t\t\t\t\t\tObject.keys(section).forEach(function(name) {\n\t\t\t\t\t\t\tif (name === '"'"'Adapter'"'"') { return; }\n\t\t\t\t\t\t\tvar temps = section[name];\n\t\t\t\t\t\t\tObject.keys(temps).forEach(function(t) {\n\t\t\t\t\t\t\t\tif (t.indexOf('"'"'_input'"'"') !== -1) {\n\t\t\t\t\t\t\t\t\tparts.push(dev.split('"'"'-'"'"')[0] + '"'"' '"'"' + name + '"'"': '"'"' + Number(temps[t]).toFixed(1) + '"'"'\xc2\xb0C'"'"');\n\t\t\t\t\t\t\t\t}\n\t\t\t\t\t\t\t});\n\t\t\t\t\t\t});\n\t\t\t\t\t});\n\t\t\t\t\treturn parts.join('"'"', '"'"');\n\t\t\t\t} catch (e) {\n\t\t\t\t\treturn '"'"'n\/a'"'"';\n\t\t\t\t}\n\t\t\t}\n\t\t},\n$1/s
  ' "$JS_FILE"

  if ! grep -q "itemId: 'thermal'" "$JS_FILE"; then
    err "Failed to patch pvemanagerlib.js automatically (file layout may have changed)."
    err "Restoring from backup and aborting."
    cp -a "$BACKUP_DIR/pvemanagerlib.js.orig" "$JS_FILE"
    exit 1
  fi
  log "pvemanagerlib.js patched successfully."
}

restart_services() {
  log "Restarting pveproxy and pvedaemon..."
  systemctl restart pvedaemon
  systemctl restart pveproxy
  log "Done. Hard-refresh your browser (Ctrl+Shift+R) on the node Summary page."
}

uninstall() {
  require_root
  if [[ -f "$BACKUP_DIR/Nodes.pm.orig" ]]; then
    cp -a "$BACKUP_DIR/Nodes.pm.orig" "$NODES_PM"
    log "Restored original Nodes.pm"
  else
    warn "No backup found for Nodes.pm"
  fi
  if [[ -f "$BACKUP_DIR/pvemanagerlib.js.orig" ]]; then
    cp -a "$BACKUP_DIR/pvemanagerlib.js.orig" "$JS_FILE"
    log "Restored original pvemanagerlib.js"
  else
    warn "No backup found for pvemanagerlib.js"
  fi
  restart_services
  exit 0
}

main() {
  require_root

  if [[ "${1:-}" == "--uninstall" ]]; then
    uninstall
  fi

  require_files
  backup_files
  install_lmsensors
  patch_nodes_pm
  patch_js
  restart_services

  echo
  log "All done! Backups are in $BACKUP_DIR"
  log "To revert everything: $0 --uninstall"
}

main "$@"