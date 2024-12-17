

## Description
Ce projet est un ensemble de fichiers ASM et un fichier binaire compilé permettant de modifier des fichiers ELF.
Les fichiers inclus dans ce projet permettent de :

1. **modif.asm** : Modifie l'adresse `e_entry` de l'en-tête ELF, change le type du segment de `PT_NOTE` à `PT_LOAD`, et met à jour les flags du segment.
2. **octetmodif.asm** : Change les valeurs de `p_memsz` et `p_filesz` dans l'en-tête du programme ELF.
3. **append.asm** : Ajoute des données supplémentaires au fichier binaire.
4. **projet.asm** : Le programme principal qui orchestre les modifications.
5. **hello** : Un fichier binaire précompilé (fourni) utilisé pour les tests.

Vous pouvez également tester ce projet avec un autre fichier ELF binaire de votre choix. Assurez-vous simplement de le nommer `hello`.

---

## Prérequis

1. **NASM** : Assembleur nécessaire pour assembler les fichiers `.asm`.
   - Installez NASM avec la commande suivante (pour les systèmes basés sur Debian/Ubuntu) :
     ```bash
     sudo apt update && sudo apt install nasm
     ```

2. **Linker (ld)** : Utilisé pour créer un exécutable à partir des fichiers objet.

---

## Compilation et Lancement

### Compilation des fichiers ASM

1. Assemblez un fichier avec la commande suivante :
   ```bash
   nasm -f elf64 <nom_du_fichier.asm> -o <nom_du_fichier.o>
   ```

2. Liez ensuite le fichier objet pour créer l'exécutable :
   ```bash
   ld <nom_du_fichier.o> -o <nom_du_fichier>
   ```

### Exemple de Compilation

Pour assembler et exécuter `projet.asm` :
```bash
nasm -f elf64 projet.asm -o projet.o
ld projet.o -o projet
./projet
```

---

## Description des Fichiers

### `modif.asm`
- **Objectif** :
  - Modifie l'adresse d'entrée (`e_entry`) dans l'en-tête ELF.
  - Change le type de segment de `PT_NOTE` à `PT_LOAD`.
  - Met à jour les flags du segment.

### `octetmodif.asm`
- **Objectif** :
  - Modifie les champs `p_memsz` et `p_filesz` dans l'en-tête du programme ELF.

### `append.asm`
- **Objectif** :
  - Ajoute des données supplémentaires à la fin d'un fichier ELF binaire.

### `projet.asm`
- **Objectif** :
  - Programme principal gérant toutes les modifications des fichiers ELF.

### `hello`
- **Objectif** :
  - Fichier ELF précompilé utilisé pour tester les modifications apportées par les différents fichiers ASM.

---

## Utilisation

1. Assurez-vous que le fichier binaire `hello` est présent dans le répertoire.
2. Compilez et exécutez les fichiers `.asm` pour tester leurs fonctionnalités.
3. Vous pouvez remplacer `hello` par tout autre fichier ELF de votre choix (en le renommant `hello`).

---

## Notes Importantes

- Les modifications effectuées par ces fichiers ASM peuvent rendre un fichier ELF inutilisable. Veillez à effectuer des sauvegardes avant de travailler sur des fichiers importants.
- Pour éviter les problèmes de permissions, exécutez les commandes avec les droits appropriés ou utilisez `sudo` si nécessaire.

---

## Ressources Supplémentaires

- [Documentation ELF](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
- [Tutoriel NASM](https://nasm.us/doc/)
- [Linker GNU ld](https://sourceware.org/binutils/docs/ld/)

---

## Auteur

Votre nom ou pseudonyme.

---

## Licence

Ajoutez ici la licence de votre choix (par exemple, MIT, GPL, etc.).

