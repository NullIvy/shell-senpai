$e = [char]27
$C = @{
  ip   = "$e[1;38;2;79;179;217m";  ok   = "$e[38;2;125;220;140m"
  warn = "$e[38;2;240;198;116m";   bad  = "$e[38;2;255;107;107m"
  dim  = "$e[38;2;110;130;150m";   head = "$e[1;38;2;133;212;227m"
  val  = "$e[38;2;224;247;250m";   r    = "$e[0m"
}
$ICON_OK = [char]0xf00c; $ICON_X = [char]0xf00d; $ICON_ARR = [char]0x279C

function _lat([int]$ms) {
  if ($ms -lt 50) { $C.ok } elseif ($ms -lt 100) { $C.warn } else { $C.bad }
}

# ---------- PING ----------
function ping {
  ping.exe @args | ForEach-Object {
    $l = $_
    if ($l -match '^Reply from ([^:]+): bytes=(\d+) time([=<])(\d+)ms TTL=(\d+)') {
      $ms = [int]$matches[4]; $lc = _lat $ms
      "  $($C.ok)$ICON_OK$($C.r) Reply from $($C.ip)$($matches[1])$($C.r)  $($C.dim)bytes=$($matches[2])$($C.r)  time$($matches[3])$lc$ms ms$($C.r)  $($C.dim)TTL=$($matches[5])$($C.r)"
    }
    elseif ($l -match 'timed out|unreachable|could not find|General failure|transmit failed') {
      "  $($C.bad)$ICON_X $($l.Trim())$($C.r)"
    }
    elseif ($l -match '^Pinging (\S+)') {
      "$($C.head)$ICON_ARR $l$($C.r)"
    }
    elseif ($l -match 'Lost = (\d+) \((\d+)% loss\)') {
      $lc = if ([int]$matches[1] -eq 0) { $C.ok } else { $C.bad }
      $l -replace 'Lost = \d+ \(\d+% loss\)', "${lc}Lost = $($matches[1]) ($($matches[2])% loss)$($C.r)"
    }
    elseif ($l -match 'Minimum = ') {
      [regex]::Replace($l, '(\w+) = (\d+)ms', { param($m) "$($m.Groups[1].Value) = $(_lat ([int]$m.Groups[2].Value))$($m.Groups[2].Value)ms$($C.r)" })
    }
    elseif ($l -match 'statistics|round trip') { "$($C.head)$l$($C.r)" }
    else { $l }
  }
}

# ---------- TRACERT ----------
function tracert {
  tracert.exe @args | ForEach-Object {
    $l = $_
    if ($l -match '^\s+\d+\s') {
      $l = [regex]::Replace($l, '<?(\d+) ms', { param($m) "$(_lat ([int]$m.Groups[1].Value))$($m.Value)$($C.r)" })
      $l = $l -replace '(\s)\*(?=\s)', "`$1$($C.bad)*$($C.r)"
      $l = $l -replace '(\d{1,3}(\.\d{1,3}){3})', "$($C.ip)`$1$($C.r)"
      $l
    }
    elseif ($l -match 'Tracing|Trace complete') { "$($C.head)$l$($C.r)" }
    else { $l }
  }
}

# ---------- IPCONFIG ----------
function ipconfig {
  ipconfig.exe @args | ForEach-Object {
    $l = $_
    if ($l -match '^\S.*:\s*$') { "$($C.head)$l$($C.r)" }
    elseif ($l -match '^(\s+)(IPv4 Address|Default Gateway)([ .]*:\s)(.*)$') {
      "$($matches[1])$($C.dim)$($matches[2])$($matches[3])$($C.r)$($C.ip)$($matches[4])$($C.r)"
    }
    elseif ($l -match 'disconnected') { "$($C.bad)$l$($C.r)" }
    elseif ($l -match '^(\s+)([^:]+?)(\s*:\s)(.*)$') {
      "$($matches[1])$($C.dim)$($matches[2])$($matches[3])$($C.r)$($C.val)$($matches[4])$($C.r)"
    }
    else { $l }
  }
}

