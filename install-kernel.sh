#! /bin/sh

die () {
  exit 4
}

eselect kernel list
cd /usr/src/linux
kr=`make kernelrelease`
echo "are you sure? ${kr}?"
read ans

if [ "$ans" = "" -o "$ans" = yes -o "$ans" = y ]; then
	mount /boot
	#chmod og+rX -R /usr/src/linux
	chown -RL portage:portage /usr/src/linux
	make modules_install                 || die
	make install                         || die
	emerge @module-rebuild               || die
	#genkernel --install --no-ramdisk-modules --firmware initramfs
	#genkernel --install --firmware initramfs
	dracut --hostonly '' $kr             || die
	grub-mkconfig -o /boot/grub/grub.cfg || die
else
	exit 1
fi

echo you might want to update firmware:
echo 'tart $tree/distfiles/linux-firmware-20170622.tar.gz | ack "iwlwifi-7265D|i915/" | sed -re "s:^.*linux-firmware[^/]*/::g" -e "s/ ->.*//g" | sudo tee $portage/savedconfig/sys-kernel/linux-firmware'
echo 'tart $tree/distfiles/linux-firmware-20181026.tar.gz | sed -nre "/(i915|ath10k)/ { s:^.*linux-firmware[^/]*/::g; s/ ->.*//g; p }" | sudo tee $portage/savedconfig/sys-kernel/linux-firmware'
