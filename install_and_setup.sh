#!/bin/bash
set -e

echo "📦 1. Installiere alle benötigten System-Pakete..."
sudo pacman -S --needed --noconfirm \
    hyprland \
    kitty \
    waybar \
    rofi-wayland \
    thunar \
    polkit-gnome \
    stow \
    grim \
    slurp \
    wl-clipboard \
    xdg-desktop-portal-hyprland \
    ttf-font-awesome

echo "📁 2. Erstelle Dotfiles-Struktur, falls nicht vorhanden..."
mkdir -p ~/dotfiles/hypr/.config/hypr
mkdir -p ~/dotfiles/waybar/.config/waybar
mkdir -p ~/dotfiles/rofi/.config/rofi
mkdir -p ~/dotfiles/kitty/.config/kitty

echo "📝 3. Schreibe Standard-Konfigurationen (nur wenn sie noch leer sind)..."

# --- Hyprland Config ---
if [ ! -s ~/dotfiles/hypr/.config/hypr/hyprland.conf ]; then
cat << 'HYPR' > ~/dotfiles/hypr/.config/hypr/hyprland.conf
# --- AUTOSTART ---
exec-once = waybar
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# --- MONITORE ---
monitor=,preferred,auto,1

# --- INPUT (DEUTSCHES LAYOUT) ---
input {
    kb_layout = de
    follow_mouse = 1
    touchpad {
        natural_scroll = true
    }
}

# --- LOOK & FEEL ---
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

decoration {
    rounding = 8
    blur {
        enabled = true
        size = 3
        passes = 1
    }
}

animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 5, myBezier
    animation = workspaces, 1, 5, default
}

# --- KEYBINDS ---
$mainMod = SUPER

bind = $mainMod, Q, exec, kitty                               # Terminal
bind = $mainMod, E, exec, thunar                              # Dateimanager
bind = $mainMod, R, exec, rofi -show drun                     # App-Launcher
bind = $mainMod, C, killactive,                               # Fenster schließen
bind = $mainMod, M, exit,                                     # Hyprland beenden (Ausloggen)
bind = $mainMod, V, togglefloating,                           # Fenster schweben lassen

# Fokus wechseln
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Workspaces wechseln (1-5)
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# Fenster verschieben (1-5)
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
HYPR
fi

# --- Waybar Config ---
if [ ! -s ~/dotfiles/waybar/.config/waybar/config.jsonc ]; then
cat << 'WAYBAR' > ~/dotfiles/waybar/.config/waybar/config.jsonc
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["pulseaudio", "network", "battery", "clock"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{name}"
    },
    "clock": {
        "format": "🕒 {:%H:%M - %d.%m.%Y}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "🔋 {capacity}%",
        "format-charging": "⚡ {capacity}%"
    },
    "network": {
        "format-wifi": "📶 {essid}",
        "format-ethernet": "🔗 Connected",
        "format-disconnected": "⚠️ Disconnected"
    },
    "pulseaudio": {
        "format": "🔊 {volume}%",
        "format-muted": "🔇 Muted"
    }
}
WAYBAR
fi

# --- Waybar Style ---
if [ ! -s ~/dotfiles/waybar/.config/waybar/style.css ]; then
cat << 'WAYBARCSS' > ~/dotfiles/waybar/.config/waybar/style.css
* {
    font-family: sans-serif;
    font-size: 13px;
}
window#waybar {
    background-color: rgba(30, 30, 46, 0.9);
    border-bottom: 2px solid rgba(137, 180, 250, 0.5);
    color: #cdd6f4;
}
#workspaces button {
    padding: 0 10px;
    color: #cdd6f4;
    background: transparent;
}
#workspaces button.active {
    background-color: #89b4fa;
    color: #11111b;
}
#clock, #battery, #network, #pulseaudio {
    padding: 0 10px;
}
WAYBARCSS
fi

# --- Rofi Config ---
if [ ! -s ~/dotfiles/rofi/.config/rofi/config.rasi ]; then
cat << 'ROFI' > ~/dotfiles/rofi/.config/rofi/config.rasi
configuration {
    modi: "drun,run";
    show-icons: true;
    icon-theme: "Adwaita";
    terminal: "kitty";
    drun-display-format: "{icon} {name}";
    disable-history: false;
    hide-scrollbar: true;
}
@theme "/usr/share/rofi/themes/glue_recvim.rasi"
ROFI
fi

# --- Kitty Config ---
if [ ! -f ~/dotfiles/kitty/.config/kitty/kitty.conf ]; then
    touch ~/dotfiles/kitty/.config/kitty/kitty.conf
fi

echo "🧹 4. Räume kollidierende Verzeichnisse in ~/.config auf..."
rm -rf ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/kitty

echo "🔗 5. Verlinke Configs mit GNU Stow..."
cd ~/dotfiles
stow hypr
stow waybar
stow rofi
stow kitty

echo "✅ SETUP ERFOLGREICH BEENDET!"
