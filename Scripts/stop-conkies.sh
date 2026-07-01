#!/bin/bash

echo "Arrêt des Conky..."

# Tuer toutes les instances
killall conky 2>/dev/null

# Attendre la fin
sleep 1

# Vérification
if pgrep conky > /dev/null; then
    killall -9 conky 2>/dev/null
    echo "Conky forcés"
else
    echo "Tous les Conky sont arrêtés"
fi
