section .data
    filename db 'hello', 0
    octet_position equ 0x338 j'ai récupéré cette info avec readel - l hello
    new_value db 0x01

section .bss
    file_descriptor resq 1

section .text
    global _start

_start:
    ; Ouvrir le fichier
    mov rax, 2
    mov rdi, filename
    mov rsi, 2          ; O_RDWR
    syscall
    mov [file_descriptor], rax

    ; Positionner le curseur
    mov rax, 8          ; sys_lseek
    mov rdi, [file_descriptor]
    mov rsi, octet_position
    mov rdx, 0          ; SEEK_SET
    syscall

    ; Écrire le nouvel octet
    mov rax, 1
    mov rdi, [file_descriptor]
    mov rsi, new_value
    mov rdx, 1
    syscall

    ; Fermer le fichier
    mov rax, 3
    mov rdi, [file_descriptor]
    syscall

    ; Sortir
    mov rax, 60
    xor rdi, rdi
    syscall
