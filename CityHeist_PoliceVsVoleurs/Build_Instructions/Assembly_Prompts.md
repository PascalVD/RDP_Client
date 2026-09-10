# Prompts d'assemblage pour Claude Code + Unreal MCP — CITY HEIST

Une fois l'Unreal MCP connecté (voir `UEFN_MCP_Setup.md`), copie-colle ces
prompts **dans l'ordre** dans Claude Code. Chaque prompt correspond à une étape
de `Assembly_Checklist.md`. Adapte les noms/positions si tu as changé le plan.

> Astuce : commence chaque session en donnant le contexte —
> *« Référence les fichiers `CityHeist_PoliceVsVoleurs/Verse/*.verse`,
> `Devices/Devices_List.md` et `Docs/Placement_Plan.md`. Coordonnées en mètres,
> ×100 pour UEFN (cm). N'avance à l'étape suivante qu'après compilation OK. »*

---

## 0. Contexte initial (à envoyer en premier)
```
Tu pilotes UEFN via l'Unreal MCP pour construire la map "City Heist – Police vs
Voleurs". Utilise comme spécification les fichiers du projet :
- Verse/ (9 scripts), Devices/Devices_List.md, Docs/Placement_Plan.md,
  Build_Instructions/Assembly_Checklist.md.
Règles : coordonnées du plan en mètres → multiplie par 100 pour UEFN.
Après chaque étape : compile le Verse, vérifie 0 erreur, résume ce que tu as
placé, puis attends ma validation avant de continuer.
```

## 1. Import Verse
```
Crée dans le projet les 9 fichiers Verse à partir de CityHeist_PoliceVsVoleurs/
Verse/ (TeamSetup, HUDManager, WantedLevelManager, PrisonManager,
LootDepositManager, RobberyZone, ConvoyManager, ArrestManager, GameManager),
puis lance "Build Verse Code". Corrige les erreurs de compilation liées aux
noms d'API en te basant sur le digest UEFN courant, sans changer la logique.
Liste les erreurs résolues.
```

## 2. Équipes & spawns
```
Place et configure :
- 2 Team Settings & Inventory : "TeamSettings_Police" (Team index 0, bleu) en
  (-12000,0,100) et "TeamSettings_Voleurs" (Team index 1, orange) en (14000,-8000,100).
- Player Spawners : Spawn_Police_1..2 au commissariat, Spawn_Voleurs_1..2 à la planque.
Respecte Devices_List.md. Confirme les positions.
```

## 3. Managers de base (ordre de branchement)
```
Place les devices Verse dans cet ordre et branche leurs @editable :
1) city_heist_team_setup (PoliceTeamIndex=0, VoleursTeamIndex=1)
2) city_heist_hud_manager + HUD_Broadcast/HUD_Police/HUD_Voleurs (HUD Message)
3) city_heist_wanted_manager + Wanted_StarTracker + Wanted_Alarm_Audio
Branche HUD/TeamSetup là où c'est requis. Compile et confirme.
```

## 4. Zone Banque (braquage)
```
Place la Banque en (0,0,0). Ajoute Bank_CaptureArea, Bank_VaultDoor (Barrier),
Bank_LootSpawner (Item Spawner "Sac de butin"), Bank_Progress (Tracker max 45),
Bank_Alarm_Audio, Bank_Alarm_VFX. Place city_heist_robbery_zone "Bank"
(RewardPoints=5, RobberySeconds=45, LootType=BankBag) et branche ses 6 devices
+ HUD + Wanted + TeamSetup. Compile.
```

## 5. Bijouterie & Casino
```
Duplique le pattern de braquage pour :
- Bijouterie en (4000,6000,0) : RewardPoints=2, RobberySeconds=12,
  ResetIfInterrupted=true, LootType=Jewelry (+ devices Jewelry_*).
- Casino en (8000,-12000,0) : RewardPoints=3, RobberySeconds=25,
  LootType=CasinoChips, Casino_VaultDoor ouvert par carte d'accès hacker
  (+ devices Casino_*).
Branche chaque zone. Compile.
```

