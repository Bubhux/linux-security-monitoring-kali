#!/bin/bash
if ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
    echo "\${color5}UP\${color1}"
else
    echo "\${color4}DOWN\${color1}"
fi
