; load 'dh' sectors from drive 'dl' into ES:BX
disk_load:
    pusha
    ; reading from disk requires setting specific values in all registers
    ; so we will overwrite our input parameters from 'dx'. Let's save it
    ; to the stack for later use.
    push dx

comment /*

0x02 chs_mod chs模式就是通过设置磁头号，磁道号，扇区号，调用bios的0x13的2号功能进行读取磁盘扇区
BIOS call "INT 0x13 Function 0x2" to read sectors from disk into memory
INT 0x13 Function 0x2
读扇区
(3)、功能02H  
功能描述：读扇区 
入口参数：AH＝02H 
AL＝扇区数 
CH＝柱面 
CL＝扇区 
DH＝磁头 
DL＝驱动器，00H~7FH：软盘；80H~0FFH：硬盘 
ES:BX＝缓冲区的地址 
出口参数：CF＝0——操作成功，AH＝00H，AL＝传输的扇区数，否则，AH＝状态代码，参见功能号01H中的说明

*/

    mov ah, 0x02 ; ah <- int 0x13 function. 0x02 = 'read'
    mov al, dh   ; al <- number of sectors to read (0x01 .. 0x80)
    mov cl, 0x02 ; cl <- sector (0x01 .. 0x11)
                 ; 0x01 is our boot sector, 0x02 is the first 'available' sector
    mov ch, 0x00 ; ch <- cylinder (0x0 .. 0x3FF, upper 2 bits in 'cl')
    ; dl <- drive number. Our caller sets it as a parameter and gets it from BIOS
    ; (0 = floppy, 1 = floppy2, 0x80 = hdd, 0x81 = hdd2)
    mov dh, 0x00 ; dh <- head number (0x0 .. 0xF)

    ; [es:bx] <- pointer to buffer where the data will be stored
    ; caller sets it up for us, and it is actually the standard location for int 13h

comment /*

INT 13H，AH=02H 读扇区说明：
调用此功能将从磁盘上把一个或更多的扇区内容读进存贮器。因为这是一个
低级功能，在一个操作中读取的全部扇区必须在同一条磁道上（磁头号和磁道号
相同）。BIOS不能自动地从一条磁道末尾切换到另一条磁道开始，因此用户必须
把跨多条磁道的读操作分为若干条单磁道读操作。
入口参数：
AH=02H 指明调用读扇区功能。
AL 置要读的扇区数目，不允许使用读磁道末端以外的数值，也不允许
使该寄存器为0。
DL 需要进行读操作的驱动器号。
DH 所读磁盘的磁头号。
CH 磁道号的低8位数。
CL 低5位放入所读起始扇区号，位7-6表示磁道号的高2位。
ES:BX 读出数据的缓冲区地址。
返回参数：
如果CF=1，AX中存放出错状态。读出后的数据在ES:BX区域依次排列。
详情请参见磁盘错误状态返回码一文。
示例：
C_SEG SEGMENT PUBLIC
ASSUME CS:C_SEG,DS:C_SEG
ORG 100H
START: JMP READ
BUFFER DB 512 DUP(0)
READ: PUSH CS
POP ES
MOV BX, OFFSET BUFFER
MOV AX, 0201H
MOV CX, 0001H
MOV DX, 0000H
INT 13H
;读软盘A, 0面0道1扇区
;读出后数据在BUFFER中
JC ERROR
……
ERROR: ……
C_SEG ENDS
END START

*/

    int 0x13      ; BIOS interrupt
    jc disk_error ; if error (stored in the carry bit)

    pop dx
    cmp al, dh    ; BIOS also sets 'al' to the # of sectors read. Compare it.
    jne sectors_error
    popa
    ret


disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl
    mov dh, ah ; ah = error code, dl = disk drive that dropped the error
    call print_hex ; check out the code at http://stanislavs.org/helppc/int_13-1.html
    jmp disk_loop

sectors_error:
    mov bx, SECTORS_ERROR
    call print

disk_loop:
    jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0
