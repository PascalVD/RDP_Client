# =====================================================================
#  NEON FUTURE - GAUNTLET
#  CoinRewardManager.verse
#  Role : Attribue les pieces d'or en fonction du CLASSEMENT final.
#         Appele par le GauntletDirector a la fin (AwardByRank).
#
#  Modele des pieces
#  -----------------
#  UEFN n'a pas de "monnaie" universelle. Deux options (au choix) :
#   A) Item Granter d'un objet "Piece d'or" (barre d'or / gold) : on
#      accorde N fois l'objet au joueur (GoldGranter).
#   B) Score Manager : les pieces = points, additionnes au score global
#      (utile pour un classement persistant entre parties via stats).
#  Ce script pilote les deux ; branchez celui que vous utilisez.
#
#  Bareme par defaut (modifiable) : degressif selon le rang.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

neon_coin_manager := class(creative_device):

    @editable
    HUD : neon_hud_manager = neon_hud_manager{}

    # Option A : granter d'objet "piece d'or".
    @editable
    GoldGranter : item_granter_device = item_granter_device{}
    # Option B : score/monnaie.
    @editable
    CoinScore : score_manager_device = score_manager_device{}

    @editable
    var UseGoldGranter : logic = true
    @editable
    var UseScore : logic = true

    # Bareme : pieces pour le rang 1, 2, 3, puis valeur "au-dela".
    @editable
    var CoinsRank1 : int = 100
    @editable
    var CoinsRank2 : int = 60
    @editable
    var CoinsRank3 : int = 40
    # Les autres rangs : recompense de participation degressive.
    @editable
    var CoinsBase : int = 20        # rang 4
    @editable
    var CoinsStepDown : int = 2     # -2 pieces par rang au-dela du 3e

    # Attribue les pieces a un joueur selon son rang (1 = vainqueur).
    AwardByRank(Player : agent, Rank : int, Total : int) : void =
        Amount := CoinsForRank(Rank)
        if (UseScore?):
            CoinScore.SetScoreAward(Amount)
            CoinScore.Activate(Player)
        if (UseGoldGranter?):
            # Accorde l'objet "piece" ; repetez pour representer le montant.
            # (En pratique, reglez le GoldGranter pour donner une pile.)
            GoldGranter.GrantItem(Player)
        HUD.ShowToAgent(Player, HUD.MsgCoins(Amount, Rank))
        Print("[Neon] Rang #{Rank}/{Total} -> {Amount} pieces pour {Player}.")

    CoinsForRank(Rank : int)<transacts> : int =
        case (Rank):
            1 => CoinsRank1
            2 => CoinsRank2
            3 => CoinsRank3
            _ => Max(0, CoinsBase - (Rank - 4) * CoinsStepDown)

    OnBegin<override>()<suspends> : void =
        Print("[Neon] CoinRewardManager pret (bareme #1={CoinsRank1}, #2={CoinsRank2}, #3={CoinsRank3}).")
