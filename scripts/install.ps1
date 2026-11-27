$ErrorActionPreference = "Stop"

# Installs windows-mcp and registers it, in one go, in every agent found on this machine:
#   - Google Antigravity : ~/.gemini/config/mcp_config.json  (+ skill in ~/.gemini/config/skills/)
#   - Claude Code        : `claude mcp add --scope user`, or ~/.claude.json  (+ skill in ~/.claude/skills/)
#   - Claude Desktop     : %APPDATA%\Claude\claude_desktop_config.json
# An agent that is not installed is skipped, never created. Other MCP servers are left untouched,
# and each config file gets a one-time backup (<file>.windows-mcp.bak) before its first rewrite.

$ServerName = "windows-mcp"
$SkillName  = "windows-desktop-control"

# 1. Verify uv is installed
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv..."
    irm https://astral.sh/uv/install.ps1 | iex
}

# 2. Install windows-mcp tool
Write-Host "Installing windows-mcp..."
uv tool install windows-mcp --upgrade
if ($LASTEXITCODE -ne 0) {
    # Typical cause: a running windows-mcp (started by Antigravity or Claude) locks its folder, and
    # uv stops halfway through - the old package removed, the new one not installed. Stop here
    # rather than register a server that cannot start.
    throw "uv could not install windows-mcp (exit code $LASTEXITCODE). If it is in use, quit Antigravity and Claude Desktop, then run this script again."
}

$exePath = Join-Path $env:USERPROFILE ".local\bin\windows-mcp.exe"
if (-not (Test-Path $exePath)) {
    throw "windows-mcp.exe not found at $exePath"
}
$serverArgs = @("serve", "--transport", "stdio")

# Writes UTF-8 *without* BOM: Windows PowerShell 5.1's `Set-Content -Encoding UTF8` adds one, and
# Node's JSON.parse (Claude Code, Claude Desktop) rejects a file that starts with it.
function Write-Utf8NoBom([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding $false))
}

# Adds or replaces mcpServers.<ServerName> in a JSON config file, keeping everything else.
# -Depth 100: ~/.claude.json nests deeper than the default (2) or 10, and ConvertTo-Json silently
# flattens whatever lies beyond the depth it is given.
function Set-McpServer([string]$Path, [hashtable]$Entry) {
    $dir = Split-Path -Parent $Path
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    if (Test-Path $Path) {
        $raw = [System.IO.File]::ReadAllText($Path)
        try {
            $config = $raw.TrimStart([char]0xFEFF) | ConvertFrom-Json
        } catch {
            Write-Warning "Unreadable JSON, left untouched: $Path"
            return
        }
        $backup = "$Path.$ServerName.bak"
        if (-not (Test-Path $backup)) { Write-Utf8NoBom $backup $raw }
    } else {
        $config = [PSCustomObject]@{}
    }
    if (-not $config.mcpServers) {
        $config | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([PSCustomObject]@{}) -Force
    }
    $config.mcpServers | Add-Member -NotePropertyName $ServerName -NotePropertyValue ([PSCustomObject]$Entry) -Force
    Write-Utf8NoBom $Path ($config | ConvertTo-Json -Depth 100)
    Write-Host "Registered $ServerName in $Path"
}

function Copy-Skill([string]$SkillsDir) {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $srcSkill = Join-Path $repoRoot "skills\$SkillName"
    $dstSkill = Join-Path $SkillsDir $SkillName
    New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
    if (Test-Path $dstSkill) { Remove-Item -Recurse -Force $dstSkill }
    Copy-Item -Path $srcSkill -Destination $dstSkill -Recurse -Force
    Write-Host "Installed skill to $dstSkill"
}

$entry = @{
    command = $exePath
    args    = $serverArgs
    env     = @{ ANONYMIZED_TELEMETRY = "false" }
}

# 3. Google Antigravity
$geminiDir = Join-Path $env:USERPROFILE ".gemini"
if (Test-Path $geminiDir) {
    Set-McpServer (Join-Path $geminiDir "config\mcp_config.json") $entry
    Copy-Skill (Join-Path $geminiDir "config\skills")
} else {
    Write-Host "Antigravity not found (no $geminiDir): skipped."
}

# 4. Claude Code (user scope, every project)
$claudeJson = Join-Path $env:USERPROFILE ".claude.json"
if (Get-Command claude -ErrorAction SilentlyContinue) {
    # The CLI owns ~/.claude.json: let it write the file it keeps open.
    # Windows PowerShell 5.1 with ErrorActionPreference=Stop turns any stderr line of a native
    # command into a terminating error. `claude mcp remove` writes one when the server is not
    # registered yet - the usual case on a first install - and the script used to stop right here.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & claude mcp remove --scope user $ServerName *> $null
        & claude mcp add --scope user $ServerName -e ANONYMIZED_TELEMETRY=false -- $exePath @serverArgs
        if ($LASTEXITCODE -ne 0) { throw "claude mcp add failed (exit code $LASTEXITCODE)." }
    } finally {
        $ErrorActionPreference = $previous
    }
    Write-Host "Registered $ServerName in Claude Code (user scope)"
} elseif (Test-Path $claudeJson) {
    Set-McpServer $claudeJson (@{ type = "stdio" } + $entry)
} else {
    Write-Host "Claude Code not found: skipped."
}
if ((Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path $claudeJson)) {
    Copy-Skill (Join-Path $env:USERPROFILE ".claude\skills")
}

# 5. Claude Desktop
$desktopDir = Join-Path $env:APPDATA "Claude"
if (Test-Path $desktopDir) {
    Set-McpServer (Join-Path $desktopDir "claude_desktop_config.json") $entry
} else {
    Write-Host "Claude Desktop not found (no $desktopDir): skipped."
}

Write-Host "`nDone! Restart Antigravity and Claude Desktop (or reload their MCP servers); Claude Code picks it up in its next session."
