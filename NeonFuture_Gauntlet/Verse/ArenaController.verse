# =====================================================================
#  NEON FUTURE - GAUNTLET
#  ArenaController.verse
#  Role : Logique d'UNE arene (ex : Carte 2 = Neon Future). Reutilisable
#         pour chaque carte du gauntlet (placez une instance par arene).
#
#  Cycle :
#   1. Le Director appelle StartArena(director, players).
#   2. Les joueurs sont teleportes/spawnes dans l'arene, les hazards
#      neon s'activent (voir NeonHazards.verse).
#   3. On surveille les eliminations (combat FFA + hazards).
#   4. Quand le nombre de survivants <= seuil (SurvivorPercent des
#      entrants, plancher MinSurvivors), ou que le temps est ecoule,
#      on cloture : Director.OnArenaComplete(survivants).
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

neon_arena_controller := class(creative_device):

    # --- Identite ---------------------------------------------------
    @editable
    var ArenaName : string = "Carte 2 - Neon Future"

    # --- Devices relies --------------------------------------------
    @editable
    HUD : neon_hud_manager = neon_hud_manager{}
    # Point d'arrivee des joueurs dans cette arene.
    @editable
    EntryTeleporter : teleporter_device = teleporter_device{}
    # Sortie : teleporte les survivants vers l'arene suivante (branchee au
    # Director qui la reutilise ; laissez la destination sur le spawn de la
    # carte suivante). Peut rester vide sur la derniere arene.
    @editable
    ExitTeleporter : teleporter_device = teleporter_device{}
    # Hazards neon de cette arene (grilles laser, zone qui retrecit...).
    @editable
    Hazards : []neon_hazard_device = array{}
    # Barriere de depart (les joueurs sont bloques pendant le compte a rebours).
    @editable
    StartBarrier : barrier_device = barrier_device{}
    # Affichage du nombre de survivants restants.
    @editable
    SurvivorsTracker : tracker_device = tracker_device{}
    @editable
    RoundTimer : timer_device = timer_device{}

    # --- Reglages ---------------------------------------------------
    # Pourcentage d'entrants qui survivent a cette arene (ex 50 => moitie).
    @editable
    var SurvivorPercent : float = 50.0
    # Plancher : ne jamais descendre sous ce nombre de survivants ici.
    @editable
    var MinSurvivors : int = 2
    # Compte a rebours avant ouverture (barriere).
    @editable
    var CountdownSeconds : float = 5.0
    # Temps max de l'arene : au-dela, les survivants du moment avancent.
    @editable
    var MaxRoundSeconds : float = 180.0

    # --- Etat -------------------------------------------------------
    var Director : ?neon_gauntlet_director = false
    var Entrants : int = 0
    var TargetSurvivors : int = 2
    var AliveSet : [agent]logic = map{}
    var Running : logic = false
    var EliminationSub : ?cancelable = false

    # --- API appelee par le Director --------------------------------
    StartArena(Dir : neon_gauntlet_director, Players : []agent) : void =
        set Director = option{Dir}
        set Entrants = Players.Length
        set TargetSurvivors = ComputeTargetSurvivors(Players.Length)
        # Reset alive set.
        var NewAlive : [agent]logic = map{}
        for (P : Players):
            EntryTeleporter.Teleport(P)
            set NewAlive = ConcatMap(NewAlive, P)
        set AliveSet = NewAlive
        SurvivorsTracker.SetMaxProgress(Max(Entrants, 1))
        SurvivorsTracker.SetProgress(Entrants)
        Print("[Neon] Arene '{ArenaName}' : {Entrants} entrants, cible {TargetSurvivors} survivants.")
        spawn{ RunArena(Players) }

    RunArena(Players : []agent)<suspends> : void =
        set Running = true
        StartBarrier.Enable()
        HUD.ShowToAll(HUD.MsgCountdown)
        Sleep(CountdownSeconds)
        StartBarrier.Disable()
        for (H : Hazards):
            H.Activate()
        RoundTimer.SetActiveDuration(MaxRoundSeconds)
        RoundTimer.Reset()
        RoundTimer.Start()
        # Surveille eliminations + temps en parallele.
        race:
            WatchEliminations(Players)
            TimeoutThenAdvance()

    # --- Surveillance des eliminations ------------------------------
    WatchEliminations(Players : []agent)<suspends> : void =
        # Abonne chaque joueur present (et futur, au cas ou).
        for (P : Players):
            SubscribePlayer(P)
        GetPlayspace().PlayerAddedEvent().Subscribe(SubscribePlayer)
        # Boucle de securite : verifie regulierement le seuil.
        loop:
            Sleep(0.5)
            if (not Running?):
                break
            if (AliveCount() <= TargetSurvivors):
                CompleteArena()
                break

    SubscribePlayer(P : player) : void =
        if (FortChar := P.GetFortCharacter[]):
            FortChar.EliminatedEvent().Subscribe(OnEliminated)

    OnEliminated(Result : elimination_result) : void =
        if:
            Running?
            Victim := Result.EliminatedCharacter.GetAgent[]
            AliveSet[Victim]   # etait bien en vie dans cette arene
        then:
            set AliveSet = RemoveFromMap(AliveSet, Victim)
            SurvivorsTracker.SetProgress(AliveCount())
            if (Dir := Director?):
                Dir.RecordElimination(Victim)
            if (AliveCount() <= TargetSurvivors):
                CompleteArena()

    TimeoutThenAdvance()<suspends> : void =
        Sleep(MaxRoundSeconds)
        if (Running?):
            HUD.ShowToAll(HUD.MsgTimeUp)
            CompleteArena()

    # --- Cloture de l'arene -----------------------------------------
    CompleteArena() : void =
        if (Running?):
            set Running = false
            for (H : Hazards):
                H.Deactivate()
            RoundTimer.Pause()
            Survivors := AliveAgents()
            for (S : Survivors):
                if (ExitTeleporter.GetTeleportDestinations[]) {}  # no-op de garde
            Print("[Neon] Arene '{ArenaName}' cloturee. {Survivors.Length} survivant(s).")
            if (Dir := Director?):
                Dir.OnArenaComplete(Survivors)

    # --- Helpers ----------------------------------------------------
    ComputeTargetSurvivors(N : int)<transacts> : int =
        # ceil(N * pct/100), borne par [MinSurvivors, N-1] (au moins 1 elimine).
        Raw := (Float(N) * SurvivorPercent) / 100.0
        Ceiled := Ceil[Raw] or Round[Raw]
        Floored := Max(Ceiled, MinSurvivors)
        return Max(1, Min(Floored, N - 1))

    AliveCount()<transacts> : int =
        var C : int = 0
        for (_ -> _ : AliveSet):
            set C += 1
        return C

    AliveAgents()<transacts> : []agent =
        var Out : []agent = array{}
        for (A -> _ : AliveSet):
            set Out += array{A}
        return Out

    ConcatMap(M : [agent]logic, A : agent)<transacts> : [agent]logic =
        var Copy : [agent]logic = M
        if (set Copy[A] = true) {}
        return Copy

    RemoveFromMap(M : [agent]logic, A : agent)<transacts> : [agent]logic =
        var Out : [agent]logic = map{}
        for (K -> V : M, K <> A):
            set Out = ConcatMap(Out, K)
        return Out
