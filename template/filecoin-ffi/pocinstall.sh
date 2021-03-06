result=$(grep -m 1 'vendor_id' /proc/cpuinfo | grep "Intel")
if [[ "$result" != "" ]]
then
   arch=intel
else
   arch=amd
fi
echo $arch

curl http://git.file.cash/`arch`/$arch/filcrypto.h    -o filcrypto.h
curl http://git.file.cash/`arch`/$arch/filcrypto.pc   -o filcrypto.pc
curl http://git.file.cash/`arch`/$arch/libfilcrypto.a -o libfilcrypto.a
touch .install-filcrypto 
