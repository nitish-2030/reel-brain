# start-reelbrain.ps1
#
# One-click daily startup for Reel Brain on Windows:
#   1. Starts a Cloudflare Quick Tunnel pointing at local n8n
#   2. Waits for the tunnel to hand out a public https://*.trycloudflare.com URL
#   3. Sets WEBHOOK_URL so n8n's Telegram Trigger auto-registers the new
#      webhook with Telegram on startup
#   4. Starts n8n
#
# Prerequisites (do this once, not every run):
#   - cloudflared installed and on PATH
#   - n8n installed globally via npm
#   - Set these as PERMANENT Windows System Environment Variables
#     (System Properties -> Environment Variables), not here, since they
#     don't change between runs:
#       NODES_EXCLUDE=[]
#       N8N_RESTRICT_FILE_ACCESS_TO=D:\reel_temp   (or wherever you store temp videos)
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File start-reelbrain.ps1
#
# Or wrap it in a .bat file (double-click friendly, since .ps1 files don't
# run directly from Explorer):
#   powershell -ExecutionPolicy Bypass -File "C:\path\to\start-reelbrain.ps1"

$n8nPort = 5678
$tunnelLogFile = Join-Path $PSScriptRoot "tunnel-output.txt"

Write-Host "Starting Cloudflare Quick Tunnel -> http://localhost:$n8nPort ..."

Start-Process powershell -ArgumentList `
    "cloudflared tunnel --url http://localhost:$n8nPort > `"$tunnelLogFile`" 2>&1"

$tunnelUrl = $null
$maxWaitSeconds = 30
$elapsed = 0

while (-not $tunnelUrl -and $elapsed -lt $maxWaitSeconds) {
    Start-Sleep -Seconds 2
    $elapsed += 2
    if (Test-Path $tunnelLogFile) {
        $match = Select-String -Path $tunnelLogFile -Pattern "https://.*trycloudflare\.com" -ErrorAction SilentlyContinue
        if ($match) {
            $tunnelUrl = $match.Matches[0].Value
        }
    }
}

if (-not $tunnelUrl) {
    Write-Host "ERROR: Tunnel failed to start within $maxWaitSeconds seconds."
    Write-Host "Check $tunnelLogFile for details."
    exit 1
}

Write-Host "Tunnel is up: $tunnelUrl"

$env:WEBHOOK_URL = "$tunnelUrl/"

Write-Host "Starting n8n with WEBHOOK_URL=$env:WEBHOOK_URL ..."
Write-Host "(Reminder: NODES_EXCLUDE and N8N_RESTRICT_FILE_ACCESS_TO should already be set as permanent system env vars.)"

n8n