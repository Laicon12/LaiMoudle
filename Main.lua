-- ============================================================
-- LAI ADMIN v3.5 | Main.lua  (Entry Point)
-- require() this file to launch the menu
-- ============================================================

local Core     = require(script.Parent.Core)
local GUI      = require(script.Parent.GUI)
local Features = require(script.Parent.Features)
local Troll    = require(script.Parent.Troll)

local T  = Core.Theme
local S  = Features.State
local P  = Core.Services.Players
local RS = Core.Services.RunService
local UIS = Core.Services.UserInputService

-- ── Build window ─────────────────────────────────────────────
local win = GUI.Build()

-- ── Shared keybind table for bind buttons ───────────────────
local updateBindTexts = {}

-- ── Main Tab ─────────────────────────────────────────────────
local flyBtn        = GUI.MkRow(win.cMain, "Toggle Fly",             "Fly",        1,  updateBindTexts)
local flyModeBtn    = GUI.MkBtn(win.cMain, "Fly Mode: Camera",       T.ElemBG,     2)
local flySpeedBox   = GUI.MkInput(win.cMain, "Fly Speed (Def: 50)",  3)  flySpeedBox.Text = "50"
GUI.MkPresets(win.cMain, "Speed:", {50, 100, 300}, flySpeedBox, 4)

local walkBtn   = GUI.MkRow(win.cMain, "Toggle WalkSpeed", "WalkSpeed", 5, updateBindTexts)
local walkBox   = GUI.MkInput(win.cMain, "Walk Speed (Def: 16)", 6)  walkBox.Text = "16"
GUI.MkPresets(win.cMain, "Speed:", {16, 50, 100}, walkBox, 7)

local jumpBtn   = GUI.MkRow(win.cMain, "Toggle JumpPower", "JumpPower", 8, updateBindTexts)
local jumpBox   = GUI.MkInput(win.cMain, "Jump Power (Def: 50)", 9)  jumpBox.Text = "50"
GUI.MkPresets(win.cMain, "Power:", {50, 100, 250}, jumpBox, 10)

local infJumpBtn    = GUI.MkRow(win.cMain, "Infinite Jump",          "InfJump",   11, updateBindTexts)
local noclipBtn     = GUI.MkRow(win.cMain, "Toggle Noclip",          "Noclip",    12, updateBindTexts)
local espBtn        = GUI.MkRow(win.cMain, "Toggle Box ESP",         "ESP",       13, updateBindTexts)
local selfFrzBtn    = GUI.MkRow(win.cMain, "🧊 Freeze Self",         "SelfFreeze",14, updateBindTexts)
local fakeInvisBtn  = GUI.MkRow(win.cMain, "👻 Toggle Fake Invis",   "FakeInvis", 15, updateBindTexts)
local fakeInvisBox  = GUI.MkInput(win.cMain, "Invis Offset (Def: 7)",16)  fakeInvisBox.Text = "7"
local antiFlingBtn  = GUI.MkRow(win.cMain, "🛡️ Toggle Anti-Fling",   "AntiFling", 17, updateBindTexts)
local bypassAcBtn   = GUI.MkRow(win.cMain, "🪝 Bypass Walk/Jump AC", "BypassAC",  18, updateBindTexts)
local saveCfgBtn    = GUI.MkBtn(win.cMain, "💾 Save Config", Color3.fromRGB(40, 100, 60), 19)

