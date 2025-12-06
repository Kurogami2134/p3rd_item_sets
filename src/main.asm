L_BUTTON    equ 0x0100
R_BUTTON    equ 0x0200
TRIANGLE    equ 0x1000
SQUARE      equ 0x8000

.createfile "../bin/itemset.bin", LOAD_ADD - 8
.word LOAD_ADD
.word @main_block_end - LOAD_ADD
.func store_item ;  a0 item id, a1 quantity
    la      at, ITEM_BOX
@@loop:
    andi    a2, at, 0xFFFF
    srl     a2, a2, 2
    slti    a2, a2, (ITEM_BOX/4 + 1000) & 0xFFFF
    beq     a2, zero, @@ret
    nop
    lh      a2, 0x0(at)  ; id
    lh      a3, 0x2(at)  ; qty
    beq     a2, zero, @@store
    nop
    beq     a3, zero, @@store
    nop
    beq     a2, a0, @@store
    nop
    b       @@loop
    addiu   at, at, 0x4
@@store:
    sh      a0, 0x0(at)
    addu    a1, a1, a3 ;  add quantities
    slti    a2, a1, 100
    bne     a2, zero, @@normal_store ;  if item quantity exceed 99, continues to search
    nop
    addiu   a1, a1, -99
    li      a2, 99
    sh      a2, 0x2(at)
    b       @@loop
    addiu   at, at, 0x4
@@normal_store:
    sh      a1, 0x2(at)
@@ret:
    jr      ra
    nop
.endfunc
.func store_all
    addiu   sp, sp, -0x4
    sw      ra, 0x0(sp)
    la      t0, ITEM_POUCH
@@loop:
    addiu   a0, t0, -(ITEM_POUCH & 0xFFFF)
    andi    a0, a0, 0xFFFF
    slti    a0, a0, 24*4
    beq     a0, zero, @@ret
    nop
    lh      a0, 0x0(t0)
    beql    a0, zero, @@loop
    addiu   t0, t0, 0x4
    lh      a1, 0x2(t0)
    bal     store_item
    nop
    sh      zero, 0x0(t0)
    sh      zero, 0x2(t0)
    b       @@loop
    addiu   t0, t0, 0x4
@@ret:
    lw      ra, 0x0(sp)
    jr      ra
    addiu   sp, sp, 0x4
.endfunc
.func remove_item ;  a0 item id, a1 quantity
    la      at, ITEM_BOX
@@loop:
    beq     a1, zero, @@ret
    nop
    andi    a2, at, 0xFFFF
    srl     a2, a2, 2
    slti    a2, a2, (ITEM_BOX/4 + 1000) & 0xFFFF
    beq     a2, zero, @@ret
    nop
    lh      a2, 0x0(at)  ; id
    lh      a3, 0x2(at)  ; qty
    beq     a2, a0, @@remove
    nop
    b       @@loop
    addiu   at, at, 0x4
@@remove:
    sub     a2, a1, a3
    slti    a2, a2, 0
    bne     a2, zero, @@enough
    nop
    sh      zero, 0x0(at) ;  not enough items
    sh      zero, 0x2(at)
    sub     a1, a1, a3
    b       @@loop
    addiu   at, at, 0x4
@@enough:
    sub     a3, a3, a1
    sh      a3, 0x2(at)
    li      a1, 0
@@ret:
    jr      ra
    nop
.endfunc
.func load_set
    addiu   sp, sp, -0x20
    sw      ra, 0x00(sp)
    sw      a0, 0x04(sp)
    sw      a1, 0x08(sp)
    sw      a2, 0x0C(sp)
    sw      a3, 0x10(sp)
    sw      t0, 0x14(sp)
    sw      t1, 0x18(sp)
    sw      t2, 0x1C(sp)
    bal     store_all
    nop
    lw      t1, 0x20(sp) ;  load set address - 4
    li      t2, ITEM_POUCH - 4
