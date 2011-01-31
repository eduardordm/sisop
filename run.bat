nasm sisop.asm -o sisop.bin
mkbt sisop.bin sisop.img
bochs -f c:\sisop\bochsrc.bxrc -q
PAUSE