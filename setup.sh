#!/usr/bin/bash

## OpenBox Desktop : Setup GUI in Ubuntu Termux

## ANSI Colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"

## Reset terminal colors
reset_color() {
	printf '\033[37m'
}

## Script Termination
exit_on_signal_SIGINT() {
    { printf "${RED}\n\n%s\n\n" "[!] Program Interrupted." 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "${RED}\n\n%s\n\n" "[!] Program Terminated." 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Show usages
usage() {
	echo -e ${ORANGE}"\nInstall GUI (Openbox Desktop) on Ubuntu Termux"
	echo -e ${ORANGE}"Usages : $(basename $0) --install | --uninstall \n"
}

## Update, chromium polybar xfconf, Program Installation
_anu=(chromium polybar xfconf )

setup_chromium() {
	echo -e ${RED}"\n[*] Installing Polybar chromium..."
        echo -e ${CYAN}"\n[*] Removing distribution provided chromium packages and dependencies..."
	{ reset_color; sudo apt remove snapd -yqq -qq && sudo apt autoremove -yqq; }
	{ reset_color; sudo apt remove chromium* -yqq && sudo apt autoremove -yqq; }
	{ reset_color; sudo apt update -qq; sudo apt install software-properties-common gnupg --no-install-recommends -y -qq; }
	echo -e ${CYAN}"\n[*] Adding Debian repo for Chromium installation... \n"
	{ reset_color; sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup; }
        { reset_color; echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic main" >> /etc/apt/sources.list; }
        { reset_color; echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic-updates main" >> /etc/apt/sources.list; }
        { reset_color; echo "deb http://ftp.debian.org/debian buster main" >> /etc/apt/sources.list; }
        { reset_color; echo "deb http://ftp.debian.org/debian buster-updates main" >> /etc/apt/sources.list; }
        { reset_color; echo "deb http://ftp.debian.org/debian buster-backports main" >> /etc/apt/sources.list; }
        { reset_color; apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DCC9EFBF77E11517; }
        { reset_color; apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138; }
        { reset_color; apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA8E81B4331F7F50; }
        { reset_color; apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 112695A0E562B32A; }
	{ reset_color; sudo apt update; }
	echo -e ${CYAN}"\n[*] Installing required programs... \n"
	for packages in "${_anu[@]}"; do
		{ reset_color; sudo apt-get install -y chromium polybar xfconf; }
		_iapt=$(apt list-installed $packages 2>/dev/null | tail -n 1)
		_checkapt=${_iapt%/*}
		if [[ "$_checkapt" == "$packages" ]]; then
			echo -e ${GREEN}"\n[*] Package $packages installed successfully.\n"
			continue
		else
			echo -e ${MAGENTA}"\n[!] Error installing $packages, Terminating...\n"
			{ reset_color; }
		fi
	done
	{ reset_color; sudo mv /etc/apt/sources.list.backup /etc/apt/sources.list; }

}
## Update, X11, Program Installation
_apts=(bc bmon calc calcurse curl dbus desktop-file-utils elinks feh fontconfig-utils fsmon \
		geany git gtk2.0 gtk3.0 imagemagick jq leafpad man mpc mpd mutt ncmpcpp \
		ncurses-utils neofetch netsurf obconf openbox openssl-tool polybar ranger rofi \
                nautilus tigervnc-standalone-server tigervnc-common \
		startup-notification tigervnc vim wget xarchiver xbitmaps xcompmgr \
		xfce4-settings dbus-x11 xmlstarlet xorg )

setup_base() {
	echo -e ${RED}"\n[*] Installing Termux Desktop..."
	echo -e ${CYAN}"\n[*] Updating Termux Base... \n"
        { reset_color; echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic main" >> /etc/apt/sources.list; }
        { reset_color; echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic-updates main" >> /etc/apt/sources.list; }
	{ reset_color; sudo update; sudo apt autoclean; sudo apt upgrade -y; }
	echo -e ${CYAN}"\n[*] Installing required programs... \n"
	for package in "${_apts[@]}"; do
		{ reset_color; sudo apt-get install -y "$package"; }
		{ reset_color; sed -i 's/chromium %U/chromium --no-sandbox %U/g' /usr/share/applications/chromium.desktop; }
		_iapt=$(apt list-installed $package 2>/dev/null | tail -n 1)
		_checkapt=${_iapt%/*}
		if [[ "$_checkapt" == "$package" ]]; then
			echo -e ${GREEN}"\n[*] Package $package installed successfully.\n"
			continue
		else
			echo -e ${MAGENTA}"\n[!] Error installing $package, Terminating...\n"
			{ reset_color; }
		fi
	done
	reset_color
}

## Configuration
setup_config() {
	# backup
	configs=($(ls -A $(pwd)/files))
	echo -e ${RED}"\n[*] Backing up your files and dirs... "
	for file in "${configs[@]}"; do
		echo -e ${CYAN}"\n[*] Backing up $file..."
		if [[ -f "$HOME/$file" || -d "$HOME/$file" ]]; then
			{ reset_color; mv -u ${HOME}/${file}{,.old}; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist."			
		fi
	done
	
	# Copy config files
	echo -e ${RED}"\n[*] Coping config files... "
	for _config in "${configs[@]}"; do
		echo -e ${CYAN}"\n[*] Coping $_config..."
		{ reset_color; cp -rf $(pwd)/files/$_config $HOME; }
	done
	if [[ ! -d "$HOME/Desktop" ]]; then
		mkdir $HOME/Desktop
	fi
}

## install gl4es
setup_gl4es() {
        # Copy config files
        echo -e ${RED}"\n[*] Installing gl4es... "
                { reset_color; sudo mkdir -p /usr/include/gl4es; }
                { reset_color; sudo mkdir -p /usr/lib/gl4es; }
                { reset_color; sudo cp -rf $(pwd)/gl4es/include/* /usr/include/gl4es/ ; }
                { reset_color; sudo cp -rf $(pwd)/gl4es/lib/* /usr/lib/gl4es/; }

}

## Setup VNC Server
setup_vnc() {
	# backup old dir
	if [[ -d "$HOME/.vnc" ]]; then
		mv $HOME/.vnc{,.old}
	fi
	echo -e ${RED}"\n[*] Setting up VNC Server..."
	{ reset_color; vncserver -localhost no; }
	sed -i -e 's/# geometry=.*/geometry=1366x768/g' $HOME/.vnc/config
	cat > $HOME/.vnc/xstartup <<- _EOF_
	#!/usr/bin/bash
	## This file is executed during VNC server
	## startup.

	# Launch Openbox Window Manager.
	[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
export PULSE_SERVER=127.0.0.1
XAUTHORITY=$HOME/.Xauthority
export XAUTHORITY
LANG=en_US.UTF-8
export LANG
dbus-launch --exit-with-session openbox-session &
	_EOF_
	if [[ $(pidof Xvnc) ]]; then
		    echo -e ${ORANGE}"[*] Server Is Running..."
		    { reset_color; vncserver -list; }
	fi
}

## Create Launch Script
setup_launcher() {
	file="$HOME/.local/bin/startdesktop"
	if [[ -f "$file" ]]; then
		rm -rf "$file"
	fi
	echo -e ${RED}"\n[*] Creating Launcher Script... \n"
	{ reset_color; touch $file; chmod +x $file; }
	cat > $file <<- _EOF_
		#!/usr/bin/bash

		# Export Display
		export DISPLAY=:1
                export LD_LIBRARY_PATH=/usr/lib/gl4es/

		# Start VNC Server
		if [[ \$(pidof Xvnc) ]]; then
		    echo -e "\\n[!] Server Already Running."
		    { vncserver -list; echo; }
		    read -p "Kill VNC Server? (Y/N) : "
		    if [[ "\$REPLY" == "Y" || "\$REPLY" == "y" ]]; then
		        { vncserver -kill :*; echo; }
		    else
		        echo
		    fi
		else
		    echo -e "\\n[*] Starting VNC Server..."
		    vncserver -listen -localhost no -name remote-desktop -SecurityTypes none --I-KNOW-THIS-IS-INSECURE
	fi
	_EOF_
	if [[ -f "$file" ]]; then
		echo -e ${GREEN}"[*] Script ${ORANGE}$file ${GREEN}created successfully."
	fi
}
## Finish Installation
post_msg() {
	echo -e ${GREEN}"\n[*] ${RED}Termux Desktop ${GREEN}Installed Successfully.\n"
	cat <<- _MSG_
		[-] Restart termux and enter ${ORANGE}startdesktop ${GREEN}command to start the VNC server.
		[-] In VNC client, enter ${ORANGE}127.0.0.1:5901 ${GREEN}as Address and Password you created to connect.	
		[-] To connect via PC over Wifi or Hotspot, use it's IP, ie: ${ORANGE}192.168.43.1:5901 ${GREEN}to connect. Also, use TigerVNC client.	
		[-] Make sure you enter the correct port. ie: If server is running on ${ORANGE}Display :2 ${GREEN}then port is ${ORANGE}5902 ${GREEN}and so on.
		  
	_MSG_
	{ reset_color; exit 0; }
}

## Install Termux Desktop
install_td() {
	setup_chromium
	setup_base
	setup_config
        setup_gl4es
	setup_vnc
	setup_launcher
	post_msg
}

## Uninstall Termux Desktop
uninstall_td() {
	banner
	# remove apts
	echo -e ${RED}"\n[*] Unistalling Termux Desktop..."
	echo -e ${CYAN}"\n[*] Removing Packages..."
	for package in "${_apts[@]}"; do
		echo -e ${GREEN}"\n[*] Removing Packages ${ORANGE}$package \n"
		{ reset_color;sudo apt-get remove -y --purge --autoremove $package; }
	done
	
	# delete files
	echo -e ${CYAN}"\n[*] Deleting config files...\n"
	_homefiles=(.fehbg .icons .mpd .ncmpcpp .fonts .gtkrc-2.0 .mutt .themes .vnc Music)
	_configfiles=(Thunar geany  gtk-3.0 leafpad netsurf openbox polybar ranger rofi xfce4)
	_localfiles=(bin lib 'share/backgrounds' 'share/pixmaps')
	for i in "${_homefiles[@]}"; do
		if [[ -f "$HOME/$i" || -d "$HOME/$i" ]]; then
			{ reset_color; rm -rf $HOME/$i; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist.\n"
		fi
	done
	for j in "${_configfiles[@]}"; do
		if [[ -f "$HOME/.config/$j" || -d "$HOME/.config/$j" ]]; then
			{ reset_color; rm -rf $HOME/.config/$j; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist.\n"			
		fi
	done
	for k in "${_localfiles[@]}"; do
		if [[ -f "$HOME/.local/$k" || -d "$HOME/.local/$k" ]]; then
			{ reset_color; rm -rf $HOME/.local/$k; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist.\n"			
		fi
	done
	echo -e ${RED}"\n[*] Termux Desktop Unistalled Successfully.\n"
}

## Main
if [[ "$1" == "--install" ]]; then
	install_td
elif [[ "$1" == "--uninstall" ]]; then
	uninstall_td
else
	{ usage; reset_color; exit 0; }
fi
