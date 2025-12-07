.psp

.relativeinclude on

LOAD_ADD        equ 0x08802060;
ITEM_BOX        equ 0x09F52CF4
ITEM_POUCH      equ 0x09FAF7FE

CONTROL_HOLD    equ 0x09FBE764
HOOK            equ 0x0A14AAE0
CIRCLE_PRESS    equ 0x0A14AAE8
NO_PRESS        equ 0x0A14AA40

GIVE_ITEM       equ 0x0A0D20A8

PSP_O_RDONLY    equ 0x00000001
PSP_O_WRONLY    equ 0x00000002
PSP_O_CREAT     equ 0x00000200

sceIoWrite      equ 0x08965690
sceIoClose      equ 0x089656B0
sceIoGetStat    equ 0x089656B8
sceIoOpen       equ 0x089656D0
sceIoRead       equ 0x089656A0

GAME            equ "P3RDHDML"

.include "main.asm"
