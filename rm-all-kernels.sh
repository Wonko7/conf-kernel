#!/bin/sh

cd /mnt/gentoo/_auto/
for i in gentoo-root*; do
  echo $i
  # using this to only print kernels that have successfully correctly emerged @modules-rebuild:
  chroot $i /usr/bin/find /lib/modules -name wireguard.ko | sed -re 's:/lib/modules/::' -e 's:/kernel/drivers/net/wireguard.ko::'
  echo
done
