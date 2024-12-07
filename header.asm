section .data
    filename db "hello", 0
    magic db 0x7F, 'E', 'L', 'F'
    not_elf_msg db "Not an ELF file.", 10, 0  ; Message à afficher (10 = saut de ligne)

    ; Valeurs des champs ELF donnés
    e_phoff_value dq 0x64              ; Début des en-têtes de programme (e_phoff) : 0x64
    e_entry_value dq 0x1060            ; Point d'entrée (e_entry) : 0x1060
    e_phnum_value dw 13                ; Nombre d'en-têtes de programme (e_phnum) : 13

section .bss
    buffer resb 64

section .text
    global _start

_start:
    ; Ouvrir le fichier
    mov eax, 5            ; syscall: open
    lea ebx, [filename]
    mov ecx, 2            ; O_RDWR
    int 0x80
    mov esi, eax          ; Stocker le descripteur de fichier

    ; Lire les 4 premiers octets
    mov eax, 3            ; syscall: read
    mov ebx, esi
    lea ecx, [buffer]
    mov edx, 4
    int 0x80

    ; Vérifier le magic number
    lea edi, [magic]
    lea esi, [buffer]
    mov ecx, 4
    repe cmpsb
    jne not_elf

    ; Continuer si ELF
    jmp process_elf

not_elf:
    ; Afficher un message si ce n'est pas un ELF
    mov eax, 4            ; syscall: write
    mov ebx, 1            ; File descriptor: stdout
    lea ecx, [not_elf_msg] ; Adresse du message
    mov edx, 17           ; Taille du message
    int 0x80

    ; Sortir
    mov eax, 1            ; syscall: exit
    xor ebx, ebx          ; Code de retour
    int 0x80

process_elf:
    ; Lire les 64 premiers octets (en-tête ELF) avec sys_pread64
    mov eax, 17           ; syscall: pread64
    mov ebx, esi          ; Descripteur de fichier
    lea ecx, [buffer]     ; Buffer pour stocker l'en-tête
    mov edx, 64           ; Taille à lire (64 octets)
    xor esi, esi          ; Offset (début du fichier)
    int 0x80

    ; Fin du programme
    mov eax, 1
    xor ebx, ebx
    int 0x80
