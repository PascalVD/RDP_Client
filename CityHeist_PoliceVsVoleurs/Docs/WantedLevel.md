# Système Wanted Level (Niveau de recherche) — CITY HEIST

Géré par `Verse/WantedLevelManager.verse`. Le niveau est **global** aux
voleurs (échelle 1→5 étoiles) et affiché via `Wanted_StarTracker`.

## Échelle et effets

| Étoiles | Déclencheur typique | Effet en jeu | Device(s) |
|--------|---------------------|--------------|-----------|
| ★ 1 | 1er braquage commencé | **Alerte police** : son d'alarme + HUD | `Wanted_Alarm_Audio` |
| ★★ 2 | 2e crime / butin pris | **Localisation approximative** des voleurs pour la police (ping zone) | Tracker police (ping) |
| ★★★ 3 | braquage banque / casino | **Caméras / drones activés** (VFX, vision ville) | `Wanted_Drone_VFX` |
| ★★★★ 4 | escalade continue | **SWAT débloqué** : équipement lourd accordé à la police | `Wanted_SwatGranter` |
| ★★★★★ 5 | apogée du chaos | **Certaines sorties se ferment** 25 s (barrières) | `Wanted_ExitBarrier_*` |

## Montée / descente
- **Montée** : `AddStars(n)` appelé par les braquages (`StarsOnStart`, défaut 1)
  et par le convoi (+2). Chaque palier franchi applique son effet **une fois**.
- **Descente** :
  - Dépôt de butin réussi : -1★ (les voleurs se font discrets).
  - Interception du porteur : -1★ (butin perdu).
  - **Decay** : 45 s sans nouveau crime → -1★ (`DecaySeconds`).
- `ResetStars()` est appelé en début de manche.

## Détails d'implémentation
- À **4★**, le script parcourt les joueurs police et appelle
  `SwatGranter.GrantItem(Player)` → ils reçoivent l'équipement SWAT.
  Optionnellement, basculez-les via `TeamSetup.SwitchToClass(P, Swat)`.
- À **5★**, `LockExitsTemporarily()` active les `ExitBarriers` pendant
  `ExitLockSeconds`, puis les désactive. Placez ces barrières sur les
  **sorties principales de la ville** (pas les égouts, pour laisser une issue).
- L'événement `StarsChanged(int)` est diffusé : le GameManager (ou un device
  HUD) peut y réagir pour des messages contextuels.

## Conseils d'équilibrage
- Si la police peine, déclenchez le SWAT à **3★** (changez le `case`).
- Si les voleurs se sentent étouffés, augmentez `DecaySeconds` à 60 s et
  ne fermez qu'**une** sortie à 5★.
- Pour un mode « hardcore », désactivez le decay (`DecayEnabled = false`).
