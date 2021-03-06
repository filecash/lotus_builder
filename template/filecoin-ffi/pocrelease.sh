result=$(grep -m 1 'vendor_id' /proc/cpuinfo | grep "Intel")
if [[ "$result" != "" ]]
then
   arch=intel
else
   arch=amd
fi
echo $arch

scp -P 1022 -i ~/.ssh/fic1 filcrypto.h    root@118.123.241.59:/mnt/ssd/git/`arch`/$arch/
scp -P 1022 -i ~/.ssh/fic1 filcrypto.pc   root@118.123.241.59:/mnt/ssd/git/`arch`/$arch/
scp -P 1022 -i ~/.ssh/fic1 libfilcrypto.a root@118.123.241.59:/mnt/ssd/git/`arch`/$arch/
