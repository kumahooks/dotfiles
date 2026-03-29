### LTS Kernel + Nvidia 580xx for Older Nvidia GPUs:
```sh
sudo pacman -S linux-lts linux-lts-headers
yay -S nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils nvidia-580xx-settings
sudo dracut --force --hostonly --kver 6.18.20-1-lts
reboot
```

### Diagnostics
```sh
xrandr | grep connected           # current output names and resolutions
xrandr | grep primary             # confirm primary monitor
pacman -Q | grep -i nvidia        # installed nvidia packages
sudo dmesg | grep -i nouveau      # nouveau kernel messages
ls /usr/lib/modules/              # installed kernels
find /efi -type f                 # EFI partition contents
df -h                             # disk space
bootctl status                    # systemd-boot status
```

### Notes
* EFI partition is only 500M and dracut may fail if space is tight. Check df -h /efi before rebuilding initramfs.
* linux-lts is currently 6.18.x — safe with nvidia-580xx. Monitor AUR for 580xx kernel compatibility before updating. 6.19.x broke graphics, so avoid updating for now.
```
