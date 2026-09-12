# =====================================================================
#  FIVE RIFTS: SURVIVAL  (projet RIFT_DUO_1918)
#  SurvivalDirector.verse   —   MODE SOLO / individuel
#  Role : Chef d'orchestre GLOBAL du tournoi sur 5 cartes.
#         - lobby + choix d'equipement (via LobbyLoadout) ;
#         - enchaine les 5 rifts ;
#         - a chaque rift, quand les survivants <= quota, transfere les
#           survivants a la carte suivante ; les elimines -> spectateur ;
#         - garde l'ordre d'elimination pour le CLASSEMENT final ;
#         - a la 5e carte (arene finale), le dernier survivant gagne ;
#         - attribue les pieces d'or selon le classement.
#
#  Quotas : calcules au LANCEMENT a partir du nombre REEL de joueurs
#  (handoff 2) — chaque rift garde SurvivorPercent % (regle par rift).
#  Une deconnexion ne reintroduit jamais un joueur elimine (handoff 2).
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

five_rifts_director := class(creative_device):

    # --- Devices relies ---------------------------------------------
    @editable
    HUD : five_rifts_hud = five_rifts_hud{}
    @editable
    Coins : five_rifts_coins = five_rifts_coins{}
    @editable
    Lobby : five_rifts_lobby = five_rifts_lobby{}

    # Les 5 rifts, dans l'ordre (Ashford 1918, Neon Future, Black Sand,
    # Whiteout Bastion, Drowned Foundry). Le dernier = arene finale.
    @editable
    Rifts : []five_rifts_controller = array{}

    # Ou partent les elimines (spectateur). Les spectateurs ne comptent
    # jamais dans les survivants (handoff 3).
    @editable
    SpectatorTeleporter : teleporter_device = teleporter_device{}
    @editable
    EndGameDevice : end_game_device = end_game_device{}

    # --- Etat -------------------------------------------------------
    var EliminationOrder : []agent = array{}   # 1er elimine en tete (moins bien classe)
    var CurrentRift : int = 0
    var Running : logic = false

    OnBegin<override>()<suspends> : void =
        Print("[FiveRifts] Director pret. {Rifts.Length} rift(s), mode SOLO.")
        # Lobby + compte a rebours + choix d'equipement, puis on lance.
        StartingPlayers := Lobby.RunLobby()
        StartRun(StartingPlayers)

    StartRun(Players : []agent) : void =
        if (not Running?, Rifts.Length > 0):
            set Running = true
            set CurrentRift = 0
            StartRiftAt(0, Players)

    StartRiftAt(Index : int, Players : []agent) : void =
        if (Rift := Rifts[Index]):
            set CurrentRift = Index
            HUD.ToAll(HUD.MsgRiftIntro(Index + 1, Rift.RiftName))
            Rift.StartRift(self, Players)

    # --- Appele par un rift quand un joueur y est elimine -----------
    RecordElimination(Agent : agent) : void =
        if (not IsOut[Agent]):
            set EliminationOrder += array{Agent}
            SpectatorTeleporter.Teleport(Agent)
            HUD.ToAgent(Agent, HUD.MsgYouSpectate)

    # --- Appele par un rift quand le quota est atteint / temps ecoule -
    OnRiftComplete(Survivors : []agent) : void =
        NextIndex := CurrentRift + 1
        if (NextIndex < Rifts.Length):
            HUD.ToAll(HUD.MsgQualified(NextIndex + 1))
            for (S : Survivors):
                HUD.ToAgent(S, HUD.MsgQualified(NextIndex + 1))
            # Re-equipement / soin au sas (handoff 3) : delegue au Lobby.
            Lobby.ResetAndReequip(Survivors)
            StartRiftAt(NextIndex, Survivors)
        else:
            FinishRun(Survivors)

    # --- Fin : classement + pieces d'or -----------------------------
    FinishRun(Finalists : []agent) : void =
        if (Running?):
            set Running = false
            # Classement = finalistes (les mieux classes) puis ordre
            # d'elimination INVERSE (dernier elimine = mieux classe).
            var Ranking : []agent = Finalists
            for (i := 0 .. EliminationOrder.Length - 1):
                Rev := EliminationOrder.Length - 1 - i
                if (A := EliminationOrder[Rev]):
                    set Ranking += array{A}
            for (Rank -> Player : Ranking):
                Coins.AwardByRank(Player, Rank + 1, Ranking.Length)
            if (Winner := Ranking[0]):
                HUD.ToAll(HUD.MsgWinner)
            Print("[FiveRifts] Tournoi termine. {Ranking.Length} classes.")
            EndGameDevice.Activate(Ranking[0] or GetPlayspace().GetPlayers()[0])

    # --- Helpers ----------------------------------------------------
    IsOut(Agent : agent)<transacts><decides> : void =
        var Found : logic = false
        for (A : EliminationOrder):
            if (A = Agent):
                set Found = true
        Found?
