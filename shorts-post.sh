#!/bin/sh
# Generate local social-media post copy for Pixaroma shorts, photos, and stories.
# Uses deterministic templates; optionally uses a local Ollama on 127.0.0.1.
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec python3 -I "$SCRIPT_DIR/shorts_post.py" "$@"
