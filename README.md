# A Bootstrap for IA32 computers.

I've created this to help my students. That's why I won't accept pull requests, all de code is commented in portuguese. 

OS Implementation is not for the faint of heart. Good luck folks.

This is how you can compile/run, first clone the repository, then:

    nasm sisop.asm -o sisop.bin
    mkbt sisop.bin sisop.img
    bochs -f c:\sisop\bochsrc.bxrc -q

This is using the netwide assembler and bochs. This code should be compatible with Vmware.


Includes:

- Bootstrap
- A20 gate handling
- 32 bits Protected Mode 
- GDT setup
