# =====================================================================
#  CITY HEIST - POLICE VS VOLEURS
#  WantedLevelManager.verse
#  Role : Gere le niveau de recherche global des voleurs (1 a 5 etoiles).
#         Le niveau monte avec les actions criminelles et declenche des
#         effets cote police (cameras, drones, SWAT, fermeture de sorties).
#
#  Echelle :
#   1 etoile : alerte police (HUD + son).
#   2 etoiles: localisation approximative des voleurs.
#   3 etoiles: cameras / drones actives.
#   4 etoiles: SWAT debloque.
#   5 etoiles: certaines sorties se ferment temporairement.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

city_heist_wanted_manager := class(creative_device):

    # --- Devices relies ---------------------------------------------
    @editable
    HUD : city_heist_hud_manager = city_heist_hud_manager{}
    @editable
    TeamSetup : city_heist_team_setup = city_heist_team_setup{}

    # Tracker pour afficher le niveau d'etoiles a l'ecran.
    @editable
    StarTracker : tracker_device = tracker_device{}

    # Devices declenches a chaque palier (a brancher dans UEFN).
    @editable
    AlarmAudio : audio_player_device = audio_player_device{}            # 1 etoile
    DroneVFX : vfx_spawner_device = vfx_spawner_device{}                # 3 etoiles
    SwatGranter : item_granter_device = item_granter_device{}          # 4 etoiles : equipement SWAT
    ExitBarriers : []barrier_device = array{}                          # 5 etoiles : sorties verrouillees

    # --- Reglages ---------------------------------------------------
    @editable
    var MaxStars : int = 5
    @editable
    var ExitLockSeconds : float = 25.0   # duree de fermeture des sorties a 5 etoiles
    @editable
    var DecayEnabled : logic = true      # le niveau redescend si les voleurs se cachent
    @editable
    var DecaySeconds : float = 45.0      # temps sans crime avant de perdre 1 etoile

    # --- Etat -------------------------------------------------------
    var CurrentStars : int = 0
    var SecondsSinceLastCrime : float = 0.0

    # Evenement diffuse quand le niveau change (ecoute par GameManager).
    StarsChanged : event(int) = event(int){}

    # --- API publique -----------------------------------------------

    GetStars()<transacts> : int = CurrentStars

    # Augmente le niveau de recherche de N etoiles (typiquement 1).
    AddStars(Amount : int) : void =
        set SecondsSinceLastCrime = 0.0
        NewStars := Min(CurrentStars + Amount, MaxStars)
        if (NewStars > CurrentStars):
            for (Level := CurrentStars + 1 .. NewStars):
                ApplyStarEffect(Level)
            set CurrentStars = NewStars
            UpdateTracker()
            StarsChanged.Signal(CurrentStars)

    # Reduit le niveau (evasion, butin perdu, decay).
    RemoveStars(Amount : int) : void =
        NewStars := Max(CurrentStars - Amount, 0)
        if (NewStars < CurrentStars):
            set CurrentStars = NewStars
            UpdateTracker()
            StarsChanged.Signal(CurrentStars)

    ResetStars() : void =
        if (CurrentStars > 0):
            set CurrentStars = 0
            UpdateTracker()
            StarsChanged.Signal(0)

    # --- Effets par palier ------------------------------------------
    ApplyStarEffect(Level : int) : void =
        case (Level):
            1 =>
                AlarmAudio.Play()
                HUD.ShowToVoleurs(HUD.MsgBankStarted(GetPlayspace().GetPlayers()[0]))
                Print("[Wanted] 1 etoile : alerte police.")
            2 =>
                Print("[Wanted] 2 etoiles : localisation approximative des voleurs (activez le ping Tracker police).")
            3 =>
                DroneVFX.Enable()
                Print("[Wanted] 3 etoiles : cameras / drones actives.")
            4 =>
                # Debloque l'equipement SWAT pour toute la police.
                for (Player : GetPlayspace().GetPlayers(), TeamSetup.IsPolice[Player]?):
                    SwatGranter.GrantItem(Player)
                Print("[Wanted] 4 etoiles : SWAT debloque.")
            5 =>
                spawn{ LockExitsTemporarily() }
                Print("[Wanted] 5 etoiles : fermeture temporaire de certaines sorties.")
            _ => {}

    LockExitsTemporarily()<suspends> : void =
        for (Barrier : ExitBarriers):
            Barrier.Enable()
        Sleep(ExitLockSeconds)
        for (Barrier : ExitBarriers):
            Barrier.Disable()

    UpdateTracker() : void =
        StarTracker.SetTarget(CurrentStars)

    # Boucle de decroissance du niveau de recherche.
    DecayLoop()<suspends> : void =
        loop:
            Sleep(1.0)
            if (DecayEnabled? and CurrentStars > 0):
                set SecondsSinceLastCrime += 1.0
                if (SecondsSinceLastCrime >= DecaySeconds):
                    set SecondsSinceLastCrime = 0.0
                    RemoveStars(1)

    OnBegin<override>()<suspends> : void =
        StarTracker.SetMaxProgress(MaxStars)
        DroneVFX.Disable()
        for (Barrier : ExitBarriers):
            Barrier.Disable()
        Print("[CityHeist] WantedLevelManager pret (max {MaxStars} etoiles).")
        spawn{ DecayLoop() }
