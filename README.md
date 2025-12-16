# my.dotfiles

collection of my dotfiles for arch linux

## install

first run install srcipt:

`chmod +x install.sh`

than:

`./install.sh`

## setup ly

manuali cp config

than disable currnet dm

`systemctl enable ly@tty2.service`

`systemctl disable getty@tty2.service`

## random dolphin setup for niri

`yay -S archlinux-xdg-menu`

`XDG_MENU_PREFIX=arch- kbuildsycoca6`

`ln -fs /etc/xdg/menus/*applications.menu ~/.config/menus/applications.menu`

if kde instaled before hand just run last command!!!
