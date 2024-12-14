section .data
    filename db 'hello', 0
    position dq 488
    buffer db 0
    tailleShellcode dw 0x22

section .bss
    file_descriptor resq 1
    p_filesz resb 1

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

    ; Positionner le curseur pour lire
    mov rax, 8
    mov rdi, [file_descriptor]
    mov rsi, [position]
    xor rdx, rdx  ; SEEK_SET
    syscall

    ; Lire l'octet
    mov rax, 0
    mov rdi, [file_descriptor]
    mov rsi, buffer
    mov rdx, 1
    syscall

    ; Additionner buffer et tailleShellcode
    movzx ax, byte [buffer]
    add ax, [tailleShellcode]
    mov [p_filesz], al

    ; Repositionner le curseur pour écrire
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

    ; Fermer le fichier
    mov rax, 3
    mov rdi, [file_descriptor]
    syscall

    ; Sortie normale
    mov rax, 60
    xor rdi, rdi
    syscall

error:
    ; Gestion d'erreur (à adapter selon vos besoins)
    mov rax, 60
    mov rdi, 1  ; Code d'erreur
    syscall
