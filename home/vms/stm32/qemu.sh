#!/bin/sh
set -eu

# qemu-img create -f qcow2 stm32.qcow2 30G

qemu-system-x86_64 -accel kvm -smp cpus=4 -boot order=c,once=d -m 6G \
  -usb -device usb-host,vendorid=0x0483,productid=0x374b \
  -drive file=stm32.qcow2,if=virtio,index=0,media=disk,format=qcow2 \
  -display gtk,show-cursor=on -vga virtio \
  -no-hpet -nic user,ipv4=on \
  -serial none -parallel none -rtc base=utc

#  -cdrom /tmp/deb/debian-12.8.0-amd64-netinst.iso
