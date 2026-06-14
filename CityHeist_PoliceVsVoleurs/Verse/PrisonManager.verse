# =====================================================================
#  CITY HEIST - POLICE VS VOLEURS
#  PrisonManager.verse
#  Role : Gere les arrestations, la teleportation en prison, le timer de
#         detention (30s), l'evasion via bouton cache / conduit, et la
#         liberation par un complice.
#
#  Detection d'arrestation : deux methodes au choix (cf. UEFN doc) :
#   A) Le voleur est elimine par la police -> EliminationEvent.
#   B) Le voleur entre dans un "Mutator Zone" de menottage (stun) en
#      etant a portee d'un policier -> on ecoute ce trigger.
#  Ce script gere les deux via ArrestAgent().
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

city_heist_prison_manager := class(creative_device):

    # --- Reglages ---------------------------------------------------
    @editable
    var DetentionSeconds : float = 30.0
    @editable
    var FreeOnReturnFullStars : logic = false  # liberation enleve-t-elle des etoiles

    # --- Devices physiques ------------------------------------------
    @editable
    PrisonTeleporter : teleporter_device = teleporter_device{}   # destination = cellule
    @editable
    CityRespawnTeleporter : teleporter_device = teleporter_device{} # retour en ville apres detention
    @editable
    CellBarrier : barrier_device = barrier_device{}              # barreaux de cellule
    @editable
    EscapeButton : button_device = button_device{}              # bouton cache d'evasion
    @editable
    RescueZone : capture_area_device = capture_area_device{}    # zone ou un complice libere les detenus
    @editable
    PrisonTimer : timer_device = timer_device{}                 # affiche le compte a rebours au detenu

    # --- Managers relies --------------------------------------------
    @editable
    HUD : city_heist_hud_manager = city_heist_hud_manager{}
    @editable
    Wanted : city_heist_wanted_manager = city_heist_wanted_manager{}
    @editable
    TeamSetup : city_heist_team_setup = city_heist_team_setup{}

    # --- Etat -------------------------------------------------------
    # Detenus actuellement en prison + leur tache de detention annulable.
    var Detainees : [agent]cancelable = map{}

    # Evenements pour le GameManager / stats.
    AgentArrested : event(agent) = event(agent){}
    AgentReleased : event(agent) = event(agent){}

    OnBegin<override>()<suspends> : void =
        CellBarrier.Enable()
        EscapeButton.InteractedWithEvent.Subscribe(OnEscapeButton)
        RescueZone.AgentEntersEvent.Subscribe(OnRescuerEnters)
        Print("[CityHeist] PrisonManager pret (detention {DetentionSeconds}s).")

    # --- Arrestation -------------------------------------------------
    # Appele par le GameManager quand un voleur est neutralise/menotte.
    ArrestAgent(Agent : agent) : void =
        if (TeamSetup.IsVoleur[Agent], not Detainees[Agent]):
            HUD.ShowToAgent(Agent, HUD.MsgArrested)
            PrisonTeleporter.Teleport(Agent)
            AgentArrested.Signal(Agent)
            DetentionTask := DetentionCountdown(Agent)
            if (set Detainees[Agent] = DetentionTask) {}

    # Compte a rebours individuel de detention.
    DetentionCountdown(Agent : agent)<suspends> : void =
        PrisonTimer.SetActiveDuration(DetentionSeconds)
        PrisonTimer.Reset()
        PrisonTimer.Start(Agent)
        Sleep(DetentionSeconds)
        ReleaseAgent(Agent, FromTimer := true)

    # --- Liberation --------------------------------------------------
    # Liberation "normale" (fin de timer) ou forcee (evasion/sauvetage).
    ReleaseAgent(Agent : agent, FromTimer : logic) : void =
        if (Task := Detainees[Agent]):
            if (not FromTimer?):
                Task.Cancel()
            if (Detainees.RemoveKey[Agent]) {}
            CityRespawnTeleporter.Teleport(Agent)
            AgentReleased.Signal(Agent)
            if (FreeOnReturnFullStars?):
                Wanted.RemoveStars(1)

    # Bouton cache : tous les detenus presents s'evadent.
    OnEscapeButton(Agent : agent) : void =
        if (TeamSetup.IsVoleur[Agent]):
            HUD.ShowToAgent(Agent, HUD.MsgEscaped)
            ReleaseAgent(Agent, FromTimer := false)

    # Un complice (voleur libre) entre dans la zone de sauvetage et
    # libere tous les detenus encore en prison.
    OnRescuerEnters(Rescuer : agent) : void =
        if (TeamSetup.IsVoleur[Rescuer], not Detainees[Rescuer]):
            for (Detainee -> _ : Detainees):
                HUD.ShowToAgent(Detainee, HUD.MsgFreed)
                ReleaseAgent(Detainee, FromTimer := false)

    # Helper pour le GameManager : combien de voleurs en prison.
    DetaineeCount()<transacts> : int:
        var Count : int = 0
        for (_ -> _ : Detainees):
            set Count += 1
        return Count
