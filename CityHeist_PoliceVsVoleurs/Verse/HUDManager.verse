# =====================================================================
#  CITY HEIST - POLICE VS VOLEURS
#  HUDManager.verse
#  Role : Point central pour tous les messages HUD du mode.
#         Les autres managers appellent ce device au lieu de parler
#         directement aux "HUD Message Device", ce qui centralise le
#         ton, la couleur et la localisation FR des messages.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

city_heist_hud_manager := class(creative_device):

    # HUD Message devices a placer dans le niveau (un par usage).
    @editable
    BannerBroadcast : hud_message_device = hud_message_device{}   # message plein ecran, tout le monde
    @editable
    BannerPolice : hud_message_device = hud_message_device{}      # message reserve equipe police
    @editable
    BannerVoleurs : hud_message_device = hud_message_device{}     # message reserve equipe voleurs

    # Pour les objectifs persistants on s'appuie sur Tracker Device,
    # gere par les managers concernes ; ici on ne fait que du texte.

    # --- API de messages -------------------------------------------

    # Message global a tous les joueurs.
    ShowToAll(Message : message) : void =
        BannerBroadcast.SetText(Message)
        BannerBroadcast.Show()

    # Message a un seul agent.
    ShowToAgent(Agent : agent, Message : message) : void =
        BannerBroadcast.SetText(Message)
        BannerBroadcast.Show(Agent)

    ShowToPolice(Message : message) : void =
        BannerPolice.SetText(Message)
        BannerPolice.Show()

    ShowToVoleurs(Message : message) : void =
        BannerVoleurs.SetText(Message)
        BannerVoleurs.Show()

    # --- Bibliotheque de messages localises (FR) -------------------
    # On utilise des fonctions <localizes> : UEFN cree automatiquement
    # une cle de localisation par message.

    MsgRoundStart<localizes> : message = "Manche lancee ! Voleurs : preparez vos braquages. Police : protegez la ville."
    MsgBankStarted<localizes>(P : agent) : message = "ALARME BANQUE ! Un braquage est en cours."
    MsgBankDone<localizes> : message = "Le coffre de la banque est ouvert ! +5 si le butin atteint la planque."
    MsgJewelryDone<localizes> : message = "Bijouterie devalisee ! +2 pour les voleurs."
    MsgCasinoDone<localizes> : message = "Casino braque ! +3 pour les voleurs."
    MsgLootDeposited<localizes>(Points : int) : message = "Butin depose a la planque ! +{Points} points pour les Voleurs."
    MsgArrested<localizes> : message = "Vous etes arrete ! Direction la prison (30s)."
    MsgEscaped<localizes> : message = "Evasion reussie ! Retournez en ville."
    MsgFreed<localizes> : message = "Un complice vous a libere ! Filez."
    MsgConvoy<localizes> : message = "CONVOI BLINDE ! Voleurs : attaquez-le. Police : escortez-le. +5 points."
    MsgPoliceWin<localizes> : message = "VICTOIRE DE LA POLICE ! La ville est securisee."
    MsgVoleursWin<localizes> : message = "VICTOIRE DES VOLEURS ! Le casse du siecle est reussi."

    OnBegin<override>()<suspends> : void =
        Print("[CityHeist] HUDManager pret.")