## 6. Dépôt du butin & score
```
Place city_heist_loot_deposit_manager + Deposit_Zone (Capture Area à la planque),
Deposit_VFX, Deposit_Audio, Score_Voleurs (Score Manager, Team 1). Règle les
points Bank=5/Jewelry=2/Casino=3. Branche HUD/Wanted/TeamSetup. Compile.
```

## 7. Prison
```
Place city_heist_prison_manager + Prison_TP_In (Teleporter vers cellule),
Prison_TP_Out (retour ville), Prison_CellBarrier, Prison_EscapeButton (bouton
caché), Prison_RescueZone (Capture Area), Prison_Timer (30s). Branche
HUD/Wanted/TeamSetup. Compile.
```

## 8. Arrestation (ArrestManager)
```
Place city_heist_arrest_manager. Branche Prison/TeamSetup/HUD.
Active UseEliminationMode=true et UseCuffMode=true. Pour le menottage, place
Cuff_Zone_1..3 (Capture Area aux sorties de braquage/barrages), Cuff_SlowMutator
(Mutator Zone ralentissant les voleurs) et Cuff_Audio. Compile.
```

## 9. Wanted Level complet
```
Complète city_heist_wanted_manager : branche Wanted_Drone_VFX (3★, désactivé au
départ), Wanted_SwatGranter (Item Granter SWAT, 4★) et Wanted_ExitBarrier_1..3
(Barrier, 5★, fermeture 25s). Vérifie ResetStars au début de manche. Compile.
```

## 10. Convoi final mobile (ConvoyManager)
```
Place city_heist_convoy_manager. Crée 4 Capture Areas "Convoy_Waypoint_1..4" le
long de la route principale (du commissariat vers la planque) et liste-les dans
l'ordre dans Waypoints. Branche Convoy_Vehicle (Vehicle Spawner Armored Battle
Bus), Convoy_Audio, Convoy_Progress (Tracker), HUD/Wanted/TeamSetup.
SecondsPerSegment=18, VoleursHoldToLoot=12, StarsOnStart=2. Compile.
```

## 11. GameManager (orchestrateur)
```
Place city_heist_game_manager et branche TOUS les managers : HUD, TeamSetup,
Wanted, Prison, LootDeposit, Convoy, Arrest + les 3 zones (BankZone, JewelryZone,
CasinoZone) + Round_Timer, EndGame, Score_Police, Convoy_* (fallback).
Règle RoundTimeSeconds=900, ConvoyTriggerSecondsBeforeEnd=180,
UseConvoyManager=true, VoleursWinScore=20, PoliceWinIfArrestsReach=8. Compile.
```

## 12. Mobilité & monde
```
Ajoute : Vehicle_Police_1..2 (garage commissariat), Vehicle_Getaway (garage
planque), les téléporteurs d'égouts (raccourcis voleurs, par paires), le parking
souterrain sous la banque, le quartier résidentiel (4 maisons instanciées),
supérette + station essence, et 3 barricades police aux points de contrôle.
```

## 13. Ambiance nuit & finitions
```
Passe la map en ambiance nuit : lumières bleues (police), orange (voleurs),
néons casino/bijouterie. Ajoute des kill volumes autour de la map. Vérifie le
budget mémoire (Project Memory < 100%). Instancie les meshes répétés.
```

## 14. Test
```
Lance une session de test (Launch Session) à 2 joueurs/bots. Vérifie : spawns,
alarme au braquage, ouverture coffre, dépôt = points, arrestation → prison 30s →
évasion, convoi à T-3min, fin de manche. Rapporte les logs [CityHeist] et tout
bug observé.
```

---

## Rappel ordre de branchement Verse
`team_setup → hud → wanted → prison → loot_deposit → arrest → 3× robbery_zone →
convoy → game_manager`. Ne branche le GameManager qu'en dernier (il référence
tout le reste).
