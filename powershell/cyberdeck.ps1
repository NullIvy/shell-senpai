param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  $o = [ordered]@{ count = 0; optional = 0; kb = ''; patch = '' }
  try {
    $se = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
    foreach ($u in $se.Search("IsInstalled=0 and IsHidden=0").Updates) {
      if ($u.Title -match 'Security Intelligence|Definition Update') { continue }
      if ($u.BrowseOnly -or $u.Type -eq 2) { $o.optional++ } else { $o.count++; if (-not $o.kb -and $u.Title -match 'KB\d+') { $o.kb = $Matches[0] } }
    }
    $n = $se.GetTotalHistoryCount()
    if ($n) {
      $last = @($se.QueryHistory(0, [math]::Min($n, 100)) | Where-Object { param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  try {
    $s = New-Object -ComObject Microsoft.Update.Session
    $r = $s.CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    $t = @(); foreach ($u in $r.Updates) { $t += [string]$u.Title }
    [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", (@{ count = $t.Count; titles = $t } | ConvertTo-Json))
  } catch {}
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  $wlf = "$($global:CD.Cache)\winlogos.txt"
  if (-not $wls -and (Test-Path $wlf)) { $wls = @(Get-Content $wlf | Where-Object { param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  $o = [ordered]@{ count = 0; optional = 0; kb = ''; patch = '' }
  try {
    $se = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
    foreach ($u in $se.Search("IsInstalled=0 and IsHidden=0").Updates) {
      if ($u.Title -match 'Security Intelligence|Definition Update') { continue }
      if ($u.BrowseOnly -or $u.Type -eq 2) { $o.optional++ } else { $o.count++; if (-not $o.kb -and $u.Title -match 'KB\d+') { $o.kb = $Matches[0] } }
    }
    $n = $se.GetTotalHistoryCount()
    if ($n) {
      $last = @($se.QueryHistory(0, [math]::Min($n, 100)) | Where-Object { param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  try {
    $s = New-Object -ComObject Microsoft.Update.Session
    $r = $s.CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    $t = @(); foreach ($u in $r.Updates) { $t += [string]$u.Title }
    [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", (@{ count = $t.Count; titles = $t } | ConvertTo-Json))
  } catch {}
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  if (-not $wls) { $wls = @(fastfetch --list-logos 2>$null | Select-String -Pattern '(?i)\bwindows[\w-]*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique); $global:CDWinLogos = $wls }
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools.Title -match 'Cumulative Update|Insider Preview' -and param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  try {
    $s = New-Object -ComObject Microsoft.Update.Session
    $r = $s.CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    $t = @(); foreach ($u in $r.Updates) { $t += [string]$u.Title }
    [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", (@{ count = $t.Count; titles = $t } | ConvertTo-Json))
  } catch {}
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  if (-not $wls) { $wls = @(fastfetch --list-logos 2>$null | Select-String -Pattern '(?i)\bwindows[\w-]*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique); $global:CDWinLogos = $wls }
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools.ResultCode -eq 2 } | Sort-Object Date -Descending)[0]
      if ($last) {
        $parts = @()
        if ($last.Title -match '^(\d{4}-\d{2})') { $parts += "$($Matches[1]) cumulative" } elseif ($last.Title -match 'Insider Preview') { $parts += 'Insider build' }
        if ($last.Title -match 'KB\d+') { $parts += $Matches[0] }
        $parts += $last.Date.ToLocalTime().ToString('dd MMM yyyy')
        $o.patch = $parts -join ' · '
      }
    }
  } catch {}
  if (-not $o.patch) {
    $hf = Get-HotFix -ErrorAction SilentlyContinue | Where-Object InstalledOn | Sort-Object InstalledOn -Descending | Select-Object -First 1
    if ($hf) { $o.patch = "$($hf.HotFixID) · " + $hf.InstalledOn.ToString('dd MMM yyyy') }
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", ($o | ConvertTo-Json))
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  if (-not $wls) { $wls = @(fastfetch --list-logos 2>$null | Select-String -Pattern '(?i)\bwindows[\w-]*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique); $global:CDWinLogos = $wls }
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools }) }
  if (-not $wls) {
    $wls = @(); $seen = @{}
    foreach ($n in 'windows_xp', 'windows', 'windows_8', 'windows_11', 'windows_2025') {
      $o = (fastfetch -l $n --logo-type builtin -s none --pipe 2>$null | Out-String).Trim()
      if ($o.Length -gt 40 -and -not $seen.ContainsKey($o)) { $seen[$o] = 1; $wls += $n }
    }
    $wls | Set-Content $wlf
  }
  $global:CDWinLogos = $wls
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools.Title -match 'Cumulative Update|Insider Preview' -and param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  try {
    $s = New-Object -ComObject Microsoft.Update.Session
    $r = $s.CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    $t = @(); foreach ($u in $r.Updates) { $t += [string]$u.Title }
    [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", (@{ count = $t.Count; titles = $t } | ConvertTo-Json))
  } catch {}
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  $wlf = "$($global:CD.Cache)\winlogos.txt"
  if (-not $wls -and (Test-Path $wlf)) { $wls = @(Get-Content $wlf | Where-Object { param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  $o = [ordered]@{ count = 0; optional = 0; kb = ''; patch = '' }
  try {
    $se = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
    foreach ($u in $se.Search("IsInstalled=0 and IsHidden=0").Updates) {
      if ($u.Title -match 'Security Intelligence|Definition Update') { continue }
      if ($u.BrowseOnly -or $u.Type -eq 2) { $o.optional++ } else { $o.count++; if (-not $o.kb -and $u.Title -match 'KB\d+') { $o.kb = $Matches[0] } }
    }
    $n = $se.GetTotalHistoryCount()
    if ($n) {
      $last = @($se.QueryHistory(0, [math]::Min($n, 100)) | Where-Object { param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  try {
    $s = New-Object -ComObject Microsoft.Update.Session
    $r = $s.CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    $t = @(); foreach ($u in $r.Updates) { $t += [string]$u.Title }
    [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", (@{ count = $t.Count; titles = $t } | ConvertTo-Json))
  } catch {}
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  if (-not $wls) { $wls = @(fastfetch --list-logos 2>$null | Select-String -Pattern '(?i)\bwindows[\w-]*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique); $global:CDWinLogos = $wls }
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools.Title -match 'Cumulative Update|Insider Preview' -and param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  try {
    $s = New-Object -ComObject Microsoft.Update.Session
    $r = $s.CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    $t = @(); foreach ($u in $r.Updates) { $t += [string]$u.Title }
    [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", (@{ count = $t.Count; titles = $t } | ConvertTo-Json))
  } catch {}
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  if (-not $wls) { $wls = @(fastfetch --list-logos 2>$null | Select-String -Pattern '(?i)\bwindows[\w-]*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique); $global:CDWinLogos = $wls }
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools.ResultCode -eq 2 } | Sort-Object Date -Descending)[0]
      if ($last) {
        $parts = @()
        if ($last.Title -match '^(\d{4}-\d{2})') { $parts += "$($Matches[1]) cumulative" } elseif ($last.Title -match 'Insider Preview') { $parts += 'Insider build' }
        if ($last.Title -match 'KB\d+') { $parts += $Matches[0] }
        $parts += $last.Date.ToLocalTime().ToString('dd MMM yyyy')
        $o.patch = $parts -join ' · '
      }
    }
  } catch {}
  if (-not $o.patch) {
    $hf = Get-HotFix -ErrorAction SilentlyContinue | Where-Object InstalledOn | Sort-Object InstalledOn -Descending | Select-Object -First 1
    if ($hf) { $o.patch = "$($hf.HotFixID) · " + $hf.InstalledOn.ToString('dd MMM yyyy') }
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", ($o | ConvertTo-Json))
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  if (-not $wls) { $wls = @(fastfetch --list-logos 2>$null | Select-String -Pattern '(?i)\bwindows[\w-]*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique); $global:CDWinLogos = $wls }
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools }) }
  if (-not $wls) {
    $wls = @(); $seen = @{}
    foreach ($n in 'windows_xp', 'windows', 'windows_8', 'windows_11', 'windows_2025') {
      $o = (fastfetch -l $n --logo-type builtin -s none --pipe 2>$null | Out-String).Trim()
      if ($o.Length -gt 40 -and -not $seen.ContainsKey($o)) { $seen[$o] = 1; $wls += $n }
    }
    $wls | Set-Content $wlf
  }
  $global:CDWinLogos = $wls
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools.ResultCode -eq 2 } | Sort-Object Date -Descending)[0]
      if ($last) {
        $parts = @()
        if ($last.Title -match '^(\d{4}-\d{2})') { $parts += "$($Matches[1]) cumulative" } elseif ($last.Title -match 'Insider Preview') { $parts += 'Insider build' }
        if ($last.Title -match 'KB\d+') { $parts += $Matches[0] }
        $parts += $last.Date.ToLocalTime().ToString('dd MMM yyyy')
        $o.patch = $parts -join ' · '
      }
    }
  } catch {}
  if (-not $o.patch) {
    $hf = Get-HotFix -ErrorAction SilentlyContinue | Where-Object InstalledOn | Sort-Object InstalledOn -Descending | Select-Object -First 1
    if ($hf) { $o.patch = "$($hf.HotFixID) · " + $hf.InstalledOn.ToString('dd MMM yyyy') }
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", ($o | ConvertTo-Json))
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  $wlf = "$($global:CD.Cache)\winlogos.txt"
  if (-not $wls -and (Test-Path $wlf)) { $wls = @(Get-Content $wlf | Where-Object { param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  $o = [ordered]@{ count = 0; optional = 0; kb = ''; patch = '' }
  try {
    $se = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
    foreach ($u in $se.Search("IsInstalled=0 and IsHidden=0").Updates) {
      if ($u.Title -match 'Security Intelligence|Definition Update') { continue }
      if ($u.BrowseOnly -or $u.Type -eq 2) { $o.optional++ } else { $o.count++; if (-not $o.kb -and $u.Title -match 'KB\d+') { $o.kb = $Matches[0] } }
    }
    $n = $se.GetTotalHistoryCount()
    if ($n) {
      $last = @($se.QueryHistory(0, [math]::Min($n, 100)) | Where-Object { param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  try {
    $s = New-Object -ComObject Microsoft.Update.Session
    $r = $s.CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    $t = @(); foreach ($u in $r.Updates) { $t += [string]$u.Title }
    [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", (@{ count = $t.Count; titles = $t } | ConvertTo-Json))
  } catch {}
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  if (-not $wls) { $wls = @(fastfetch --list-logos 2>$null | Select-String -Pattern '(?i)\bwindows[\w-]*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique); $global:CDWinLogos = $wls }
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools.Title -match 'Cumulative Update|Insider Preview' -and param([string]$Shell, [switch]$BuildCache, [switch]$CheckUpdate)

$global:CD = @{
  FF    = "$HOME\.config\fastfetch"
  Cache = "$HOME\.cache\cyberdeck"
  Self  = "$HOME\.config\powershell\cyberdeck.ps1"
}
if (-not (Test-Path $global:CD.Cache)) { New-Item -ItemType Directory -Force $global:CD.Cache | Out-Null }

function Build-CDCache {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $os   = Get-CimInstance Win32_OperatingSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object Name -notmatch 'Basic Display|Remote|Virtual')
  $mem  = @(Get-CimInstance Win32_PhysicalMemory)
  $bios = Get-CimInstance Win32_BIOS
  $nt   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

  $memTxt = '–'
  if ($mem.Count) {
    $types = @{ 24 = 'DDR3'; 26 = 'DDR4'; 29 = 'LPDDR3'; 30 = 'LPDDR4'; 34 = 'DDR5'; 35 = 'LPDDR5' }
    $mt = $types[[int]$mem[0].SMBIOSMemoryType]
    $gb = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB)
    $sp = ($mem | Measure-Object ConfiguredClockSpeed -Maximum).Maximum
    $memTxt = "$gb GB" + $(if ($mt) { " $mt" }) + $(if ($sp) { " · $sp MT/s" })
  }
  $man   = ($cs.Manufacturer -replace 'ASUSTeK COMPUTER INC\.?', 'ASUS' -replace '\s*(Inc|Corporation|Co\.,? Ltd)\.?$', '').Trim()
  $model = ($cs.Model -replace '_.*$', '').Trim()
  $cpuN  = ($cpu.Name -replace '\(R\)|\(TM\)|\s+with .*$|\s+CPU|\s*@.*$|\s+\d+-Core Processor', '' -replace '\s+', ' ').Trim()
  $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
    ("{0} GB {1} {2}" -f [math]::Round($_.Size / 1e9), $_.BusType, $(if ("$($_.MediaType)" -eq 'Unspecified') { '' } else { $_.MediaType })).Trim() })
  $main = $gpus | Where-Object CurrentHorizontalResolution | Select-Object -First 1
  $disp = if ($main) { "$($main.CurrentHorizontalResolution)×$($main.CurrentVerticalResolution) · $($main.CurrentRefreshRate) Hz" } else { '–' }
  $design = $null; $full = $null
  try { $design = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity } catch {}
  try { $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity } catch {}
  if (-not $design) { try { $x = "$env:TEMP\cd-battery.xml"; powercfg /batteryreport /xml /output $x | Out-Null; [xml]$bx = Get-Content $x -Raw; $bb = @($bx.BatteryReport.Batteries.Battery)[0]; $design = [int]$bb.DesignCapacity; $full = [int]$bb.FullChargeCapacity } catch {} }
  $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } | Select-Object -ExpandProperty DisplayName -Unique)
  $domain = if ($cs.PartOfDomain) { "$($cs.Domain) · AD domain" } else { "$($cs.Workgroup) · workgroup" }

  $data = [ordered]@{
    os = ($os.Caption -replace '^Microsoft\s+', ''); ver = $nt.DisplayVersion
    build = "$($nt.CurrentBuild).$($nt.UBR)"; arch = $os.OSArchitecture
    machine = "$man $model".Trim(); sku = $cs.SystemSKUNumber; bios = $bios.SMBIOSBIOSVersion
    cpu = $cpuN; cores = $cpu.NumberOfCores; threads = $cpu.NumberOfLogicalProcessors
    gpu = (($gpus | ForEach-Object { $_.Name -replace '\(R\)|\(TM\)', '' }) -join ' · ')
    mem = $memTxt; disk = ($disks -join ' · '); display = $disp
    design = $design; full = $full; apps = $apps.Count; domain = $domain
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\hw.json", ($data | ConvertTo-Json))
}

function Invoke-CDUpdateCheck {
  try {
    $s = New-Object -ComObject Microsoft.Update.Session
    $r = $s.CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    $t = @(); foreach ($u in $r.Updates) { $t += [string]$u.Title }
    [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", (@{ count = $t.Count; titles = $t } | ConvertTo-Json))
  } catch {}
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  if (-not $wls) { $wls = @(fastfetch --list-logos 2>$null | Select-String -Pattern '(?i)\bwindows[\w-]*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique); $global:CDWinLogos = $wls }
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools.ResultCode -eq 2 } | Sort-Object Date -Descending)[0]
      if ($last) {
        $parts = @()
        if ($last.Title -match '^(\d{4}-\d{2})') { $parts += "$($Matches[1]) cumulative" } elseif ($last.Title -match 'Insider Preview') { $parts += 'Insider build' }
        if ($last.Title -match 'KB\d+') { $parts += $Matches[0] }
        $parts += $last.Date.ToLocalTime().ToString('dd MMM yyyy')
        $o.patch = $parts -join ' · '
      }
    }
  } catch {}
  if (-not $o.patch) {
    $hf = Get-HotFix -ErrorAction SilentlyContinue | Where-Object InstalledOn | Sort-Object InstalledOn -Descending | Select-Object -First 1
    if ($hf) { $o.patch = "$($hf.HotFixID) · " + $hf.InstalledOn.ToString('dd MMM yyyy') }
  }
  [IO.File]::WriteAllText("$($global:CD.Cache)\update.json", ($o | ConvertTo-Json))
}

function Start-CDJob([string]$arg) {
  Start-Process -WindowStyle Hidden -FilePath (Get-Process -Id $PID).Path `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($global:CD.Self)`" $arg"
}

function Show-Cyberdeck([string]$ShellName) {
  $E = [char]27; $cR = "$E[0m"; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; $cdWork = (Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work'; [Console]::OutputEncoding = [Text.Encoding]::UTF8
  function c([string]$rgb) { "$E[38;2;${rgb}m" }
  $cV = c '224;247;250'; $Dm = c '110;135;160'; $Dk = c '45;65;85'; $cW = "$E[1;38;2;240;250;255m"
  $cG = c '133;212;227'; $cY = c '240;198;116'; $cP = c '255;107;107'; $Ok = c '125;220;140'
  $dot = " $Dm·$cV "
  $cAc = c '63;169;245'; $cGt = c '30;70;110'; $cDm = c '78;128;170'; $cNum = c '95;215;255'; $ln = @{ n = 0 }
  $mods = New-Object System.Collections.ArrayList

  function line([string]$s) { [void]$mods.Add(@{ type = 'custom'; format = $s }) }
  function fit([string]$s, [int]$n = 50) { if ($s.Length -gt $n) { $s.Substring(0, $n - 1) + '…' } else { $s } }
  function val([string]$s, [int]$n = 50) { $s = cdmask $s; $cV + (((fit $s $n) -replace '\b\d+(?:[.,]\d+)*\b', "$cNum`$0$cV") -replace ' · ', $dot) + $cR }
  function cdmask([string]$s) {
    if ($global:CDShowIP) { return $s }
    [regex]::Replace($s, '\b(\d{1,3})(?:\.\d{1,3}){3}(/\d{1,2})?\b', { param($m) $m.Groups[1].Value + '.xxx.xxx.xxx' + $(if ($m.Groups[2].Success) { '/xx' }) })
  }
  function bar([double]$p, [switch]$inv) {
    $p = [math]::Max(0, [math]::Min(100, $p)); $n = [int][math]::Round($p / 10)
    if ($inv) { $k = if ($p -ge 50) { $cG } elseif ($p -ge 20) { $cY } else { $cP } }
    else      { $k = if ($p -lt 60) { $cG } elseif ($p -lt 85) { $cY } else { $cP } }
    "$k$('━' * $n)$Dk$('─' * (10 - $n))$cR $k$('{0,3}%' -f [int]$p)$cR"
  }
  function gut { $ln.n++; "$cDm$('{0:D2}' -f $ln.n) $cGt│$cR " }
  function card([string]$title, [string]$rgb, $rows) {
    if ($ln.s) { line (gut) }; $ln.s = 1
    $cm = @{ SYSTEM = 'the os you are living in'; SOFTWARE = 'tools that keep you alive'; HARDWARE = 'the metal under your fingers'; STATUS = 'how hard senpai is working'; NETWORK = 'where your packets travel' }
    line ((gut) + "$cAc$E[1m### $title$E[22m  $cDm// $($cm[$title])$cR")
    foreach ($r in $rows) { $g = gut; if ("$($r[2])".Contains($cP)) { $g = $g.Replace("$cGt│", "$cP▌"); $ln.w++ }; line ($g + "  $cAc$($r[0])$cR  $cW$($r[1].PadRight(10))$cR $($r[2])") }
  }
  function boot {
    $b = c '79;179;217'; $k = c '133;212;227'; $d = c '45;90;125'
    [Console]::Write("`n  $d[ ${b}SHELL SENPAI v1.0 $d// ${k}NOTICE ME, SENPAI $d]$cR`n")
    for ($n = 2; $n -le 24; $n += 2) {
      [Console]::Write("`r  ${d}SCANNING SYSTEM $k$('▮' * $n)$d$('▯' * (24 - $n)) $b$('{0,3}' -f [int]($n * 100 / 24))%$cR")
      Start-Sleep -Milliseconds 12
    }
    [Console]::Write("`n")
  }

  # ---------- cache ----------
  $hwf = "$($global:CD.Cache)\hw.json"
  if (-not (Test-Path $hwf)) { Build-CDCache }
  elseif ((Get-Item $hwf).LastWriteTime -lt (Get-Date).AddDays(-1)) { Start-CDJob '-BuildCache' }
  $hw = Get-Content $hwf -Raw | ConvertFrom-Json
  $us = "$($global:CD.Cache)\update.stamp"
  if (-not (Test-Path $us) -or (Get-Item $us).LastWriteTime -lt (Get-Date).AddHours(-6)) { [IO.File]::WriteAllText($us, ''); Start-CDJob '-CheckUpdate' }
  $up = $null; $uf = "$($global:CD.Cache)\update.json"
  if (Test-Path $uf) { $up = Get-Content $uf -Raw | ConvertFrom-Json }

  # ---------- data live ----------
  $os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime
  $ts = (Get-Date) - $os.LastBootUpTime; $u = @()
  if ($ts.Days)  { $u += "$($ts.Days) day$(if ($ts.Days -ne 1) { 's' })" }
  if ($ts.Hours) { $u += "$($ts.Hours) hour$(if ($ts.Hours -ne 1) { 's' })" }
  $u += "$($ts.Minutes) min$(if ($ts.Minutes -ne 1) { 's' })"

  $patch = "$cDm" + 'Checking…' + $cR
  if (-not $up) { $upd = "$cDm" + 'Checking…' + $cR }
  else {
    $opt = [int]$up.optional
    if ([int]$up.count -eq 0) { $upd = "$Ok✔ " + (val ('Up to date' + $(if ($opt) { " · $opt optional" })) 40) }
    else { $upd = "$cY⬆ " + (val ("$($up.count) update$(if ([int]$up.count -ne 1) { 's' }) pending" + $(if ($up.kb) { " · $($up.kb)" })) 40) }
    if ($up.patch) { $patch = val $up.patch }
  }

  if (-not $ShellName) {
    $ShellName = if ($PSVersionTable.PSEdition -eq 'Core') { "PowerShell $($PSVersionTable.PSVersion)" }
                 else { "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }
  }
  $term = 'Console'
  if ($env:WT_SESSION) {
    $wtp = (Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    $term = 'Windows Terminal' + $(if ($wtp -match '_(\d+\.\d+\.\d+\.\d+)_') { " $($Matches[1])" })
  }

  $tot = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB; $used = $tot - $free
  $ramT = "{0:N1} / {1:N1} GB · {2:N1} GB free" -f ($used / 1GB), ($tot / 1GB), ($free / 1GB)
  $drv = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' -and ($_.Used + $_.Free) -gt 0 } | Select-Object -First 3)
  $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

  # ---------- network ----------
  $nics = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -notin 'Loopback', 'Tunnel' })
  $ips = @(); $gw = @(); $dns = @(); $dsrv = @(); $dhcpOn = $false; $sfx = @(); $names = @()
  foreach ($n in $nics) {
    $p = $n.GetIPProperties()
    $v4 = @($p.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and -not "$($_.Address)".StartsWith('169.254') })
    if (-not $v4.Count) { continue }
    $names += $n.Name
    $ips += $v4 | ForEach-Object { "$($_.Address)/$($_.PrefixLength)" }
    $gw  += $p.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and "$($_.Address)" -ne '0.0.0.0' } | ForEach-Object { "$($_.Address)" }
    $dns += $p.DnsAddresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | ForEach-Object { "$_" }
    try { if ($p.GetIPv4Properties().IsDhcpEnabled) { $dhcpOn = $true; $dsrv += $p.DhcpServerAddresses | ForEach-Object { "$_" } } } catch {}
    if ($p.DnsSuffix) { $sfx += $p.DnsSuffix }
  }
  $wl = $nics | Where-Object NetworkInterfaceType -eq 'Wireless80211' | Select-Object -First 1
  $ifc = ($names | Select-Object -Unique) -join ' · '
  if ($wl) {
    $w = netsh wlan show interfaces 2>$null
    $ssid = $w | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1
    $sig  = $w | Select-String '^\s*Signal\s*:\s*(\d+)%' | Select-Object -First 1
    $ifc = "$($wl.Name)" + $(if ($ssid) { " · $($ssid.Matches[0].Groups[1].Value.Trim())" }) + $(if ($sig) { " · $($sig.Matches[0].Groups[1].Value)% signal" })
  }
  if ($dsrv.Count) { $dhcp = "$Ok● " + (val ("enabled · server " + (($dsrv | Select-Object -Unique) -join ', ')) 40) }
  elseif ($dhcpOn) { $dhcp = "$Ok● " + (val 'enabled' 40) }
  else { $dhcp = "$Dm○ " + (val 'static IP' 40) }

  # ---------- greeting & quote ----------
  $hr = (Get-Date).Hour; $sun = [char]0xf185; $moon = [char]0xf186
  if     ($hr -ge 5  -and $hr -lt 12) { $ic = $sun;  $gs = 'Ohayou, {u}. Senpai already brewed the coffee', 'Good morning, {u}. New day, new commits', 'Rise and grind, {u}. The terminal missed you', 'Morning, {u}. Let''s ship something cool today', 'Ohayou gozaimasu, {u}. All systems are green' }
  elseif ($hr -ge 12 -and $hr -lt 17) { $ic = $sun;  $gs = 'Konnichiwa, {u}. Stay hydrated, stay compiling', 'Good afternoon, {u}. Halfway there, keep pushing', 'Afternoon, {u}. Lunch first, debug later', 'Konnichiwa, {u}. Senpai is watching your uptime', 'Good afternoon, {u}. One more task, you got this' }
  elseif ($hr -ge 17 -and $hr -lt 21) { $ic = $moon; $gs = 'Konbanwa, {u}. Time to wind down, or deploy?', 'Good evening, {u}. Golden hour, golden code', 'Evening, {u}. Commit your work before you rest', 'Konbanwa, {u}. Senpai noticed your hard work today', 'Good evening, {u}. Calm terminal, calm mind' }
  elseif ($hr -ge 21)                 { $ic = $moon; $gs = 'Oyasumi soon, {u}. Don''t stay up too late', 'Late night, {u}? Push it, then sleep', 'Good night, {u}. Bugs can wait until tomorrow', 'Night owl mode, {u}. Hydrate and stretch', 'Oyasuminasai, {u}. Senpai is still awake with you' }
  else                                { $ic = $moon; $gs = 'Still awake, {u}? Senpai is worried', 'It''s way past bedtime, {u}', '3 AM coding hits different, but sleep, {u}', 'The bugs are asleep, {u}. You should be too', 'Dawn patrol, {u}. Save your work, then rest' }
  $greet = ($gs | Get-Random).Replace('{u}', $env:USERNAME); if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }; if ($cdWork) { $greet = (Get-Content "$($global:CD.FF)\work-greet.txt" -Encoding UTF8 | Where-Object { $_.Trim() } | Get-Random).Replace('{u}', $env:USERNAME) }
  $qf = "$($global:CD.FF)\quotes.txt"; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }; if ($cdWork) { $qf = "$($global:CD.FF)\work-quotes.txt" }
  $q = if (Test-Path $qf) { Get-Content $qf -Encoding UTF8 | Where-Object { $_.Trim() -and $_.Length -le 60 } | Get-Random } else { 'Hello, World!' }

  # ---------- render ----------
  $i = @{ os = [char]0xf17a; bld = [char]0xf02a; up = [char]0xf017; upd = [char]0xf01e; pkg = [char]0xf487; sh = [char]0xf120; term = [char]0xf489
          pc = [char]0xf109; cpu = [char]0xf2db; gpu = [char]0xf26c; mem = [char]0xf0e4; disk = [char]0xf0a0; disp = [char]0xf108; pwr = [char]0xf0e7
          bat = [char]0xf240; proc = [char]0xf085; wifi = [char]0xf1eb; ip = [char]0xf0ac; gw = [char]0xf0ec; dns = [char]0xf233; dhcp = [char]0xf0e8; dom = [char]0xf0c1 }

  $ttl = '███████╗███████╗███╗   ██╗██████╗  █████╗ ██╗', '██╔════╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║', '███████╗█████╗  ██╔██╗ ██║██████╔╝███████║██║', '╚════██║██╔══╝  ██║╚██╗██║██╔═══╝ ██╔══██║██║', '███████║███████╗██║ ╚████║██║     ██║  ██║██║', '╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝'
  $tc = '30;110;210', '40;135;225', '55;160;238', '70;185;248', '95;205;255', '120;220;255'
  for ($k = 0; $k -lt 6; $k++) { line ((gut) + "$(c $tc[$k])$E[1m$($ttl[$k])$cR") }
  line ((gut) + "$cAc> ${cW}hello $env:USERNAME$cV, $(if ($cdWork) { 'ready to build from' } else { 'notice me from' }) $cAc$env:COMPUTERNAME$cR")
  line ((gut) + "$cAc> $cV$E[3m$($greet.ToLower())$E[23m$cR")
  line (gut)
  $top = $mods.Count

  card 'SYSTEM' '79;179;217' @(
    @($i.os,  'OS',     (val "$($hw.os) $($hw.ver)")),
    @($i.bld, 'Build',  (val "$($hw.build) · $($hw.arch)")),
    @([char]0xf132, 'Patch',  $patch),
    @($i.up,  'Uptime', (val ($u -join ', '))),
    @($i.upd, 'Update', $upd)
  )
  card 'SOFTWARE' '133;212;227' @(
    @($i.pkg,  'Packages', (val "$($hw.apps) apps installed")),
    @($i.sh,   'Shell',    (val $ShellName)),
    @($i.term, 'Terminal', (val $term))
  )
  $pwr = if ($hw.design) { "{0:N1} Wh design capacity" -f ($hw.design / 1000) } else { 'AC only' }
  card 'HARDWARE' '199;146;234' @(
    @($i.pc,   'Machine', (val $hw.machine)),
    @($i.bld,  'Model',   (val $(if ("$($hw.sku)".Trim()) { "SKU $($hw.sku) · BIOS $($hw.bios)" } else { "BIOS $($hw.bios)" }))),
    @($i.cpu,  'Chip',    (val "$($hw.cpu) · $($hw.cores)C / $($hw.threads)T")),
    @($i.gpu,  'GPU',     (val $hw.gpu)),
    @($i.mem,  'Memory',  (val $hw.mem)),
    @($i.disk, 'Storage', (val $hw.disk)),
    @($i.disp, 'Display', (val $hw.display)),
    @($i.pwr,  'Power',   (val $pwr))
  )
  $st = New-Object System.Collections.ArrayList
  [void]$st.Add(@($i.mem, 'RAM', ((bar ($used / $tot * 100)) + ' ' + (val $ramT 34))))
  foreach ($d in $drv) {
    $t = $d.Used + $d.Free
    $dt = "{0:N0} / {1:N0} GB · {2:N0} GB free" -f ($d.Used / 1GB), ($t / 1GB), ($d.Free / 1GB)
    [void]$st.Add(@($i.disk, "Disk $($d.Name):", ((bar ($d.Used / $t * 100)) + ' ' + (val $dt 34))))
  }
  if ($bat) {
    $bp = [int]$bat.EstimatedChargeRemaining; $ac = $bat.BatteryStatus -ne 1
    $bs = if ($ac -and $bp -ge 99) { 'AC · full' } elseif ($ac) { 'AC · charging' } else { 'On battery' }
    if ($hw.design -and $hw.full) { $bs += " · {0}% health" -f [math]::Min(100, [int]($hw.full / $hw.design * 100)) }
    [void]$st.Add(@($i.bat, 'Battery', ((bar $bp -inv) + ' ' + (val $bs 34))))
  }
  [void]$st.Add(@($i.proc, 'Procs', (val "$((Get-Process).Count) running")))
  card 'STATUS' '240;198;116' $st.ToArray()
  card 'NETWORK' '125;220;140' @(
    @($i.wifi, 'Adapter', (val $(if ($ifc) { $ifc } else { 'offline' }))),
    @($i.ip,   'IP',      (val $(if ($ips) { ($ips | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.gw,   'Gateway', (val $(if ($gw)  { ($gw  | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dns,  'DNS',     (val $(if ($dns) { ($dns | Select-Object -Unique) -join ' · ' } else { '–' }))),
    @($i.dhcp, 'DHCP',    $dhcp),
    @($i.dom,  'Domain',  (val ("$($hw.domain)" + $(if ($sfx) { " · $($sfx[0])" }))))
  )
  line (gut)
  line ((gut) + "$cDm// $cV$E[3m$q$E[23m$cR")
  $nu = if ($up) { [int]$up.count } else { 0 }
  $sb = " $([char]0xf489) $ShellName   $([char]0xf00d) $([int]$ln.w)   $([char]0xf062) $nu   Ln $($ln.n), Col 1   UTF-8   CRLF   senpai.ps1"
  $sb = if ($sb.Length -gt 74) { $sb.Substring(0, 73) + "…" } else { $sb.PadRight(74) }
  line ("$E[48;2;18;55;100m$cW" + $sb + "$cR")

  $wls = $global:CDWinLogos
  if (-not $wls) { $wls = @(fastfetch --list-logos 2>$null | Select-String -Pattern '(?i)\bwindows[\w-]*' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique); $global:CDWinLogos = $wls }
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools }) }
  if (-not $wls) {
    $wls = @(); $seen = @{}
    foreach ($n in 'windows_xp', 'windows', 'windows_8', 'windows_11', 'windows_2025') {
      $o = (fastfetch -l $n --logo-type builtin -s none --pipe 2>$null | Out-String).Trim()
      if ($o.Length -gt 40 -and -not $seen.ContainsKey($o)) { $seen[$o] = 1; $wls += $n }
    }
    $wls | Set-Content $wlf
  }
  $global:CDWinLogos = $wls
  $wsrc = if ($wls) { $wls | Get-Random } else { 'windows' }
  $lh = $mods.Count; $lw = [int][math]::Round($lh * 1.24)
  $logoPath = "$($global:CD.FF)\logo-neon-glow.png"; if (-not (Test-Path $logoPath)) { $logoPath = "$($global:CD.FF)\logo-bw.png" }; if ((Get-Content "$($global:CD.Cache)\mode" -ErrorAction SilentlyContinue) -eq 'work') { $logoPath = 'X:\none' }
  $pad = @{ top = 0; left = 2; right = 3 }
  $logo = if (Test-Path $logoPath) { [ordered]@{ type = 'sixel'; source = $logoPath.Replace('\', '/'); width = $lw; height = $lh; padding = $pad } }
          else { [ordered]@{ source = $wsrc; padding = $pad; color = @{ '1' = '38;2;0;175;255'; '2' = '38;2;0;215;255'; '3' = '38;2;0;175;255'; '4' = '38;2;0;215;255' } } }
  $tmp = "$env:TEMP\cyberdeck.jsonc"
  [IO.File]::WriteAllText($tmp, ([ordered]@{ logo = $logo; display = @{ separator = '' }; modules = $mods } | ConvertTo-Json -Depth 6))

  if ($global:CDBoot -ne $false) { boot; [Console]::Write("$E[2A") }
  fastfetch -c $tmp
}

function Initialize-CDTools {
  function global:Set-CDMode([string]$m) {
    [IO.File]::WriteAllText("$($global:CD.Cache)\mode", $m)
    if ($PSVersionTable.PSEdition -eq 'Core') {
      $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      $s = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
      $s.profiles.defaults['backgroundImageOpacity'] = $(if ($m -eq 'work') { 0 } else { 0.06 })
      $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding utf8
    }
    Clear-Host; fetch
  }
  function global:work { Set-CDMode 'work' }
  function global:play { Set-CDMode 'play' }
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function global:cat { bat --paging=never --style=numbers @args }
  }
  $bt = Get-Command btop4win, btop -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($bt) { $global:CDBtop = $bt.Source; function global:top { & $global:CDBtop @args } }
  if (Get-Command duf -ErrorAction SilentlyContinue) { function global:df { duf @args } }
  function global:glog { git log --graph --pretty=format:'%C(#4FB3D9)%h%C(reset) %C(#85D4E3)%d%C(reset) %s %C(#6E87A0)· %cr · %an%C(reset)' -20 }
  function global:myip {
    $e = [char]27
    $l = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" }
    $p = try { Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 3 } catch { '–' }
    ""
    "  $e[38;2;79;179;217m$([char]0xf0ac)$e[0m  $e[38;2;110;135;160mlocal $e[0m  $e[38;2;224;247;250m$($l -join '  ')$e[0m"
    "  $e[38;2;133;212;227m$([char]0xf0c2)$e[0m  $e[38;2;110;135;160mpublic$e[0m  $e[38;2;224;247;250m$p$e[0m"
    ""
  }
  if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    $env:FZF_DEFAULT_OPTS = "--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='◆' --marker='✔' " +
      "--color=bg+:#13283B,fg:#CFE8F0,fg+:#FFFFFF,hl:#85D4E3,hl+:#85D4E3,border:#1D6A96,prompt:#4FB3D9,pointer:#FF6B6B,marker:#7DDC8C,info:#F0C674"
  }
}

if ($BuildCache)  { Build-CDCache; return }
if ($CheckUpdate) { Invoke-CDUpdateCheck; return }
if ($Shell)       { Show-Cyberdeck -ShellName $Shell; return }
function global:fetch { Show-Cyberdeck }
Initialize-CDTools