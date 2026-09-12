# =====================================================================
#  NEON FUTURE - GAUNTLET
#  HUDManager.verse
#  Role : Messages HUD centralises du gauntlet (FR). Meme principe que
#         le HUDManager de City Heist : les autres managers passent par
#         ce device au lieu de parler aux HUD Message directement.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }

neon_hud_manager := class(creative_device):

    @editable
    Banner : hud_message_device = hud_message_device{}      # message global
    @editable
    Personal : hud_message_device = hud_message_device{}    # message a un joueur

    ShowToAll(Message : message) : void =
        Banner.SetText(Message)
        Banner.Show()

    ShowToAgent(Agent : agent, Message : message) : void =
        Personal.SetText(Message)
        Personal.Show(Agent)

    # --- Bibliotheque de messages (FR) ------------------------------
    MsgArenaStart<localizes>(N : int) : message = "CARTE {N} — Neon Future. Survivez pour passer a la suivante !"
    MsgCountdown<localizes> : message = "Preparez-vous... la grille neon s'active."
    MsgTimeUp<localizes> : message = "Temps ecoule ! Les survivants avancent."
    MsgEliminated<localizes>(Remaining : int) : message = "ELIMINE. Il reste {Remaining} joueurs en lice."
    MsgAdvance<localizes>(Count : int, NextN : int) : message = "{Count} survivants passent a la Carte {NextN} !"
    MsgYouAdvance<localizes> : message = "Vous survivez ! Direction la carte suivante."
    MsgWinner<localizes> : message = "Le gauntlet est termine — nous avons un vainqueur !"
    MsgYouWin<localizes> : message = "VICTOIRE ! Vous remportez le plus gros butin de pieces d'or."
    MsgCoins<localizes>(Amount : int, Rank : int) : message = "Classe #{Rank} — vous gagnez {Amount} pieces d'or."

    OnBegin<override>()<suspends> : void =
        Print("[Neon] HUDManager pret.")