# ---------- Warna saat mengetik command ----------
Set-PSReadLineOption -Colors @{
  Command   = "$e[1;38;2;79;179;217m"
  Parameter = "$e[38;2;133;212;227m"
  String    = "$e[38;2;240;198;116m"
  Number    = "$e[38;2;177;240;247m"
  Operator  = "$e[38;2;110;130;150m"
  Variable  = "$e[38;2;125;220;140m"
  Comment   = "$e[3;38;2;110;130;150m"
}
# ===== Warna tambahan =====
$C.dir  = "$e[1;38;2;79;179;217m";  $C.code = "$e[38;2;240;198;116m"
$C.img  = "$e[38;2;199;146;234m";   $C.arc  = "$e[38;2;247;140;108m"
$C.v6   = "$e[38;2;179;157;219m";   $C.mac  = "$e[38;2;199;146;234m"
$C.size = "$e[38;2;133;212;227m";   $C.dim2 = "$e[38;2;70;85;100m"

function _valcolor([string]$v) {
  $v = $v.Trim()
  if     ($v -match '^\d{1,3}(\.\d{1,3}){3}')            { $C.ip }
  elseif ($v -match '^[0-9a-fA-F]{1,4}:[0-9a-fA-F:%]+')  { $C.v6 }
  elseif ($v -match '^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$') { $C.mac }
  elseif ($v -match '^(Yes|Enabled)$')                   { $C.ok }
  elseif ($v -match '^(No|Disabled)$|disconnected')      { $C.bad }
  else { $C.val }
}

# ---------- IPCONFIG (versi baru) ----------
function ipconfig {
  ipconfig.exe @args | ForEach-Object {
    $l = $_
    if ($l -match '^\S.*:\s*$') {
      $ic = if ($l -match 'Wireless') { [char]0xf1eb } else { [char]0xf0e8 }
      "$($C.head)$ic  $($l.TrimEnd(':',' '))$($C.r)"
    }
    elseif ($l -match '^(\s+)([^.:]+?)([ .]*:\s?)(.*)$') {
      $vc = _valcolor $matches[4]
      "$($matches[1])$($C.dim)$($matches[2])$($C.dim2)$($matches[3])$($C.r)$vc$($matches[4])$($C.r)"
    }
    elseif ($l -match '^\s+(\S+)\s*$') {
      $l -replace '(\S+)', "$(_valcolor $matches[1])`$1$($C.r)"
    }
    else { $l }
  }
}

# ---------- NSLOOKUP ----------
function nslookup {
  nslookup.exe @args 2>&1 | ForEach-Object {
    $l = "$_"
    if ($l -match '^Server:\s+(.*)') {
      "$($C.dim)$([char]0xf233)  Server   $($C.r)$($C.val)$($matches[1])$($C.r)"
    }
    elseif ($l -match '^Name:\s+(.*)') {
      "`n$($C.head)$([char]0xf0ac)  $($matches[1])$($C.r)"
    }
    elseif ($l -match 'Non-authoritative') {
      "$($C.dim2)$([char]0xf05a)  non-authoritative answer$($C.r)"
    }
    elseif ($l -match '^(?:Addresses?:)?\s+([0-9a-fA-F:.]+)\s*$') {
      $a = $matches[1]
      if ($a -match ':') { "   $($C.dim)v6$($C.r)  $($C.v6)$a$($C.r)" }
      else               { "   $($C.dim)v4$($C.r)  $($C.ip)$a$($C.r)" }
    }
    elseif ($l -match '\*\*\*|timed out|can''t find') { "$($C.bad)$ICON_X $($l.Trim())$($C.r)" }
    elseif ($l -match '\S') { $l }
  }
}