-- ── TP Tab ───────────────────────────────────────────────────
local tpBox          = GUI.MkInput(win.cTP, "Player Name (ex: rob...)", 1)
local _, _, tpRefresh = GUI.MkPlayerList(win.cTP, tpBox, 2)
local tpRefreshBtn   = GUI.MkBtn(win.cTP, "🔄 Refresh",                   T.ElemHover,               3)
local tpInstant      = GUI.MkBtn(win.cTP, "⚡ Instant Teleport",          Color3.fromRGB(80, 40, 150), 4)
local tpDash         = GUI.MkBtn(win.cTP, "☄️ Dash Teleport",             Color3.fromRGB(200, 90, 40), 5)
local mouseTpBtn     = GUI.MkBtn(win.cTP, "🖱️ Ctrl+Click TP Tween (Toggle)", Color3.fromRGB(40, 150, 100), 6)
local mouseTpSpeedBox = GUI.MkInput(win.cTP, "Tween Speed (Studs/s) (Def: 150)", 7) mouseTpSpeedBox.Text = "150"
GUI.MkPresets(win.cTP, "Speed:", {100, 150, 300}, mouseTpSpeedBox, 8)
tpRefreshBtn.MouseButton1Click:Connect(tpRefresh)

-- ── Emotes Tab ───────────────────────────────────────────────
local emoteList = {"wave","point","dance","dance2","dance3","laugh","cheer","salute","stadium","tilt","shrug"}
local emoteBtns = {}
for i, n in ipairs(emoteList) do emoteBtns[n] = GUI.MkBtn(win.cEmotes, "▶ " .. n, T.ElemBG, i) end

-- ── Troll Tab ────────────────────────────────────────────────
GUI.MkLabel(win.cTroll, "Target Player:", 1)
local trollBox = GUI.MkInput(win.cTroll, "Player Name (ex: rob...)", 2)
local _, _, refreshPlayerList = GUI.MkPlayerList(win.cTroll, trollBox, 3)
local refreshBtn = GUI.MkBtn(win.cTroll, "🔄 Refresh Player List", T.ElemHover, 4)
refreshBtn.MouseButton1Click:Connect(refreshPlayerList)

P.PlayerAdded:Connect(function()   task.wait(0.1); refreshPlayerList(); tpRefresh() end)
P.PlayerRemoving:Connect(function() task.wait(0.1); refreshPlayerList(); tpRefresh() end)
refreshPlayerList(); tpRefresh()

GUI.MkLabel(win.cTroll, "─── Freeze & Fling ──────────", 5)
local freezeBtn     = GUI.MkRow(win.cTroll, "🧊 Freeze Player", "Freeze",  6, updateBindTexts)
local unfrzBtn      = GUI.MkBtn(win.cTroll, "🔥 Unfreeze Player",  Color3.fromRGB(160, 70, 20),  7)
local modernFlingBtn = GUI.MkBtn(win.cTroll, "⚙️ Modern Fling: OFF", Color3.fromRGB(60, 60, 80), 8)
local flingBtn      = GUI.MkBtn(win.cTroll, "💥 Fling Player",     Color3.fromRGB(180, 30, 50),  9)
local touchFlingBtn = GUI.MkBtn(win.cTroll, "👆 Touch Fling (Toggle)", Color3.fromRGB(160, 50, 10), 10)

GUI.MkLabel(win.cTroll, "─── NaN Fling ───────────────", 11)
local nanModeBtn    = GUI.MkBtn(win.cTroll, "Mode: Area (gần mình)", Color3.fromRGB(50, 50, 80), 12)
local nanFlingBtn   = GUI.MkBtn(win.cTroll, "☠️ NaN Fling (Toggle)", Color3.fromRGB(80, 0, 0),   13)

GUI.MkLabel(win.cTroll, "─── Welder ──────────────────", 14)
local weldPoseFrame1 = GUI.MkPoseFrame(win.cTroll, 15)
local weldBangBtn    = GUI.MkPoseBtn(weldPoseFrame1, "💋 Bang",   1)
local weldStandBtn   = GUI.MkPoseBtn(weldPoseFrame1, "🧍 Stand",  2)
local weldAttackBtn  = GUI.MkPoseBtn(weldPoseFrame1, "⚔️ Attack", 3)
local weldHeadBtn    = GUI.MkPoseBtn(weldPoseFrame1, "👑 Head",   4)

