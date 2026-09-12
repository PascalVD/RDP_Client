# =====================================================================
#  FIVE RIFTS: SURVIVAL  (projet RIFT_DUO_1918)
#  HUDManager.verse
#  MODE : SOLO / individuel (chacun pour soi) — confirme par l'auteur,
#  en remplacement du modele "duos" du handoff d'origine.
#
#  Role : Centralise tout le HUD (handoff section 7), version solo :
#         carte actuelle /5, temps restant, survivants actifs, quota de
#         qualification, etat de la zone, messages qualif/elim/departage.
#  Le SERVEUR est l'autorite du resultat ; ce device ne fait qu'afficher.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }

five_rifts_hud := class(creative_device):

    @editable
    StatusBanner : hud_message_device = hud_message_device{}   # ligne d'etat permanente (tous)
    @editable
    EventBanner : hud_message_device = hud_message_device{}    # messages ponctuels (tous)
    @editable
    PersonalBanner : hud_message_device = hud_message_device{} # messages a un joueur

    @editable
    SurvivorsTracker : tracker_device = tracker_device{}       # survivants actifs
    @editable
    RiftTracker : tracker_device = tracker_device{}            # carte X / 5

    # --- Etat d'affichage -------------------------------------------
    ShowStatus(RiftIndex : int, TotalRifts : int, Survivors : int, Quota : int) : void =
        StatusBanner.SetText(MsgStatus(RiftIndex, TotalRifts, Survivors, Quota))
        StatusBanner.Show()
        SurvivorsTracker.SetProgress(Survivors)
        RiftTracker.SetProgress(RiftIndex)

    ToAll(M : message) : void =
        EventBanner.SetText(M)
        EventBanner.Show()

    ToAgent(A : agent, M : message) : void =
        PersonalBanner.SetText(M)
        PersonalBanner.Show(A)

    # --- Messages localises (FR), version SOLO ----------------------
    MsgStatus<localizes>(Rift : int, Total : int, Survivors : int, Quota : int) : message =
        "CARTE {Rift}/{Total}  •  Survivants : {Survivors}  •  Qualifies : {Quota}"

    MsgRiftIntro<localizes>(Rift : int, Name : string) : message =
        "RIFT {Rift} — {Name}. Survivez pour vous qualifier !"

    MsgZoneShrinking<localizes> : message = "La zone se retrecit — repliez-vous !"
    MsgZoneDamage<localizes> : message = "Hors zone : vous subissez des degats."

    MsgQualified<localizes>(Next : int) : message = "QUALIFIE ! Direction la carte {Next}."
    MsgEliminated<localizes>(Remaining : int) : message = "ELIMINE. Survivants restants : {Remaining}."
    MsgYouSpectate<localizes> : message = "Vous etes elimine — vous suivez la partie en spectateur."
    MsgTiebreak<localizes> : message = "Egalite — departage par eliminations puis degats infliges."

    MsgLobby<localizes>(Seconds : int) : message = "Choisissez votre equipement — depart dans {Seconds}s."
    MsgFinalArena<localizes> : message = "ARENE FINALE — dernier survivant, plus gros butin de pieces d'or !"
    MsgWinner<localizes> : message = "DERNIER SURVIVANT — VICTOIRE !"
    MsgYouWin<localizes>(Coins : int) : message = "VICTOIRE ! Vous remportez {Coins} pieces d'or."
    MsgCoins<localizes>(Coins : int, Rank : int) : message = "Classe #{Rank} — {Coins} pieces d'or."

    OnBegin<override>()<suspends> : void =
        RiftTracker.SetMaxProgress(5)
        Print("[FiveRifts] HUD pret (mode SOLO).")