# ---------- DIR / LS ----------
function _hsize([long]$b) {
  if ($b -ge 1GB) { "{0:N1} GB" -f ($b / 1GB) }
  elseif ($b -ge 1MB) { "{0:N1} MB" -f ($b / 1MB) }
  elseif ($b -ge 1KB) { "{0:N1} KB" -f ($b / 1KB) }
  else { "$b B" }
}
function _ago([datetime]$d) {
  $s = (Get-Date) - $d
  if ($s.TotalMinutes -lt 1) { 'just now' }
  elseif ($s.TotalHours -lt 1) { "$([math]::Floor($s.TotalMinutes))m ago" }
  elseif ($s.TotalDays -lt 1)  { "$([math]::Floor($s.TotalHours))h ago" }
  elseif ($s.TotalDays -lt 7)  { "$([math]::Floor($s.TotalDays))d ago" }
  else { $d.ToString('dd MMM yyyy') }
}
function _fileStyle($i) {
  $hid = $i.Name.StartsWith('.')
  if ($i.PSIsContainer) { if ($hid) { return @([char]0xf07b, $C.dim) } else { return @([char]0xf07b, $C.dir) } }
  switch -regex ($i.Extension.ToLower()) {
    '^\.(ps1|sh|bat|cmd|py|js|ts|php|java|c|cpp|cs|go|rs|html|css|json|jsonc|xml|ya?ml|toml|sql)$' { return @([char]0xf121, $C.code) }
    '^\.(png|jpe?g|gif|svg|webp|bmp|ico)$' { return @([char]0xf1c5, $C.img) }
    '^\.(zip|rar|7z|tar|gz|iso)$'          { return @([char]0xf1c6, $C.arc) }
    '^\.(exe|msi|dll)$'                    { return @([char]0xf013, $C.ok) }
    '^\.pdf$'                              { return @([char]0xf1c1, $C.bad) }
    '^\.(xlsx?|csv)$'                      { return @([char]0xf1c3, $C.ok) }
    '^\.(pptx?)$'                          { return @([char]0xf1c4, $C.warn) }
    '^\.(docx?)$' { return @([char]0xf1c2, "$e[38;2;90;150;255m") }
    '^\.(txt|md|log)$'               { return @([char]0xf15c, $C.val) }
    '^\.(mp3|wav|flac)$'                   { return @([char]0xf001, $C.img) }
    '^\.(mp4|mkv|avi|mov)$'                { return @([char]0xf03d, $C.img) }
  }
  if ($hid) { return @([char]0xf15b, $C.dim) } else { return @([char]0xf15b, $C.val) }
}

Remove-Item Alias:dir -Force -ErrorAction SilentlyContinue
Remove-Item Alias:ls  -Force -ErrorAction SilentlyContinue
function dir {
  param([Parameter(Position = 0)][string]$Path = '.', [switch]$a)
  if ($Path -eq '.') { $full = (Get-Location).ProviderPath } else { $full = (Get-Item -LiteralPath $Path -Force -ErrorAction Stop).FullName }; $full = $full.Replace('`','')
  $items = @(Get-ChildItem -LiteralPath $full -Force:$a)
  $dirs  = @($items | Where-Object { $_.PSIsContainer } | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) })
  $files = @($items | Where-Object { -not $_.PSIsContainer } | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) })
  ""
  "  $($C.head)$([char]0xf07c)  $full$($C.r)  $($C.dim)$([char]0x00B7) $($dirs.Count) folders, $($files.Count) files$($C.r)"
  "  $($C.dim2)$('─' * 60)$($C.r)"
  foreach ($i in ($dirs + $files)) {
    $st = _fileStyle $i
    $n = $i.Name; if ($n.Length -gt 34) { $n = $n.Substring(0, 33) + [char]0x2026 }
    $sz = if ($i.PSIsContainer) { _count $i.FullName } else { _hsize $i.Length }
    "  $($st[1])$($st[0])  $($n.PadRight(36))$($C.r)$($C.size)$($sz.PadLeft(9))$($C.r)   $($C.dim)$(_ago $i.LastWriteTime)$($C.r)"
  }
  ""
}
function ls { dir @args }
function ll { dir -a @args }
# ===== Jumlah isi folder =====
function _count([string]$p) {
  try { "$(@([IO.Directory]::GetFileSystemEntries($p)).Count) items" } catch { 'locked' }
}

