$ErrorActionPreference = "Stop"

# 1. Verify uv is installed
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv..."
    irm https://astral.sh/uv/install.ps1 | iex
}

# 2. Install windows-mcp tool
Write-Host "Installing windows-mcp..."
uv tool install windows-mcp --upgrade

$exePath = Join-Path $env:USERPROFILE ".local\bin\windows-mcp.exe"
if (-not (Test-Path $exePath)) {
    throw "windows-mcp.exe not found at $exePath"
}

# 3. Register MCP server in Antigravity global config
$configDir = Join-Path $env:USERPROFILE ".gemini\config"
$mcpConfigPath = Join-Path $configDir "mcp_config.json"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

if (Test-Path $mcpConfigPath) {
    $config = Get-Content $mcpConfigPath -Raw | ConvertFrom-Json
} else {
    $config = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
}

if (-not $config.mcpServers) {
    $config | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([PSCustomObject]@{})
}

$serverEntry = [PSCustomObject]@{
    command = $exePath
    args    = @("serve", "--transport", "stdio")
    env     = [PSCustomObject]@{ ANONYMIZED_TELEMETRY = "false" }
}

$config.mcpServers | Add-Member -NotePropertyName "windows-mcp" -NotePropertyValue $serverEntry -Force
$config | ConvertTo-Json -Depth 10 | Set-Content -Path $mcpConfigPath -Encoding UTF8
Write-Host "Updated $mcpConfigPath"

# 4. Install skill globally
$repoRoot = Split-Path -Parent $PSScriptRoot
$srcSkill = Join-Path $repoRoot "skills\windows-desktop-control"
$dstSkill = Join-Path $configDir "skills\windows-desktop-control"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dstSkill) | Out-Null
Copy-Item -Path $srcSkill -Destination $dstSkill -Recurse -Force
Write-Host "Installed skill to $dstSkill"

Write-Host "`nDone! Restart Antigravity or reload MCP Servers to use windows-mcp."
