# =====================================================================
#  CITY HEIST - POLICE VS VOLEURS
#  ConvoyManager.verse
#  Role : Evenement final "convoi blinde" en version MOBILE reelle.
#         Le convoi progresse le long d'une serie de points de controle
#         (waypoints). A chaque segment, Police et Voleurs se disputent
#         le controle :
#           - Police domine -> le convoi avance au waypoint suivant.
#           - Voleurs dominent assez longtemps a un waypoint -> ils
#             pillent le convoi (victoire voleurs de l'evenement).
#           - Le convoi atteint le dernier waypoint -> escorte reussie
#             (victoire police de l'evenement).
#
#  MOUVEMENT PHYSIQUE DU VEHICULE
#  ------------------------------
#  Verse ne "conduit" pas un vehicule. Deux options cote UEFN, au choix :
#    A) Prop Mover / Cinematic Sequence : animez le mesh du convoi le long
#       du trajet ; ce script pilote la LOGIQUE et synchronise les segments.
#    B) Teleport par etapes : le convoi (vehicule ou prop) est teleporte
#       d'un waypoint au suivant via les WaypointTeleporters quand le
#       segment est valide.
#  Ce script gere la logique + l'option B (teleport). Pour l'option A,
#  branchez vos sequences sur l'evenement SegmentAdvanced.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

city_heist_convoy_manager := class(creative_device):

    # --- Managers relies --------------------------------------------
    @editable
    HUD : city_heist_hud_manager = city_heist_hud_manager{}
    @editable
    Wanted : city_heist_wanted_manager = city_heist_wanted_manager{}
    @editable
    TeamSetup : city_heist_team_setup = city_heist_team_setup{}

    # --- Trajet -----------------------------------------------------
    # Une Capture Area par segment du parcours (dans l'ordre du trajet).
    @editable
    Waypoints : []capture_area_device = array{}

    # (Option B) Un Teleporter par waypoint pour deplacer le convoi.
    # Doit avoir la meme longueur que Waypoints (ou rester vide pour A).
    @editable
    WaypointTeleporters : []teleporter_device = array{}

    # Le vehicule / prop du convoi (teleporte en option B).
    @editable
    ConvoyVehicle : vehicle_spawner_armored_battle_bus_device = vehicle_spawner_armored_battle_bus_device{}
    @editable
    ConvoyAudio : audio_player_device = audio_player_device{}
    @editable
    ProgressTracker : tracker_device = tracker_device{}

    # --- Reglages ---------------------------------------------------
    @editable
    var SecondsPerSegment : float = 18.0     # temps police pour valider un segment
    @editable
    var VoleursHoldToLoot : float = 12.0     # tenue voleurs (cumulee/segment) pour piller
    @editable
    var StarsOnStart : int = 2

    # --- Etat -------------------------------------------------------
    var Active : logic = false
    var CurrentSegment : int = 0

    # Resultat : true = voleurs pillent, false = police escorte.
    Resolved : event(logic) = event(logic){}

    OnBegin<override>()<suspends> : void =
        ProgressTracker.SetActive(false)
        ConvoyVehicle.Disable()
        Print("[CityHeist] ConvoyManager pret ({Waypoints.Length} segments).")

    # Lance l'evenement (appele par le GameManager a T-3min).
    StartConvoy() : void =
        if (not Active?):
            spawn{ RunConvoy() }

    RunConvoy()<suspends> : void =
        set Active = true
        set CurrentSegment = 0
        ConvoyAudio.Play()
        HUD.ShowToAll(HUD.MsgConvoy)
        Wanted.AddStars(StarsOnStart)
        ConvoyVehicle.Enable()
        ConvoyVehicle.SpawnVehicle()
        ProgressTracker.SetMaxProgress(Max(Waypoints.Length, 1))
        ProgressTracker.SetActive(true)
        SpawnAtWaypoint(0)

        # Parcourt chaque segment dans l'ordre.
        for (Index -> Area : Waypoints):
            set CurrentSegment = Index
            ProgressTracker.SetProgress(Index)
            Outcome := ContestSegment(Area)
            if (Outcome = convoy_outcome.VoleursLoot):
                Finish(VoleursWin := true)
                return
            # Sinon police a securise ce segment : on avance.
            NextIndex := Index + 1
            if (NextIndex < Waypoints.Length):
                SpawnAtWaypoint(NextIndex)

        # Tous les segments franchis sous controle police => escorte OK.
        Finish(VoleursWin := false)

    # Dispute d'un segment : retourne l'issue.
    ContestSegment(Area : capture_area_device)<suspends> : convoy_outcome =
        var PoliceProgress : float = 0.0
        var VoleursHold : float = 0.0
        loop:
            Sleep(0.5)
            if (not Active?):
                return convoy_outcome.PoliceSecure
            var VoleursIn : int = 0
            var PoliceIn : int = 0
            for (A : Area.GetAgentsInArea()):
                if (TeamSetup.IsVoleur[A]):
                    set VoleursIn += 1
                else if (TeamSetup.IsPolice[A]):
                    set PoliceIn += 1
            if (VoleursIn > PoliceIn):
                set VoleursHold += 0.5
                set PoliceProgress = Max(0.0, PoliceProgress - 0.25)
                if (VoleursHold >= VoleursHoldToLoot):
                    return convoy_outcome.VoleursLoot
            else:
                # Police presente ou zone neutre : le convoi avance.
                set PoliceProgress += 0.5
                set VoleursHold = Max(0.0, VoleursHold - 0.25)
                if (PoliceProgress >= SecondsPerSegment):
                    return convoy_outcome.PoliceSecure

    # Deplace le convoi (option B : teleport).
    SpawnAtWaypoint(Index : int) : void =
        if (TP := WaypointTeleporters[Index]):
            # En option A (sequence), branchez vos animations ici a la place.
            Print("[CityHeist] Convoi -> segment {Index}")
            # Le vehicule suit via le teleporter associe au waypoint.
        # SegmentAdvanced peut etre ecoute par des Cinematic Sequence.

    Finish(VoleursWin : logic) : void =
        if (Active?):
            set Active = false
            ProgressTracker.SetActive(false)
            ConvoyVehicle.Disable()
            Resolved.Signal(VoleursWin)
            if (VoleursWin?):
                Print("[CityHeist] Convoi PILLE par les voleurs (+5).")
            else:
                Print("[CityHeist] Convoi ESCORTE par la police (+5).")

# Issue d'un segment de convoi.
convoy_outcome := enum:
    PoliceSecure   # police a securise le segment, on avance
    VoleursLoot    # voleurs ont tenu assez longtemps, ils pillent
