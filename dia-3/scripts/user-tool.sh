#!/usr/bin/env bash
# User tool — invocations signed by the investor / token holder.
#
# Usage: ./user-tool.sh [demo|invest AMOUNT|balance|transfer]
#   demo (default): invest 100 (must fail with AmountTooLow), invest 500, balance.
# Defaults point to the week 4 deployment; override any of them with env vars.

set -euo pipefail

NETWORK="${NETWORK:-testnet}"
USER_KEY="${USER_KEY:-rwa-inversor}"
CONTRACT_ID="${CONTRACT_ID:-CACCOKUX3J426XD745IGWDM4BI7KEBK65QQZD2ALE4OGNP6X5OMLEKMR}"
RECIPIENT="${RECIPIENT:-G...RECIPIENT_PUBLIC_KEY...}"

USER_ADDRESS="$(stellar keys address "$USER_KEY")"

invoke() {
  stellar contract invoke \
    --id "$CONTRACT_ID" \
    --source "$USER_KEY" \
    --network "$NETWORK" \
    -- \
    "$@"
}

invest() {
  echo "=== invest $1 ==="
  invoke invest \
    --investor "$USER_ADDRESS" \
    --payment_amount "$1"
}

balance() {
  echo "=== balance ==="
  invoke balance --id "$USER_ADDRESS"
}

transfer() {
  echo "=== transfer RWA tokens ==="
  invoke transfer \
    --from "$USER_ADDRESS" \
    --to "$RECIPIENT" \
    --amount 10
}

demo() {
  # AmountTooLow is contract error #7: the minimum investment is 500.
  if invest 100; then
    echo "!!! invest 100 should have failed with AmountTooLow (#7)" >&2
    exit 1
  fi
  echo "--> invest 100 rejected as expected: AmountTooLow (#7), minimum is 500"
  echo
  invest 500
  echo
  balance
}

case "${1:-demo}" in
  demo) demo ;;
  invest) invest "${2:?Usage: $0 invest AMOUNT}" ;;
  balance) balance ;;
  transfer) transfer ;;
  *) echo "Usage: $0 [demo|invest AMOUNT|balance|transfer]" >&2; exit 2 ;;
esac
