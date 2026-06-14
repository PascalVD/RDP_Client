# =====================================================================
#  CITY HEIST - POLICE VS VOLEURS
#  ArrestManager.verse
#  Role : Centralise la DETECTION des arrestations et delegue la suite
#         (prison, score, perte du butin) au PrisonManager / GameManager.
#
#  Deux modes d'arrestation, activables independamment :
#   - MODE ELIMINATION : un voleur elimine par un policier est "arrete"
#     (au lieu de simplement reapparaitre). Branchez ce mode si vous
#     voulez un gameplay plus direct / arcade.
#   - MODE MENOTTAGE (proximite) : un policier "menotte" un voleur en
#     restant a cote de lui dans une zone de capture/menottage pendant
#     CuffSeconds, le voleur etant ralenti par un Mutator Zone. Plus
#     tactique et non letal (style "Police vs Voleurs").
#
#  Ce device s'abonne aux sources d'evenements et appelle
#  PrisonManager.ArrestAgent(Voleur).
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

city_heist_arrest_manager := class(creative_device):

    # --- Managers relies --------------------------------------------
    @editable
    Prison : city_heist_prison_manager = city_heist_prison_manager{}
    @editable
    HUD : city_heist_hud_manager = city_heist_hud_manager{}
    @editable
    TeamSetup : city_heist_team_setup = city_heist_team_setup{}

    # --- Modes actifs -----------------------------------------------
    @editable
    var UseEliminationMode : logic = true
    @editable
    var UseCuffMode : logic = true

    # --- Mode menottage : devices ----------------------------------
    # Zone(s) ou un policier peut menotter un voleur present.
    @editable
    CuffZones : []capture_area_device = array{}
    # Mutator Zone qui ralentit les voleurs dans la zone de menottage.
    @editable
    SlowMutator : mutator_zone_device = mutator_zone_device{}
    @editable
    CuffAudio : audio_player_device = audio_player_device{}

    @editable
    var CuffSeconds : float = 3.0          # duree de menottage requise
    @editable
    var CuffMaxDistance : float = 350.0    # portee policier<->voleur (cm)

    OnBegin<override>()<suspends> : void =
        if (UseEliminationMode?):
            SubscribeEliminations()
        if (UseCuffMode?):
            for (Zone : CuffZones):
                Zone.AgentEntersEvent.Subscribe(OnVoleurEntersCuffZone)
        Print("[CityHeist] ArrestManager pret (elim={UseEliminationMode}, menottage={UseCuffMode}).")

    # --- MODE ELIMINATION -------------------------------------------
    SubscribeEliminations() : void =
        # S'abonne aux joueurs presents + futurs.
        for (Player : GetPlayspace().GetPlayers()):
            SubscribePlayerElimination(Player)
        GetPlayspace().PlayerAddedEvent().Subscribe(SubscribePlayerElimination)

    SubscribePlayerElimination(Player : player) : void =
        if (FortChar := Player.GetFortCharacter[]):
            FortChar.EliminatedEvent().Subscribe(OnEliminated)

    OnEliminated(Result : elimination_result) : void =
        # La victime est-elle un voleur ? L'auteur est-il un policier ?
        if:
            Victim := Result.EliminatedCharacter.GetAgent[]
            TeamSetup.IsVoleur[Victim]
        then:
            # Arrestation : direction prison (au lieu d'un simple respawn).
            Prison.ArrestAgent(Victim)

    # --- MODE MENOTTAGE (proximite) ---------------------------------
    OnVoleurEntersCuffZone(Agent : agent) : void =
        if (TeamSetup.IsVoleur[Agent]):
            spawn{ TryCuff(Agent) }

    # Tant que le voleur reste pres d'un policier dans la zone, le
    # compteur monte ; a CuffSeconds il est arrete.
    TryCuff(Voleur : agent)<suspends> : void =
        var Held : float = 0.0
        loop:
            Sleep(0.5)
            if (not VoleurStillInAnyCuffZone[Voleur]):
                return
            if (PoliceNearby(Voleur)):
                set Held += 0.5
                if (Held >= CuffSeconds):
                    CuffAudio.Play()
                    Prison.ArrestAgent(Voleur)
                    return
            else:
                set Held = Max(0.0, Held - 0.5)

    VoleurStillInAnyCuffZone(Voleur : agent)<transacts><decides> : void =
        var Found : logic = false
        for (Zone : CuffZones):
            for (A : Zone.GetAgentsInArea()):
                if (A = Voleur):
                    set Found = true
        Found?

    # Un policier est-il a portee du voleur ?
    PoliceNearby(Voleur : agent)<transacts> : logic =
        if (VChar := Voleur.GetFortCharacter[]):
            VPos := VChar.GetTransform().Translation
            for (P : GetPlayspace().GetPlayers(), TeamSetup.IsPolice[P]):
                if:
                    PChar := P.GetFortCharacter[]
                    Distance(VPos, PChar.GetTransform().Translation) <= CuffMaxDistance
                then:
                    return true
        false
