# =====================================================================
#  FIVE RIFTS: SURVIVAL  (projet RIFT_DUO_1918)
#  CoinRewardManager.verse   —   MODE SOLO
#  Role : Attribue les PIECES D'OR selon le classement final
#         (1er = plus gros butin, puis degressif). Appele par le
#         SurvivalDirector a la fin du tournoi (AwardByRank).
#
#  Modele des pieces (UEFN n'a pas de monnaie universelle) :
#   A) Item Granter d'un objet "piece d'or" (GoldGranter) ;
#   B) Score Manager = pieces en points (utile pour un classement
#      persistant entre parties).
#  Les deux sont pilotes ; branchez celui que vous utilisez.
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

five_rifts_coins := class(creative_device):

    @editable
    HUD : five_rifts_hud = five_rifts_hud{}
    @editable
    GoldGranter : item_granter_device = item_granter_device{}
    @editable
    CoinScore : score_manager_device = score_manager_device{}

    @editable
    var UseGoldGranter : logic = true
    @editable
    var UseScore : logic = true

    # Bareme (modifiable) : 1er, 2e, 3e, puis participation degressive.
    @editable
    var CoinsRank1 : int = 500
    @editable
    var CoinsRank2 : int = 300
    @editable
    var CoinsRank3 : int = 200
    @editable
    var CoinsBase : int = 100       # rang 4
    @editable
    var CoinsStepDown : int = 5     # -5 pieces par rang au-dela du 3e
    @editable
    var CoinsMinimum : int = 10     # plancher de participation

    AwardByRank(Player : agent, Rank : int, Total : int) : void =
        Amount := CoinsForRank(Rank)
        if (UseScore?):
            CoinScore.SetScoreAward(Amount)
            CoinScore.Activate(Player)
        if (UseGoldGranter?):
            GoldGranter.GrantItem(Player)   # reglez le granter pour donner une pile
        if (Rank = 1):
            HUD.ToAgent(Player, HUD.MsgYouWin(Amount))
        else:
            HUD.ToAgent(Player, HUD.MsgCoins(Amount, Rank))
        Print("[FiveRifts] Rang #{Rank}/{Total} -> {Amount} pieces.")

    CoinsForRank(Rank : int)<transacts> : int =
        case (Rank):
            1 => CoinsRank1
            2 => CoinsRank2
            3 => CoinsRank3
            _ => Max(CoinsMinimum, CoinsBase - (Rank - 4) * CoinsStepDown)

    OnBegin<override>()<suspends> : void =
        Print("[FiveRifts] Coins pret (#1={CoinsRank1}, #2={CoinsRank2}, #3={CoinsRank3}).")
