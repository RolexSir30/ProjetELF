section .data

fichier db 'hello',0 ; ici nous allons travailler sur un fichier en particulier le programme hello world compilé en language C
messageConfirmation db ' Il s agit d un fichier ELF',0xA,0
messageRefus db 'Il ne s agit pas d un fichier ELF ou  erreur lors de l'ouverture du fichier.', 0xA,0
elfMagic db 0x7F, 'E', 'L', 'F' ; il s'agit de la signature elf


messagePresencePtNote db ' le fichier contient bien un segment ptnote',0xA,0 ;  ce message permet de confirmer ou non si l'elf a bien un ptnote
messageAbsencePtNote db ' Le fichier ne contient pas de segment ptnote',0xA,0 ; A l'inverse s'il n' a pas de ptnote cela retournera ce message
ptNoteOffset1 dq 0x338    ; Premier offset du segment PT_NOTE
ptNoteOffset2 dq 0x368    ; Deuxième offset du segment PT_NOTE ;  j'ai récupéré ces informations en effectuant la commande  readlf -h [nom du elf]

elf_header db 64 dup(0) ; allocation de 64 bits qu'on va utiliser afin de contenir le header.

section .bss
buffer resb 4 ; Il s'agit du tampon qui lors de l'ouverture du fichier va nous permettre de lire les 4 premiers octets contenant le numéro magique 

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
    jmp exit                     ; on sort du programme

   ; Verification de si le fichier contient un pt_note ou non.

    call verifiePtNote ; appel la fonction vérifie pt_note
      








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




verifiePtNote:

