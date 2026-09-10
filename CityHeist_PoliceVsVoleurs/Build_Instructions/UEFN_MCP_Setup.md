# Installer / activer l'Unreal MCP pour piloter UEFN avec Claude — CITY HEIST

> ⚠️ Ces étapes se font **sur ta machine** (UEFN + Claude Code local). Elles ne
> peuvent pas être exécutées depuis un environnement cloud distant.

Deux voies : **(A) l'Unreal MCP officiel d'Epic** (recommandé, rien à installer)
et **(B) un serveur MCP communautaire** (plus de contrôle, installation manuelle).

---

## A. Unreal MCP officiel (intégré à UEFN) — recommandé

Aucun plugin à télécharger : c'est **inclus dans UEFN**, il suffit de l'activer.

### 1. Pré-requis
- **UEFN à jour** (version récente supportant l'Unreal MCP — beta).
- **Claude Code** installé et connecté sur la même machine (CLI, app desktop,
  ou extension IDE).

### 2. Activer le MCP Toolset dans UEFN
1. Ouvre ton projet dans **UEFN**.
2. **Edit → Project Settings**.
3. Section **Beta Access** (ou "Experimental").
4. Active **UEFN MCP Toolset** (coche la case).
5. Redémarre UEFN si demandé.

> Le nom exact du réglage peut varier selon la version. Cherche « MCP » dans la
> barre de recherche des Project Settings.

### 3. Connecter Claude Code à l'éditeur
- UEFN expose un **serveur MCP local** quand le toolset est actif.
- Dans Claude Code, ajoute ce serveur MCP. Selon la doc Epic, UEFN fournit
  l'adresse/commande de connexion (souvent un endpoint local `stdio` ou une
  URL `http`/`sse`). Exemple de config Claude Code (`.mcp.json` du projet
  **local**, PAS ce repo cloud) :

```jsonc
{
  "mcpServers": {
    "uefn": {
      // Remplace par la commande/URL exacte affichée par UEFN quand le
      // MCP Toolset est actif (voir Project Settings > MCP).
      "type": "stdio",
      "command": "<commande fournie par UEFN>",
      "args": []
    }
  }
}
```

- Ou en ligne de commande :
  ```bash
  claude mcp add uefn -- <commande fournie par UEFN>
  claude mcp list        # vérifie que "uefn" est connecté
  ```

### 4. Vérifier
- Dans Claude Code : `/mcp` (session interactive) doit lister **uefn** comme
  connecté, avec ses outils (écrire/compiler du Verse, placer des devices,
  Scene Graph, UMG, lancer une session de test).

### 5. Doc officielle
- https://dev.epicgames.com/documentation/fortnite/uefn-mcp
- https://www.fortnite.com/news/unreal-mcp-is-now-available-in-uefn

---

## B. Serveur MCP communautaire (alternative)

Si tu veux un pont open-source (plus d'outils bas niveau, exécution Python, etc.).

### Exemple : uefn-mcp-server
```bash
# 1. Cloner
git clone https://github.com/kirchuvakov/uefn-mcp-server
cd uefn-mcp-server

# 2. Installer (suivre le README du repo — dépendances Python/Node)
#    puis récupérer la commande de lancement du serveur.

# 3. Déclarer dans Claude Code (machine locale)
claude mcp add uefn-community -- <commande de lancement du serveur>
```

Autre pont : https://github.com/quangdang46/uefn-verse-mcp

> ⚠️ Ce sont des projets tiers : lis leur README, vérifie la compatibilité avec
> ta version d'UEFN et **sauvegarde ton projet** avant de laisser un agent
> modifier le niveau.

---

## Une fois connecté : construire CITY HEIST
- Utilise **`Assembly_Prompts.md`** : des prompts prêts à copier-coller, un par
  étape de `Assembly_Checklist.md`, dans le bon ordre de branchement.
- Donne à l'agent le contexte des fichiers du repo (`Verse/`, `Devices_List.md`,
  `Placement_Plan.md`) : il pourra écrire le Verse, placer et brancher les
  devices, puis lancer une session de test.

## Précautions
- L'Unreal MCP est en **beta** : comportements changeants, garde une **copie de
  sauvegarde** du `.uproject` avant chaque grosse manip agentique.
- Vérifie chaque compilation Verse et chaque placement avant de continuer.
