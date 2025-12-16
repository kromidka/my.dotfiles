# my.dotfiles

collection of my dotfiles for arch linux

## clone repo

mkdir -p ~/git && git clone https://github.com/kromidka/my.dotfiles.git ~/git/my.dotfiles

## install

first run install srcipt:

```sh
chmod +x install.sh
```

than:

```sh
./install.sh
```

## random dolphin setup for niri

dolphin doesn't show open with correctly on niri or wm-s this is the fix:

```sh
yay -S archlinux-xdg-menu
```

```sh
XDG_MENU_PREFIX=arch- kbuildsycoca6
```

```sh
ln -fs /etc/xdg/menus/*applications.menu ~/.config/menus/applications.menu
```

if kde instaled before hand just run last command!!!

## Brave profile

this is brave template for clean brave prfile, just the way I like it.

```sh
cp -rf ~/git/my.dotfiles/default-Brave-profil/'Profile 1'/* ~/.config/BraveSoftware/Brave-Browser/Default/
```
