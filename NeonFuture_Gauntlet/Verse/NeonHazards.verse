# =====================================================================
#  NEON FUTURE - GAUNTLET
#  NeonHazards.verse
#  Role : Hazards (dangers) neon d'une arene, qui aident a eliminer les
#         joueurs et donnent le rythme "survie". Chaque hazard est un
#         device active/desactive par l'ArenaController.
#
#  Trois types fournis (choisis via HazardKind) :
#   - LaserSweep    : une grille laser qui balaie une zone (mutator zone
#                     qui inflige des degats quand active).
#   - ShrinkZone    : zone de securite qui retrecit (hors zone = degats).
#   - PulseFloor    : le sol pulse : des dalles deviennent dangereuses par
#                     intermittence.
#  L'implementation reelle des degats se fait via un "Mutator Zone" et/ou
#  des VFX ; ce script pilote le TIMING et l'etat on/off.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

neon_hazard_kind := enum:
    LaserSweep
    ShrinkZone
    PulseFloor

neon_hazard_device := class(creative_device):

    @editable
    var HazardKind : neon_hazard_kind = neon_hazard_kind.LaserSweep

    # Zone de degats (Mutator Zone reglee pour infliger des degats).
    @editable
    DamageZone : mutator_zone_device = mutator_zone_device{}
    # Effets visuels/sonores du hazard.
    @editable
    HazardVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable
    HazardAudio : audio_player_device = audio_player_device{}

    # Cadence du hazard (secondes actif / secondes repos).
    @editable
    var OnSeconds : float = 3.0
    @editable
    var OffSeconds : float = 2.0
    # Delai avant que le hazard commence a etre dangereux (laisse respirer).
    @editable
    var WarmupSeconds : float = 8.0

    var Active : logic = false
    var Loop : ?cancelable = false

    OnBegin<override>()<suspends> : void =
        DamageZone.Disable()
        HazardVFX.Disable()
        Print("[Neon] Hazard '{HazardKind}' pret (off).")

    # Active par l'ArenaController au debut de la manche.
    Activate() : void =
        if (not Active?):
            set Active = true
            set Loop = option{ spawn{ RunHazard() } }

    Deactivate() : void =
        if (Active?):
            set Active = false
            if (L := Loop?):
                L.Cancel()
            DamageZone.Disable()
            HazardVFX.Disable()

    RunHazard()<suspends> : void =
        # Phase d'echauffement : VFX visibles mais pas de degats (telegraphe).
        HazardVFX.Enable()
        Sleep(WarmupSeconds)
        loop:
            if (not Active?):
                break
            # Phase dangereuse.
            DamageZone.Enable()
            HazardAudio.Play()
            Sleep(OnSeconds)
            # Phase de repos.
            DamageZone.Disable()
            Sleep(OffSeconds)
