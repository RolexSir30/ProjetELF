section .data
    filename db "hello", 0
    magic db 0x7F, 'E', 'L', 'F'
    not_elf_msg db "Not an ELF file.", 10, 0  ; Message à afficher (10 = saut de ligne)

    ; Valeurs des champs ELF donnés
    e_phoff_value dq 0x64              ; Début des en-têtes de programme (e_phoff) : 0x64
    e_entry_value dq 0x1060            ; Point d'entrée (e_entry) : 0x1060
    e_phnum_value dw 13                ; Nombre d'en-têtes de programme (e_phnum) : 13
    
    ; Informations sur PT_NOTE
    pt_note_1_offset dq 0x0000000000000338  ; Offset de la première entrée PT_NOTE
    pt_note_1_filesz dq 0x30                ; Taille du fichier pour la première entrée PT_NOTE
    pt_note_1_vaddr dq 0x0000000000000338  ; Adresse virtuelle pour la première entrée PT_NOTE
    pt_note_1_flags dq 0x4                 ; Permissions pour la première entrée PT_NOTE (R)

    ; Informations sur PT_NOTE
    pt_note_2_offset dq 0x0000000000000368  ; Offset de la deuxième entrée PT_NOTE
    pt_note_2_filesz dq 0x44                ; Taille du fichier pour la deuxième entrée PT_NOTE
    pt_note_2_vaddr dq 0x0000000000000368  ; Adresse virtuelle pour la deuxième entrée PT_NOTE
    pt_note_2_flags dq 0x4                 ; Permissions pour la deuxième entrée PT_NOTE (R)


section .bss
    buffer resb 64

section .text
    global _start

_start:
    ; Ouvrir le fichier (syscall open)
    mov rax, 2            ; syscall: open
    lea rdi, [filename]
    mov rsi, 0x2          ; O_RDWR
    mov rdx, 0            ; Aucun mode (permission non spécifiée)
    syscall
    mov rsi, rax          ; Stocker le descripteur de fichier

    ; Lire les 4 premiers octets (syscall read)
    mov rax, 0            ; syscall: read
    mov rdi, rsi          ; Descripteur de fichier
    lea rsi, [buffer]     ; Buffer pour stocker les données
    mov rdx, 4            ; Taille à lire (4 octets)
    syscall

    ; Vérifier le magic number
    lea rdi, [magic]
    lea rsi, [buffer]
    mov rcx, 4            ; Comparer 4 octets
    repe cmpsb
    jne not_elf

    ; Continuer si ELF
    jmp process_elf

not_elf:
    ; Afficher un message si ce n'est pas un ELF (syscall write)
    mov rax, 1            ; syscall: write
    mov rdi, 1            ; File descriptor: stdout
    lea rsi, [not_elf_msg] ; Adresse du message
    mov rdx, 17           ; Taille du message
    syscall

    ; Sortir (syscall exit)
    mov rax, 60           ; syscall: exit
    xor rdi, rdi          ; Code de retour
    syscall

process_elf:
    ; Lire les 64 premiers octets (en-tête ELF) avec syscall pread64
    mov rax, 17           ; syscall: pread64
    mov rdi, rsi          ; Descripteur de fichier
    lea rsi, [buffer]     ; Buffer pour stocker l'en-tête
    mov rdx, 64           ; Taille à lire (64 octets)
    xor r10, r10          ; Offset (début du fichier)
    syscall

    ; Fin du programme (syscall exit)
    mov rax, 60           ; syscall: exit
    xor rdi, rdi          ; Code de retour
    syscall
