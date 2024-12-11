section .data
    filename db 'hello', 0  ; Nom du fichier ELF
    octet_position equ 10          ; Position de l'octet à modifier (0-indexed)
    new_value db 0xFF               ; Nouvelle valeur de l'octet

section .bss
    file_descriptor resq 1          ; Descripteur de fichier (64 bits)
    buffer resb 256                  ; Tampon pour lire le fichier

section .text
    global _start

_start:
    ; Ouvrir le fichier en mode lecture/écriture
    mov rax, 2                       ; sys_open
    mov rdi, filename                ; Nom du fichier
    mov rsi, 2                       ; O_RDWR
    syscall
    mov [file_descriptor], rax       ; Stocker le descripteur

    ; Lire le fichier
    mov rax, 0                       ; sys_read
    mov rdi, [file_descriptor]       ; Descripteur de fichier
    mov rsi, buffer                  ; Tampon
    mov rdx, 256                     ; Lire jusqu'à 256 octets (ajuster si nécessaire)
    syscall

    ; Modifier l'octet à la position spécifiée
    mov al, [new_value]             ; Charger la nouvelle valeur dans al
    mov byte [buffer + octet_position], al  ; Modifier l'octet

    ; Revenir au début du fichier
    mov rax, 8                       ; sys_lseek
    mov rdi, [file_descriptor]       ; Descripteur de fichier
    xor rsi, rsi                     ; Offset 0 (début du fichier)
    mov rdx, 0                       ; SEEK_SET
    syscall

    ; Écrire le fichier
    mov rax, 1                       ; sys_write
    mov rdi, [file_descriptor]       ; Descripteur de fichier
    mov rsi, buffer                  ; Tampon
    mov rdx, 256                     ; Écrire jusqu'à 256 octets (ajuster si nécessaire)
    syscall

    ; Fermer le fichier
    mov rax, 3                       ; sys_close
    mov rdi, [file_descriptor]       ; Descripteur de fichier
    syscall

    ; Sortir
    mov rax, 60                      ; sys_exit
    xor rdi, rdi                     ; Code de sortie 0
    syscall
