#!/usr/bin/env bash
set -euo pipefail

JOBS="$(nproc --all 2>/dev/null || echo 8)"

usage() {
  cat <<'EOF'
Usage:
  .repo/local_manifests/sync_projects.sh                # sync ALL (fast-forward to remote latest per-project)
  .repo/local_manifests/sync_projects.sh common         # sync common only
  .repo/local_manifests/sync_projects.sh thyme lmi      # sync selected targets

Supported targets:
  common sm8250-common thyme psyche lmi enuma
Aliases:
  sm8250, mikona-common -> sm8250-common

Notes:
  - Runs from ROM root.
  - After repo sync + repo start, it will:
      * fetch all remotes in each project (best-effort)
      * pick a remote that actually has the branch
      * git reset --hard <remote>/<branch> (remote latest)
      * set upstream to that remote branch
EOF
}

log() { printf "\n==> %s\n" "$*"; }

# sync + start + reset to remote latest (auto-detect correct remote) + set upstream
sync_start_track_latest() {
  local BR="$1"; shift
  local PROJS=("$@")

  log "repo sync (${#PROJS[@]} projects) [detach + force-sync]"
  repo sync --force-checkout --detach --force-sync -j"${JOBS}" "${PROJS[@]}"

  log "repo start ${BR}"
  repo start "${BR}" "${PROJS[@]}"

  log "fetch + hard reset to <remote>/${BR} + set upstream (auto remote)"
  repo forall "${PROJS[@]}" -c '
set -e
BR="'"$BR"'"
proj="$(pwd)"

# 1) fetch all remotes (best-effort)
for r in $(git remote); do
  git fetch "$r" 2>/dev/null || true
done

# 2) choose a remote that actually has refs/remotes/<remote>/<BR>
chosen=""

# Prefer these remotes if available (you can reorder this priority)
for pref in flicker-dev flicker-gitlab origin upstream; do
  if git remote | grep -qx "$pref"; then
    if git show-ref --verify --quiet "refs/remotes/$pref/$BR"; then
      chosen="$pref"
      break
    fi
  fi
done

# If none of preferred remotes match, try any remote
if [ -z "$chosen" ]; then
  for r in $(git remote); do
    if git show-ref --verify --quiet "refs/remotes/$r/$BR"; then
      chosen="$r"
      break
    fi
  done
fi

# 3) reset + upstream
if [ -n "$chosen" ]; then
  git reset --hard "$chosen/$BR"
  git branch --set-upstream-to="$chosen/$BR" "$BR" 2>/dev/null || true
  echo "[OK]   $proj -> $chosen/$BR"
else
  echo "[WARN] $proj: branch not found on any remote: */$BR (kept manifest revision)"
fi
'
}

# ---- target groups ----
do_common() {
  sync_start_track_latest "master" vendor/lineage-priv/keys
  sync_start_track_latest "main"   vendor/bcr
}

do_sm8250_common() {
  sync_start_track_latest "sixteen-qpr2" \
    device/xiaomi/sm8250-common \
    hardware/xiaomi \
    kernel/xiaomi/sm8250 \
    vendor/xiaomi/sm8250-common
}

do_thyme() {
  sync_start_track_latest "sixteen-qpr2" \
    device/xiaomi/thyme \
    device/xiaomi/camera-thyme \
    vendor/xiaomi/thyme \
    vendor/xiaomi/camera-thyme
}

do_psyche() {
  sync_start_track_latest "sixteen-qpr2" \
    device/xiaomi/psyche \
    device/xiaomi/camera-psyche \
    vendor/xiaomi/psyche \
    vendor/xiaomi/camera-psyche
}

do_lmi() {
  sync_start_track_latest "sixteen-qpr2" \
    device/xiaomi/lmi \
    vendor/xiaomi/lmi
}

do_enuma() {
  sync_start_track_latest "sixteen-qpr2" \
    device/xiaomi/enuma \
    device/xiaomi/camera-enuma \
    vendor/xiaomi/enuma \
    vendor/xiaomi/camera-enuma
}

run_target() {
  case "$1" in
    common) do_common ;;
    sm8250-common|sm8250|mikona-common) do_sm8250_common ;;
    thyme) do_thyme ;;
    psyche) do_psyche ;;
    lmi) do_lmi ;;
    enuma) do_enuma ;;
    -h|--help|help) usage; exit 0 ;;
    *)
      echo "Unknown target: $1"
      usage
      exit 1
      ;;
  esac
}

main() {
  command -v repo >/dev/null 2>&1 || { echo "repo not found in PATH"; exit 1; }

  if [[ $# -eq 0 ]]; then
    run_target common
    run_target sm8250-common
    run_target thyme
    run_target psyche
    run_target lmi
    run_target enuma
  else
    for t in "$@"; do
      run_target "$t"
    done
  fi

  log "Done."
  echo "Tip: in any project repo, 'git status -sb' should show upstream like:"
  echo "  ## <branch>...<remote>/<branch>"
}

main "$@"
