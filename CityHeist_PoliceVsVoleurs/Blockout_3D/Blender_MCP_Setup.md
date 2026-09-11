# Blender + Claude — deux façons de faire — CITY HEIST

> ⚠️ Comme pour UEFN, tout ceci se fait **sur ta machine**. Je ne peux pas
> configurer ton Blender à distance depuis le cloud.

## Chemin 1 — Sans Claude (recommandé pour démarrer)
Tu n'as **rien à connecter**. Le blockout est généré par un script.

1. Installe **Blender 3.6+** : https://www.blender.org
2. Dans ce dossier, lance :
   ```bash
   blender --background --python generate_blockout.py
   ```
3. Résultat dans `export/` : `CityHeist_Blockout.fbx` (+ .glb + un FBX par bâtiment).

C'est suffisant pour toute la map. Passe directement à l'import UEFN.

---

## Chemin 2 — Piloter Blender avec Claude (Blender MCP, optionnel)
Utile seulement si tu veux **améliorer** le blockout en langage naturel
(détailler des bâtiments, ajouter du mobilier, etc.) au lieu d'éditer le script.

Plugin communautaire : **`blender-mcp`** — https://github.com/ahujasid/blender-mcp
(non officiel, mais très répandu et fiable).

### 1. Installer `uv` (fournit la commande `uvx`)
- **macOS** : `brew install uv` ou `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **Windows** : `powershell -c "irm https://astral.sh/uv/install.ps1 | iex"`
- ⚠️ N'utilise PAS `pip install uv` (ne crée pas toujours `uvx`).

### 2. Installer l'addon dans Blender
- Télécharge `addon.py` depuis le repo `ahujasid/blender-mcp`.
- Blender → **Edit → Preferences → Add-ons → Install from Disk** → choisis `addon.py`.
- Coche **Interface: Blender MCP** pour l'activer.
- (Alternative : `uvx blender-mcp install-addon`.)

### 3. Configurer Claude Desktop
- **Settings → Developer → Edit Config** → ouvre `claude_desktop_config.json`
  (emplacement : voir `../Build_Instructions/Claude_Desktop_Setup.md`).
- Ajoute (voir aussi `blender_mcp_config.example.json`) :
```json
{
  "mcpServers": {
    "blender": {
      "command": "uvx",
      "args": ["blender-mcp"]
    }
  }
}
```
- **Windows** : si `uvx` n'est pas trouvé, mets le chemin complet, p.ex.
  `"command": "C:\\Users\\<toi>\\.local\\bin\\uvx.exe"`.
- **Redémarre complètement Claude Desktop.**

### 4. Connecter dans Blender
- Ouvre Blender → panneau latéral de la 3D View (touche **N**) → onglet
  **BlenderMCP** → **Connect / Start MCP Server**.
- Dans Claude, l'outil **blender** doit apparaître.

### Règles importantes
- **Une seule** instance du serveur MCP à la fois (soit Claude Desktop, soit
  Claude Code / Cursor — pas les deux).
- Blender doit rester **ouvert** (le serveur tourne dans Blender).
- Sauvegarde ton `.blend` avant de laisser l'agent modifier la scène.

---

## Que puis-je faire, moi (session cloud) ?
- Écrire/améliorer `generate_blockout.py` (fait ✅) — le chemin 1 ne dépend de rien.
- Te donner la config exacte (ci-dessus).
- **Je ne peux pas** installer uv, l'addon, ni éditer ta config locale à distance.

## Comparatif rapide
| | Chemin 1 (script) | Chemin 2 (Blender MCP) |
|---|---|---|
| Config Claude | aucune | uv + addon + config Desktop |
| Usage | 1 commande, tout généré | modélisation IA interactive |
| Officiel | — (ton propre script) | non (communautaire) |
| Recommandé pour | **démarrer / toute la map** | fignoler / détailler ensuite |
