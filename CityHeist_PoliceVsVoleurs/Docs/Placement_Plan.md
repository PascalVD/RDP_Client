# Plan de placement — CITY HEIST

Échelle : **1 unité = 1 mètre**. Dans UEFN, 1 m = 100 unités Unreal (cm).
Multipliez donc ces coordonnées par **100** pour les saisir dans le panneau
*Transform* d'UEFN (ou importez le FBX qui contient déjà les positions).

L'origine (0,0) est le centre de la ville = **Banque**.

## Coordonnées des zones (mètres)

| Zone | X | Y | Z | Largeur×Profondeur×Hauteur | Ambiance |
|------|---|---|---|----------------------------|----------|
| Commissariat | -120 | 0 | 0 | 28×22×9 | Bleu police |
| Prison | -120 | -40 | 0 | 22×18×7 | Bleu police |
| Banque (centre) | 0 | 0 | 0 | 34×30×14 | Gris pierre / néon |
| Parking souterrain | 0 | -30 | **-15** | 34×30×4 | Béton |
| Bijouterie | 40 | 60 | 0 | 16×14×7 | Néon rose |
| Casino | 80 | -120 | 0 | 30×26×12 | Néon |
| Planque des voleurs | 140 | -80 | 0 | 24×20×8 | Orange |
| Quartier résidentiel | 150→168 | 80→98 | 0 | 4 maisons 12×10×6 | Maison |
| Supérette | 60 | 10 | 0 | 14×12×6 | Néon |
| Station essence | 64 | -8 | 0 | 18×8×5 | Béton |

## Schéma ASCII (vue de dessus, Nord = +Y)

```
                          +Y (Nord)
                            |
                  [Bijouterie]      [Quartier résidentiel]
                    (40,60)            (150-168, 80-98)
                            |
  [Commissariat]   [Supérette]
   (-120,0)         (60,10)
 ------ROUTE PRINCIPALE (E-O)-----[BANQUE]----------------------  +X (Est)
                   (0,0)  [Station ess.] (64,-8)
                            |
  [Prison]         [Parking SS]        [Planque voleurs]
  (-120,-40)        (0,-30, z=-15)      (140,-80)
                            |
                       [Casino]
                       (80,-120)
                            |
                          -Y (Sud)
```

## Réseau routier (assez large pour véhicules, 10–12 m)
- **Route principale** E-O : passe par la Banque, relie Commissariat ↔ Planque.
- **Route verticale** N-S : Bijouterie ↔ Banque ↔ Casino.
- **Bretelle Casino** : descend vers (80,-120).
- **Bretelle Planque** : (140,-40)→(140,-80).
- **Rue résidentielle** : dessert les 4 maisons.

## Égouts (tunnels souterrains, z ≈ -4)
Relient par téléporteurs/passages :
- Banque (18,-10) ↔ Parking (5,-28)
- Parking ↔ Planque (125,-78)
- Planque ↔ Quartier (152,70)
- Casino (95,-110) ↔ réseau central

Ce sont les **raccourcis voleurs**. La police n'y a pas d'accès rapide
(points de contrôle en surface seulement).

## Points de contrôle police (barrages)
- Centre-ville (30, 6)
- Sud Banque (0, -20)
- Accès Casino (80, -90)

## Spawns
- Police : Commissariat (-120, 0).
- Voleurs : Planque (140, -80).
- Prison (téléport) : (-120, -40).
- Retour ville après prison : (-100, -20).
