function global:senpai-release {
  param([Parameter(Mandatory)][string]$Version, [Parameter(Mandatory)][string]$Title, [string]$Notes = '')
  if ("$Title $Notes" -match '^Judul Update$|^Judul update aslimu$|^Catatan singkat|aslimu') { Write-Host '✖ Judul/catatan masih contoh, ganti dulu' -ForegroundColor Red; return }
  Push-Location "$HOME\shell-senpai"
  try {
    git pull --rebase --autostash -q
    Copy-Item "$HOME\.config\powershell\*.ps1" .\powershell\ -Force
    Copy-Item "$HOME\.config\fastfetch\*.txt" .\fastfetch\ -Force
    Copy-Item "$HOME\.config\starship.toml" .\starship\ -Force
    Copy-Item "$HOME\.config\windows-terminal\*.hlsl" .\windows-terminal\ -Force -ErrorAction SilentlyContinue
    $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    (Get-Content $wt -Raw).Replace($HOME.Replace('\','\\'), '__HOME__').Replace($HOME, '__HOME__') | Set-Content .\windows-terminal\settings.json -Encoding utf8
    $hit = Select-String -Path (Get-ChildItem -Recurse -File -Exclude *.png, senpai-release.ps1 | Where-Object FullName -notmatch '\\.git\\').FullName -Pattern 'csinf|Rizki|C:\\\\Users|token|secret|api_key'
    if ($hit) { $hit | Format-Table Path, LineNumber, Line -AutoSize; Write-Host '✖ Data pribadi terdeteksi, rilis dibatalkan' -ForegroundColor Red; return }
    if (-not (git status --porcelain)) { Write-Host '• Tidak ada perubahan untuk dirilis' -ForegroundColor Yellow; return }
    git status --short
    if ((Read-Host "Lanjut rilis ${Version}? (y/n)") -ne 'y') { Write-Host 'Dibatalkan'; return }
    git add .; git commit -q -m "feat: $Version $Title"; git push -q
    git tag -a $Version -m $Title; git push -q origin $Version
    $a = @('release', 'create', $Version, '--title', "$Version — $Title", '--latest', '--generate-notes')
    if ($Notes) { $a += @('--notes', $Notes) }
    gh @a
  } finally { Pop-Location }
}





