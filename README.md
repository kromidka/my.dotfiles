# my.dotfiles

collection of my dotfiles for arch linux

## clone repo

mkdir -p ~/git && git clone https://github.com/kromidka/my.dotfiles.git ~/git/my.dotfiles

## install

first run install srcipt:

`chmod +x install.sh`

than:

`./install.sh`

## random dolphin setup for niri

dolphin doesn't show open with correctly on niri or wm-s this is the fix:

`yay -S archlinux-xdg-menu`

`XDG_MENU_PREFIX=arch- kbuildsycoca6`

`ln -fs /etc/xdg/menus/*applications.menu ~/.config/menus/applications.menu`

if kde instaled before hand just run last command!!!

## Brave profile

this is brave template for clean brave prfile, just the way I like it.

`cp -rf "~/git/my.dotfiles/default-Brave-profil/Profile 1/*" ~/.config/BraveSoftware/Brave-Browser/Default/`