local weldPoseFrame2 = GUI.MkPoseFrame(win.cTroll, 16)
local weldBackBtn    = GUI.MkPoseBtn(weldPoseFrame2, "🎒 Back",   1)
local weldCarpetBtn  = GUI.MkPoseBtn(weldPoseFrame2, "🟫 Carpet", 2)
local weldBehindBtn  = GUI.MkPoseBtn(weldPoseFrame2, "🫷 Behind", 3)
local weldCustomBtn  = GUI.MkPoseBtn(weldPoseFrame2, "⚙️ Custom", 4)

local weldPoseFrame3 = GUI.MkPoseFrame(win.cTroll, 17)
local weldPushBtn    = GUI.MkPoseBtn(weldPoseFrame3, "👊 Push",   1) weldPushBtn.Size = UDim2.new(0, 90, 1, 0)
local weldUnweldBtn  = GUI.MkPoseBtn(weldPoseFrame3, "❌ Unweld", 2) weldUnweldBtn.Size = UDim2.new(0, 90, 1, 0)
weldUnweldBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)

GUI.MkLabel(win.cTroll, "─── Misc ────────────────────", 18)
local spinBtn   = GUI.MkBtn(win.cTroll, "🌀 Spin Player (Toggle)",  Color3.fromRGB(100, 20, 140), 19)
local followBtn = GUI.MkBtn(win.cTroll, "👁 Follow Player (Toggle)", Color3.fromRGB(20, 120, 80), 20)

-- ── Refs table (shared across features) ─────────────────────
local refs = {
    -- main tab
    flyBtn = flyBtn, flyModeBtn = flyModeBtn, flySpeedBox = flySpeedBox,
    walkBtn = walkBtn, walkBox = walkBox,
    jumpBtn = jumpBtn, jumpBox = jumpBox,
    infJumpBtn = infJumpBtn, noclipBtn = noclipBtn,
    espBtn = espBtn, selfFrzBtn = selfFrzBtn,
    fakeInvisBtn = fakeInvisBtn, fakeInvisBox = fakeInvisBox,
    antiFlingBtn = antiFlingBtn, bypassAcBtn = bypassAcBtn,
    saveCfgBtn = saveCfgBtn,
    -- tp tab
    tpBox = tpBox, tpInstant = tpInstant, tpDash = tpDash,
    mouseTpBtn = mouseTpBtn, mouseTpSpeedBox = mouseTpSpeedBox,
    -- troll tab
    trollBox = trollBox,
    freezeBtn = freezeBtn, unfrzBtn = unfrzBtn,
    modernFlingBtn = modernFlingBtn, flingBtn = flingBtn, touchFlingBtn = touchFlingBtn,
    nanModeBtn = nanModeBtn, nanFlingBtn = nanFlingBtn,
    weldBangBtn = weldBangBtn, weldStandBtn = weldStandBtn, weldAttackBtn = weldAttackBtn,
    weldHeadBtn = weldHeadBtn, weldBackBtn = weldBackBtn,
    weldCarpetBtn = weldCarpetBtn, weldBehindBtn = weldBehindBtn,
    weldCustomBtn = weldCustomBtn, weldPushBtn = weldPushBtn, weldUnweldBtn = weldUnweldBtn,
    spinBtn = spinBtn, followBtn = followBtn,
    -- fly mode state
    currentFlyMode = "Camera",
}

