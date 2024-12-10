
; j'essaye de parcourir la liste des segments dans le programe header et extrair l'adresse virtuelle pour changer le type p_type

section .data
    filename db "hello", 0
    fmt db "Segment %d: Address: 0x%x", 10, 0


    
section .bss
    elf_header resb 52 ; Taille de l'en-tête ELF (e_phoff = 64 donc après l'en-tête)
    program_header resb 56 ; Taille d'un en-tête de programme (taille standard de 56 octets)

section .text
    global _start

_start:
    ; Ouvrir le fichier ELF
    ; Ouvrir le fichier (syscall open)
    mov rax, 2            ; syscall: open
    lea rdi, [filename]
    mov rsi, 0x2          ; O_RDWR
    mov rdx, 0            ; Aucun mode (permission non spécifiée)
    syscall
    mov rsi, rax          ; Stocker le descripteur de fichier
    ; Stocker le descripteur de fichier
    mov r14, rax

    ; Lire l'en-tête ELF (juste pour atteindre e_phoff)
    mov rax, 0 ; read
    mov rdi, r14
    mov rsi, elf_header
    mov rdx, 64
    syscall

    ; Se positionner au début des en-têtes de programme (e_phoff)
    mov rax, 8 ; lseek
    mov rdi, r14
    mov rsi, 64 ; e_phoff
    mov rdx, 0 ; SEEK_SET
    syscall

    ; Boucle pour parcourir les en-têtes de programme (e_phnum = 13)
    mov rcx, 13 ; e_phnum
    mov r15, 0 ; Compteur de segment




    

loop_segments:
    ; Lire l'en-tête de programme actuel
    mov rax, 0 ; read
    mov rdi, r14
    mov rsi, program_header
    mov rdx, 56
    syscall

    ; Extraire l'adresse virtuelle du segment (p_vaddr, offset 16 dans l'en-tête du programme)
    mov rdi, fmt
    mov rsi, r15
    mov rdx, [program_header + 16] ; p_vaddr


    ; Incrémenter le compteur de segment
    inc r15

    ; Passer à l'en-tête de programme suivant
    ;add rsi, 56 ; Taille de l'en-tête de programme.  Déjà géré par la lecture séquentielle.

    cmp r15, rcx    ; Comparer r15 et rcx
    jge end_loop   ; Sauter à end_loop si r15 >= rcx


    loop loop_segments









    ; Fermer le fichier
    mov rax, 3
    mov rdi, r14
    syscall

    ; Sortir du programme
    mov rax, 60
    xor rdi, rdi
    syscall



end_loop:
    mov rax, 60      ; Appel système exit
    xor rdi, rdi    ; Code de retour 0 (succès)
    syscall