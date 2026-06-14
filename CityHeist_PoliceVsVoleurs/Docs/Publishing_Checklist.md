# Checklist de publication & optimisation — CITY HEIST

## A. Optimisation mémoire & performance (à faire AVANT publication)
- [ ] Ouvrir **Window > Project Memory** : budget total **< 100 %**.
- [ ] Meshes répétés (maisons, lampadaires, barrages) → **Instanced Static
      Mesh** ou réutiliser le **même** asset (pas de duplicatas distincts).
- [ ] Garder le **blockout low-poly** tant que possible ; n'ajouter les assets
      Fab/Fortnite détaillés que sur les zones vues de près.
- [ ] **Lumières** : privilégier *Static* ; limiter les lumières dynamiques
      (néons) aux zones clés ; baisser le rayon d'influence.
- [ ] **VFX** : désactivés au départ (`Disable()`), activés seulement au besoin
      (alarmes, drones 3★). Pas de boucles VFX permanentes.
- [ ] **Audio** : mutualiser les Audio Players, sons courts, pas de musique
      lourde non compressée.
- [ ] **Devices** : viser le minimum utile. Supprimer les devices de test.
- [ ] **Collisions** : *Simple* sur tous les meshes blockout (pas de
      *Complex as Simple*).
- [ ] Tester le **framerate** sur une session lancée (cible 60 fps).

## B. Conformité contenu
- [ ] Aucune **marque réelle** (banque, casino, enseignes) — noms génériques.
- [ ] Aucun **logo** protégé ni texture importée non autorisée.
- [ ] Tous les assets viennent de **Fab autorisé Fortnite** ou sont créés ici.
- [ ] Pas de contenu choquant ; respect des **règles de la communauté Epic**.
- [ ] Crédits des assets tiers éventuels renseignés.

## C. Gameplay & robustesse
- [ ] La manche **démarre** et **se termine** proprement (timer + End Game).
- [ ] Les **deux conditions de victoire** fonctionnent (score / arrestations).
- [ ] Spawns équipes corrects, pas de spawn dans un mur.
- [ ] Braquages : alarme, progression, ouverture coffre, butin, dépôt = points.
- [ ] Prison : téléport, timer 30 s, bouton d'évasion, sauvetage par complice.
- [ ] Wanted Level : 1→5★, effets et decay OK.
- [ ] Convoi à T-3 min, résolution Police/Voleurs OK.
- [ ] HUD lisible, messages FR corrects.
- [ ] Aucun moyen de **sortir de la map** / zones bloquées (kill volume autour).

## D. Tests multijoueurs
- [ ] Testé à **2 joueurs** minimum (idéal 4–8).
- [ ] Pas d'erreur Verse dans l'**Output Log** (`[CityHeist]` visibles).
- [ ] Rejoindre en cours de partie ne casse rien.
- [ ] Équilibrage validé sur ≥ 3 manches (voir `Balancing.md`).

## E. Métadonnées de l'île
- [ ] **Titre** : "City Heist – Police vs Voleurs".
- [ ] **Description** FR claire (objectifs des 2 équipes).
- [ ] **Vignette / images** attractives (capture de nuit).
- [ ] **Tags** : Team Deathmatch / Roleplay / Heist (selon pertinence).
- [ ] **Nombre de joueurs** : 4–16.
- [ ] **Île Code** réservé.

## F. Publication
- [ ] **Validate** le projet (UEFN : *Validate*).
- [ ] **Push Changes** puis **Publish** depuis UEFN.
- [ ] Vérifier la version publiée via le **code d'île** (session réelle).
- [ ] Itérer : republier après corrections de playtest.

## G. Versions
- [ ] **v0.1 MVP** publiée et jouable (Banque + Prison + score).
- [ ] **v1.0 complète** (toutes zones + Wanted + convoi + égouts).
- [ ] Notes de version tenues à jour.
