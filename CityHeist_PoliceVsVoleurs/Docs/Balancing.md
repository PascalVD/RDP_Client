# Équilibrage — CITY HEIST

> Toutes ces valeurs sont des **points de départ**. Ajustez après playtest
> (voir section « Boucle d'équilibrage »).

## 1. Économie de points

| Action | Équipe | Points | Difficulté/temps |
|--------|--------|--------|------------------|
| Braquage Bijouterie + dépôt | Voleurs | **2** | rapide (12 s) |
| Braquage Casino + dépôt | Voleurs | **3** | moyen (25 s, carte d'accès) |
| Braquage Banque + dépôt | Voleurs | **5** | long (45 s) |
| Piller le convoi | Voleurs | **5** | événement final |
| Arrestation d'un voleur | Police | **1** | continu |
| Escorte du convoi | Police | **5** | événement final |
| Empêcher un dépôt (interception) | Police | indirect | retire le butin |

**Cibles de victoire (réglables dans GameManager) :**
- Voleurs : **20 points** (≈ 4 braquages réussis ou mix + convoi).
- Police : **8 arrestations**.
- À l'écoulement du temps : Voleurs gagnent si `ScoreVoleurs > Arrestations × 2`.

> Le facteur **×2** rend une arrestation « équivalente » à 2 pts de butin.
> Augmentez-le si la police perd trop souvent ; baissez-le sinon.

## 2. Classes & équipement

### POLICE (Team 0)

| Classe | Vie | Vitesse | Armes / outils | Notes |
|--------|-----|---------|----------------|-------|
| **Patrol** | 120 | 1.00 | Pistolet, Fusil tactique, **Stun** (ralentit) | classe de base |
| **SWAT** | 150 | 0.85 | Fusil lourd, **Bouclier**, grenades | **débloqué à 4★** via Verse |

- Véhicule police (`Vehicle_Police`) : rapide, sert aux poursuites/barrages.

### VOLEURS (Team 1)

| Classe | Vie | Vitesse | Armes / outils | Notes |
|--------|-----|---------|----------------|-------|
| **Braqueur** | 100 | 1.00 | SMG, **Fumigène** | dégâts soutenus, couverture |
| **Hacker** | 100 | 1.05 | Grappler, **Carte d'accès**, **Kit piratage** | ouvre Casino VIP, accélère banque |
| **Éclaireur** | 80 | 1.15 | Pistolet léger, sprint | repère, distrait, peu armé |

- Véhicule de fuite (`Vehicle_Getaway`) : pour ramener le butin vite.

## 3. Timers de référence

| Élément | Valeur | Réglage |
|---------|--------|---------|
| Manche | 600–900 s | `RoundTimeSeconds` |
| Braquage Banque | 45 s | `RobberySeconds` (Bank) |
| Braquage Casino | 25 s | `RobberySeconds` (Casino) |
| Braquage Bijouterie | 12 s | `RobberySeconds` (Jewelry) |
| Détention prison | 30 s | `DetentionSeconds` |
| Convoi (déclenchement) | T-180 s | `ConvoyTriggerSecondsBeforeEnd` |
| Convoi (tenue voleurs) | 20 s | `RequiredHold` (ResolveConvoy) |
| Décroissance Wanted | 45 s sans crime → -1★ | `DecaySeconds` |
| Fermeture sorties 5★ | 25 s | `ExitLockSeconds` |

## 4. Multiplicateur de braquage à plusieurs
Progression = `1.0 + 0.25 × (nb_voleurs_dans_zone - 1)`.
→ 1 voleur : 100 % vitesse ; 3 voleurs : 150 %. Encourage le jeu d'équipe
sans rendre les braquages triviaux. Plafonnez à 4 voleurs si besoin.

## 5. Recommandations selon le nombre de joueurs

| Joueurs | Police | Voleurs | Ajustements |
|---------|--------|---------|-------------|
| 4 | 2 | 2 | Banque seule un peu longue → 35 s |
| 6–8 | 3–4 | 3–4 | valeurs par défaut |
| 10–12 | 5–6 | 5–6 | `PoliceWinIfArrestsReach` = 12 |
| 14–16 | 7–8 | 7–8 | `VoleursWinScore` = 28, plafond braquage = 4 |

## 6. Boucle d'équilibrage (playtest)
1. Jouez 2–3 manches complètes.
2. Notez : durée moyenne des braquages réels, nombre d'arrestations, qui gagne.
3. Si **les voleurs dominent** : ↑ timers braquage, ↑ effets Wanted (3★ drones),
   ↓ vitesse butin (retirer le véhicule de fuite), ↑ `RequiredHold` convoi.
4. Si **la police domine** : ↓ timers braquage, ↑ raccourcis égouts, ↓ détention
   à 20 s, ↑ portée fumigène, retarder le SWAT (5★ au lieu de 4★).
5. Visez ~55 % victoires voleurs (rôle plus « actif » et fun à jouer).
