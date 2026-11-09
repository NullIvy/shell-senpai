param([Parameter(Mandatory)][string]$Source, [double]$Glow = 0.35, [int]$Scanline = 45)
Add-Type -AssemblyName System.Drawing
$dir = "$HOME\.config\fastfetch"; New-Item -ItemType Directory -Force $dir | Out-Null
$img = [Drawing.Image]::FromFile((Resolve-Path $Source))
$h = $img.Height; $w = [int][math]::Min($img.Width, $h * 0.62); $x = [int](($img.Width - $w) / 2)

function Draw-Matrix($rows, $out) {
  $bmp = New-Object Drawing.Bitmap $w, $h
  $g = [Drawing.Graphics]::FromImage($bmp)
  $ia = New-Object Drawing.Imaging.ImageAttributes
  $ia.SetColorMatrix([Drawing.Imaging.ColorMatrix]::new([single[][]]$rows))
  $g.DrawImage($img, (New-Object Drawing.Rectangle 0, 0, $w, $h), $x, 0, $w, $h, [Drawing.GraphicsUnit]::Pixel, $ia)
  $bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
}

# Hitam-putih (dipakai sebagai watermark background)
Draw-Matrix @(@(0.299,0.299,0.299,0,0), @(0.587,0.587,0.587,0,0), @(0.114,0.114,0.114,0,0), @(0,0,0,1,0), @(0,0,0,0,1)) "$dir\logo-bw.png"

# Neon biru
$k = 0.65
Draw-Matrix @(@((0.299*0.26*$k),(0.299*0.72*$k),(0.299*$k),0,0), @((0.587*0.26*$k),(0.587*0.72*$k),(0.587*$k),0,0), @((0.114*0.26*$k),(0.114*0.72*$k),(0.114*$k),0,0), @(0,0,0,1,0), @(0.02,0.05,0.10,0,1)) "$dir\logo-neon.png"

# Glow + scanline tercetak di foto
$neon = [Drawing.Image]::FromFile("$dir\logo-neon.png")
$small = New-Object Drawing.Bitmap ([int]($w / 10)), ([int]($h / 10))
$g = [Drawing.Graphics]::FromImage($small); $g.InterpolationMode = 'HighQualityBilinear'; $g.DrawImage($neon, 0, 0, $small.Width, $small.Height); $g.Dispose()
$res = New-Object Drawing.Bitmap $w, $h
$g = [Drawing.Graphics]::FromImage($res); $g.DrawImage($neon, 0, 0, $w, $h)
$ia = New-Object Drawing.Imaging.ImageAttributes
$ia.SetColorMatrix([Drawing.Imaging.ColorMatrix]::new([single[][]]@(@(1.1,0,0,0,0), @(0,1.5,0,0,0), @(0,0,1.8,0,0), @(0,0,0,$Glow,0), @(0,0,0,0,1))))
$g.InterpolationMode = 'HighQualityBicubic'
$g.DrawImage($small, (New-Object Drawing.Rectangle 0, 0, $w, $h), 0, 0, $small.Width, $small.Height, [Drawing.GraphicsUnit]::Pixel, $ia)
$br = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb($Scanline, 0, 0, 0))
for ($y = 0; $y -lt $h; $y += 4) { $g.FillRectangle($br, 0, $y, $w, 1) }
$res.Save("$dir\logo-neon-glow.png", [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $res.Dispose(); $small.Dispose(); $neon.Dispose(); $img.Dispose()
"Logo siap di $dir"
