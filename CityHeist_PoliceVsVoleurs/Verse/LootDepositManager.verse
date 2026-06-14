# =====================================================================
#  CITY HEIST - POLICE VS VOLEURS
#  LootDepositManager.verse
#  Role : Gere le depot du butin a la planque. Le butin ne rapporte des
#         points QUE lorsqu'un voleur le ramene vivant a la zone de
#         depot. La police peut intercepter le butin avant le depot.
#
#  Implementation conseillee dans UEFN :
#   - Chaque "Item Spawner" de butin produit un objet ramassable
#     (ex: item collectible) associe a un heist_loot_type.
#   - La zone de depot est une "Capture Area" ou un "Mutator Zone".
#     Quand un voleur porteur de butin y entre, on attribue les points.
#   - L'interception se gere via l'elimination du porteur (PrisonManager)
#     qui fait tomber/retirer le butin (RemoveCarriedLoot).
# =====================================================================

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

city_heist_loot_deposit_manager := class(creative_device):

    # --- Devices physiques ------------------------------------------
    @editable
    DepositZone : capture_area_device = capture_area_device{}   # zone de depot a la planque
    @editable
    DepositVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable
    DepositAudio : audio_player_device = audio_player_device{}

    # --- Managers relies --------------------------------------------
    @editable
    HUD : city_heist_hud_manager = city_heist_hud_manager{}
    @editable
    Wanted : city_heist_wanted_manager = city_heist_wanted_manager{}
    @editable
    TeamSetup : city_heist_team_setup = city_heist_team_setup{}
    @editable
    ScoreManager : score_manager_device = score_manager_device{} # equipe Voleurs

    # --- Points par type de butin -----------------------------------
    @editable
    var BankPoints : int = 5
    @editable
    var JewelryPoints : int = 2
    @editable
    var CasinoPoints : int = 3

    # --- Etat : qui porte quoi --------------------------------------
    # Un agent peut porter plusieurs types de butin a la fois.
    var Carried : [agent][]heist_loot_type = map{}

    # Evenement diffuse au depot (ecoute par GameManager pour le total).
    LootDeposited : event(tuple(agent, int)) = event(tuple(agent, int)){}

    OnBegin<override>()<suspends> : void =
        DepositZone.AgentEntersEvent.Subscribe(OnAgentEntersDeposit)
        Print("[CityHeist] LootDepositManager pret.")

    # --- API appelee par RobberyZone / collectibles -----------------
    # Quand un voleur ramasse le butin produit par une zone.
    PickupLoot(Agent : agent, Loot : heist_loot_type) : void =
        if (TeamSetup.IsVoleur[Agent]):
            var Current : []heist_loot_type = array{}
            if (Existing := Carried[Agent]):
                set Current = Existing
            set Current += array{Loot}
            if (set Carried[Agent] = Current) {}
            Print("[CityHeist] {Agent} porte maintenant un butin ({Loot}).")

    # Quand la police intercepte / le porteur est arrete : butin perdu.
    RemoveCarriedLoot(Agent : agent) : void =
        if (Carried[Agent]):
            if (Carried.RemoveKey[Agent]) {}
            Wanted.RemoveStars(1)   # plus discret sans butin
            Print("[CityHeist] Butin perdu par {Agent} (interception police).")

    # --- Depot a la planque -----------------------------------------
    OnAgentEntersDeposit(Agent : agent) : void =
        if (TeamSetup.IsVoleur[Agent], LootList := Carried[Agent], LootList.Length > 0):
            var Total : int = 0
            for (Loot : LootList):
                set Total += PointsFor(Loot)
            # Reset du portage et attribution des points.
            if (Carried.RemoveKey[Agent]) {}
            ScoreManager.SetScoreAward(Total)
            ScoreManager.Activate(Agent)
            DepositVFX.Enable()
            DepositAudio.Play()
            Wanted.RemoveStars(1)
            HUD.ShowToAll(HUD.MsgLootDeposited(Total))
            LootDeposited.Signal((Agent, Total))
            Print("[CityHeist] Depot reussi : +{Total} points (Voleurs).")

    PointsFor(Loot : heist_loot_type)<transacts> : int =
        case (Loot):
            heist_loot_type.BankBag     => BankPoints
            heist_loot_type.Jewelry     => JewelryPoints
            heist_loot_type.CasinoChips => CasinoPoints
