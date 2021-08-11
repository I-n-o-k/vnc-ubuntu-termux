#!/bin/bash
#Get the necessary components
sudo apt update
sudo apt install udisks2 -y
echo "" > /var/lib/dpkg/info/udisks2.postinst
sudo dpkg --configure -a
sudo apt-mark hold udisks2
sudo apt install keyboard-configuration -y
sudo apt install tzdata -y
sudo apt install sudo wget nano inetutils-tools dialog -y
sudo apt install xfce4 xfce4-goodies xfce4-terminal nautilus tigervnc-standalone-server tigervnc-common exo-utils dbus-x11 pulseaudio pavucontrol libexo-1-0 ffmpeg language-pack-en --no-install-recommends -y
sudo apt --fix-broken install
sudo apt clean

# Make more Minimalis
sudo apt remove thunar xfce4-clipman xfburn texinfo xfce4-taskmanager byobu -y
sudo apt autoremove -y

sudo apt-get install --download-only \
desktop-file-utils libburn4 libexif12 libgarcon-1-0 libgarcon-common \
libgarcon-gtk3-1-0 libgtksourceview-3.0-1 libgtksourceview-3.0-common \
libisofs6 libjte2 libkeybinder-3.0-0 libqrencode4 libtag1v5 libtag1v5-vanilla \
libtagc0 libthunarx-3-0 libwnck-3-0 libwnck-3-common libxfce4ui-utils \
libxklavier16 libxnvctrl0 libxpresent1 libxres1 mousepad ristretto \
xfce4-appfinder xfce4-battery-plugin \
xfce4-cpufreq-plugin xfce4-cpugraph-plugin \
xfce4-datetime-plugin xfce4-dict xfce4-diskperf-plugin xfce4-fsguard-plugin \
xfce4-genmon-plugin xfce4-mailwatch-plugin xfce4-netload-plugin xfce4-panel \
xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-sensors-plugin \
xfce4-session xfce4-settings xfce4-smartbookmark-plugin \
xfce4-systemload-plugin xfce4-timer-plugin \
xfce4-verve-plugin xfce4-wavelan-plugin xfce4-weather-plugin \
xfce4-whiskermenu-plugin xfce4-xkb-plugin xfdesktop4 xfdesktop4-data xfwm4 --no-install-recommends

cd /var/cache/apt/archives
sudo dpkg -i *.deb
sudo apt --fix-broken install
sudo apt clean

# install theme macos
cd ~
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme t
git clone https://github.com/vinceliuice/WhiteSur-icon-theme i

cd ~/t
./install.sh -d /usr/share/themes -o normal -i ubuntu -N glassy --round --roundedmaxwindow
cd ~/i
./install.sh -d /usr/share/icons 

cd ~
mkdir -p ~/.vnc

echo '#!/bin/bash
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
export PULSE_SERVER=127.0.0.1
XAUTHORITY=$HOME/.Xauthority
export XAUTHORITY
LANG=en_US.UTF-8
export LANG
echo $$ > /tmp/xsession.pid
dbus-launch --exit-with-session startxfce4 &' > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

echo " "

echo "Running browser patch"
wget https://raw.githubusercontent.com/I-n-o-k/vnc-ubuntu-termux/master/ubchromiumfix.sh && chmod +x ubchromiumfix.sh
sudo ./ubchromiumfix.sh && rm -rf ubchromiumfix.sh

echo "You can now start vncserver by running vncserver-start"
echo " "
echo "It will ask you to enter a password when first time starting it."
echo " "
echo "The VNC Server will be started at 127.0.0.1:5901"
echo " "
echo "You can connect to this address with a VNC Viewer you prefer"
echo " "
echo "Connect to this address will open a window with Xfce4 Desktop Environment"
echo " "
echo " "
echo " "
echo "Running vncserver-start"
echo " "
echo " "
echo " "
echo "To Kill VNC Server just run vncserver-stop"
echo " "
echo " "
echo " "

echo "export DISPLAY=":1"" >> /etc/profile
source /etc/profile

vncpasswd
wget -q https://raw.githubusercontent.com/I-n-o-k/vnc-ubuntu-termux/master/.profile -O $HOME/.profile.1 > /dev/null
cat $HOME/.profile.1 >> $HOME/.profile && rm -rf $HOME/.profile.1
source ~/.profile
