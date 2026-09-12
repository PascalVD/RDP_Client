# FIVE RIFTS: SURVIVAL — couche de règles Verse (mode SOLO)

Projet UEFN : `D:\Projets\Fortnite MAP1\RIFT_DUO_1918` (sur ta machine).
Ce dossier contient la **couche de règles Verse** du tournoi, alignée sur
`PROJECT-HANDOFF-FIVE-RIFTS-SURVIVAL.md`, **en mode SOLO / individuel**
(correction de l'auteur : le handoff d'origine décrivait des duos).

## ⚠️ Ce que ce dossier EST / N'EST PAS
- ✅ **EST** : les scripts Verse portables des règles (lobby, 5 rifts, quotas,
  zone, HUD, classement, pièces d'or) + docs + dashboard/état.
- ❌ **N'EST PAS** : la géométrie des cartes. **Neon Future existe déjà à ~92 %**
  dans ton UEFN (1 478 acteurs). Ashford 1918 est en V15. On ne régénère
  **rien** : règle #5 du handoff (utiliser les assets présents, ne rien
  inventer). Les scripts référencent des devices via `@editable`, jamais un
  chemin d'asset inventé.
- ❌ Cette session cloud **ne peut pas** ouvrir ton UEFN ni ton disque D:. Le
  placement, le Map Check et le Play test se font **en local** (ton Claude
  Code + MCP UEFN sur `http://127.0.0.1:8000/mcp`).

## Mode de jeu (SOLO)
1. Lobby commun → **20 s** de compte à rebours → choix individuel d'armes/accessoires
   (kit par défaut si aucun choix).
2. Carte 1 : jusqu'à **100 joueurs** individuels.
3. Chaque rift : zone qui **rétrécit** (préavis HUD + audio, dégâts hors zone).
4. Quand les survivants ≤ **quota** (`SurvivorPercent` % des entrants, calculé
   sur le **nombre réel** au lancement), les survivants passent au rift suivant
   via un **sas** (soin, nettoyage, nouveau choix, téléport, départ synchro).
5. Éliminé = spectateur (jamais recompté, jamais réintroduit).
6. **Rift 5 = arène finale** : jusqu'au **dernier survivant**.
7. **Pièces d'or** attribuées selon le classement final (1er = plus gros butin).

Chaîne nominale à 100 joueurs avec 50 % : `100 → 50 → 25 → 13 → 7 → 1`.
Tout est réglable par rift (`SurvivorPercent`, `MinSurvivors`, `MaxRoundSeconds`).

## Fichiers Verse
| Script | Device Verse | Rôle |
|---|---|---|
| `SurvivalDirector.verse` | `five_rifts_director` | Orchestre lobby → 5 rifts → classement → pièces |
| `RiftController.verse` | `five_rifts_controller` | 1 par carte : entrée, zone, quota, clôture |
| `ZoneManager.verse` | `five_rifts_zone` | Zone par paliers, préavis, dégâts |
| `LobbyLoadout.verse` | `five_rifts_lobby` | Lobby 20 s, choix d'équipement, sas |
| `HUDManager.verse` | `five_rifts_hud` | Carte X/5, survivants, quota, zone, messages |
| `CoinRewardManager.verse` | `five_rifts_coins` | Pièces d'or par rang |

## Installation dans TON projet (en local, via ton Claude Code + MCP)
1. Copie les `.verse` dans `RIFT_DUO_1918\Content\Rules-V1\` (ou dossier Verse au choix).
2. UEFN → **Build Verse Code**. Ajuste les noms d'API si ta version diffère
   (logique inchangée).
3. Place **1** `five_rifts_director`, **1** `five_rifts_lobby`, **1** `five_rifts_hud`,
   **1** `five_rifts_coins`, et **1** `five_rifts_controller` + **1** `five_rifts_zone`
   **par carte** (5×). Le controller de la 5e carte : `IsFinalArena = true`.
4. Branche les `@editable` : téléporteurs d'entrée par rift, spectateur, barrières,
   timers, anneaux de dégâts (`DamageRings`, du plus large au plus serré),
   kits/boutons d'équipement, granter de pièces.
5. **Sauvegarde**, **Map Check**, puis **Play test** multi-joueurs (quota, zone,
   transitions, compteur, pièces). Ne déclare rien terminé avant Play.

## Brief à coller dans ton Claude Code local
> Lis `outputs/PROJECT-HANDOFF-FIVE-RIFTS-SURVIVAL.md`. **Le mode est SOLO**
> (pas duos). Importe les scripts de `FIVE_RIFTS_SURVIVAL/Verse/`, compile,
> place les devices selon `README_FR.md`, branche les `@editable` avec les
> devices **réellement présents** (ne rien inventer), sauvegarde, Map Check,
> Play test. Mets à jour `PROJECT-LIVE-STATE.json` et le dashboard avec des
> chiffres **observés**.

## Dashboard & état
- `outputs/PROJECT-LIVE-STATE.json` — état du projet (observé vs à vérifier).
- `outputs/five-rifts-live-dashboard.html` — dashboard visuel.
Règle : **chiffres observés uniquement** ; tout ce que cette session n'a pas
pu vérifier en UEFN est marqué « à vérifier en local ».
