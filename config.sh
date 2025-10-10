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

#enable late microcode updates
echo 1 > /sys/devices/system/cpu/microcode/reload

#install system services
pacman -S NetworkManager sddm lm_sensors acpid power-profiles-daemon bluetooth preload

#Enable system services
systemctl enable NetworkManager
systemctl enable sddm
systemctl enable lm_sensors
systemctl enable acpid
systemctl enable power-profiles-daemon 
systemctl enable bluetooth
systemctl enable preload

#install extra packages
pacman -S konsole xterm fish vivaldi iwd plasma plasma-meta discord aura timeshift starship vscodium btop dolphin strawberry libreoffice-fresh ttf-daddytime-mono-nerd

#Configure journal
echo "Storage=persistent" >> /etc/systemd/journald.conf

#Enable SysRq key
echo "kernel.sysrq = 1" >> /etc/sysctl.d/99-sysctl.conf

#Configure zram
pacman -S zram-generator --noconfirm
cp /archinstall/zram-generator.conf /etc/systemd/zram-generator.conf

#configure snapper
cp /archinstall/root /etc/snapper/configs/root

#Configure initramfs for intel
sed -i '7,52 s/^/#/' /etc/mkinitcpio.conf
echo "
COMPRESSION="lzop"
MODULES=(crc32c intel_agp i915 vmd)
BINARIES=(btrfs)
FILES=()
HOOKS=(base udev autodetect modconf block keyboard keymap consolefont resume filesystems grub-btrfs-overlayfs) " >> /etc/mkinitcpio.conf

#Generate the initramfs
mkinitcpio -p linux
mkinitcpio -p linux-zen
