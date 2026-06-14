# Checklist d'assemblage pas à pas — CITY HEIST

Suivez dans l'ordre. Cochez au fur et à mesure. Deux paliers : **MVP** (jouable
vite) puis **version complète**.

---

## PHASE 0 — Préparation
- [ ] UEFN installé, projet **Blank** créé (`CityHeist`).
- [ ] Blender installé, blockout généré (`Blockout_3D/README_Blender.md`).
- [ ] FBX importé dans UEFN (`UEFN_Import_Guide.md`), échelle vérifiée.
- [ ] Les 7 scripts Verse copiés + **Build Verse Code** OK (0 erreur).

---

## PHASE 1 — MVP JOUABLE (≈ 30 devices, ~1–2 h)
But : une boucle complète **Banque → fuite → arrestation/prison → dépôt → score → fin**.

### Équipes & spawns
- [ ] `TeamSettings_Police` (index 0) + `TeamSettings_Voleurs` (index 1).
- [ ] `Class_Patrol`, `Class_Robber` (les 2 classes de base suffisent au MVP).
- [ ] `Granter_Police_Base`, `Granter_Robber`.
- [ ] `Spawn_Police_1..2` (commissariat), `Spawn_Voleurs_1..2` (planque).

### Managers de base
- [ ] Placer `city_heist_team_setup` → renseigner index 0/1 + class switchers.
- [ ] Placer `city_heist_hud_manager` + `HUD_Broadcast`, `HUD_Police`, `HUD_Voleurs`.
- [ ] Placer `city_heist_wanted_manager` + `Wanted_StarTracker`, `Wanted_Alarm_Audio`
      (laisser drone/SWAT/barrières vides pour le MVP).

### Banque (1 RobberyZone)
- [ ] `Bank_CaptureArea`, `Bank_VaultDoor`, `Bank_LootSpawner`, `Bank_Progress`,
      `Bank_Alarm_Audio`, `Bank_Alarm_VFX`.
- [ ] Placer `city_heist_robbery_zone` (Bank) → RewardPoints=5, RobberySeconds=45,
      brancher ses 6 devices + HUD + Wanted + TeamSetup.

### Dépôt & prison
- [ ] `city_heist_loot_deposit_manager` + `Deposit_Zone`, `Deposit_VFX`,
      `Deposit_Audio`, `Score_Voleurs`.
- [ ] `city_heist_prison_manager` + `Prison_TP_In`, `Prison_TP_Out`,
      `Prison_CellBarrier`, `Prison_EscapeButton`, `Prison_RescueZone`, `Prison_Timer`.

### Manche
- [ ] `city_heist_game_manager` + `Round_Timer`, `EndGame`, `Score_Police`.
      (Laisser Convoy_* vides au MVP, ou désactiver l'événement.)
- [ ] Brancher dans le GameManager : HUD, TeamSetup, Wanted, Prison, LootDeposit,
      BankZone (réutiliser BankZone pour Jewelry/Casino temporairement ou laisser
      vides si le code tolère — sinon dupliquer la zone).

### Test MVP
- [ ] Launch Session 2 joueurs : braquer la banque, déposer, vérifier +5.
- [ ] Se faire arrêter → prison 30 s → retour ville.
- [ ] Fin de manche déclenchée (score ou temps).
- [ ] **➡ Publier v0.1** si stable (`Publishing_Checklist.md`).

---

## PHASE 2 — VERSION COMPLÈTE

### Zones de braquage restantes
- [ ] **Bijouterie** : 2e `RobberyZone` (2 pts, 12 s, ResetIfInterrupted=true)
      + devices `Jewelry_*`.
- [ ] **Casino** : 3e `RobberyZone` (3 pts, 25 s) + devices `Casino_*` +
      carte d'accès hacker pour `Casino_VaultDoor`.
- [ ] Brancher les 3 zones dans le GameManager (Bank/Jewelry/Casino).

### Classes & équipement complets
- [ ] `Class_Swat`, `Class_Hacker`, `Class_Scout` + leurs Item Granters.
- [ ] `Switcher_Swat` / `Wanted_SwatGranter` branchés au WantedLevelManager.

### Wanted Level complet
- [ ] `Wanted_Drone_VFX` (3★), `Wanted_SwatGranter` (4★),
      `Wanted_ExitBarrier_1..3` (5★) branchés.

### Mobilité & monde
- [ ] Véhicules : `Vehicle_Police_1..2`, `Vehicle_Getaway`.
- [ ] Égouts : `Sewer_TP_*` (raccourcis voleurs) + meshes d'entrée.
- [ ] Parking souterrain accessible + connexion égouts.
- [ ] Quartier résidentiel (4 maisons instanciées) + supérette + station.
- [ ] Barrages police `Mutator_StunZone` / barricades aux points de contrôle.

### Arrestation avancée (ArrestManager)
- [ ] Placer `city_heist_arrest_manager` → brancher Prison, TeamSetup, HUD.
- [ ] Mode menottage : `Cuff_Zone_*`, `Cuff_SlowMutator`, `Cuff_Audio` branchés.
- [ ] Régler `UseEliminationMode` / `UseCuffMode` (cf. `Docs/Arrest_System.md`).
- [ ] Brancher `Arrest` dans le GameManager.

### Convoi final mobile (ConvoyManager)
- [ ] Placer `city_heist_convoy_manager` → brancher HUD, Wanted, TeamSetup.
- [ ] Placer 3–6 `Convoy_Waypoint_*` (Capture Area) **dans l'ordre** du trajet
      → liste `Waypoints`. Brancher `Convoy_Vehicle`, `Convoy_Audio`, `Convoy_Progress`.
- [ ] (Option B) Remplir `Convoy_WaypointTP_*` ; (Option A) animer via Cinematic Sequence.
- [ ] Brancher `Convoy` dans le GameManager + `UseConvoyManager = true`.
- [ ] Vérifier déclenchement à T-3 min et résolution Police/Voleurs (+5).
- [ ] (Fallback MVP) `Convoy_CaptureArea` + `UseConvoyManager = false` si convoi statique.

### Ambiance nuit
- [ ] Lumières bleues (police), orange (voleurs), néons (casino/bijouterie).
- [ ] Skybox/heure de nuit, brouillard léger, post-process contrasté.

### Finitions
- [ ] Kill volumes autour de la map (anti-sortie).
- [ ] Équilibrage sur ≥ 3 playtests (`Balancing.md`).
- [ ] Optimisation mémoire (`Publishing_Checklist.md` section A).
- [ ] **➡ Publier v1.0**.

---

## Ordre de branchement Verse (important)
1. `team_setup` → 2. `hud_manager` → 3. `wanted_manager` → 4. `prison_manager`
→ 5. `loot_deposit_manager` → 6. les 3 `robbery_zone` → 7. `game_manager`
(référence tout le reste). Brancher dans cet ordre évite les références vides.
