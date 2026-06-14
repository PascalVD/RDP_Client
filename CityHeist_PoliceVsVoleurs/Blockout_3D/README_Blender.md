# Blockout 3D — Génération Blender — CITY HEIST

Le script `generate_blockout.py` construit **toute la ville en blockout
low-poly** et l'exporte en FBX + GLB, prêts pour UEFN.

## Prérequis
- **Blender 3.6 LTS ou plus récent** (gratuit) : https://www.blender.org

## Lancement (recommandé : ligne de commande)
Placez-vous dans ce dossier puis :

```bash
blender --background --python generate_blockout.py
```

Cela crée :
```
export/
├── CityHeist_Blockout.blend     # projet Blender (éditable)
├── CityHeist_Blockout.fbx       # IMPORT UEFN principal (toute la map)
├── CityHeist_Blockout.glb       # alternative / preview web
└── parts/
    ├── BL_Commissariat.fbx
    ├── BL_Banque.fbx
    ├── BL_Casino.fbx
    └── ...                       # un FBX par bâtiment (import modulaire)
```

### Alternative dans l'interface Blender
1. Ouvrez Blender → onglet **Scripting**.
2. **Open** → `generate_blockout.py` → **Run Script** (▶).
3. Les exports sont écrits dans `export/` à côté du `.blend` (ou du cwd).

## Ce qui est généré
| Bâtiment | Dimensions (m) | Porte | Fenêtres | Ambiance |
|----------|----------------|-------|----------|----------|
| Banque | 34×30×14 | sud | oui | gris pierre |
| Commissariat | 28×22×9 | est | oui | bleu police |
| Prison | 22×18×7 | nord | oui | bleu police |
| Planque voleurs | 24×20×8 | ouest | oui | orange |
| Bijouterie | 16×14×7 | sud | oui | néon rose |
| Casino | 30×26×12 | ouest | oui | néon |
| Supérette | 14×12×6 | sud | oui | néon |
| Station essence | 18×8×5 | ouverte (auvent + pompes) | — | béton |
| 4 maisons | 12×10×6 | sud | non | maison |
| Parking souterrain | 34×30×4 | nord, z=-15 | non | béton |
| Routes + trottoirs | larges 10–12 | — | — | asphalte |
| Entrées d'égouts ×5 | trappe + puits | — | — | sombre |
| Barrages police ×3 | 6×0.6×1.2 | — | — | jaune |

Chaque bâtiment est **creux** (4 murs + sol + toit), avec **porte percée**
par opération booléenne et fenêtres simples → on peut entrer dedans et y
placer les devices.

## Conventions
- **1 unité Blender = 1 mètre**. Voir l'échelle d'import dans
  `../Build_Instructions/UEFN_Import_Guide.md`.
- Tous les bâtiments sont préfixés **`BL_`** (utile pour les filtrer/instancier).
- Code couleur par **matériau** (bleu police, orange voleurs, néon, béton…),
  défini dans le dictionnaire `MATERIALS` du script — modifiable librement.

## Personnalisation rapide
- **Déplacer/redimensionner** un bâtiment : éditez le dictionnaire `LAYOUT`
  (x, y, largeur, profondeur, hauteur, matériau).
- **Changer une couleur** : éditez `MATERIALS`.
- **Ajouter un bâtiment** : ajoutez une ligne dans `LAYOUT` puis, au besoin,
  une règle de porte dans `door_map` (fonction `build_map`).
- **Épaisseur des murs** : `WALL_THICKNESS`.

## Conseils import UEFN (rappel)
- À l'import FBX, **Generate Collision = Simple** (boîtes), pas Complex.
- Vérifiez l'échelle : si la map paraît minuscule, réimportez avec **Import
  Uniform Scale = 100** ou activez **Convert Scene Unit**.
- Importez d'abord le FBX global pour le **layout**, puis remplacez
  progressivement les pièces par les assets détaillés Fab.
