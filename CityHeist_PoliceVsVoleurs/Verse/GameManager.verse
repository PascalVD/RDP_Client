# =====================================================================
#  CITY HEIST - POLICE VS VOLEURS
#  GameManager.verse
#  Role : Chef d'orchestre du mode. Gere le cycle de manche (debut/fin),
#         le timer global, le score des deux equipes, l'evenement convoi
#         final, et les conditions de victoire Police / Voleurs.
#
#  C'est le SEUL device qui connait tous les autres managers. Branchez
#  toutes ses references @editable dans UEFN.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

city_heist_game_manager := class(creative_device):

    # --- Reglages de manche -----------------------------------------
    @editable
    var RoundTimeSeconds : int = 900       # 15 min (min recommande 600 = 10 min)
    @editable
    var ConvoyTriggerSecondsBeforeEnd : int = 180  # convoi a 3 min de la fin
    @editable
    var PoliceWinIfArrestsReach : int = 8  # arrestations cumulees => victoire police
    @editable
    var VoleursWinScore : int = 20         # score cible des voleurs

    # --- Managers relies --------------------------------------------
    @editable
    HUD : city_heist_hud_manager = city_heist_hud_manager{}
    @editable
    TeamSetup : city_heist_team_setup = city_heist_team_setup{}
    @editable
    Wanted : city_heist_wanted_manager = city_heist_wanted_manager{}
    @editable
    Prison : city_heist_prison_manager = city_heist_prison_manager{}
    @editable
    LootDeposit : city_heist_loot_deposit_manager = city_heist_loot_deposit_manager{}

    # Les 3 zones de braquage.
    @editable
    BankZone : city_heist_robbery_zone = city_heist_robbery_zone{}
    @editable
    JewelryZone : city_heist_robbery_zone = city_heist_robbery_zone{}
    @editable
    CasinoZone : city_heist_robbery_zone = city_heist_robbery_zone{}

    # --- Devices globaux --------------------------------------------
    @editable
    RoundTimer : timer_device = timer_device{}                  # timer global affiche
    @editable
    EndGameDevice : end_game_device = end_game_device{}         # termine la partie
    @editable
    PoliceScore : score_manager_device = score_manager_device{} # score equipe police
    @editable
    ConvoyVehicle : vehicle_spawner_armored_battle_bus_device = vehicle_spawner_armored_battle_bus_device{}
    @editable
    ConvoyCaptureArea : capture_area_device = capture_area_device{} # le convoi a escorter / attaquer
    @editable
    ConvoyAudio : audio_player_device = audio_player_device{}

    # --- Etat -------------------------------------------------------
    var VoleursScore : int = 0
    var PoliceArrests : int = 0
    var ConvoyResolved : logic = false
    var RoundOver : logic = false

    OnBegin<override>()<suspends> : void =
        Print("[CityHeist] === GameManager : initialisation ===")
        SubscribeEvents()
        RunRound()

    # --- Abonnements -------------------------------------------------
    SubscribeEvents() : void =
        # Score voleurs au depot du butin.
        LootDeposit.LootDeposited.Subscribe(OnLootDeposited)
        # Arrestations.
        Prison.AgentArrested.Subscribe(OnArrest)
        Prison.AgentReleased.Subscribe(OnRelease)
        # Quand le porteur est arrete, il perd son butin.
        Prison.AgentArrested.Subscribe(LootDeposit.RemoveCarriedLoot)

    # --- Boucle de manche -------------------------------------------
    RunRound()<suspends> : void =
        HUD.ShowToAll(HUD.MsgRoundStart)
        RoundTimer.SetMaxDuration(Float(RoundTimeSeconds))
        RoundTimer.Reset()
        RoundTimer.Start()

        # Lance en parallele : compte a rebours, convoi, surveillance victoire.
        race:
            RoundCountdown()
            block:
                WatchVictoryConditions()
                # boucle infinie de WatchVictory => ne se termine que par victoire

        if (not RoundOver?):
            DeclareWinnerByScore()

    RoundCountdown()<suspends> : void =
        # Attend jusqu'au declenchement du convoi.
        Sleep(Float(RoundTimeSeconds - ConvoyTriggerSecondsBeforeEnd))
        spawn{ TriggerConvoyEvent() }
        # Attend la fin du temps restant.
        Sleep(Float(ConvoyTriggerSecondsBeforeEnd))
        # Temps ecoule.
        DeclareWinnerByScore()

    # --- Evenement convoi final -------------------------------------
    TriggerConvoyEvent()<suspends> : void =
        if (not ConvoyResolved?):
            ConvoyAudio.Play()
            HUD.ShowToAll(HUD.MsgConvoy)
            ConvoyVehicle.Enable()
            ConvoyVehicle.SpawnVehicle()
            Wanted.AddStars(2)
            # Resolution : si les voleurs tiennent la zone du convoi assez
            # longtemps, ils le pillent (+5). Sinon la police l'escorte (+5).
            ConvoyResult := ResolveConvoy()
            set ConvoyResolved = true
            if (ConvoyResult?):
                AwardVoleurs(5)
                Print("[CityHeist] Convoi pille par les voleurs (+5).")
            else:
                AwardPolice(5)
                Print("[CityHeist] Convoi escorte par la police (+5).")

    # Retourne true si les voleurs reussissent a capturer le convoi.
    ResolveConvoy()<suspends> : logic =
        var VoleursHoldSeconds : float = 0.0
        RequiredHold := 20.0
        loop:
            Sleep(0.5)
            if (RoundOver?):
                return false
            var VoleursIn : int = 0
            var PoliceIn : int = 0
            for (A : ConvoyCaptureArea.GetAgentsInArea()):
                if (TeamSetup.IsVoleur[A]):
                    set VoleursIn += 1
                else if (TeamSetup.IsPolice[A]):
                    set PoliceIn += 1
            if (VoleursIn > PoliceIn):
                set VoleursHoldSeconds += 0.5
                if (VoleursHoldSeconds >= RequiredHold):
                    return true
            else if (PoliceIn > 0):
                set VoleursHoldSeconds = Max(0.0, VoleursHoldSeconds - 0.5)

    # --- Score -------------------------------------------------------
    OnLootDeposited(Data : tuple(agent, int)) : void =
        AwardVoleurs(Data(1))

    AwardVoleurs(Points : int) : void =
        set VoleursScore += Points
        Print("[CityHeist] Score Voleurs = {VoleursScore}")

    AwardPolice(Points : int) : void =
        PoliceScore.SetScoreAward(Points)
        for (P : GetPlayspace().GetPlayers(), TeamSetup.IsPolice[P]):
            PoliceScore.Activate(P)
        Print("[CityHeist] Score Police credite (+{Points}).")

    OnArrest(Agent : agent) : void =
        set PoliceArrests += 1
        AwardPolice(1)
        Print("[CityHeist] Arrestations police = {PoliceArrests}")

    OnRelease(Agent : agent) : void =
        Print("[CityHeist] {Agent} libere.")

    # --- Conditions de victoire -------------------------------------
    WatchVictoryConditions()<suspends> : void =
        loop:
            Sleep(1.0)
            if (RoundOver?):
                break
            if (VoleursScore >= VoleursWinScore):
                EndRound(VoleursWin := true)
                break
            if (PoliceArrests >= PoliceWinIfArrestsReach):
                EndRound(VoleursWin := false)
                break

    DeclareWinnerByScore() : void =
        if (not RoundOver?):
            # A egalite de temps, on compare score voleurs vs arrestations*2.
            PoliceEquivalent := PoliceArrests * 2
            EndRound(VoleursWin := VoleursScore > PoliceEquivalent)

    EndRound(VoleursWin : logic) : void =
        if (not RoundOver?):
            set RoundOver = true
            RoundTimer.Pause()
            if (VoleursWin?):
                HUD.ShowToAll(HUD.MsgVoleursWin)
            else:
                HUD.ShowToAll(HUD.MsgPoliceWin)
            Print("[CityHeist] === FIN DE MANCHE. Voleurs gagnent: {VoleursWin} ===")
            # Termine la partie via le device dedie (a regler sur l'equipe
            # gagnante dans UEFN, ou utilisez deux end_game_device).
            EndGameDevice.Activate(GetPlayspace().GetPlayers()[0])
