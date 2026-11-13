# Підключає плагін code-skills-test до Claude Code (десктопна апка / CLI) з автооновленням.
# Windows. Запуск у PowerShell:
#   irm https://raw.githubusercontent.com/YuraKolyada/code-skills-test-marketplace/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'

$repo = if ($env:CODE_HELPER_REPO) { $env:CODE_HELPER_REPO } else { 'YuraKolyada/code-skills-test-marketplace' }
$dir = Join-Path $env:USERPROFILE '.claude'
$path = Join-Path $dir 'settings.json'
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$s = [pscustomobject]@{}
if (Test-Path $path) {
    Copy-Item $path "$path.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
    $text = [IO.File]::ReadAllText($path)
    if ($text.Trim()) { $s = $text | ConvertFrom-Json }
}

function Set-Prop($obj, $name, $value) {
    if ($obj.PSObject.Properties[$name]) { $obj.$name = $value }
    else { $obj | Add-Member -NotePropertyName $name -NotePropertyValue $value }
}

if (-not $s.PSObject.Properties['extraKnownMarketplaces']) { Set-Prop $s 'extraKnownMarketplaces' ([pscustomobject]@{}) }
Set-Prop $s.extraKnownMarketplaces 'lineup-tools' ([pscustomobject]@{
    source     = [pscustomobject]@{ source = 'github'; repo = $repo }
    autoUpdate = $true
})

if (-not $s.PSObject.Properties['enabledPlugins']) { Set-Prop $s 'enabledPlugins' ([pscustomobject]@{}) }
Set-Prop $s.enabledPlugins 'code-skills-test@lineup-tools' $true

# UTF-8 без BOM, щоб Claude Code коректно прочитав файл
[IO.File]::WriteAllText($path, ($s | ConvertTo-Json -Depth 20), (New-Object Text.UTF8Encoding $false))

if (Get-Command claude -ErrorAction SilentlyContinue) {
    claude plugin install code-skills-test@lineup-tools
} else {
    Write-Host "Не знайдено claude CLI. У вкладці Code виконайте:"
    Write-Host "/plugin install code-skills-test --marketplace $repo"
}

Write-Host ''
Write-Host 'Готово! Плагін code-skills-test підключено.' -ForegroundColor Green
Write-Host 'Перезапустіть Claude (повністю закрийте й відкрийте апку).'
Write-Host 'Потім у вкладці Code напишіть: перевір мої зміни'
