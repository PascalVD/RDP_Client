# CITY HEIST – POLICE VS VOLEURS — README (FR)

Mode **Police vs Voleurs** pour **Fortnite UEFN** (Unreal Editor for Fortnite).
Ville de nuit stylisée : commissariat, banque, casino, bijouterie, planque,
prison, égouts, parking souterrain, quartier résidentiel, supérette/station.

⚠️ **Honnêteté technique** : ce dépôt **ne contient pas** de fichier `.umap`
UEFN natif (impossible à générer hors d'UEFN). Il fournit **tout le reste**
pour assembler la map vous-même en quelques heures :
- 7 scripts **Verse** prêts à compiler ;
- un générateur **Blender Python** du blockout 3D (FBX/GLB) ;
- la **liste complète des devices** avec positions et branchements ;
- la **documentation**, le **gameplay**, l'**équilibrage**, et une
  **checklist d'assemblage** pas à pas.

## Structure du projet
```
CityHeist_PoliceVsVoleurs/
├── Verse/                 # 7 scripts Verse (logique du mode)
│   ├── GameManager.verse
│   ├── RobberyZone.verse
│   ├── PrisonManager.verse
│   ├── WantedLevelManager.verse
│   ├── LootDepositManager.verse
│   ├── TeamSetup.verse
│   └── HUDManager.verse
├── Docs/                  # documentation (ce dossier)
│   ├── README_FR.md
│   ├── Placement_Plan.md
│   ├── Gameplay_Loop.md
│   ├── Balancing.md
│   ├── WantedLevel.md
│   ├── FinalEvent_Convoy.md
│   └── Publishing_Checklist.md
├── Blockout_3D/           # génération 3D
│   ├── generate_blockout.py
│   └── README_Blender.md
├── Devices/
│   └── Devices_List.md    # ~70 devices, positions, params, scripts liés
├── Images/
│   └── layout_map.svg     # plan visuel de la ville
└── Build_Instructions/
    ├── UEFN_Import_Guide.md
    └── Assembly_Checklist.md
```

## Démarrage rapide (vue d'ensemble)
1. **Installer UEFN** (via l'Epic Games Launcher).
2. **Créer un projet vierge** UEFN (« Create New > Blank »).
3. **Importer le blockout** : lancer `Blockout_3D/generate_blockout.py` dans
   Blender → importer `export/CityHeist_Blockout.fbx` dans UEFN
   (voir `Build_Instructions/UEFN_Import_Guide.md`).
4. **Ajouter les scripts Verse** : copier le dossier `Verse/` dans le projet,
   ouvrir VS Code via UEFN, **Verse > Build Verse Code**.
5. **Placer les devices** selon `Devices/Devices_List.md`, renommer **exactement**
   comme indiqué, puis **brancher** les références `@editable`.
6. **Tester** : *Launch Session* à 2 joueurs minimum.
7. **Équilibrer** : ajuster les valeurs (voir `Balancing.md`).
8. **Publier** : suivre `Publishing_Checklist.md`.

## Comment importer les modèles 3D
Voir `Build_Instructions/UEFN_Import_Guide.md`. En résumé : générez le FBX avec
Blender, glissez-le dans le *Content Browser* UEFN, réglez l'échelle (×100 /
cm), activez **Generate Collision = Simple**, placez les meshes aux coordonnées
de `Placement_Plan.md`.

## Comment ajouter les scripts Verse
1. Dans UEFN : **Verse > Create New Verse File** *(ou)* copiez les `.verse`
   fournis dans le dossier du projet `…/<Projet>/`.
2. Chaque script définit une classe `creative_device`. Après **Build Verse
   Code**, ces devices apparaissent dans le *Content Browser*.
3. Glissez chaque device dans le niveau, renommez-le, puis branchez ses
   propriétés `@editable` (cf. `Devices_List.md`).

## Comment tester la map
- **Launch Session** (bouton ▶) ; ajoutez des bots ou un 2e client si possible.
- Vérifiez : spawns corrects, alarme au braquage, ouverture coffre, dépôt =
  points, arrestation → prison → évasion, convoi à T-3 min, fin de manche.
- Consultez la console (Output Log) : les scripts impriment `[CityHeist] …`.

## Comment équilibrer les points
Tout est centralisé dans les `@editable` du **GameManager** et des
**RobberyZone**. Voir `Balancing.md` (économie, timers, classes, boucle de
playtest).

## Comment optimiser la mémoire
Voir la section *Optimisation* de `Publishing_Checklist.md` :
- rester en blockout/low-poly, instancier les meshes répétés (maisons) ;
- limiter les VFX/lumières dynamiques (priorité aux lumières statiques) ;
- regrouper les Audio Players, réutiliser un seul HUD Message par usage ;
- surveiller le **Memory Budget** (onglet *Project Memory* d'UEFN, < 100 %).

## MVP vs version complète
- **MVP jouable** (~30 devices) : Banque + Prison + dépôt + score + 2 spawns.
  Voir la section MVP de `Build_Instructions/Assembly_Checklist.md`.
- **Version complète** : toutes les zones, Wanted Level, convoi, égouts, SWAT.

## Contraintes respectées
- Aucune marque réelle, aucun logo protégé, aucun asset non autorisé.
- Style Fortnite, priorité gameplay + performance.