-- ── Wire up Features ─────────────────────────────────────────
flyModeBtn.MouseButton1Click:Connect(function()
    refs.currentFlyMode = refs.currentFlyMode == "Camera" and "Hover" or "Camera"
    flyModeBtn.Text = refs.currentFlyMode == "Camera" and "Fly Mode: Camera" or "Fly Mode: Hover (Space/Ctrl)"
end)
flyBtn.MouseButton1Click:Connect(function()       Features.ToggleFly(refs) end)
walkBtn.MouseButton1Click:Connect(function()      Features.ToggleWalkSpeed(refs) end)
jumpBtn.MouseButton1Click:Connect(function()      Features.ToggleJumpPower(refs) end)
infJumpBtn.MouseButton1Click:Connect(function()   Features.ToggleInfJump(refs) end)
noclipBtn.MouseButton1Click:Connect(function()    Features.ToggleNoclip(refs) end)
espBtn.MouseButton1Click:Connect(function()       Features.ToggleESP(refs) end)
selfFrzBtn.MouseButton1Click:Connect(function()   Features.ToggleSelfFreeze(refs) end)
fakeInvisBtn.MouseButton1Click:Connect(function() Features.ToggleFakeInvis(refs) end)
antiFlingBtn.MouseButton1Click:Connect(function() Features.ToggleAntiFling(refs) end)
bypassAcBtn.MouseButton1Click:Connect(function()  Features.ToggleBypassAC(refs) end)

-- Config
saveCfgBtn.MouseButton1Click:Connect(function()
    local ok = Core.SaveConfig(refs)
    saveCfgBtn.Text = ok and "✅ Saved!" or "❌ Not Supported"
    task.delay(1.5, function() saveCfgBtn.Text = "💾 Save Config" end)
end)
Core.LoadConfig(refs, updateBindTexts)

-- ── Wire up Troll ─────────────────────────────────────────────
Troll.SetupTP(refs)
mouseTpBtn.MouseButton1Click:Connect(function() Troll.ToggleMouseTween(refs) end)
Troll.SetupFreeze(refs)
Troll.SetupFling(refs)
Troll.SetupTouchFling(refs)
Troll.SetupNanFling(refs)
local stopWeld    = Troll.SetupWelder(refs)
local resetSpin   = Troll.SetupSpin(refs)
local resetFollow = Troll.SetupFollow(refs)
Troll.SetupEmotes(emoteBtns)

-- ── Character respawn ─────────────────────────────────────────
Core.Player.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if S.isWalk    then Features.ApplyWalk(refs) end
    if S.isJump    then Features.ApplyJump(refs) end
    if S.isFlying  then Features.StopFly(); S.isFlying = false; task.wait(0.15); Features.ToggleFly(refs) end
    if S.isNoclip  then
        task.wait(0.1)
        Features.noclipParts = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then Features.noclipParts[#Features.noclipParts + 1] = p end
        end
    end
    if S.isFakeInvis then
        S.isFakeInvis = false; Core.Untrack("fakeInvisSim")
        Core.Services.RunService:UnbindFromRenderStep("FakeInvis_Cam")
        task.wait(0.1); Features.ToggleFakeInvis(refs)
    end
end)

-- ── Panic (RightShift) ────────────────────────────────────────
local function Panic()
    for label, _ in pairs(Core.Connections) do Core.Untrack(label) end
    if S.isFlying    then S.isFlying   = false; Features.StopFly(); GUI.SetBtn(flyBtn, false) end
    if S.isWalk      then S.isWalk     = false; GUI.SetBtn(walkBtn, false)
        local hum = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
    if S.isJump      then S.isJump     = false; GUI.SetBtn(jumpBtn, false)
        local hum = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = 50 end
    end
    if S.isInfJump   then S.isInfJump  = false; Core.Untrack("infJump"); GUI.SetBtn(infJumpBtn, false) end
    if S.isNoclip    then S.isNoclip   = false; GUI.SetBtn(noclipBtn, false)
        for _, p in ipairs(Features.noclipParts) do if p and p.Parent then p.CanCollide = true end end
        Features.noclipParts = {}
    end
    if S.isESP       then S.isESP = false; GUI.SetBtn(espBtn, false)
        pcall(function() game:GetService("Workspace"):FindFirstChild("espFolder") end)
    end
    if S.isSelfFrozen then
        S.isSelfFrozen = false; Core.Untrack("selfFreeze")
        local hrp2 = Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart")
        local hum2 = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
        if hrp2 then hrp2.Anchored = false end
        if hum2 then hum2.WalkSpeed = 16; hum2.JumpPower = 50 end
        selfFrzBtn.Text = "🧊 Freeze Self"; GUI.SetBtn(selfFrzBtn, false)
    end
    if S.isFakeInvis  then Features.ToggleFakeInvis(refs) end
    if Troll.isMouseTween() then Troll.ToggleMouseTween(refs) end
    if S.isAntiFling  then Features.ToggleAntiFling(refs) end
    if S.isBypassAC   then Features.ToggleBypassAC(refs) end

    Troll.ResetFreeze(refs)
    Troll.ResetTouchFling(refs)
    Troll.ResetNanFling(refs)
    pcall(stopWeld)
    resetSpin()
    resetFollow()

    pcall(function()
        local orig = win.titleLbl.TextColor3
        win.titleLbl.Text      = "⚠ PANIC — RESET"
        win.titleLbl.TextColor3 = T.Troll
        task.delay(1.5, function()
            win.titleLbl.Text       = "LAI ADMIN"
            win.titleLbl.TextColor3 = orig
        end)
    end)
