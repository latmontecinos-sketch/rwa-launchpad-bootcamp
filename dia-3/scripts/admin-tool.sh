#!/usr/bin/env bash
# Admin tool — invocations that require the issuer/admin key to sign.
#
# Usage: ./admin-tool.sh [setup|initialize|whitelist|mint|withdraw|pause|unpause]
#   setup (default): initialize + whitelist the investor.
# Defaults point to the week 4 deployment; override any of them with env vars.

set -euo pipefail

NETWORK="${NETWORK:-testnet}"
ADMIN_KEY="${ADMIN_KEY:-rwa-admin}"
CONTRACT_ID="${CONTRACT_ID:-CACCOKUX3J426XD745IGWDM4BI7KEBK65QQZD2ALE4OGNP6X5OMLEKMR}"
# Native XLM Stellar Asset Contract on testnet: 1 unit = 1 stroop (0.0000001 XLM).
PAYMENT_TOKEN="${PAYMENT_TOKEN:-CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC}"
INVESTOR="${INVESTOR:-GBAI5EARC3PGRVMGD4CV5XTVMA3QKM2QZFWEVVGCPWXKGLM5EGY75TCC}"
TREASURY="${TREASURY:-G...TREASURY_PUBLIC_KEY...}"

ADMIN="$(stellar keys address "$ADMIN_KEY")"

invoke() {
  stellar contract invoke \
    --id "$CONTRACT_ID" \
    --source "$ADMIN_KEY" \
    --network "$NETWORK" \
    -- \
    "$@"
}

initialize() {
  echo "=== initialize (run once after deploy) ==="
  invoke initialize \
    --admin "$ADMIN" \
    --asset '{"name":"RWAToken","total_supply":"1000000","price_per_unit":"100","payment_token":"'"$PAYMENT_TOKEN"'","paused":false}'
}

whitelist() {
  echo "=== set_whitelist ==="
  invoke set_whitelist \
    --admin "$ADMIN" \
    --investor "$INVESTOR" \
    --approved true
}

mint() {
  echo "=== mint (admin-only; optional if using invest) ==="
  invoke mint \
    --admin "$ADMIN" \
    --to "$INVESTOR" \
    --amount 100
}

withdraw() {
  echo "=== withdraw collected payment tokens ==="
  invoke withdraw \
    --admin "$ADMIN" \
    --to "$TREASURY" \
    --amount 500
}

pause() {
  echo "=== pause ==="
  invoke pause --admin "$ADMIN"
}

unpause() {
  echo "=== unpause ==="
  invoke unpause --admin "$ADMIN"
}

case "${1:-setup}" in
  setup) initialize; whitelist ;;
  initialize | whitelist | mint | withdraw | pause | unpause) "$1" ;;
  *) echo "Usage: $0 [setup|initialize|whitelist|mint|withdraw|pause|unpause]" >&2; exit 2 ;;
esac
