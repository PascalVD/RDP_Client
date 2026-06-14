# CITY HEIST – POLICE VS VOLEURS — Liste complète des devices UEFN

> Convention : chaque device a un **nom exact** à donner dans l'Outliner
> UEFN (colonne "Label"), pour que les références `@editable` des scripts
> Verse soient faciles à brancher. Les positions sont en **mètres** et
> suivent `Docs/Placement_Plan.md` (multipliez par 100 pour les cm UEFN).

Légende colonne « Script » : indique le device Verse qui pilote/lit ce device.

---

## 1. Configuration équipes & classes

| Nom exact | Device | Position (x,y,z) | Paramètres clés | Script |
|-----------|--------|------------------|-----------------|--------|
| `TeamSettings_Police` | Team Settings & Inventory | (-120, 0, 1) | Team = **0**, Name "Police", couleur bleu, respawn ON, vie 120 | TeamSetup |
| `TeamSettings_Voleurs` | Team Settings & Inventory | (140, -80, 1) | Team = **1**, Name "Voleurs", couleur orange, vie 100 | TeamSetup |
| `Class_Patrol` | Class Designer | (-118, 2, 1) | Classe 0, vitesse 1.0 | TeamSetup |
| `Class_Swat` | Class Designer | (-118, 4, 1) | Classe 1, vitesse 0.85, vie 150 | TeamSetup |
| `Class_Robber` | Class Designer | (142, -78, 1) | Classe 2, vitesse 1.0 | TeamSetup |
| `Class_Hacker` | Class Designer | (142, -76, 1) | Classe 3, vitesse 1.05 | TeamSetup |
| `Class_Scout` | Class Designer | (142, -74, 1) | Classe 4, vitesse 1.15, vie 80 | TeamSetup |
| `Switcher_Swat` | Class & Team Selector | (-118, 6, 1) | Cible classe SWAT, déclenché par Verse | TeamSetup / Wanted |

## 2. Spawns

| Nom exact | Device | Position | Paramètres | Script |
|-----------|--------|----------|------------|--------|
| `Spawn_Police_1..4` | Player Spawner | Commissariat (-120, 0, 1) | Team 0, "Use Team" ON | — |
| `Spawn_Voleurs_1..4` | Player Spawner | Planque (140, -80, 1) | Team 1 | — |
| `Spawn_Prison` | Player Spawner | Prison (-120, -40, 1) | Prioritaire OFF, utilisé via Teleporter | PrisonManager |

## 3. Inventaire / équipement

| Nom exact | Device | Position | Paramètres | Script |
|-----------|--------|----------|------------|--------|
| `Granter_Police_Base` | Item Granter | -120, 0 | Pistolet + fusil tactique + stun (cf. Balancing.md) | classe |
| `Granter_Swat` | Item Granter | -118, 4 | Fusil lourd + bouclier, **grant via Verse** à 4★ | WantedLevelManager |
| `Granter_Robber` | Item Granter | 142, -78 | SMG + fumigène | classe |
| `Granter_Hacker` | Item Granter | 142, -76 | Grappler + kit piratage (item clé) | classe |
| `Granter_Scout` | Item Granter | 142, -74 | Pistolet léger + sprint | classe |

## 4. Zones de braquage (3 instances de `RobberyZone.verse`)

### Banque
| Nom exact | Device | Position | Paramètres | Script |
|-----------|--------|----------|------------|--------|
| `Bank_CaptureArea` | Capture Area | Banque (0, 0, 1) | Team 1 capture, temps interne géré par Verse | RobberyZone (Bank) |
| `Bank_VaultDoor` | Barrier | (0, 4, 1) | Démarre activée (fermée), désactivée à la fin | RobberyZone |
| `Bank_LootSpawner` | Item Spawner | (0, 5, 1) | Objet "Sac de butin", spawn via Verse | RobberyZone / LootDeposit |
| `Bank_Progress` | Tracker | HUD | Max = 45, suit la progression | RobberyZone |
| `Bank_Alarm_Audio` | Audio Player | (0, 0, 6) | Son alarme, 1-shot | RobberyZone |
| `Bank_Alarm_VFX` | VFX Spawner | (0, 0, 6) | Gyrophare rouge | RobberyZone |

### Bijouterie (RewardPoints=2, RobberySeconds=12, ResetIfInterrupted=true)
| `Jewelry_CaptureArea` | Capture Area | (40, 60, 1) | — | RobberyZone (Jewelry) |
| `Jewelry_LootSpawner` | Item Spawner | (40, 61, 1) | "Bijoux" | RobberyZone |
| `Jewelry_Progress` | Tracker | HUD | Max = 12 | RobberyZone |
| `Jewelry_Alarm_Audio` | Audio Player | (40, 60, 5) | — | RobberyZone |

### Casino (RewardPoints=3, RobberySeconds=25)
| `Casino_CaptureArea` | Capture Area | (80, -120, 1) | Salle VIP | RobberyZone (Casino) |
| `Casino_VaultDoor` | Barrier | VIP | Ouverte par carte d'accès (hacker) | RobberyZone |
| `Casino_LootSpawner` | Item Spawner | (80, -119, 1) | "Jetons" | RobberyZone |
| `Casino_Progress` | Tracker | HUD | Max = 25 | RobberyZone |
| `Casino_Alarm_Audio` | Audio Player | (80, -120, 5) | — | RobberyZone |

