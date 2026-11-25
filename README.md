# Windows Desktop Control Skill (Claude + Antigravity + `windows-mcp`)

Skill et script d'installation pour permettre à **Claude Code**, **Claude Desktop** et
**Google Antigravity** (ou tout autre client MCP compatible) de voir et piloter le bureau Windows
via [`windows-mcp`](https://github.com/CursorTouch/Windows-MCP).

## Contenu

- `skills/windows-desktop-control/SKILL.md` — Workflow structuré (*Observe → Act → Verify*) et garde-fous de sécurité pour piloter le bureau Windows.
- `skills/windows-desktop-control/references/tools.md` — Référence rapide des outils exposés par `windows-mcp`.
- `scripts/install.ps1` — Script PowerShell qui installe `windows-mcp` via `uv`, l'enregistre dans chaque agent présent et copie le skill.
- `mcp_config.example.json` — Exemple de configuration MCP prête à l'emploi.

## Installation rapide (Windows)

Prérequis : [`uv`](https://docs.astral.sh/uv/) (`irm https://astral.sh/uv/install.ps1 | iex`). Le script l'installe s'il manque.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Le script enregistre `windows-mcp` **dans tous les agents installés**, en une fois :

| Agent | Où | Skill copié dans |
| :--- | :--- | :--- |
| Google Antigravity | `~/.gemini/config/mcp_config.json` | `~/.gemini/config/skills/` |
| Claude Code | `claude mcp add --scope user` (ou `~/.claude.json` si la commande `claude` est absente) | `~/.claude/skills/` |
| Claude Desktop | `%APPDATA%\Claude\claude_desktop_config.json` | — |

Un agent absent est ignoré, jamais créé. Les autres serveurs MCP ne sont pas touchés, un fichier
JSON illisible est laissé tel quel, et chaque fichier reçoit une sauvegarde
`<fichier>.windows-mcp.bak` avant sa première réécriture. Le script peut être relancé sans risque
(mise à jour de `windows-mcp`, ajout d'un agent installé depuis).

Puis redémarre Antigravity et Claude Desktop (ou recharge les serveurs MCP depuis **… > MCP
Servers** dans Antigravity). Claude Code le voit à sa session suivante (`claude mcp list` pour
vérifier).

## Utilisation

Demande simplement à l'agent ce que tu veux faire sur le bureau :

> Ouvre le Bloc-notes, écris « bonjour » et enregistre sur le Bureau sous essai.txt.

Le skill lui impose la boucle *Observe → Act → Verify* (`Snapshot` avant d'agir, cibles par
libellé plutôt que par coordonnées, `WaitFor` plutôt que des pauses) et une confirmation avant toute
action destructrice ou sensible.

**Pour un site web qui vit dans un profil NovaBrowser** (comptes isolés avec proxy et empreinte),
utilise plutôt le skill `novabrowser-browser-control` du serveur MCP NovaBrowser : il pilote le
navigateur du profil en arrière-plan, sans prendre la souris ni le clavier. Les deux skills ont la
même structure (`SKILL.md` + `references/tools.md`) et s'installent aux mêmes endroits.

## Sécurité

`windows-mcp` donne à l'agent accès à l'écran, à la souris, au clavier et à PowerShell. Il est recommandé de :
- conserver la validation des outils activée dans les réglages d'Antigravity (`request-review`) et dans Claude (ne pas autoriser `windows-mcp` en permanence) ;
- restreindre certains outils si besoin via `--exclude-tools PowerShell,Registry` dans les `args` de la configuration.
