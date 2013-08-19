#!/bin/sh 

# $Xorg: xinitrc.cpp,v 1.3 2000/08/17 19:54:30 cpqbld Exp $
#
# This .xinitrc is for starting the Orca screen reader without Gnome. It works
# with AT-SPI1 and AT-SPI2. If you don't need AT-SPI1 (it's becoming
# deprecated), use the "orca.atspi2.xinitrc" file, which only supports AT-SPI2.

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

# Brazilian keyboard
#setxkbmap br


# Graphical environment A11y Initialization

# Variables
export LOGNAME="GDM"
export SAL_USE_VCLPLUGIN="gtk"
export GTK_MODULES="gail:atk-bridge"
export GNOME_ACCESSIBILITY=1
export ATSPI=2
export sleep="sleep 0.4"


# Functions

dbusSend() {
if [ $ATSPI -eq 2 ]; then
	exec dbus-send --session --dest="org.gnome.SessionManager" /org/gnome/SessionManager org.gnome.SessionManager.Setenv string:"GTK_PATH" string:"/usr/lib/gtk-2.0/modules/at-spi-dbus/modules/.."&
fi
}


setGTKModules() {
	if [ $1 -eq 0 ]; then
	gconftool-2 -s --type string /apps/gnome_settings_daemon/gtk-modules/gail:atk-bridge /desktop/gnome/interface/accessibility
fi
}


execute() {
cmds=$1
	for ((i=0; $i<${#cmds[@]}; i++)) do
ARGS=""
		if [ $i -eq 0 -a $ATSPI -eq 2 ]; then
ARGS=$ATSPIARGS
		fi
exec ${cmds[$i]} $ARGS &
$sleep
setGTKModules $i
	done
}

# Begin
dbusSend

$sleep


# AT-SPI
if [ $ATSPI -eq 2 ]; then
ATSPICORBA=false
ATSPIDBUS=true
REGISTRYD="at-spi2-registryd"
ATSPIARGS=" --use-gnome-session"
else
	ATSPICORBA=true
ATSPIDBUS=false
REGISTRYD="at-spi-registryd"
ATSPIARGS=""
fi

# GConf
gconftool-2 -s --type bool /desktop/gnome/interface/accessibility true
gconftool-2 -s --type bool /desktop/gnome/interface/at-spi-corba $ATSPICORBA
gconftool-2 -s --type bool /desktop/gnome/interface/at-spi-dbus $ATSPIDBUS 
gconftool-2 -s --type list --list-type string /desktop/gnome/session/required_components_list [windowmanager]



# Execute things in this order
cmds[0]="/usr/libexec/$REGISTRYD"
cmds[1]="/usr/bin/orca -n"

execute $cmds


$sleep
# Lastly, start your preferred window manager or desktop.
# Uncomment the line below or add your own
#exec /usr/bin/startfluxbox

