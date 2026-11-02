Invoke-Expression (&starship init powershell)
function fetch {
  $h = (Get-Date).Hour
  if     ($h -ge 5  -and $h -lt 12) { $g = "Good morning";   $i = [char]0xf185 }
  elseif ($h -ge 12 -and $h -lt 17) { $g = "Good afternoon"; $i = [char]0xf185 }
  elseif ($h -ge 17 -and $h -lt 21) { $g = "Good evening";   $i = [char]0xf186 }
  else                               { $g = "Good night";     $i = [char]0xf186 }
  $q = Get-Content "$HOME\.config\fastfetch\quotes.txt" | Where-Object { $_.Trim() } | Get-Random
  $q = $q.Replace('\','\\').Replace('"','\"')
  $t = [IO.File]::ReadAllText("$HOME\.config\fastfetch\template.jsonc")
  $t = $t.Replace('__GREET__', "$i  $g, $env:USERNAME").Replace('__QUOTE__', $q)
  $tmp = "$env:TEMP\fastfetch-now.jsonc"
  [IO.File]::WriteAllText($tmp, $t)
  fastfetch -c $tmp
}
Remove-Item Alias:clear -Force -ErrorAction SilentlyContinue
Remove-Item Alias:cls   -Force -ErrorAction SilentlyContinue
function clear { Clear-Host; fetch }
function cls   { Clear-Host; fetch }
fetch

. "$HOME\.config\powershell\colors.ps1"

Invoke-Expression (& { (zoxide init powershell | Out-String) })
