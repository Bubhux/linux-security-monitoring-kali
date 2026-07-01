#!/bin/bash

# Aller dans le dossier parent (Conky/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Nettoyage
killall conky 2>/dev/null
sleep 1

echo "📁 Dossier Conky : $SCRIPT_DIR"
echo "⚡ Lancement simultané des 4 Conky..."

# Lancement en parallèle
conky -c "$SCRIPT_DIR/conky_clock" &
conky -c "$SCRIPT_DIR/conky_monitor" &
conky -c "$SCRIPT_DIR/conky_system_design" &
conky -c "$SCRIPT_DIR/conky_security" &

echo "✅ 4 Conky lancés en parallèle"
