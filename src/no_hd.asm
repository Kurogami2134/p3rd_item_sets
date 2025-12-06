.psp

.relativeinclude on

LOAD_ADD        equ 0x08802060
ITEM_BOX        equ 0x09B4C244
ITEM_POUCH      equ 0x09BA8D4A

HOOK            equ 0x09D48EE0
CIRCLE_PRESS    equ 0x09D48EE8
NO_PRESS        equ 0x09D48E40
SELECTED_OPTION equ 0x09E6AB52

GIVE_ITEM       equ 0x09CD0440

PSP_O_RDONLY    equ 0x00000001
PSP_O_WRONLY    equ 0x00000002
PSP_O_CREAT     equ 0x00000200

sceIoWrite      equ 0x08960A00
sceIoClose      equ 0x08960A20
sceIoGetStat    equ 0x08960A28
sceIoOpen       equ 0x08960A40
sceIoRead       equ 0x08960A10


.include "main.asm"
