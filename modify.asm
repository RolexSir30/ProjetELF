section .data
    filename db 'hello', 0
    octet_position equ 456 ; voir read me pour voir comment j'ai trouvé cette valeur.
    flags_position equ 460  ; Position du champ p_flags
    new_flags dd 0x00000001 ; Valeur pour PF_X (exécutable)
    new_value db 1

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

    ; Positionner le curseur pour les flags
    mov rax, 8          ; sys_lseek
    mov rdi, [file_descriptor]
    mov rsi, flags_position
    mov rdx, 0          ; SEEK_SET
    syscall

    ; Écrire les nouveaux flags
    mov rax, 1          ; sys_write
    mov rdi, [file_descriptor]
    mov rsi, new_flags
    mov rdx, 4          ; Taille de la valeur (4 octets pour un dword)
    syscall

    ; Repositionner le curseur pour l'octet à modifier
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
