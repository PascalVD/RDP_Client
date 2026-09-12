# =====================================================================
#  FIVE RIFTS: SURVIVAL  (projet RIFT_DUO_1918)
#  LobbyLoadout.verse
#  Role : Lobby commun + compte a rebours de 20 s + choix individuel
#         d'armes/accessoires + option par defaut (handoff 7), et le
#         "sas" entre deux cartes : soin, nettoyage d'equipement,
#         nouveau choix, teleportation (handoff 3).
#
#  Les equipements ne doivent pas donner d'avantage cache entre cartes
#  (handoff 7) : chaque rift repart d'un choix propre et equivalent.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

five_rifts_lobby := class(creative_device):

    @editable
    HUD : five_rifts_hud = five_rifts_hud{}

    # Zone lobby ou les joueurs attendent / choisissent.
    @editable
    LobbyTeleporter : teleporter_device = teleporter_device{}
    @editable
    LobbyBarrier : barrier_device = barrier_device{}

    # Choix d'equipement : un Item Granter par "kit" (ex : Assaut, Sniper,
    # Shotgun...). Le joueur en active un via un bouton / zone ; le premier
    # kit est l'option PAR DEFAUT si rien n'est choisi.
    @editable
    LoadoutKits : []item_granter_device = array{}
    @editable
    LoadoutButtons : []button_device = array{}   # meme ordre que LoadoutKits

    # Remet a neuf au sas : soin + nettoyage (item remover / heal via zone).
    @editable
    HealZone : mutator_zone_device = mutator_zone_device{}
    @editable
    ItemRemover : item_remover_device = item_remover_device{}

    @editable
    var CountdownSeconds : int = 20

    # Kit choisi par joueur (index dans LoadoutKits).
    var Chosen : [agent]int = map{}

    OnBegin<override>()<suspends> : void =
        for (Index -> Btn : LoadoutButtons):
            Btn.InteractedWithEvent.Subscribe(MakeChooser(Index))
        Print("[FiveRifts] Lobby pret ({LoadoutKits.Length} kits, {CountdownSeconds}s).")

    # Fabrique un handler qui memorise le kit Index pour l'agent.
    MakeChooser(Index : int) : (agent) -> void =
        Handler(A : agent) : void =
            if (set Chosen[A] = Index) {}
        Handler

    # --- Lobby de depart : retourne les joueurs prets a jouer ---------
    RunLobby()<suspends> : []agent =
        Players := GetPlayspace().GetPlayers()
        for (P : Players):
            LobbyTeleporter.Teleport(P)
        LobbyBarrier.Enable()
        # Compte a rebours affiche.
        for (i := 0 .. CountdownSeconds - 1):
            Remaining := CountdownSeconds - i
            HUD.ToAll(HUD.MsgLobby(Remaining))
            Sleep(1.0)
        GrantChosenKits(Players)
        LobbyBarrier.Disable()
        return Players

    # --- Sas entre deux cartes (handoff 3) ---------------------------
    # Soigne, nettoie l'equipement, rouvre un choix, puis le Director
    # teleporte vers le rift suivant.
    ResetAndReequip(Survivors : []agent) : void =
        for (S : Survivors):
            ItemRemover.Remove(S)     # nettoyage
            HealZone.Enable()          # soin (zone de heal active brievement)
        # Nouveau choix identique pour tous (pas d'avantage cache).
        GrantChosenKits(Survivors)

    # Accorde a chacun son kit choisi, sinon le kit par defaut (index 0).
    GrantChosenKits(Players : []agent) : void =
        for (P : Players):
            var Index : int = 0
            if (C := Chosen[P]):
                set Index = C
            if (Kit := LoadoutKits[Index]):
                Kit.GrantItem(P)
            else if (Default := LoadoutKits[0]):
                Default.GrantItem(P)