# ===== TREE =====
function _tree($dir, $pre, $lvl, $max, $all) {
  $items = @(Get-ChildItem -LiteralPath $dir -Force:$all -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin 'node_modules', '.git', 'vendor' } |
    Sort-Object @{ Expression = { -not $_.PSIsContainer } }, @{ Expression = { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } })
  for ($k = 0; $k -lt $items.Count; $k++) {
    $i = $items[$k]; $last = ($k -eq $items.Count - 1)
    $h = [string][char]0x2500
    $br = if ($last) { "$([char]0x2514)$h$h " } else { "$([char]0x251C)$h$h " }
    $st = _fileStyle $i
    "$pre$($C.dim2)$br$($C.r)$($st[1])$($st[0])  $($i.Name)$($C.r)"
    if ($i.PSIsContainer -and $lvl -lt $max) {
      $np = if ($last) { "$pre    " } else { "$pre$($C.dim2)$([char]0x2502)$($C.r)   " }
      _tree $i.FullName $np ($lvl + 1) $max $all
    }
  }
}
function tree {
  param([Parameter(Position = 0)][string]$Path = '.', [int]$d = 2, [switch]$a)
  if ($Path -eq '.') { $root = (Get-Location).ProviderPath } else { $root = (Get-Item -LiteralPath $Path -Force).FullName }
  $root = $root.Replace('`', '')
  ""
  "  $($C.head)$([char]0xf07c)  $root$($C.r)"
  _tree $root '  ' 1 $d $a
  ""
}

# ===== Prediksi + navigasi history =====
try {
  Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView -ErrorAction Stop
  Set-PSReadLineOption -Colors @{ InlinePrediction = "$e[38;2;80;100;120m"; ListPrediction = "$e[38;2;79;179;217m" }
  Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView
} catch {}
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
# ===== Jumlah isi folder =====
function _count([string]$p) {
  try { "$(@([IO.Directory]::GetFileSystemEntries($p)).Count) items" } catch { 'locked' }
}

# ===== TREE =====
function _tree($dir, $pre, $lvl, $max, $all) {
  $items = @(Get-ChildItem -LiteralPath $dir -Force:$all -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin 'node_modules', '.git', 'vendor' } |
    Sort-Object @{ Expression = { -not $_.PSIsContainer } }, @{ Expression = { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } })
  for ($k = 0; $k -lt $items.Count; $k++) {
    $i = $items[$k]; $last = ($k -eq $items.Count - 1)
    $h = [string][char]0x2500
    $br = if ($last) { "$([char]0x2514)$h$h " } else { "$([char]0x251C)$h$h " }
    $st = _fileStyle $i
    "$pre$($C.dim2)$br$($C.r)$($st[1])$($st[0])  $($i.Name)$($C.r)"
    if ($i.PSIsContainer -and $lvl -lt $max) {
      $np = if ($last) { "$pre    " } else { "$pre$($C.dim2)$([char]0x2502)$($C.r)   " }
      _tree $i.FullName $np ($lvl + 1) $max $all
    }
  }
}
function tree {
  param([Parameter(Position = 0)][string]$Path = '.', [int]$d = 2, [switch]$a)
  if ($Path -eq '.') { $root = (Get-Location).ProviderPath } else { $root = (Get-Item -LiteralPath $Path -Force).FullName }
  $root = $root.Replace('`', '')
  ""
  "  $($C.head)$([char]0xf07c)  $root$($C.r)"
  _tree $root '  ' 1 $d $a
  ""
}

# ===== Prediksi + navigasi history =====
try {
  Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView -ErrorAction Stop
  Set-PSReadLineOption -Colors @{ InlinePrediction = "$e[38;2;80;100;120m"; ListPrediction = "$e[38;2;79;179;217m" }
  Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView
} catch {}
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward