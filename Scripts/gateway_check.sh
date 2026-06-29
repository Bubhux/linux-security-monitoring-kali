#!/bin/bash
if ping -c 1 -W 1 $(ip route | grep default | awk '{print $3}') > /dev/null 2>&1; then
    echo "\${color5}UP\${color1}"
else
    echo "\${color4}DOWN\${color1}"
fi
