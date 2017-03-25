#!/bin/bash 

# $Xorg: xinitrc.cpp,v 1.3 2000/08/17 19:54:30 cpqbld Exp $
#
# This .xinitrc is for starting the Orca screen reader without Gnome.

eval `dbus-launch --sh-syntax --exit-with-session`
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/usr/lib/X11/xinit/.Xresources
sysmodmap=/usr/lib/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    /usr/bin/xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    /usr/bin/xmodmap $sysmodmap
fi

if [ -f $userresources ]; then
    /usr/bin/xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
    /usr/bin/xmodmap $usermodmap
fi

# Graphical environment A11y Initialization

# Variables
export LOGNAME="GDM"
export SAL_USE_VCLPLUGIN="gtk"
export GTK_MODULES="gail:atk-bridge" # for GTK2
export GNOME_ACCESSIBILITY=1
export QT_ACCESSIBILITY=1 # for QT4
export QT_LINUX_ACCESSIBILITY_ALWAYS_ON=1 # for QT5
sleep="sleep 0.4"


# Functions

function execute() {
    cmds=$1
    for ((i=0; $i<${#cmds[@]}; i++)) do
        exec ${cmds[$i]}&
        $sleep
    done
}

# Begin

$sleep

# Execute things in this order
cmds[0]="/usr/libexec/at-spi2-registryd --use-gnome-session"
cmds[1]="/usr/bin/orca"
cmds[2]="/usr/bin/lxterminal"

execute $cmds

$sleep
# Lastly, start your preferred window manager or desktop.
# Uncomment the line below or add your own
exec /usr/bin/startfluxbox
