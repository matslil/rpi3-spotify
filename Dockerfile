from scratch as build

# Arguments expected to be given on build command line
ARG IMAGE="ArchLinuxARM-rpi-2-latest.tar.gz"

# Import files from repository to image
ADD ${IMAGE} /

# This file is expected to be created by user, and should have the following content:
# ALARM_PW=<pw for user alarm>
# WLAN_SSID=<SSID for WLAN to connect to>
# WLAN_PW=<Password for WLAN to connect to>

COPY env /
COPY config.txt /boot/
COPY wpa_supplicant.conf /boot/

# Make somethings that can boot
RUN . /env && sed -i -e 's/wifi_ssid/'"${WLAN_SSID}"'/' -e 's/wifi_password/'"${WLAN_PW}"'/' /boot/wpa_supplicant.conf
RUN sed -i 's/mmcblk0p1/sda1/' /etc/fstab
RUN echo 'root=/dev/sda2 rw rootwait console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 logo.nologo' > /boot/cmdline.txt
RUN sed -i 's/MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
RUN pacman-key --init
RUN pacman-key --populate archlinuxarm
RUN pacman --sync --refresh --refresh --quiet --noconfirm uboot-tools btrfs-progs sudo
RUN mkinitcpio -P

# Setup sane user environment
# This involves removing possibility to login as root, change password for alarm user and make alarm part of sudo
RUN echo 'alarm ALL=(ALL) ALL' > /etc/sudoers.d/alarm
RUN . /env && printf '%s:%s\n' 'alarm' "${ALARM_PW}" | chpasswd
RUN passwd --lock root

# Install Wayland and Firefox
RUN pacman --sync --quiet --noconfirm wayland firefox
RUN echo 'MOZ_ENABLE_WAYLAND=1' >> /etc/environment

# Install audio over bluetooth support
RUN pacman --sync --quiet --noconfirm pipewire pipewire-alsa pipewire-pulse