## 5. Dépôt du butin (LootDepositManager)

| Nom exact | Device | Position | Paramètres | Script |
|-----------|--------|----------|------------|--------|
| `Deposit_Zone` | Capture Area | Planque (140, -80, 1) | Team 1 only | LootDepositManager |
| `Deposit_VFX` | VFX Spawner | (140, -80, 2) | Confettis / lumière verte | LootDepositManager |
| `Deposit_Audio` | Audio Player | (140, -80, 2) | Jingle réussite | LootDepositManager |
| `Score_Voleurs` | Score Manager | global | Award via Verse, Team 1 | LootDepositManager / GameManager |

## 6. Prison (PrisonManager)

| Nom exact | Device | Position | Paramètres | Script |
|-----------|--------|----------|------------|--------|
| `Prison_TP_In` | Teleporter | Cellule (-120, -40, 1) | Destination = cellule, pas de groupe | PrisonManager |
| `Prison_TP_Out` | Teleporter | Rue (-100, -20, 1) | Retour ville après 30s | PrisonManager |
| `Prison_CellBarrier` | Barrier | cellule | Démarre activée | PrisonManager |
| `Prison_EscapeButton` | Button | conduit caché (-124, -44, 1) | Interaction 1.5s, visible OFF par défaut | PrisonManager |
| `Prison_RescueZone` | Capture Area | entrée prison (-114, -40, 1) | Un voleur libre libère les détenus | PrisonManager |
| `Prison_Timer` | Timer | HUD | 30s, par joueur | PrisonManager |

## 7. Niveau de recherche (WantedLevelManager)

| Nom exact | Device | Position | Paramètres | Script |
|-----------|--------|----------|------------|--------|
| `Wanted_StarTracker` | Tracker | HUD | Max = 5, affiche les étoiles | WantedLevelManager |
| `Wanted_Alarm_Audio` | Audio Player | global | 1★ | WantedLevelManager |
| `Wanted_Drone_VFX` | VFX Spawner | ville | 3★, désactivé au début | WantedLevelManager |
| `Wanted_SwatGranter` | Item Granter | -118, 4 | 4★ équipement SWAT (= `Granter_Swat`) | WantedLevelManager |
| `Wanted_ExitBarrier_1..3` | Barrier | sorties ville | 5★, fermeture 25s | WantedLevelManager |

## 8. HUD (HUDManager)

| Nom exact | Device | Position | Paramètres | Script |
|-----------|--------|----------|------------|--------|
| `HUD_Broadcast` | HUD Message | global | Plein écran, tous joueurs | HUDManager |
| `HUD_Police` | HUD Message | global | Team 0 only | HUDManager |
| `HUD_Voleurs` | HUD Message | global | Team 1 only | HUDManager |

## 9. Manche & convoi final (GameManager)

| Nom exact | Device | Position | Paramètres | Script |
|-----------|--------|----------|------------|--------|
| `Round_Timer` | Timer | HUD | 600–900s, affiché | GameManager |
| `EndGame` | End Game | global | Déclenché par Verse | GameManager |
| `Score_Police` | Score Manager | global | Team 0 | GameManager |
| `Convoy_Vehicle` | Vehicle Spawner (Armored Battle Bus) | route principale (20, 0, 1) | Spawn via Verse à T-3min | GameManager |
| `Convoy_CaptureArea` | Capture Area | autour du convoi | Suit le trajet (statique simplifié) | GameManager |
| `Convoy_Audio` | Audio Player | global | Annonce convoi | GameManager |

## 10. Véhicules & mobilité

| Nom exact | Device | Position | Paramètres | Script |
|-----------|--------|----------|------------|--------|
| `Vehicle_Police_1..2` | Vehicle Spawner | Garage commissariat (-115, 0, 1) | Team 0 préféré | — |
| `Vehicle_Getaway` | Vehicle Spawner | Garage planque (138, -80, 1) | Team 1 | — |
| `Mutator_StunZone` | Mutator Zone | configurable | Ralentit les voleurs menottés (option arrestation B) | PrisonManager |
| `Sewer_TP_1..2` | Teleporter | entrées égouts | Raccourcis voleurs (liés par paires) | — |

---

### Récapitulatif des branchements Verse (à faire dans l'onglet Details)
- `city_heist_game_manager` : brancher **tous** les managers + Round_Timer, EndGame, Score_Police, Convoy_*.
- Chaque `city_heist_robbery_zone` : brancher ses 6 devices + HUD + Wanted + TeamSetup.
- `city_heist_prison_manager`, `..._loot_deposit_manager`, `..._wanted_manager`, `..._hud_manager`, `..._team_setup` : voir leurs `@editable` respectifs.

> Total approximatif : **~70 devices**. Pour le **MVP**, vous pouvez n'en
> placer que ~30 (voir `Build_Instructions/Assembly_Checklist.md`, section MVP).
