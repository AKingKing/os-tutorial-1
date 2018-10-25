;ORG是Origin的缩写：起始地址，源。在汇编语言源程序的开始通常都用一条ORG伪指令来实现规定程序的起始地址。如果不用ORG规定则汇编得到的目标程序将从0000H开始

[org 0x7c00]


comment /*

32位CPU所含有的寄存器有：
4个数据寄存器(EAX、EBX、ECX和EDX)
2个变址和指针寄存器(ESI和EDI) 2个指针寄存器(ESP和EBP)
6个段寄存器(ES、CS、SS、DS、FS和GS)
1个指令指针寄存器(EIP) 1个标志寄存器(EFlags)

*/

    mov bp, 0x8000 ; set the stack safely away from us
    mov sp, bp

comment /*

数据寄存器
寄存器EAX通常称为累加器(Accumulator)，用累加器进行的操作可能需要更少时间。可用于乘、除、输入/输出等操作，使用频率很高；
寄存器EBX称为基地址寄存器(Base Register)。它可作为存储器指针来使用； 
寄存器ECX称为计数寄存器(Count Register)。
在循环和字符串操作时，要用它来控制循环次数；在位操作中，当移多位时，要用CL来指明移位的位数；
寄存器EDX称为数据寄存器(Data Register)。在进行乘、除运算时，它可作为默认的操作数参与运算，也可用于存放I/O的端口地址。
在16位CPU中，AX、BX、CX和DX不能作为基址和变址寄存器来存放存储单元的地址，
在32位CPU中，其32位寄存器EAX、EBX、ECX和EDX不仅可传送数据、暂存数据保存算术逻辑运算结果，
而且也可作为指针寄存器，所以，这些32位寄存器更具有通用性。


变址寄存器
32位CPU有2个32位通用寄存器ESI和EDI。
其低16位对应先前CPU中的SI和DI，对低16位数据的存取，不影响高16位的数据。
寄存器ESI、EDI、SI和DI称为变址寄存器(Index Register)，它们主要用于存放存储单元在段内的偏移量，
用它们可实现多种存储器操作数的寻址方式，为以不同的地址形式访问存储单元提供方便。
变址寄存器不可分割成8位寄存器。作为通用寄存器，也可存储算术逻辑运算的操作数和运算结果。
它们可作一般的存储器指针使用。在字符串操作指令的执行过程中，对它们有特定的要求，而且还具有特殊的功能。

指针寄存器
其低16位对应先前CPU中的BP和SP，对低16位数据的存取，不影响高16位的数据。
32位CPU有2个32位通用寄存器EBP和ESP。
它们主要用于访问堆栈内的存储单元，并且规定：
EBP为基指针(Base Pointer)寄存器，用它可直接存取堆栈中的数据；
ESP为堆栈指针(Stack Pointer)寄存器，用它只可访问栈顶。
寄存器EBP、ESP、BP和SP称为指针寄存器(Pointer Register)，主要用于存放堆栈内存储单元的偏移量，
用它们可实现多种存储器操作数的寻址方式，为以不同的地址形式访问存储单元提供方便。
指针寄存器不可分割成8位寄存器。作为通用寄存器，也可存储算术逻辑运算的操作数和运算结果


段寄存器是根据内存分段的管理模式而设置的。内存单元的物理地址由段寄存器的值和一个偏移量组合而成
的，这样可用两个较少位数的值组合成一个可访问较大物理空间的内存地址。
CPU内部的段寄存器：
ECS——代码段寄存器(Code SegmentRegister)，其值为代码段的段值；
EDS——数据段寄存器(Data SegmentRegister)，其值为数据段的段值；
EES——附加段寄存器(Extra SegmentRegister)，其值为附加数据段的段值；
ESS——堆栈段寄存器(Stack SegmentRegister)，其值为堆栈段的段值；
EFS——附加段寄存器(Extra SegmentRegister)，其值为附加数据段的段值；
EGS——附加段寄存器(Extra SegmentRegister)，其值为附加数据段的段值。
在16位CPU系统中，它只有4个段寄存器，所以，程序在任何时刻至多有4个正在使用的段可直接访问；在32位
微机系统中，它有6个段寄存器，所以，在此环境下开发的程序最多可同时访问6个段。
32位CPU有两个不同的工作方式：实方式和保护方式。在每种方式下，段寄存器的作用是不同的。有关规定简
单描述如下：
实方式：前4个段寄存器CS、DS、ES和SS与先前CPU中的所对应的段寄存器的含义完全一致，内存单元的逻辑
地址仍为  “段值：偏移量”  的形式。为访问某内存段内的数据，必须使用该段寄存器和存储单元的偏移量。
保护方式：在此方式下，情况要复杂得多，装入段寄存器的不再是段值，而是称为“选择子”(Selector)的某个值。。

cs ss ds es 段地址寄存器,存储内存段地址
ax bx cx dx 通用寄存器,存放普通数据
bp si di bx 偏移地址寄存器
寄存器内存访问: 段地址*16+偏移地址=物理地址
常用组合举例:
ss:sp ss栈段地址寄存器,sp栈偏移地址寄存器
cs:ip cs cpu指针段地址寄存器,ip cpu指针偏移地址寄存器
ds:[bx]  ds[任何偏移地址寄存器]组合
es:[di]  es[任何偏移地址寄存器]组合
[bp] bp默认段寄存器是ss,其他偏移地址寄存器默认的段寄存器是ds
段寄存器不能直接赋值,可以通过通用寄存器间接赋值

*/

    mov bx, 0x9000 ; es:bx = 0x0000:0x9000 = 0x09000

comment /*



*/

    mov dh, 2 ; read 2 sectors
    ; the bios sets 'dl' for our boot disk number
    ; if you have trouble, use the '-fda' flag: 'qemu -fda file.bin'
    call disk_load

    mov dx, [0x9000] ; retrieve the first loaded word, 0xdada
    call print_hex

    call print_nl

    mov dx, [0x9000 + 512] ; first word from second loaded sector, 0xface
    call print_hex

    jmp $

%include "../05-bootsector-functions-strings/boot_sect_print.asm"
%include "../05-bootsector-functions-strings/boot_sect_print_hex.asm"
%include "boot_sect_disk.asm"

; Magic number
times 510 - ($-$$) db 0
dw 0xaa55

; boot sector = sector 1 of cyl 0 of head 0 of hdd 0
; from now on = sector 2 ...
times 256 dw 0xdada ; sector 2 = 512 bytes
times 256 dw 0xface ; sector 3 = 512 bytes
