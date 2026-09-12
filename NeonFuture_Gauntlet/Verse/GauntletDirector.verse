# =====================================================================
#  NEON FUTURE - GAUNTLET (multi-cartes, solo / free-for-all)
#  GauntletDirector.verse
#  Role : Chef d'orchestre GLOBAL de tout le gauntlet (toutes les cartes).
#         - garde le roster des joueurs et l'ordre d'elimination ;
#         - fait avancer les survivants d'une arene a la suivante ;
#         - a la fin, calcule le classement et attribue les pieces d'or.
#
#  MODELE UEFN CONSEILLE
#  ---------------------
#  Tout le gauntlet vit dans UNE ile UEFN, decoupee en plusieurs ARENES
#  (Carte 1, Carte 2 = Neon Future, Carte 3, ...). Chaque arene a son
#  arena_controller. Le Director les enchaine : quand une arene a reduit
#  les joueurs au seuil de survivants, ils sont teleportes dans l'arene
#  suivante ; les elimines partent en zone spectateur.
#
#  Ce fichier fait partie de la serie "Neon Future". La CARTE 2 est
#  fournie cle en main ; les autres cartes reutilisent les memes scripts
#  (il suffit d'ajouter des arena_controller dans la liste Arenas).
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

neon_gauntlet_director := class(creative_device):

    # --- Devices relies ---------------------------------------------
    @editable
    HUD : neon_hud_manager = neon_hud_manager{}
    @editable
    Coins : neon_coin_manager = neon_coin_manager{}

    # Arenes dans l'ordre de jeu (Carte 1, Carte 2, ...). Pour tester la
    # Carte 2 seule, ne mettez qu'elle.
    @editable
    Arenas : []neon_arena_controller = array{}

    # Ou partent les joueurs elimines (mode spectateur / loge des perdants).
    @editable
    SpectatorTeleporter : teleporter_device = teleporter_device{}

    # Termine l'experience quand le gauntlet est fini.
    @editable
    EndGameDevice : end_game_device = end_game_device{}

    # --- Reglages ---------------------------------------------------
    @editable
    var StartDelaySeconds : float = 5.0

    # --- Etat global ------------------------------------------------
    # Ordre d'elimination : le PREMIER elimine est en tete (= plus mauvais
    # classement). Les survivants du dernier duel seront ajoutes a la fin.
    var EliminationOrder : []agent = array{}
    var CurrentArenaIndex : int = 0
    var GauntletRunning : logic = false

    OnBegin<override>()<suspends> : void =
        Print("[Neon] Director pret. {Arenas.Length} arene(s).")
        Sleep(StartDelaySeconds)
        StartGauntlet()

    # --- Demarrage --------------------------------------------------
    StartGauntlet() : void =
        if (not GauntletRunning?, Arenas.Length > 0):
            set GauntletRunning = true
            set CurrentArenaIndex = 0
            StartArenaAt(0, GetPlayspace().GetPlayers())

    StartArenaAt(Index : int, Players : []agent) : void =
        if (Arena := Arenas[Index]):
            set CurrentArenaIndex = Index
            HUD.ShowToAll(HUD.MsgArenaStart(Index + 1))
            Arena.StartArena(self, Players)

    # --- Appele par une arene quand un joueur y est elimine ---------
    # Enregistre le classement et envoie le joueur en spectateur.
    RecordElimination(Agent : agent) : void =
        if (not IsAlreadyOut[Agent]):
            set EliminationOrder += array{Agent}
            SpectatorTeleporter.Teleport(Agent)
            HUD.ShowToAgent(Agent, HUD.MsgEliminated(RemainingAliveCount()))
            Print("[Neon] Elimine (place provisoire {PlacementOf(Agent)}) : {Agent}")

    # --- Appele par une arene quand le seuil de survivants est atteint
    #     (ou le temps ecoule). Fait avancer les survivants. ----------
    OnArenaComplete(Survivors : []agent) : void =
        NextIndex := CurrentArenaIndex + 1
        if (NextIndex < Arenas.Length):
            # Il reste des arenes : on avance les survivants.
            HUD.ShowToAll(HUD.MsgAdvance(Survivors.Length, NextIndex + 1))
            for (S : Survivors):
                HUD.ShowToAgent(S, HUD.MsgYouAdvance)
            StartArenaAt(NextIndex, Survivors)
        else:
            # Derniere arene terminee : fin du gauntlet.
            FinishGauntlet(Survivors)

    # --- Fin : classement + pieces d'or -----------------------------
    FinishGauntlet(Finalists : []agent) : void =
        if (GauntletRunning?):
            set GauntletRunning = false
            # Classement final = finalistes (meilleurs) devant, puis
            # l'ordre d'elimination inverse (dernier elimine = mieux classe).
            var Ranking : []agent = Finalists
            for (i := 0 .. EliminationOrder.Length - 1):
                ReverseIndex := EliminationOrder.Length - 1 - i
                if (A := EliminationOrder[ReverseIndex]):
                    set Ranking += array{A}
            # Attribution des pieces d'or selon le rang (1 = vainqueur).
            for (Rank -> Player : Ranking):
                Coins.AwardByRank(Player, Rank + 1, Ranking.Length)
            if (Winner := Ranking[0]):
                HUD.ShowToAll(HUD.MsgWinner)
                HUD.ShowToAgent(Winner, HUD.MsgYouWin)
            Print("[Neon] Gauntlet termine. Vainqueur classe #1 sur {Ranking.Length}.")
            EndGameDevice.Activate(Ranking[0] or GetPlayspace().GetPlayers()[0])

    # --- Helpers ----------------------------------------------------
    IsAlreadyOut(Agent : agent)<transacts><decides> : void =
        var Found : logic = false
        for (A : EliminationOrder):
            if (A = Agent):
                set Found = true
        Found?

    PlacementOf(Agent : agent)<transacts> : int =
        # Place provisoire = nb de joueurs encore en vie + 1 au moment de l'elim.
        RemainingAliveCount() + 1

    RemainingAliveCount()<transacts> : int =
        var Alive : int = 0
        for (P : GetPlayspace().GetPlayers()):
            if (not IsAlreadyOut[P]):
                set Alive += 1
        return Alive
