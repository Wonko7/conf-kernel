#! /bin/sh

die () {
  exit 4
}

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

# FIXME nostromo!
echo you might want to update firmware:
case $HOST in
  daban-urnud)
    echo 'tart $tree/distfiles/linux-firmware-20170622.tar.gz | sed -nre "/(iwlwifi-7265D|i915)/ { s:^.*linux-firmware[^/]*/::g; s/ ->.*//g; p }" | sudo tee $portage/savedconfig/sys-kernel/linux-firmware && emerge -1 linux-firmware'
    ;;
  yggdrasill)
    echo 'tart $tree/distfiles/linux-firmware-20181026.tar.gz | sed -nre "/(i915|ath10k|qca)/ { s:^.*linux-firmware[^/]*/::g; s/ ->.*//g; p }" | sudo tee $portage/savedconfig/sys-kernel/linux-firmware && emerge -1 linux-firmware'
    ;;
esac
