section .data
    filename db 'hello', 0
    octet_position equ 456 -- obtenu en effectuant un chagement manuel et en comparant les octets avec une copue de hello
    flags_position equ 460  il s'agit de la position de octet_position auquel on ajoute. 
    octetentry_position equ 24 ; Offset correct pour e_entry (64 bits)
    new_flags dd 0x00000001 -flags d'exection = 1
    new_value db 1 -- valeur que va prendre l'octet_position
    newentry_adress dq 0x0338 ; adresse virtuelle obtenue en faisant la commande readme sur github.

section .bss
    file_descriptor resq 1

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

    ; Fermer le fichier
    mov rax, 3
    mov rdi, [file_descriptor]
    syscall

    ; Sortir
    mov rax, 60
    xor rdi, rdi
    syscall
