#! /bin/sh

die () {
  exit 4
}

HOST=$(hostname)
eselect kernel list
curr_kr=$(make kernelrelease)
curr_kv=linux-$(make kernelversion)
latest_kv=$(eselect kernel list | sed -rne '$ s/^.*(linux-[^ ]+).*$/\1/p')
pwd

if [ $latest_kv != $curr_kv ]; then
  echo "$latest_kv != $curr_kv, fucking right off"
  exit 1
fi

eselect kernel set $latest_kv || die
eselect kernel list

echo "are you sure? ${curr_kr}?"
read ans


if [[ ! ( "$ans" = "" || "$ans" = yes || "$ans" = y ) ]]; then
  exit 1
fi

eselect kernel set $latest_kv

cp .config /home/wjc/conf/kernel-config/$HOST/config-$curr_kr
chown wjc:wjc /home/wjc/conf/kernel-config/$HOST/config-$curr_kr

mount /boot
#chmod og+rX -R /usr/src/linux
chown -RL portage:portage /usr/src/linux
make modules_install                 || die
make install                         || die
emerge @module-rebuild               || die
#genkernel --install --no-ramdisk-modules --firmware initramfs
#genkernel --install --firmware initramfs
dracut --hostonly '' $curr_kr        || die
grub-mkconfig -o /boot/grub/grub.cfg || die

echo you might want to update firmware:
echo 'nostromo: tart $tree/distfiles/linux-firmware-20170622.tar.gz | ack "iwlwifi-7265D|i915/" | sed -re "s:^.*linux-firmware[^/]*/::g" -e "s/ ->.*//g" | sudo tee $portage/savedconfig/sys-kernel/linux-firmware'
echo 'yggdrasill: tart $tree/distfiles/linux-firmware-20181026.tar.gz | sed -nre "/(i915|ath10k|qca)/ { s:^.*linux-firmware[^/]*/::g; s/ ->.*//g; p }" | sudo tee $portage/savedconfig/sys-kernel/linux-firmware'
