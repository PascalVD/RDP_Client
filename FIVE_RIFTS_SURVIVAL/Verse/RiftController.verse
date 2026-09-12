# =====================================================================
#  FIVE RIFTS: SURVIVAL  (projet RIFT_DUO_1918)
#  RiftController.verse   —   MODE SOLO / individuel
#  Role : Logique d'UNE carte (rift). Placez une instance par carte
#         (Ashford 1918, Neon Future, Black Sand, Whiteout, Drowned).
#
#  Cycle (handoff 2/3) :
#   1. Director appelle StartRift(director, players).
#   2. Joueurs teleportes a l'entree du rift, zone du rift activee.
#   3. La zone se retrecit (ZoneManager), le combat elimine des joueurs.
#   4. Quand survivants <= Quota (SurvivorPercent des entrants du rift),
#      ou temps ecoule, on cloture -> Director.OnRiftComplete(survivants).
#   5. Le dernier rift (IsFinalArena) va jusqu'au dernier survivant.
#
#  Regroupement des eliminations simultanees avant calcul du quota
#  (handoff 3) : on evalue le seuil sur un tick regulier, pas a chaud.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

five_rifts_controller := class(creative_device):

    @editable
    var RiftName : string = "Neon Future"
    @editable
    var IsFinalArena : logic = false   # true pour la 5e carte

    # --- Devices relies ---------------------------------------------
    @editable
    HUD : five_rifts_hud = five_rifts_hud{}
    @editable
    Zone : five_rifts_zone = five_rifts_zone{}
    @editable
    EntryTeleporter : teleporter_device = teleporter_device{}   # arrivee des survivants
    @editable
    StartBarrier : barrier_device = barrier_device{}
    @editable
    RoundTimer : timer_device = timer_device{}

    # --- Reglages ---------------------------------------------------
    @editable
    var SurvivorPercent : float = 50.0   # % d'entrants qui se qualifient ici
    @editable
    var MinSurvivors : int = 2           # plancher (sauf arene finale = 1)
    @editable
    var CountdownSeconds : float = 5.0
    @editable
    var MaxRoundSeconds : float = 240.0

    # --- Etat -------------------------------------------------------
    var Director : ?five_rifts_director = false
    var Entrants : int = 0
    var Quota : int = 2
    var AliveSet : [agent]logic = map{}
    var Running : logic = false

    StartRift(Dir : five_rifts_director, Players : []agent) : void =
        set Director = option{Dir}
        set Entrants = Players.Length
        set Quota = ComputeQuota(Players.Length)
        var NewAlive : [agent]logic = map{}
        for (P : Players):
            EntryTeleporter.Teleport(P)
            if (set NewAlive[P] = true) {}
        set AliveSet = NewAlive
        HUD.ShowStatus(RiftIndexGuess(), 5, Entrants, Quota)
        Print("[FiveRifts] Rift '{RiftName}' : {Entrants} entrants -> quota {Quota} (final={IsFinalArena}).")
        spawn{ RunRift(Players) }

    RunRift(Players : []agent)<suspends> : void =
        set Running = true
        StartBarrier.Enable()
        HUD.ToAll(HUD.MsgLobby(Round[CountdownSeconds]))
        Sleep(CountdownSeconds)
        StartBarrier.Disable()
        Zone.StartZone()                    # demarre le retrecissement de zone
        RoundTimer.SetActiveDuration(MaxRoundSeconds)
        RoundTimer.Reset()
        RoundTimer.Start()
        race:
            WatchEliminations(Players)
            TimeoutThenComplete()

    WatchEliminations(Players : []agent)<suspends> : void =
        for (P : Players):
            SubscribePlayer(P)
        GetPlayspace().PlayerAddedEvent().Subscribe(SubscribePlayer)
        loop:
            Sleep(0.5)                       # tick : regroupe les elims simultanees
            if (not Running?):
                break
            HUD.ShowStatus(RiftIndexGuess(), 5, AliveCount(), Quota)
            if (SeuilAtteint[]):
                CompleteRift()
                break

    SubscribePlayer(P : player) : void =
        if (FortChar := P.GetFortCharacter[]):
            FortChar.EliminatedEvent().Subscribe(OnEliminated)

    OnEliminated(Result : elimination_result) : void =
        if:
            Running?
            Victim := Result.EliminatedCharacter.GetAgent[]
            AliveSet[Victim]
        then:
            var NewAlive : [agent]logic = map{}
            for (K -> _ : AliveSet, K <> Victim):
                if (set NewAlive[K] = true) {}
            set AliveSet = NewAlive
            if (Dir := Director?):
                Dir.RecordElimination(Victim)
            HUD.ToAll(HUD.MsgEliminated(AliveCount()))

    TimeoutThenComplete()<suspends> : void =
        Sleep(MaxRoundSeconds)
        if (Running?):
            HUD.ToAll(HUD.MsgTiebreak)      # temps ecoule : departage (handoff 3)
            CompleteRift()

    CompleteRift() : void =
        if (Running?):
            set Running = false
            Zone.StopZone()
            RoundTimer.Pause()
            Survivors := AliveAgents()
            Print("[FiveRifts] Rift '{RiftName}' cloture : {Survivors.Length} survivant(s).")
            if (Dir := Director?):
                Dir.OnRiftComplete(Survivors)

    # --- Regle de fin de rift ---------------------------------------
    SeuilAtteint()<transacts><decides> : void =
        Target := if (IsFinalArena?) then 1 else Quota
        AliveCount() <= Target

    ComputeQuota(N : int)<transacts> : int =
        if (IsFinalArena?):
            return 1
        Raw := (Float(N) * SurvivorPercent) / 100.0
        Ceiled := Ceil[Raw] or Round[Raw]
        return Max(1, Min(Max(Ceiled, MinSurvivors), N - 1))

    # --- Helpers ----------------------------------------------------
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

    # Index d'affichage (1..5). Reglez-le si besoin via l'ordre dans le Director.
    RiftIndexGuess()<transacts> : int = 1
