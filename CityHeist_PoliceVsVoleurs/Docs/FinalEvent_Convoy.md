# Événement final — Le Convoi blindé — CITY HEIST

Géré dans `GameManager.verse` (`TriggerConvoyEvent` / `ResolveConvoy`).

## Déclenchement
- À **T-3:00** de la fin de manche (`ConvoyTriggerSecondsBeforeEnd = 180`).
- Annonce sonore (`Convoy_Audio`) + HUD global :
  *« CONVOI BLINDÉ ! Voleurs : attaquez-le. Police : escortez-le. +5 points. »*
- Le **Wanted Level** monte de +2★ (tension maximale).
- Le véhicule blindé apparaît (`Convoy_Vehicle`, Armored Battle Bus) sur la
  route principale et constitue l'objectif mobile.

## Règle de résolution
Une **Capture Area** (`Convoy_CaptureArea`) entoure le convoi.

- Tant que **plus de voleurs que de policiers** sont dans la zone, un compteur
  de « tenue » monte (0.5 s par tick).
- Si la présence police domine, le compteur **redescend**.
- **Voleurs gagnent l'événement** s'ils atteignent **20 s de tenue cumulée**
  (`RequiredHold`) → **+5 points Voleurs** (« convoi pillé »).
- Sinon (temps écoulé / police garde le contrôle) → **+5 points Police**
  (« convoi escorté »).

## Variantes possibles (selon ambition)
1. **Convoi mobile réel** : faites suivre un trajet au véhicule via une
   séquence de Teleporters/Trigger ou un *Patrol Path* ; déplacez la Capture
   Area par étapes (plusieurs zones successives activées le long du parcours).
2. **Coffre du convoi** : remplacez la Capture Area par une `RobberyZone`
   supplémentaire montée sur le point d'arrivée du convoi (butin +5).
3. **Multi-vagues** : à 16 joueurs, faites spawn 2 convois espacés de 60 s.

## Devices nécessaires
| Device | Rôle |
|--------|------|
| `Convoy_Vehicle` (Vehicle Spawner – Armored Battle Bus) | le convoi |
| `Convoy_CaptureArea` (Capture Area) | mesure le contrôle |
| `Convoy_Audio` (Audio Player) | annonce |
| `HUD_Broadcast` | message global |

## Équilibrage
- `RequiredHold` = 20 s : ↑ si les voleurs raflent trop facilement, ↓ sinon.
- Le +2★ rend la fin nerveuse (drones/SWAT actifs) ; retirez-le pour une fin
  plus calme.
- Faites coïncider la récompense (5 pts) avec un braquage banque pour que
  l'événement soit un vrai « tout ou rien » décisif.
