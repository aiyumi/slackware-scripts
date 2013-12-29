#!/bin/sh 

# $Xorg: xinitrc.cpp,v 1.3 2000/08/17 19:54:30 cpqbld Exp $
#
# This .xinitrc is for starting the Orca screen reader without Gnome.
# It only works with AT-SPI 2. If you need AT-SPI 1, use
# the # "orca.atspi12.xinitrc" file.

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
export GTK_MODULES="gail:atk-bridge"
export GNOME_ACCESSIBILITY=1
export sleep="sleep 0.4"


# Functions

dbusSend() {
    exec dbus-send --session --dest="org.gnome.SessionManager" /org/gnome/SessionManager org.gnome.SessionManager.Setenv string:"GTK_PATH" string:"/usr/lib/gtk-2.0/modules/at-spi-dbus/modules/.."&
}


setGTKModules() {
    if [ $1 -eq 0 ]; then
        gconftool-2 -s --type string /apps/gnome_settings_daemon/gtk-modules/gail:atk-bridge /desktop/gnome/interface/accessibility
    fi
}


execute() {
    cmds=$1
    for ((i=0; $i<${#cmds[@]}; i++)) do
        exec ${cmds[$i]}&
        $sleep
        setGTKModules $i
    done
}

# Begin
dbusSend

$sleep


# GConf
gconftool-2 -s --type bool /desktop/gnome/interface/accessibility true
gconftool-2 -s --type bool /desktop/gnome/interface/at-spi-corba false 
gconftool-2 -s --type bool /desktop/gnome/interface/at-spi-dbus true 
gconftool-2 -s --type list --list-type string /desktop/gnome/session/required_components_list [windowmanager]



# Execute things in this order
cmds[0]="/usr/libexec/at-spi2-registryd --use-gnome-session"
cmds[1]="/usr/bin/orca -n"
cmds[2]="/usr/bin/xfterm4"

execute $cmds


$sleep
# Lastly, start your preferred window manager or desktop.
# Uncomment the line below or add your own
#exec /usr/bin/startfluxbox

