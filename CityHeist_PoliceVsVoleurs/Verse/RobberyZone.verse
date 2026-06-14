# =====================================================================
#  CITY HEIST - POLICE VS VOLEURS
#  RobberyZone.verse
#  Role : Logique generique d'une zone de braquage (banque, bijouterie,
#         casino). Une instance de ce device = un objectif de vol.
#
#  Fonctionnement :
#   1. Un voleur entre dans la Capture Area et reste dedans.
#   2. Un timer de braquage demarre (configurable par zone).
#   3. Si la police vide la zone, le timer se met en pause (ou se reset
#      selon ResetIfInterrupted).
#   4. A la fin du timer : alarme, butin spawn (Item Spawner), points
#      attribues quand le butin atteint la planque (via LootDepositManager).
#
#  Reutilisable : placez 3 instances (Bank/Jewelry/Casino) avec des
#  reglages differents.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Type de butin produit par la zone (sert au score au depot).
heist_loot_type := enum:
    BankBag      # 5 points
    Jewelry      # 2 points
    CasinoChips  # 3 points

city_heist_robbery_zone := class(creative_device):

    # --- Identite de la zone ----------------------------------------
    @editable
    var ZoneName : string = "Banque"
    @editable
    var LootType : heist_loot_type = heist_loot_type.BankBag
    @editable
    var RewardPoints : int = 5
    @editable
    var RobberySeconds : float = 45.0      # 45 banque / 12 bijouterie / 25 casino
    @editable
    var StarsOnStart : int = 1             # combien d'etoiles ajoute le declenchement
    @editable
    var ResetIfInterrupted : logic = false # true = recommence si police nettoie la zone

    # --- Devices physiques de la zone (a placer dans UEFN) ----------
    @editable
    CaptureArea : capture_area_device = capture_area_device{}   # detecte les voleurs presents
    @editable
    VaultDoor : barrier_device = barrier_device{}               # porte coffre (banque/casino VIP)
    @editable
    LootSpawner : item_spawner_device = item_spawner_device{}   # fait apparaitre le sac de butin
    @editable
    ProgressTracker : tracker_device = tracker_device{}         # barre de progression du braquage
    @editable
    AlarmAudio : audio_player_device = audio_player_device{}
    @editable
    AlarmVFX : vfx_spawner_device = vfx_spawner_device{}

    # --- Devices managers relies ------------------------------------
    @editable
    HUD : city_heist_hud_manager = city_heist_hud_manager{}
    @editable
    Wanted : city_heist_wanted_manager = city_heist_wanted_manager{}
    @editable
    TeamSetup : city_heist_team_setup = city_heist_team_setup{}

    # --- Etat -------------------------------------------------------
    var IsLooted : logic = false
    var IsInProgress : logic = false
    var ProgressSeconds : float = 0.0

    # Evenement diffuse a la fin du braquage (ecoute par GameManager).
    Completed : event(heist_loot_type) = event(heist_loot_type){}

    # --- Cycle de vie -----------------------------------------------
    OnBegin<override>()<suspends> : void =
        VaultDoor.Enable()                  # le coffre commence ferme
        ProgressTracker.SetMaxProgress(Round[RobberySeconds])
        ProgressTracker.SetActive(false)
        # Reagit quand un voleur entre/sort de la zone de capture.
        CaptureArea.AgentEntersEvent.Subscribe(OnAgentEnters)
        Print("[CityHeist] Zone de braquage '{ZoneName}' prete ({RewardPoints} pts, {RobberySeconds}s).")

    OnAgentEnters(Agent : agent) : void =
        if (not IsLooted?, not IsInProgress?, TeamSetup.IsVoleur[Agent]):
            spawn{ RunRobbery(Agent) }

    # Boucle principale d'un braquage.
    RunRobbery(Starter : agent)<suspends> : void =
        set IsInProgress = true
        set ProgressSeconds = 0.0
        ProgressTracker.SetActive(true)
        AlarmAudio.Play()
        AlarmVFX.Enable()
        Wanted.AddStars(StarsOnStart)
        HUD.ShowToAll(StartMessage())

        loop:
            Sleep(0.5)
            VoleursPresent := CountVoleursInArea()
            if (VoleursPresent > 0):
                # Progression (legerement plus vite si plusieurs voleurs).
                Speed := 1.0 + (Float(VoleursPresent - 1) * 0.25)
                set ProgressSeconds += 0.5 * Speed
                ProgressTracker.SetProgress(Round[ProgressSeconds])
                if (ProgressSeconds >= RobberySeconds):
                    FinishRobbery()
                    break
            else:
                # Personne ne braque : police a repris la zone.
                if (ResetIfInterrupted?):
                    set ProgressSeconds = 0.0
                    ProgressTracker.SetProgress(0)
                # Sinon le timer reste en pause a sa valeur courante.

    FinishRobbery() : void =
        set IsInProgress = false
        set IsLooted = true
        ProgressTracker.SetActive(false)
        VaultDoor.Disable()                 # ouvre le coffre
        LootSpawner.SpawnItem()             # fait apparaitre le butin a recuperer
        AlarmVFX.Disable()
        HUD.ShowToAll(DoneMessage())
        Completed.Signal(LootType)
        Print("[CityHeist] Braquage '{ZoneName}' termine. Butin disponible.")

    # --- Helpers ----------------------------------------------------
    CountVoleursInArea()<transacts> : int =
        var Count : int = 0
        for (Agent : CaptureArea.GetAgentsInArea(), TeamSetup.IsVoleur[Agent]):
            set Count += 1
        return Count

    StartMessage()<transacts> : message =
        case (LootType):
            heist_loot_type.BankBag     => HUD.MsgBankStarted(GetPlayspace().GetPlayers()[0])
            heist_loot_type.Jewelry     => HUD.MsgBankStarted(GetPlayspace().GetPlayers()[0])
            heist_loot_type.CasinoChips => HUD.MsgBankStarted(GetPlayspace().GetPlayers()[0])

    DoneMessage()<transacts> : message =
        case (LootType):
            heist_loot_type.BankBag     => HUD.MsgBankDone
            heist_loot_type.Jewelry     => HUD.MsgJewelryDone
            heist_loot_type.CasinoChips => HUD.MsgCasinoDone