@@loop:
    addiu   a0, t2, -((ITEM_POUCH - 4) & 0xFFFF)
    andi    a0, a0, 0xFFFF
    slti    a0, a0, 24*4
    beq     a0, zero, @@ret
    nop

    addiu   t1, t1, 4
    addiu   t2, t2, 4
    lh      a0, 0x0(t1)
    beq     a0, zero, @@loop
    nop
    bal     remove_item
    lh      a1, 0x2(t1)
    
    lh      a3, 0x2(t1)
    sub     a3, a3, a1
    beq     a3, zero, @@loop
    nop

    sh      a0, 0x0(t2)
    b       @@loop
    sh      a3, 0x2(t2)
@@ret:
    lw      ra, 0x00(sp)
    lw      a0, 0x04(sp)
    lw      a1, 0x08(sp)
    lw      a2, 0x0C(sp)
    lw      a3, 0x10(sp)
    lw      t0, 0x14(sp)
    lw      t1, 0x18(sp)
    lw      t2, 0x1C(sp)
    jr      ra
    addiu   sp, sp, 0x20
.endfunc
.func save_set ;  a0: item set address
    addiu   sp, sp, -0xC
    sw      a0, 0x0(sp)
    sw      a1, 0x4(sp)
    sw      a2, 0x8(sp)
    li      at, ITEM_POUCH
    li      a1, 0
@@loop:
    slti    a2, a1, 48
    beq     a2, zero, @@ret
    lh      a2, 0x0(at)
    sh      a2, 0x0(a0)
    addiu   a1, 1
    addiu   a0, 2
    b       @@loop
    addiu   at, 2
@@ret:
    lw      a0, 0x0(sp)
    lw      a1, 0x4(sp)
    lw      a2, 0x8(sp)
    j       write_sets
    addiu   sp, sp, 0xC
.endfunc
.func read_sets
    addiu   sp, sp, -0x8
    sw      ra, 0x0(sp)
    sw      s0, 0x4(sp)
    ; check if file exists
    la      a0, ITEM_SET_FILE

    jal     sceIoGetStat
    addiu   a1, sp, -0x60

    slt     at, v0, zero
    bne     at, zero, @@ret
    nop
    
    li      a0, ITEM_SET_FILE
    li      a1, PSP_O_RDONLY
    jal     sceIoOpen
    li      a2, 0x1B6
    move    s0, v0
    ; save sets
    move    a0, v0
    la      a1, ITEM_SET_1
    li      a2, 24*4*2
    jal     sceIoRead
    li      a3, 0x0
    ; close file
    jal     sceIoClose
    move    a0, s0
@@ret:
    lw      ra, 0x0(sp)
    lw      s0, 0x4(sp)
    jr      ra
    addiu   sp, sp, 8
.endfunc
.func write_sets
    ; open file
    addiu   sp, sp, -0x8
    sw      ra, 0x4(sp)

    li      a0, ITEM_SET_FILE
    li      a1, PSP_O_CREAT | PSP_O_WRONLY
    jal     sceIoOpen
    li      a2, 0x1B6
    sw      v0, 0x0(sp)
    ; save sets
    lw      a0, 0x0(sp)
    la      a1, ITEM_SET_1
    li      a2, 24*4*2
    jal     sceIoWrite
    li      a3, 0x0
    ; close file
    lw      a0, 0x0(sp)
    jal     sceIoClose
    nop
@@ret:
    lw      ra, 0x4(sp)
    jr      ra
    addiu   sp, sp, 8
.endfunc
.func input
    bne     v0, zero, @@circle
    nop
    andi    v0, s1, L_BUTTON
    bne     v0, zero, @@load_set1
    nop
    andi    v0, s1, R_BUTTON
    bne     v0, zero, @@load_set2
    nop
    andi    v0, s1, SQUARE
    bne     v0, zero, @@save_set1
    nop
    andi    v0, s1, TRIANGLE
    bne     v0, zero, @@save_set2
    nop
    b       @@none
    nop
@@circle:
    j       CIRCLE_PRESS
    nop
