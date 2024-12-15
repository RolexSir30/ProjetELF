section .data
    filename db 'hello', 0  ; Nom du fichier ELF

section .bss
    fd resb 4          ; Descripteur de fichier
    offset resq 1      ; offset de fin de fichier

section .text
    global _start

_start:
    ; Ouvrir le fichier
    mov rax, 2          ; sys_open
    mov rdi, filename   ; fichier binaire hello
    mov rsi, 0          ; mode lecture seule
    syscall
    mov [fd], rax      ; sauvegarde du descripteur de fichier

    ; Utilisation de lseek pour obtenir l'offset de fin de fichier
    mov rax, 8          ; sys_lseek
    mov rdi, [fd]       ; descripteur de fichier
    mov rsi, 0          ; Offs
    mov rdx, 2          ; SEEK_END
    syscall
    mov [offset], rax   ; Sauvegarder l'offset

 
    ; Fermer le fichier
    mov rax, 3          ; sys_close
    mov rdi, [fd]       ; descripteur de fichier
    syscall

    ; Sortir du programme
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; code de retour 0
    syscall
