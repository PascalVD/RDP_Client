# Configurer Claude (Desktop ou Code) pour UEFN — CITY HEIST

> ⚠️ Ces réglages se font **sur TA machine**. Personne (ni moi en cloud) ne peut
> les faire à distance. Mais voici tout à copier-coller.

## Quel outil choisir ?
| Outil | Peut se connecter à un MCP ? | Adapté pour construire la map ? |
|-------|------------------------------|----------------------------------|
| **Claude Code** (CLI/IDE) | ✅ | ✅ **Recommandé** (écrit/compile Verse, place devices, teste) |
| **Claude Desktop** (app chat) | ✅ (via config) | ⚠️ Limité — pas conçu pour le workflow éditeur/dev |

➡️ **Pour ce projet, installe Claude Code.** Garde Claude Desktop pour discuter.

---

## Étape commune : activer l'Unreal MCP dans UEFN
1. Ouvre ton projet dans **UEFN**.
2. **Edit → Project Settings → Beta Access**.
3. Active **UEFN MCP Toolset**. Redémarre si demandé.
4. UEFN affiche alors la **commande / l'adresse** du serveur MCP local.
   👉 **Note-la** : c'est la seule valeur que moi je ne peux pas connaître
   (elle est propre à ta machine). Tu la colleras dans `<VALEUR_UEFN>` ci-dessous.

---

## Option A — Claude Code (recommandé)

En ligne de commande, une seule ligne :
```bash
claude mcp add uefn -- <VALEUR_UEFN>
claude mcp list          # doit afficher "uefn : connected"
```
Puis dans Claude Code : tape `/mcp` → vérifie que **uefn** est connecté.
Ensuite, ouvre `Assembly_Prompts.md` et colle les prompts dans l'ordre.

---

## Option B — Claude Desktop

Claude Desktop lit un fichier `claude_desktop_config.json`.

### Où est le fichier ?
- **Windows** : `%APPDATA%\Claude\claude_desktop_config.json`
  (ex. `C:\Users\<toi>\AppData\Roaming\Claude\claude_desktop_config.json`)
- **macOS** : `~/Library/Application Support/Claude/claude_desktop_config.json`

Si le fichier n'existe pas, crée-le. Tu peux aussi passer par
**Settings → Developer → Edit Config** dans l'app.

### Contenu à coller
Voir le fichier voisin `claude_desktop_config.example.json`. Remplace
`<VALEUR_UEFN>` par ce qu'affiche UEFN (souvent une commande + arguments, ou une
URL si le transport est http/sse).

Cas 1 — le serveur MCP est une **commande** (stdio) :
```json
{
  "mcpServers": {
    "uefn": {
      "command": "<CHEMIN_DE_LA_COMMANDE>",
      "args": ["<arg1>", "<arg2>"]
    }
  }
}
```

Cas 2 — le serveur MCP est une **URL** (http/sse) : Claude Desktop pilote les
serveurs distants via un pont `mcp-remote`. Exemple :
```json
{
  "mcpServers": {
    "uefn": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "<URL_UEFN>"]
    }
  }
}
```

### Appliquer
1. Enregistre le fichier.
2. **Quitte complètement Claude Desktop puis relance-le** (obligatoire pour
   recharger la config).
3. Dans une conversation, l'icône outils/MCP doit montrer **uefn**.

---

## Ce que je ne peux PAS faire (et pourquoi)
- Éditer `claude_desktop_config.json` sur ton PC : je n'ai pas accès à ta machine.
- Connaître `<VALEUR_UEFN>` : elle est générée localement par ton UEFN.
- Cliquer dans ton UEFN / ton app.

## Ce que je PEUX faire
- Te fournir tous les fichiers, configs et prompts (fait ✅).
- Relire une capture d'écran de l'erreur si la connexion échoue, et te dire quoi
  corriger.
- Générer le prompt de construction de la map à coller une fois connecté.

## Dépannage rapide
- **uefn n'apparaît pas** : mauvais chemin de config, ou app pas totalement
  redémarrée. Vérifie le JSON (virgules !) sur un validateur.
- **"server failed to start"** : la `<VALEUR_UEFN>` est incorrecte, ou UEFN
  n'est pas ouvert (le serveur MCP tourne quand UEFN est lancé).
- **JSON invalide** : une virgule en trop / manquante casse tout — recolle
  l'exemple proprement.
