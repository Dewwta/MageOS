org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A


;
; FAT12 HEADERS
;
jmp short start
nop

bdb_oem:                    db 'MSWIN4.1'           ; 8 Bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                     ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record
ebr_drive_number:           db 0                         ; 0x00 floppy, 0x80 hdd, useless
                            db 0                         ; reserved
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h           ; serial number, value doesnt matter
ebr_volume_label:           db 'MAGE OS'                ; 7 Bytes padded with spaces
ebr_system_id:              db 'FAT12'                      ; 8 bytes

;
; code goes here
;


start:
    jmp main
;
; Print a string to the screen.
;   Params:
;       -ds:si points to string
puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb                       ; loads next character in al
    or al, al                   ; verify if next character is null
    jz .done

    mov ah, 0x0e                ; call bios interrupt
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret


main:
    
    ; setup data segments
    mov ax, 0           ; can't write to ds/es directly
    mov ds, ax
    mov es, ax

    ; setup stack
    mov ss, ax
    mov sp, 0x7C00       ; stack grows downwards from where we are loaded in memory

    ; print message
    mov si, msg_hello
    call puts

    
    hlt

.halt:
    jmp .halt

;
; Disk Routines
;

;
; Converts an LBA adress to a CHS adress
; Parameters: 
;   - ax: LBA address
; Returns:
;   - cx [bits 0-5]: sector number
;   - cx [bits 6-15]: cylinder
;   - dh: head

lba_to_chs:

    xor dx, dx                          ; dx = 0
    div word [bdb_sectors_per_track]    ; ax = LBA / SectorsPerTrack
                                        ; dx = LBA % SectorsPerTrack

    inc dx                              ; dx = (LBA % SectorsPerTrack + 1) = sector
    mov cx,dx                           ; cx = sector
    
    xor dx, dx                          ; dx = 0
    div word[bdb_heads]                 ; ax = (LBA / SectorsPerTrack) / Heads
                                        ; dx = (LBA / SectorsPerTrack) % Heads






msg_hello: db 'Hello world!', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h
