#!/usr/bin/bash

#FUNCTIONS GO HERE

confirm() {         
    while true; do
        read -p "${1}" yn
        case $yn in
            [Yy]* ) $2; break;;
            [Nn]* ) echo "aborted"; exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}
example-function() {
    echo "Excellent. You haven't broken it. Yet."
}

#set time
timedatectl set-ntp true
timedatectl set-timezone America/New_York
hwclock --systohc
timedatectl set-ntp true
timedatectl status
locale-gen
confirm "Did the time set correctly?"

#install system services
pacman -S --needed networkmanager --noconfirm
systemctl enable NetworkManager
confirm "Did networkmanager install?"

pacman -S --needed sddm --noconfirm
systemctl enable sddm
confirm "Did sddm install?"

pacman -S --needed lm_sensors --noconfirm
systemctl enable lm_sensors
confirm "Did lmsensors install?"lm_sensors acpid power-profiles-daemon  preload upower

pacman -S --needed acpid --noconfirm
systemctl enable acpid
confirm "Did acpid install?"

pacman -S --needed power-profiles-daemon --noconfirm
systemctl enable power-profiles-daemon
confirm "Did power-profiles-daemon install?"

pacman -S --needed bluez bluez-utils pulseaudio-bluetooth blueman --noconfirm
systemctl enable bluetooth
confirm "Did bluetooth install?"

pacman -S --needed preload --noconfirm
systemctl enable preload
confirm "Did preload install?"

pacman -S --needed upower --noconfirm
systemctl enable upower
confirm "Did upower install?"

#install aura
pacman -S aura --noconfirm
aura - A beautyline
confirm "Did aura install?"

for pkg in zellij yazi rsync vim brave-bin konsole fish vivaldi iwd plasma plasma-meta discord aura starship vscodium btop dolphin strawberry libreoffice-fresh ttf-daddytime-mono-nerd kde-style-oxygen-qt6; do
  pacman -S --needed --noconfirm "$pkg"
done

#Install AUR packages
for pkg in oxygen-cursors-extra chromium-extension-plasma-integration hunspell-en-med-glut-git debtap masterpdfeditor-free appimagelauncher hunspell-en-med-glut-git libreoffice-extension-cleandoc ocs-url onevpl-intel-gpu pacdiff-pacman-hook-git wd719x-firmware aic94xx-firmware; do
  aura -A --noconfirm "$pkg"
done

confirm "Did everything install?"

#Configure journal
echo "Storage=persistent" >> /etc/systemd/journald.conf

#Enable SysRq key
echo "kernel.sysrq = 1" >> /etc/sysctl.d/99-sysctl.conf

#enable late microcode updates
pacman -S --needed intel-ucode --noconfirm

#configure rclone
mkdir /home/ellie/proton
pacman -S --needed rclone rsync --noconfirm
rclone config
rsync -av /archinstall_sda/rclone.service /etc/systemd/system/rclone.service
systemctl enable rclone
confirm "Did rclone configure successfully?"

#Configure zram
pacman -S zram-generator --noconfirm
rsync -av /archinstall_sda/zram-generator.conf /etc/systemd/zram-generator.conf

#Configure sddm
aura -A archlinux-themes-sddm --noconfirm
echo "[Theme]
Current=archlinux-simplyblack">> /etc/sddm.conf
vim /etc/sddm.conf
confirm "All good?"

#sync files
chmod +x files.sh
./files.sh
confirm "Did home files sync?"

#set theme elements
pacman -S --needed beautyline oxygen --noconfirm
rsync -av /archinstall_sda/files/HotPinkAnemone.colors /home/ellie/.local/share/color-schemes/
mkdir /home/ellie/Pictures
rsync -av /archinstall_sda/files/arch_pink_background.png /home/ellie/Pictures

#Generate the initramfs
mkinitcpio -p linux
mkinitcpio -p linux-lts
mkinitcpio -p linux-archinstall_sda
confirm "Did the initramfs generate successfully?"
