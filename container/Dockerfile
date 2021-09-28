# Copyright (c) 2021 Mats G. Liljegren
# SPDX-License-Identifier: MIT
# This file is under MIT license, see LICENSE file or https://spdx.org/licenses/MIT.html.

from scratch as build

# Arguments expected to be given on build command line
ARG IMAGE="ArchLinuxARM-rpi-2-latest.tar.gz"

# Import files from repository to image
ADD files/${IMAGE} /

# This file is expected to be created by user, and should have the following content:
# ALARM_PW=<pw for user alarm>
# WLAN_SSID=<SSID for WLAN to connect to>
# WLAN_PW=<Password for WLAN to connect to>

COPY files/env /
COPY files/config.txt /boot/

# Install pacman database and tools for generating initramfs
RUN pacman-key --init
RUN pacman-key --populate archlinuxarm
RUN pacman --sync --refresh --refresh --quiet --noconfirm uboot-tools btrfs-progs sudo

# Setup USB and btrfs boot media
RUN sed -i 's/mmcblk0p1/sda1/' /etc/fstab
RUN echo 'root=/dev/sda2 rw rootwait console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 logo.nologo' > /boot/cmdline.txt
RUN sed -i 's/MODULES=()/MODULES=(btrfs btusb)/' /etc/mkinitcpio.conf
RUN mkinitcpio -P

# Setup Wifi at boot
COPY files/wlan0.network /etc/systemd/network/
COPY files/wpa_supplicant-wlan0.conf /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
RUN . /env && wpa_passphrase "${WLAN_SSID}" "${WLAN_PW}" >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
RUN printf '        %s\n' "scan_ssid=1" "key_mgmt=WPA-PSK" > wpa_fragment.conf
RUN sed -i '/^[ \t]*ssid=.*/r wpa_fragment.conf' /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
RUN rm wpa_fragment.conf
RUN chmod 400 /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
RUN ln -s /usr/lib/systemd/system/wpa_supplicant@.service /etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service

# Install button support
COPY files/rpi-button /sbin/
COPY files/rpi-button.service /etc/systemd/system/
COPY files/rpi-display-backlight.service /etc/systemd/system/
RUN systemctl enable rpi-button.service rpi-display-backlight.service
RUN pacman --sync --refresh --quiet --noconfirm python-pip
RUN pip install gpiozero

# Autologin to console, first part is done by copying autologin.conf above
COPY files/autologin.conf /etc/systemd/system/getty@tty2.service.d/
COPY files/autologintty /etc/
COPY files/login.pam /
RUN systemctl set-default multi-user.target
RUN ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty2.service
RUN sed -i '/^#%PAM.*/r /login.pam' /etc/pam.d/login
RUN rm /login.pam

# Setup sane user environment
# This involves removing possibility to login as root, change password for alarm user and make alarm part of sudo
RUN echo 'alarm ALL=(ALL) ALL' > /etc/sudoers.d/alarm
RUN . /env && printf '%s:%s\n' 'alarm' "${ALARM_PW}" | chpasswd
RUN passwd --lock root

# Remove /env file, so we don't expose passwords
RUN rm /env

# Install Wayland and Firefox
RUN pacman --sync --refresh --quiet --noconfirm wayland sway firefox
RUN echo 'MOZ_ENABLE_WAYLAND=1' >> /etc/environment
RUN echo 'XDG_CURRENT_DESKTOP=cage' >> /etc/environment
RUN echo 'XDG_SESSION_TYPE=wayland' >> /etc/environment
RUN echo 'WAYLAND_DISPLAY="wayland-1"' >> /etc/environment

# Install audio over bluetooth support
RUN pacman --sync --refresh --quiet --noconfirm pipewire pipewire-pulse xdg-desktop-portal-wlr bluez bluez-utils blueman
RUN rfkill unblock bluetooth
RUN systemctl enable bluetooth.service

# Backlight control GUI
COPY files/backlight-permissions.rules /etc/udev/rules.d/
RUN pip install rpi_backlight

# Clean pacman caches to minimize disk usage
RUN pacman --sync --quiet --noconfirm --clean --clean

# Configure sway
COPY files/config.sway /etc/sway/config
COPY files/sway-focus /sbin