@@save_set1:
    li      a0, ITEM_SET_1
    b       @@save_set
    nop
@@save_set2:
    li      a0, ITEM_SET_2
@@save_set:
    addiu   sp, sp, -0x8
    sw      ra, 0x0(sp)
    sw      a0, 0x4(sp)

    la      a0, SET_SAVED_MSG
    bal     show_msg
    nop

    bal     save_set
    lw      a0, 0x4(sp)

    lw      ra, 0x0(sp)
    b       @@none
    addiu   sp, sp, 0x8
@@load_set1:
    la      at, ITEM_SET_1 - 4
    b       @@load_set
    nop
@@load_set2:
    la      at, ITEM_SET_2 - 4
@@load_set:
    addiu   sp, sp, -0x8
    sw      at, 0x0(sp)
    sw      ra, 0x4(sp)

    la      a0, SET_LOADED_MSG
    bal     show_msg
    nop

    bal     load_set
    nop

    lw      ra, 0x4(sp)
    b       @@none
    addiu   sp, sp, 0x8

@@save:
    la      at, save_set
@@call:
    addiu   sp, sp, -4
    sw      ra, 0x0(sp)
    bal     save_set
    nop
    lw      ra, 0x0(sp)
    addiu   sp, sp, 4
@@none:
    j       NO_PRESS
    nop
.endfunc
.func show_msg
    addiu   sp, sp, -0x8
    sw      ra, 0x0(sp)
    sw      a0, 0x4(sp)

    li      a0, 0
    li      a1, 8
    li      a2, 0
    jal     GIVE_ITEM ;  give 0 potions to trigger a message
    li      a3, 0

@@loop:
    lb      a0, -0x1(t0)
    bnel    a0, zero, @@loop
    addiu   t0, t0, -0x1

    lw      a0, 0x4(sp)
@@cpy_loop:
    lb      a1, 0x0(a0)
    sb      a1, 0x0(t0)
    addiu   a0, a0, 1
    bne     a1, zero, @@cpy_loop
    addiu   t0, t0, 1

    lw      ra, 0x0(sp)
    jr      ra
    addiu   sp, sp, 0x8
.endfunc
SET_SAVED_MSG:
.asciiz "Item Set Saved!"
SET_LOADED_MSG:
.asciiz "Item Set Loaded!"
ITEM_SET_FILE:
.asciiz "ms0:/P3RDML/ITEM_SET.BIN"
.align 4
ITEM_SET_1:
.area 24*4, 0

.halfword 0x0008
.halfword 0x000A
.halfword 0x0009
.halfword 0x000A
.halfword 0x005B
.halfword 0x0014
.halfword 0x003B
.halfword 0x003F
.halfword 0x002C
.halfword 0x0001
.halfword 0x0048
.halfword 0x0001
.halfword 0x0049
.halfword 0x0001
.halfword 0x0044
.halfword 0x0005
.halfword 0x0047
.halfword 0x0002
.halfword 0x0046
.halfword 0x0001
.halfword 0x00D0
.halfword 0x0001
.halfword 0x0000
.halfword 0x0000
.halfword 0x0000
.halfword 0x0000
.halfword 0x0000
.halfword 0x0000
.halfword 0x0000
.halfword 0x0000
.halfword 0x0000
.halfword 0x0000
.halfword 0x0096
.halfword 0x000A
.halfword 0x00A2
.halfword 0x000A
.halfword 0x0097
.halfword 0x000A
.halfword 0x0040
.halfword 0x000A
.halfword 0x0025
.halfword 0x0001
.halfword 0x0023
.halfword 0x0001
.halfword 0x0026
.halfword 0x0001
.halfword 0x0024
.halfword 0x0001

.endarea
ITEM_SET_2:
.area 24*4, 0
.endarea

@main_block_end:
.word HOOK
.word 8
    j       input
    nop
.word @main_block_end
.word 8 | 0x80000000
    j       read_sets
    nop
.word -1
.word 0
.close
