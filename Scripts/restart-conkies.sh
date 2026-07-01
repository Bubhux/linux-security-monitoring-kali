#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/stop-conkies.sh"
sleep 2
"$SCRIPT_DIR/start-conkies.sh"
