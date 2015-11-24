#!/bin/sh

PROGRAMS=('bash' 'cat' 'chroot' 'echo' 'insmod' 'mount' 'sleep')
#MODULES=('efivarfs.ko' 'mcb.ko' 'mcb-pci.ko')

# 
# $1 program
copy_libs_for_prog()
{
	local prog libs
	prog=$1

	libs=$(ldd ${prog} | cut -d '>' -f 2 | cut -d ' ' -f 2 | grep ^/)
	for l in ${libs}; do
		cp $l lib64
	done
}

while getopts "k:m:" flag; do
	case ${flag} in
		k)
			KDIR=${OPTARG}
			;;
		m)
			MODULES=${OPTARG}
			;;
		*)
			echo "invalid option"
			;;
	esac
done

mkdir -p initrd/{bin,dev,etc,lib/modules,lib64,proc,sys,sysroot}
pushd initrd
ln -s bin sbin
pushd bin
ln -s bash sh
popd

echo "#!/bin/sh" >> bin/init

for mod in ${MODULES[@]}; do
	echo "echo \"Loading ${mod}\"" >> bin/init
	echo "insmod /lib/modules/${mod}" >> bin/init
done

cat >> bin/init << __EOF__

echo "Mounting /proc, /dev and /sys"
mount -t proc /proc /proc
mount -t sysfs /sys /sys
mount -t devtmpfs /dev /dev

# Mount rootfs to /sysroot
mount -o ro /dev/vda1 /sysroot

echo "Switching to new root"
cd /sysroot
exec chroot . sh -c 'exec /sbin/init'

__EOF__

chmod 755 bin/init

for prog in ${PROGRAMS[@]}; do
	absprog=$(which ${prog})
	cp ${absprog} bin/
	copy_libs_for_prog ${absprog}
done

if [ x"$KDIR" != "x" ]; then
	for mod in ${MODULES[@]}; do
		find $KDIR -name ${mod} | xargs cp -t lib/modules/
	done
fi

find ./ | cpio -H newc -o > ../initrd.cpio
popd

gzip -9 -c initrd.cpio > initrd.img

