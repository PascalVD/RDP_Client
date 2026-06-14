# Événement final — Le Convoi blindé — CITY HEIST

Deux implémentations fournies :
- **Convoi MOBILE (recommandé)** : `Verse/ConvoyManager.verse`. Le convoi
  progresse le long d'une série de **waypoints** (Capture Areas successives) ;
  chaque segment est disputé. Activé par défaut (`UseConvoyManager = true`
  dans le GameManager).
- **Convoi statique (fallback MVP)** : logique interne du `GameManager.verse`
  (`TriggerConvoyEvent` / `ResolveConvoy`), une seule zone. Utilisé si
  `UseConvoyManager = false` ou si le ConvoyManager n'est pas branché.

Dans les deux cas, le GameManager attribue **+5** au vainqueur via
`OnConvoyResolved`.

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

## Convoi mobile — comment le câbler (ConvoyManager)
1. Placez 3 à 6 **Capture Areas** le long du trajet (du point de départ au
   point d'arrivée) et listez-les **dans l'ordre** dans `Waypoints`.
2. Mouvement physique du mesh/véhicule, deux options :
   - **A) Cinematic Sequence / Prop Mover** : animez le convoi le long du
     trajet ; le script ne fait que la logique (recommandé pour un rendu
     fluide). Branchez vos séquences sur l'avancée de segment.
   - **B) Teleport par étapes** : remplissez `WaypointTeleporters` (même
     longueur que `Waypoints`) ; le convoi est téléporté de segment en segment.
3. Réglez `SecondsPerSegment` (temps police pour valider un segment) et
   `VoleursHoldToLoot` (tenue voleurs cumulée pour piller).

**Règle :** à chaque segment, si la police domine elle valide le segment et le
convoi avance ; si les voleurs tiennent assez longtemps **à un** segment, ils
pillent le convoi. Convoi arrivé au dernier waypoint = escorte réussie (police).

## Autres variantes possibles
- **Coffre du convoi** : montez une `RobberyZone` sur le point d'arrivée.
- **Multi-vagues** : à 16 joueurs, 2 convois espacés de 60 s.

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