end

-- ── Global input handler ──────────────────────────────────────
Core.Track("input", UIS.InputBegan:Connect(function(input, gp)
    -- Keybind listener
    if Core._listeningForAction then
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local btn = Core._listeningButton
        if input.KeyCode == Enum.KeyCode.Escape then
            Core.Keybinds[Core._listeningForAction] = Enum.KeyCode.Unknown; btn.Text = "[-]"
        elseif input.KeyCode ~= Enum.KeyCode.Unknown then
            Core.Keybinds[Core._listeningForAction] = input.KeyCode; btn.Text = "[" .. input.KeyCode.Name .. "]"
        end
        if updateBindTexts[Core._listeningForAction] then updateBindTexts[Core._listeningForAction]() end
        Core._listeningForAction = nil; Core._listeningButton = nil; return
    end

    if gp then return end

    -- Panic
    if input.KeyCode == Enum.KeyCode.RightShift then Panic(); return end

    -- Menu toggle
    if input.KeyCode == Core.Keybinds.Menu then win.toggleMenu() end

    -- Feature binds
    local function tryBind(key, fn) if key ~= Enum.KeyCode.Unknown and input.KeyCode == key then fn() end end
    tryBind(Core.Keybinds.Fly,        function() Features.ToggleFly(refs) end)
    tryBind(Core.Keybinds.WalkSpeed,  function() Features.ToggleWalkSpeed(refs) end)
    tryBind(Core.Keybinds.JumpPower,  function() Features.ToggleJumpPower(refs) end)
    tryBind(Core.Keybinds.InfJump,    function() Features.ToggleInfJump(refs) end)
    tryBind(Core.Keybinds.Noclip,     function() Features.ToggleNoclip(refs) end)
    tryBind(Core.Keybinds.ESP,        function() Features.ToggleESP(refs) end)
    tryBind(Core.Keybinds.SelfFreeze, function() Features.ToggleSelfFreeze(refs) end)
    tryBind(Core.Keybinds.FakeInvis,  function() Features.ToggleFakeInvis(refs) end)
    tryBind(Core.Keybinds.AntiFling,  function() Features.ToggleAntiFling(refs) end)
    tryBind(Core.Keybinds.BypassAC,   function() Features.ToggleBypassAC(refs) end)

    -- Freeze keybind
    if Core.Keybinds.Freeze ~= Enum.KeyCode.Unknown and input.KeyCode == Core.Keybinds.Freeze then
        local t = Core.FindPlayer(trollBox.Text)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            -- toggle via button press simulation
            freezeBtn:MouseButton1Click()
        end
    end
end))

-- Menu bind button
win.menuBindBtn.MouseButton1Click:Connect(function()
    Core._listeningForAction = "Menu"
    Core._listeningButton    = win.menuBindBtn
    win.menuBindBtn.Text     = "..."
end)

print("[LAI ADMIN] Modules loaded — GUI ready!")
