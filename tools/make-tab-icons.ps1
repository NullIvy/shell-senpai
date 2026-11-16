# Shell Senpai: membuat icon tab untuk mode play (wajah dari logo neon) dan work (logo jendela 4 kotak)
Add-Type -AssemblyName System.Drawing
$ic = "$HOME\.config\windows-terminal\icons"; New-Item -ItemType Directory -Force $ic | Out-Null
$S = 96
function New-Icon([string]$name, [scriptblock]$draw) {
  $b = New-Object Drawing.Bitmap $S, $S; $g = [Drawing.Graphics]::FromImage($b)
  $g.SmoothingMode = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'; $g.Clear([Drawing.Color]::Transparent)
  & $draw $g; $g.Dispose(); $b.Save("$ic\$name.png", [Drawing.Imaging.ImageFormat]::Png); $b.Dispose()
}
function Br([string]$hex) { New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($hex)) }
function Poly($g, $brush, $pts) { $g.FillPolygon($brush, [Drawing.PointF[]]@($pts | ForEach-Object { New-Object Drawing.PointF $_[0], $_[1] })) }

# play: potong wajah dari foto neon
$src = "$HOME\.config\fastfetch\logo-neon-glow.png"
if (-not (Test-Path $src)) { $src = "$HOME\.config\fastfetch\logo-neon.png" }
New-Icon 'play' {
  param($g)
  $img = [Drawing.Image]::FromFile($src); $w = $img.Width; $y = [int]($img.Height * 0.17)
  $g.DrawImage($img, (New-Object Drawing.Rectangle 0, 0, $S, $S), (New-Object Drawing.Rectangle 0, $y, $w, $w), 'Pixel'); $img.Dispose()
}
# work: tiga gaya logo jendela 4 kotak
New-Icon 'win-11' { param($g); $c = Br '#2FB3F5'; foreach ($p in @(@(8,8),@(50,8),@(8,50),@(50,50))) { $g.FillRectangle($c, $p[0], $p[1], 38, 38) } }
New-Icon 'win-8'  { param($g); $c = Br '#00B4F0'
  Poly $g $c @(@(6,18),@(42,12),@(42,45),@(6,45)); Poly $g $c @(@(48,11),@(90,4),@(90,45),@(48,45))
  Poly $g $c @(@(6,51),@(42,51),@(42,84),@(6,78)); Poly $g $c @(@(48,51),@(90,51),@(90,92),@(48,85)) }
New-Icon 'win-xp' { param($g)
  Poly $g (Br '#F25022') @(@(10,14),@(44,8),@(42,44),@(6,48)); Poly $g (Br '#7FBA00') @(@(50,8),@(88,12),@(86,46),@(48,44))
  Poly $g (Br '#00A4EF') @(@(6,54),@(42,50),@(42,86),@(10,90)); Poly $g (Br '#FFB900') @(@(48,50),@(86,52),@(88,88),@(50,86)) }

