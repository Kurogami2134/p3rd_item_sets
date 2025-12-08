.psp

.relativeinclude on

LOAD_ADD        equ 0x08802060
ITEM_BOX        equ 0x09B4C244
ITEM_POUCH1     equ 0x09BA8D4A
ITEM_POUCH2     equ 0x09B4D9B4

CONTROL_HOLD    equ 0x09BB7A64
HOOK            equ 0x09D48EE0
CIRCLE_PRESS    equ 0x09D48EE8
NO_PRESS        equ 0x09D48E40

GIVE_ITEM       equ 0x09CD0440

PSP_O_RDONLY    equ 0x00000001
PSP_O_WRONLY    equ 0x00000002
PSP_O_CREAT     equ 0x00000200

sceIoWrite      equ 0x08960A00
sceIoClose      equ 0x08960A20
sceIoGetStat    equ 0x08960A28
sceIoOpen       equ 0x08960A40
sceIoRead       equ 0x08960A10

GAME            equ "P3RDML"

.include "main.asm"
