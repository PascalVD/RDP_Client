# =====================================================================
#  CITY HEIST - POLICE VS VOLEURS
#  TeamSetup.verse
#  Role : Centralise la configuration des equipes, des classes et
#         expose des helpers reutilisables par les autres scripts.
#
#  IMPORTANT (lire en premier) :
#  - Ce fichier ne cree PAS les equipes tout seul. Dans UEFN les
#    equipes/classes sont definies par les devices "Team Settings &
#    Inventory" et "Class Designer". Ce script lit/utilise ces equipes
#    via l'API Verse et fournit une API stable au reste du projet.
#  - Convention du projet :
#       Team Index 0 => POLICE
#       Team Index 1 => VOLEURS
#    (Reglez vos devices "Team Settings & Inventory" dans le meme ordre.)
# =====================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Identifiant logique d'une equipe, independant de l'index brut.
heist_team_id := enum:
    Police
    Voleurs

# Roles / classes jouables. Mappez chaque valeur sur un Class Designer.
heist_class_id := enum:
    # Police
    Patrol      # pistolet + fusil tactique + stun
    Swat        # plus lent, plus resistant (debloque a 4 etoiles)
    # Voleurs
    Robber      # SMG + fumigene
    Hacker      # grappler + carte d'acces + kit piratage
    Scout       # rapide, peu arme

# Device de configuration global des equipes. Placez-le une seule fois
# dans le niveau et referencez-le depuis les autres managers.
city_heist_team_setup := class(creative_device):

    # --- Reglages editables dans UEFN -------------------------------
    @editable
    var PoliceTeamIndex : int = 0

    @editable
    var VoleursTeamIndex : int = 1

    # Class Designer correspondants (facultatif : sert au passage de
    # classe via Verse, p.ex. debloquer le SWAT a 4 etoiles).
    @editable
    PatrolClassSwitcher : class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    SwatClassSwitcher : class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    RobberClassSwitcher : class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    HackerClassSwitcher : class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    ScoutClassSwitcher : class_and_team_selector_device = class_and_team_selector_device{}

    # --- API publique ----------------------------------------------

    # Retourne l'objet team correspondant a l'identifiant logique.
    GetTeam(TeamId : heist_team_id)<transacts> : ?team =
        Playspace := GetPlayspace()
        TeamCollection := Playspace.GetTeamCollection()
        Teams := TeamCollection.GetTeams()
        Index := if (TeamId = heist_team_id.Police) then PoliceTeamIndex else VoleursTeamIndex
        if (Team := Teams[Index]):
            return option{Team}
        return false

    # Vrai si l'agent appartient a l'equipe logique demandee.
    IsOnTeam(Agent : agent, TeamId : heist_team_id)<transacts> : logic =
        if:
            Team := GetTeam(TeamId)?
            TeamCollection := GetPlayspace().GetTeamCollection()
            TeamCollection.IsOnTeam[Agent, Team]
        then:
            true
        else:
            false

    IsPolice(Agent : agent)<transacts> : logic =
        IsOnTeam(Agent, heist_team_id.Police)

    IsVoleur(Agent : agent)<transacts> : logic =
        IsOnTeam(Agent, heist_team_id.Voleurs)

    # Bascule un agent vers une classe (utile pour debloquer le SWAT).
    SwitchToClass(Agent : agent, ClassId : heist_class_id) : void =
        Switcher := case (ClassId):
            heist_class_id.Patrol => PatrolClassSwitcher
            heist_class_id.Swat   => SwatClassSwitcher
            heist_class_id.Robber => RobberClassSwitcher
            heist_class_id.Hacker => HackerClassSwitcher
            heist_class_id.Scout  => ScoutClassSwitcher
        Switcher.ChangeTeamAndClass(Agent)

    OnBegin<override>()<suspends> : void =
        Print("[CityHeist] TeamSetup pret. Police=Index {PoliceTeamIndex} / Voleurs=Index {VoleursTeamIndex}")
