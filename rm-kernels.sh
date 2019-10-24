#! /bin/sh

TMP_DIAG=$(mktemp -p /tmp KERNEL-RM-XXXXXX)
if [ -z $LINES ]; then
  echo no lines?
  LINES=20
fi

die () {
  rm -f ${TMP_DIAG}
  exit 2
}

cd /usr/src

ks=$(ls -d1 linux-* | sed -nre 's/^linux-(.*)-gentoo.*$/\1/p')
nbks=$(echo $ks | wc -w)

diag_list=""
for k in $ks; do
  diag_list+="$k '' $k "
done

echo $diag_list
echo $nbks

dialog --title "remove kernels:" --checklist "" $LINES 50 $nbks $diag_list 2> ${TMP_DIAG} || die
#dialog --title "remove kernels:" --checklist "" $LINES 50 $LINES t1 i1 s1 t2 i2 s2 t3 i3 s3 t4 i4 s4 2> ${TMP_DIAG} || die

ks=$(cat ${TMP_DIAG})
rm -f ${TMP_DIAG}

clear
echo This will remove:
to_rm=""
for k in $ks; do
  to_rm_l=""
  to_rm_l+=$(find /boot -maxdepth 1 -iname "[^c]*${k}-*" 2> /dev/null)
  to_rm_l+=" "
  to_rm_l+=$(find /lib/modules -maxdepth 1 -iname "$k-*")
  to_rm_l+=" "
  to_rm_l+=$(find /usr/src -maxdepth 1 -iname "linux-$k-*")
  echo $to_rm_l | tr ' ' '\n' | sort
  echo
  to_rm+="${to_rm_l} "
done

echo yesyes?
read ans
[ "$ans" = "" -o "$ans" = yes -o "$ans" = y ] && echo rm -rf $to_rm
