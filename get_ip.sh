#!/bin/bash
# get_ip.sh - Récupère l'adresse IP publique

# Méthode 1 : avec dyndns (votre méthode originale)
IP=$(wget http://checkip.dyndns.org/ -O - -o /dev/null | cut -d: -f 2 | cut -d\< -f 1 | xargs)

# Si la première méthode échoue, essayer d'autres services
if [ -z "$IP" ]; then
    IP=$(curl -s ifconfig.me 2>/dev/null)
fi

if [ -z "$IP" ]; then
    IP=$(curl -s ipinfo.io/ip 2>/dev/null)
fi

if [ -z "$IP" ]; then
    IP="Non disponible"
fi

echo "$IP"
