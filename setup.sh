#!/bin/bash

if [ -z "$1" ]; then
    echo "Please specify the brightness adjustment step (from 1 to 99)."
    exit 1
fi

INCREMENT=$1

if ! [[ "$INCREMENT" =~ ^[0-9]+$ ]] || [ "$INCREMENT" -lt 1 ] || [ "$INCREMENT" -gt 99 ]; then
    echo "The step must be a number from 1 to 99."
    exit 1
fi

INCREASE_SCRIPT="/usr/local/bin/increase_brightness.sh"
DECREASE_SCRIPT="/usr/local/bin/decrease_brightness.sh"

# Create the increase brightness script
sudo bash -c "cat > $INCREASE_SCRIPT" << EOF
#!/bin/bash
CURRENT_BRIGHTNESS=\$(ddcutil getvcp 10 | grep -oP '(?<=current value =\\s+)\\d+')
NEW_BRIGHTNESS=\$((CURRENT_BRIGHTNESS + $INCREMENT))
if [ \$NEW_BRIGHTNESS -le 100 ]; then
    ddcutil setvcp 10 \$NEW_BRIGHTNESS
else
    ddcutil setvcp 10 100
fi
EOF

# Create the decrease brightness script
sudo bash -c "cat > $DECREASE_SCRIPT" << EOF
#!/bin/bash
CURRENT_BRIGHTNESS=\$(ddcutil getvcp 10 | grep -oP '(?<=current value =\\s+)\\d+')
NEW_BRIGHTNESS=\$((CURRENT_BRIGHTNESS - $INCREMENT))
if [ \$NEW_BRIGHTNESS -ge 0 ]; then
    ddcutil setvcp 10 \$NEW_BRIGHTNESS
else
    ddcutil setvcp 10 0
fi
EOF

# Make the scripts executable
sudo chmod +x "$INCREASE_SCRIPT"
sudo chmod +x "$DECREASE_SCRIPT"

echo "Scripts created successfully!"
echo "Paths to the scripts:"
echo "$INCREASE_SCRIPT"
echo "$DECREASE_SCRIPT"
