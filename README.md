# Windows Desktop Control Skill (Antigravity + `windows-mcp`)

Skill et script d'installation pour permettre à **Google Antigravity** (ou tout autre client MCP compatible) de voir et piloter le bureau Windows via [`windows-mcp`](https://github.com/CursorTouch/Windows-MCP).

## Contenu

- `skills/windows-desktop-control/SKILL.md` — Workflow structuré (*Observe → Act → Verify*) et garde-fous de sécurité pour piloter le bureau Windows.
- `skills/windows-desktop-control/references/tools.md` — Référence rapide des outils exposés par `windows-mcp`.
- `scripts/install.ps1` — Script PowerShell qui installe `windows-mcp` via `uv`, l'ajoute à `~/.gemini/config/mcp_config.json` et copie le skill dans `~/.gemini/config/skills/`.
- `mcp_config.example.json` — Exemple de configuration MCP prête à l'emploi.

## Installation rapide (Windows)

Prérequis : [`uv`](https://docs.astral.sh/uv/) (`irm https://astral.sh/uv/install.ps1 | iex`).

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Puis redémarre Antigravity (ou recharge les serveurs MCP depuis **... > MCP Servers**) pour activer les outils `windows-mcp`.

## Sécurité

`windows-mcp` donne à l'agent accès à l'écran, à la souris, au clavier et à PowerShell. Il est recommandé de :
- conserver la validation des outils activée dans les réglages d'Antigravity (`request-review`),
- restreindre certains outils si besoin via `--exclude-tools PowerShell,Registry` dans `mcp_config.json`.
