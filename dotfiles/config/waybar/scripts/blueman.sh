#!/bin/sh
# Right-click on the Bluetooth icon: turn the Blueman tray applet on/off, now and at login.
# Off = an XDG autostart override with Hidden=true (same trick as nm-applet.desktop).
f="$HOME/.config/autostart/blueman.desktop"
if [ -f "$f" ]; then
    rm -f "$f"
    setsid -f blueman-applet >/dev/null 2>&1
    notify-send -a Bluetooth "Blueman ligado" "O applet abre agora e a cada login."
else
    mkdir -p "$(dirname "$f")"
    printf '[Desktop Entry]\nType=Application\nName=Blueman Applet\nHidden=true\n' > "$f"
    pkill -x blueman-applet
    notify-send -a Bluetooth "Blueman desligado" "O applet não abre mais no login. Clique direito de novo para religar."
fi
