section .data
    filename db 'hello', 0
    flags_offset equ 460
    target_offset equ 456
    entry_offset equ 24
    new_flags dd 0x00000001
    new_byte db 1
    new_entry dq 0x0338

section .bss
    fd resq 1

section .text
    global _start

_start:
    ; Ouvrir le fichier
    mov rax, 2
    mov rdi, filename
    mov rsi, 2
    syscall
    mov [fd], rax

    ; Modifier les flags
    mov rax, 8
    mov rdi, [fd]
    mov rsi, flags_offset
    mov rdx, 0
    syscall

    mov rax, 1
    mov rdi, [fd]
    mov rsi, new_flags
    mov rdx, 4
    syscall

    ; Modifier l'octet cible
    mov rax, 8
    mov rdi, [fd]
    mov rsi, target_offset
    mov rdx, 0
    syscall

    mov rax, 1
    mov rdi, [fd]
    mov rsi, new_byte
    mov rdx, 1
    syscall

    ; Modifier e_entry
    mov rax, 8
    mov rdi, [fd]
    mov rsi, entry_offset
    mov rdx, 0
    syscall

    mov rax, 1
    mov rdi, [fd]
    mov rsi, new_entry
    mov rdx, 8
    syscall

    ; Fermer le fichier
    mov rax, 3
    mov rdi, [fd]
    syscall

    ; Sortir
    mov rax, 60
    xor rdi, rdi
    syscall
