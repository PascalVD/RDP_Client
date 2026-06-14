# Boucle de jeu détaillée — CITY HEIST

Durée d'une manche : **10 à 15 min** (par défaut 15 min, réglable via
`Round_Timer` et `RoundTimeSeconds` du GameManager).

## 0. Mise en place (0:00)
- Les joueurs sont répartis : **Police** (commissariat) et **Voleurs** (planque).
- Chaque joueur reçoit l'équipement de sa classe (Item Granter).
- HUD : *« Manche lancée ! Voleurs : préparez vos braquages. Police : protégez la ville. »*
- Score Police = 0, Score Voleurs = 0, Wanted = 0★.

## 1. Spawn initial & choix des objectifs (0:00 – 1:00)
- Les voleurs choisissent leur cible : Banque (5 pts, long), Casino (3 pts,
  carte d'accès), Bijouterie (2 pts, rapide), ou objectif secondaire (supérette).
- La police se déploie : garde des bâtiments, patrouilles véhicules, salle caméras.

## 2. Déclenchement de l'alarme (braquage commencé)
- Un voleur entre dans une **Capture Area** de braquage et y reste.
- `RobberyZone.verse` démarre le timer interne (Banque 45s / Casino 25s / Bijouterie 12s).
- **Alarme** (Audio + VFX) + le **Wanted Level** augmente de 1★.
- HUD global : *« ALARME ! Un braquage est en cours. »*

## 3. Capture de zone (le braquage)
- Tant qu'au moins un voleur est dans la zone, la barre de progression
  (`Tracker`) monte. Plusieurs voleurs = progression plus rapide (+25 %/voleur).
- Si la police **vide** la zone :
  - Banque/Casino : le timer **se met en pause** (reprend où il en était).
  - Bijouterie : le timer **se réinitialise** (`ResetIfInterrupted = true`).
- À 100 % : le **coffre s'ouvre** (Barrier off) et le **butin spawn** (Item Spawner).

## 4. Prise du butin
- Un voleur ramasse le sac/bijoux/jetons → `LootDepositManager.PickupLoot`.
- Le porteur est désormais une cible prioritaire. À 2★, sa position devient
  approximative pour la police.

## 5. Poursuite
- Le porteur doit rejoindre la **planque** (zone de dépôt). Il peut :
  - emprunter les **égouts** (raccourcis voleurs),
  - utiliser le **véhicule de fuite** (garage planque),
  - se faire couvrir par ses coéquipiers (fumigènes).
- La police tente d'intercepter via barrages, véhicules, drones (3★).

## 6. Arrestation
- Deux méthodes (au choix dans UEFN — voir PrisonManager) :
  - **A) Élimination** du voleur par la police.
  - **B) Menottage** : le voleur entre stun/ralenti dans un Mutator Zone à
    portée d'un policier.
- `GameManager.OnArrest` → +1 point Police, et **le porteur perd son butin**
  (`RemoveCarriedLoot`).

## 7. Prison
- Le voleur arrêté est **téléporté en cellule** (Teleporter), timer **30 s**.
- HUD perso : *« Vous êtes arrêté ! Direction la prison (30s). »*
- Évasion possible :
  - **bouton caché / conduit** (`Prison_EscapeButton`),
  - **complice** : un voleur libre entre dans la `Prison_RescueZone` et libère
    tous les détenus.
- À la fin du timer, le voleur est renvoyé en ville.

## 8. Dépôt
- Le voleur porteur entre dans la **zone de dépôt** de la planque.
- `LootDepositManager` attribue les points selon le type de butin
  (Banque +5 / Casino +3 / Bijouterie +2) → **Score Voleurs**.
- VFX + son de réussite, le Wanted baisse de 1★ (les voleurs se font discrets).

## 9. Score
- **Voleurs** marquent en déposant du butin (et en pillant le convoi : +5).
- **Police** marque par arrestation (+1) et en escortant le convoi (+5).
- Les scores sont suivis par `Score_Voleurs` et `Score_Police`.

## 10. Événement convoi final (T-3:00)
- Voir `FinalEvent_Convoy.md`. Un convoi blindé apparaît :
  - Voleurs : le tenir 20 s → **+5**.
  - Police : empêcher / escorter → **+5**.

## 11. Fin de manche
La manche se termine quand **l'une** des conditions est remplie :
- Temps écoulé → vainqueur = meilleur score (Voleurs vs Arrestations×2).
- **Voleurs** atteignent `VoleursWinScore` (défaut 20).
- **Police** atteint `PoliceWinIfArrestsReach` arrestations (défaut 8).
- HUD final + `End Game` device.

```
 [Spawn] -> [Choix cible] -> [Alarme] -> [Capture zone] -> [Butin]
     ^                                                        |
     |                                                        v
 [Retour ville/prison] <- [Arrestation] <- [Poursuite] <- [Fuite vers planque]
                                                              |
                                                              v
                                                          [Dépôt +pts]
                                                              |
                                            (T-3min) [Convoi final] -> [Fin]
```
