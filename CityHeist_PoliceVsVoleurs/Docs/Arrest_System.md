# Système d'arrestation — CITY HEIST

Géré par `Verse/ArrestManager.verse`, qui **détecte** les arrestations et
délègue la suite (prison, score, perte du butin) au `PrisonManager` et au
`GameManager`. Deux modes, activables indépendamment (`UseEliminationMode`,
`UseCuffMode`).

## Mode A — Élimination (arcade, direct)
- Quand un **policier élimine un voleur**, au lieu d'un simple respawn le voleur
  est **arrêté** → téléporté en prison (30 s).
- Implémentation : abonnement à `EliminatedEvent` de chaque personnage ; on
  vérifie que la victime est un voleur, puis `Prison.ArrestAgent(Victim)`.
- Avantage : aucune zone à placer, fonctionne partout.
- Inconvénient : moins « roleplay » (létal).

> Conseil : réglez le respawn de l'équipe Voleurs sur **OFF/long**, car la
> prison gère le retour en jeu. Sinon le joueur peut réapparaître avant le
> téléport.

## Mode B — Menottage (tactique, non létal)
- Un **policier menotte** un voleur en restant à côté de lui dans une
  **CuffZone** (Capture Area) pendant `CuffSeconds` (défaut 3 s).
- Le voleur est **ralenti** par un **Mutator Zone** (`SlowMutator`) tant qu'il
  est dans la zone, ce qui rend le menottage possible.
- Conditions vérifiées en boucle :
  - le voleur est toujours dans une CuffZone ;
  - au moins un policier est à `CuffMaxDistance` (défaut 350 cm) du voleur.
- À `CuffSeconds` atteints → son de menottage + `Prison.ArrestAgent`.
- Avantage : style « Police vs Voleurs » crédible, pas besoin de tuer.
- Inconvénient : nécessite des zones de menottage placées aux bons endroits
  (sorties de braquage, barrages, planque).

## Devices à placer pour le mode menottage
| Nom exact | Device | Rôle |
|-----------|--------|------|
| `Cuff_Zone_1..n` | Capture Area | zones où l'on peut menotter |
| `Cuff_SlowMutator` | Mutator Zone | ralentit les voleurs dans la zone |
| `Cuff_Audio` | Audio Player | son de menottage |

Branchez-les sur les `@editable` du `city_heist_arrest_manager` : `CuffZones`,
`SlowMutator`, `CuffAudio`.

## Recommandations
- **Mix recommandé** : activez les **deux** modes. Le menottage donne le ton
  RP ; l'élimination sert de filet (un voleur acculé finit en prison même sans
  zone). Réglez les dégâts pour rendre l'élimination rare (armes peu létales).
- Pour un mode 100 % non létal : `UseEliminationMode = false` et désactivez les
  dégâts létaux entre équipes (Team Settings / armes stun uniquement).
- `CuffMaxDistance` est en **cm** (échelle Unreal) : 350 ≈ 3,5 m.

## Flux complet
```
Détection (élim. OU menottage)  ->  ArrestManager
        -> Prison.ArrestAgent(Voleur)
              -> téléport cellule + timer 30s   (PrisonManager)
              -> AgentArrested  -> GameManager : +1 Police, butin retiré
                                -> évasion possible (bouton / sauvetage)
```
