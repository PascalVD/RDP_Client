# Alignement avec le handoff FIVE RIFTS: SURVIVAL

Ce document dit **exactement** ce qui a été respecté, ce qui a été changé
sur instruction de l'auteur, et ce que cette session cloud **n'a pas pu
faire** (à réaliser en local).

## 1. Correction majeure demandée par l'auteur : mode SOLO
| Handoff d'origine | Décision (instruction auteur) |
|---|---|
| 100 joueurs en **50 duos**, partenaire qui relève, duo éliminé quand les 2 sont out, partenaire → spectateur du duo | **Tout le monde en individuel** (chacun pour soi). Éliminé = spectateur. |
| Chaîne `50 duos → 24 → 12 → 6 → 2 → 1 duo` | Chaîne par **% de survivants** par rift (défaut 50 %) : `100 → 50 → 25 → 13 → 7 → 1`. |
| Accroche « 1 winning duo » | À réviser : ex. « 100 players. 5 maps. 1 survivor. » |
| Récompense non précisée | **Pièces d'or** par classement final (1er = max, dégressif). |

⚠️ **À basculer en local** si le projet UEFN était déjà en duos : Team Settings
(solo), textes/HUD « duo/partenaire », accroche de publication.

## 2. Respecté tel quel (handoff)
- 5 cartes dans l'ordre : Ashford 1918 → Neon Future → Black Sand Front →
  Whiteout Bastion → Drowned Foundry ; la 5e = arène finale.
- Lobby commun + **20 s** + choix individuel d'armes/accessoires + option
  par défaut ; pas d'avantage caché entre cartes (sas rééquipe tout le monde).
- Quotas calculés au **lancement sur le nombre réel** de joueurs.
- Une déconnexion **ne réintroduit jamais** un éliminé (ordre d'élimination
  = source de vérité, spectateurs jamais recomptés).
- Zone propre à chaque carte, **rétrécissement** par paliers, préavis HUD +
  audio, dégâts croissants, réinitialisée à chaque transition.
- HUD : carte X/5, temps, survivants, quota, zone, messages
  qualification/élimination/départage.
- Éliminations simultanées **regroupées** (évaluation du quota sur tick 0,5 s).
- Départage en cas de blocage/temps écoulé : message + clôture (l'ordre
  éliminations → dégâts → tirage est documenté ; le tirage prédéfini reste
  à câbler côté données de partie).
- Serveur = autorité (toute la logique est côté device Verse).
- Tir allié / construction : réglages Team Settings (hors Verse).

## 3. Volontairement NON fait (et pourquoi)
- **Aucune géométrie régénérée.** Neon Future est à ~92 % (1 478 acteurs) et
  Ashford 1918 en V15 dans ton UEFN. Règle #5 : utiliser l'existant, ne pas
  dupliquer, ne pas inventer de chemin d'asset. Un blockout neuf serait
  hors-spec — l'ancien brouillon d'arène a été **supprimé** du repo.
- **Train, bombardements WWI, coffres** : déjà couverts par tes scripts
  existants (`five_rifts_city_train.verse`, `five_rifts_hidden_chests.verse`,
  `five_rifts_loot_sites.verse`). Non réécrits pour ne pas créer de doublons.

## 4. Ce que cette session cloud n'a PAS pu observer
Conformément à la règle #10 (chiffres observés uniquement), **rien** de ce
qui suit n'est vérifié par moi, faute d'accès à UEFN / au disque D: :
- état réel des cartes, nombre d'acteurs, PlayerStarts, Map Check, streaming ;
- compilation effective des scripts fournis dans **ta** version d'UEFN ;
- comportement en Play (quota, zone, transitions, compteur, pièces).
Tout ceci est marqué **« à vérifier en local »** dans `PROJECT-LIVE-STATE.json`.

## 5. Méthode obligatoire (handoff 11) — rappel pour le local
Vérifier la carte ouverte via MCP → sauvegarder → inspecter avant d'ajouter →
assets réels uniquement → Map Check (erreurs puis avertissements) → Play test →
dashboard avec chiffres observés → documenter les limites + nom exact de la
carte testée.
