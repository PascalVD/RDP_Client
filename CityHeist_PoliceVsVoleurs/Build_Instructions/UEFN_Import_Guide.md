# Guide d'import UEFN — CITY HEIST

Ce guide explique comment passer des fichiers de ce dépôt à un projet UEFN
jouable.

## 1. Créer le projet UEFN
1. Installez **UEFN** depuis l'**Epic Games Launcher** (onglet *Unreal Editor
   for Fortnite*).
2. Lancez UEFN → **Create New** → modèle **Blank** (île vierge).
3. Nommez le projet, ex. `CityHeist`. Patientez l'ouverture de l'éditeur.

## 2. Importer le blockout 3D (FBX)
1. Générez d'abord les FBX avec Blender (voir `../Blockout_3D/README_Blender.md`).
2. Dans UEFN, ouvrez le **Content Browser** (en bas).
3. Créez un dossier `Blockout`, puis **Import** → sélectionnez
   `export/CityHeist_Blockout.fbx`.
4. Réglages d'import (boîte de dialogue FBX) :
   - **Import Uniform Scale = 100** *(Blender mètres → Unreal cm)*
     — ou cochez **Convert Scene Unit** si proposé.
   - **Generate Collision = ✔** (type **Simple / Box**).
   - **Combine Meshes** : laissez décoché pour garder un mesh par bâtiment
     (import modulaire) ; cochez pour un seul gros mesh (layout rapide).
   - **Import Materials = ✔** (récupère le code couleur).
5. Cliquez **Import All**.
6. Glissez le(s) mesh(es) dans le viewport. Si vous avez importé le FBX global,
   il est déjà positionné selon `../Docs/Placement_Plan.md`. Sinon, placez
   chaque pièce aux coordonnées du plan **(×100)**.

> **Vérif échelle** : la rue principale doit faire ~10–12 m de large. Une porte
> fait ~3 m de haut. Si tout est minuscule/géant, corrigez l'échelle d'import.

## 3. Ajouter les scripts Verse
1. Dans UEFN : menu **Verse > Verse Explorer** (et **Open Verse Workspace**
   pour lancer VS Code).
2. Copiez les 7 fichiers du dossier `../Verse/` dans le dossier Verse du projet
   (`<Projet>/`), **ou** recréez-les via **Verse > Create New Verse File** et
   collez le contenu.
3. Dans UEFN : **Verse > Build Verse Code** (Ctrl+Shift+B).
4. Une fois compilés, les devices apparaissent dans le **Content Browser**
   sous *VerseDevices* (ex. `city_heist_game_manager`).

> Ordre conseillé : ils compilent ensemble. Si une erreur surgit, vérifiez que
> les **digests** (`/Fortnite.com/Devices`, `/Teams`, etc.) sont à jour et
> corrigez la signature d'API mineure éventuelle (UEFN évolue vite — voir
> notes ci-dessous).

## 4. Placer & brancher les devices
1. Suivez `../Devices/Devices_List.md` : pour chaque ligne, glissez le device,
   **renommez-le EXACTEMENT** (colonne « Nom exact ») dans l'Outliner.
2. Placez-le à la position indiquée (×100 pour les cm).
3. Pour les **devices Verse** (managers/zones), sélectionnez-les et dans
   **Details** branchez chaque propriété `@editable` sur le device cible
   (menu déroulant qui liste les devices du niveau).
   - Commencez par `city_heist_team_setup`, `..._hud_manager`,
     `..._wanted_manager` (les bases), puis les zones, puis le `game_manager`
     (qui référence tout le reste).
4. Réglez les **Team Settings & Inventory** : Police = **index 0**,
   Voleurs = **index 1** (cohérent avec `PoliceTeamIndex/VoleursTeamIndex`).

## 5. Lancer une session de test
1. Bouton **Launch Session** (▶) en haut.
2. Ajoutez un 2e client / des bots pour tester les deux équipes.
3. Ouvrez l'**Output Log** : repérez les lignes `[CityHeist] …` (prêt,
   braquage, arrestation, fin de manche).

## Notes & dépannage (API Verse)
- UEFN met à jour régulièrement les noms d'API. Si un appel ne compile pas
  (ex. `SetScoreAward`, `SpawnVehicle`, `GetAgentsInArea`), ouvrez la
  définition du device dans le **Verse digest** et adaptez le nom exact — la
  **logique reste identique**, seuls les noms de méthodes peuvent bouger.
- Les fonctions `<localizes>` du HUDManager génèrent automatiquement les clés
  de localisation à la compilation.
- Si un `@editable` de type device spécifique (ex.
  `vehicle_spawner_armored_battle_bus_device`) n'existe pas dans votre version,
  remplacez-le par le **Vehicle Spawner** générique et adaptez l'appel.
