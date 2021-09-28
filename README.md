This repository contains an image builder for a Raspberry Pi 3B+, to make it into a Spotify radio.

The intended setup is to use WiFi for network access, and connect to a Bluetooth speaker. As screen, this setup assumes Raspberry Pi official 7" toushcreen LCD.

For power LED, connect a LED anode (long leg) to GPIO 3. Connect LED cathode (short leg) via 330 ohm resistor to ground.

For an on/off switch, connect a switch between GPIO 18 and ground.

Get started
===========

1. Create a file under `container/files/env` with this content:

    ```bash
    ALARM_PW=<password for default user, needed for sudo access>
    WLAN_SSID=<name of Wifi to connect to>
    WLAN_PW=<Wifi password>
    ```

2. Insert the USB stick you will be using with your Raspberry Pi.

3. Check which device it got using:

    dmesg | tail

4. Make sure this device does not contain any mounts:

    mounts

   If there are mounts, unmount them:

    sudo umount <device path or mount path>

5. Run prepare script with device name, e.g.:

    ./prepare_disk sdd

6. Move USB stick to your Raspberry Pi and boot it.
