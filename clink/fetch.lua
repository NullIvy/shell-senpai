local home = os.getenv("USERPROFILE")
local exe = "powershell"
if os.execute("where pwsh >nul 2>nul") then exe = "pwsh" end
os.execute("cls")
os.execute(exe .. ' -NoLogo -NoProfile -ExecutionPolicy Bypass -File "' .. home .. '\\.config\\powershell\\cyberdeck.ps1" -Shell "Command Prompt"')