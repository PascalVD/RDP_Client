# =====================================================================
#  FIVE RIFTS: SURVIVAL  (projet RIFT_DUO_1918)
#  ZoneManager.verse
#  Role : Zone de combat qui se retrecit par paliers (handoff 7), propre
#         a CHAQUE rift. Avertissement HUD + audio avant chaque phase,
#         degats croissants hors zone. La zone doit etre centree sur la
#         zone jouable reelle (handoff 7), pas sur un ancien blockout.
#
#  IMPLEMENTATION UEFN
#  -------------------
#  Deux approches possibles cote devices :
#   A) Storm natif : si vous utilisez un systeme de tempete BR, branchez
#      ses phases sur StartZone/StopZone (ce script pilote le timing/HUD).
#   B) Volumes de degats : fournissez un "Mutator Zone" de degats par
#      PALIER (DamageRings), du plus large au plus serre. A chaque phase,
#      on active l'anneau suivant (= la zone sure retrecit) et on
#      desactive le precedent.
#  Ce script gere le timing, les avertissements et l'enchainement B.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

five_rifts_zone := class(creative_device):

    @editable
    HUD : five_rifts_hud = five_rifts_hud{}

    # Un Mutator Zone de degats par palier (du plus large au plus serre).
    # Chaque anneau inflige des degats aux joueurs HORS de la zone sure.
    @editable
    DamageRings : []mutator_zone_device = array{}
    @editable
    WarningAudio : audio_player_device = audio_player_device{}
    @editable
    ShrinkVFX : vfx_spawner_device = vfx_spawner_device{}

    # Duree de la phase "stable" avant le 1er retrecissement, puis duree
    # de chaque phase de retrecissement.
    @editable
    var FirstPhaseSeconds : float = 30.0
    @editable
    var ShrinkPhaseSeconds : float = 25.0
    @editable
    var WarnSeconds : float = 6.0     # preavis avant chaque retrecissement

    var Running : logic = false
    var Loop : ?cancelable = false

    OnBegin<override>()<suspends> : void =
        for (R : DamageRings):
            R.Disable()
        ShrinkVFX.Disable()
        Print("[FiveRifts] Zone prete ({DamageRings.Length} paliers).")

    # Appele par le RiftController au debut de la manche.
    StartZone() : void =
        if (not Running?):
            set Running = true
            set Loop = option{ spawn{ RunZone() } }

    StopZone() : void =
        if (Running?):
            set Running = false
            if (L := Loop?):
                L.Cancel()
            for (R : DamageRings):
                R.Disable()
            ShrinkVFX.Disable()

    RunZone()<suspends> : void =
        Sleep(FirstPhaseSeconds)
        for (Index -> Ring : DamageRings):
            if (not Running?):
                break
            # Preavis (handoff 7 : avertissement HUD + audio).
            HUD.ToAll(HUD.MsgZoneShrinking)
            WarningAudio.Play()
            ShrinkVFX.Enable()
            Sleep(WarnSeconds)
            # Retrecissement : on active cet anneau de degats, on coupe le
            # precedent (degats croissants vers le centre).
            if (Index > 0, PrevRing := DamageRings[Index - 1]):
                PrevRing.Disable()
            Ring.Enable()
            HUD.ToAll(HUD.MsgZoneDamage)
            Sleep(ShrinkPhaseSeconds)
