#!/bin/sh
# Docker env files can't hold newlines, so the GitHub App key arrives with literal "\n"; restore real newlines.
if [ -n "$GITHUB_APP_PRIVATE_KEY" ]; then
  GITHUB_APP_PRIVATE_KEY=$(printf '%b' "$GITHUB_APP_PRIVATE_KEY")
  export GITHUB_APP_PRIVATE_KEY
fi
exec "$@"
