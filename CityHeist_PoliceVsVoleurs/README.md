# 🌃 CITY HEIST – POLICE VS VOLEURS

Projet **Fortnite UEFN** complet (préparatoire) pour une map **Police vs
Voleurs** : ville de nuit stylisée, braquages, prison, niveau de recherche,
convoi blindé final et système de score.

> 🎯 4 à 16 joueurs · manche de 10–15 min · 2 équipes (Police / Voleurs).

## ⚠️ Honnêteté technique
Un fichier `.umap` UEFN **ne peut pas être généré hors d'UEFN**. Ce dépôt
fournit donc **tout le matériel préparatoire** pour assembler la map vous-même :
scripts Verse, générateur de blockout 3D, liste de devices, documentation et
checklists d'assemblage. Rien d'inventé : chaque pièce est utilisable.

## 📁 Contenu
| Dossier | Contenu |
|---------|---------|
| `Verse/` | 7 scripts Verse (GameManager, RobberyZone, PrisonManager, WantedLevelManager, LootDepositManager, TeamSetup, HUDManager) |
| `Blockout_3D/` | `generate_blockout.py` (Blender) → FBX/GLB de toute la ville |
| `Devices/` | Liste complète (~70 devices) : noms, positions, params, scripts liés |
| `Docs/` | README FR, plan de placement, boucle de jeu, équilibrage, wanted level, convoi, checklist de publication |
| `Build_Instructions/` | Guide d'import UEFN + checklist d'assemblage pas à pas (MVP → complet) |
| `Images/` | `layout_map.svg` — plan visuel de la ville |

## 🚀 Par où commencer
1. Lisez **`Docs/README_FR.md`** (vue d'ensemble + FAQ).
2. Générez le blockout : **`Blockout_3D/README_Blender.md`**.
3. Importez dans UEFN : **`Build_Instructions/UEFN_Import_Guide.md`**.
4. Assemblez : **`Build_Instructions/Assembly_Checklist.md`** (commencez par le MVP).
5. Équilibrez puis publiez : **`Docs/Balancing.md`** + **`Docs/Publishing_Checklist.md`**.

## 🗺️ Aperçu de la ville
Voir `Images/layout_map.svg`.
- Commissariat (gauche) · Banque (centre) · Bijouterie (haut) · Casino (bas)
- Planque voleurs (droite) · Quartier résidentiel (haut-droite)
- Parking souterrain (sous la banque) · Égouts (raccourcis voleurs)

## ✅ Conformité
Aucune marque réelle, aucun logo protégé, aucun asset non autorisé — style
Fortnite, priorité gameplay & performance.
