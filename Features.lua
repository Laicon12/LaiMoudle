-- ============================================================
-- LAI ADMIN v3.5 | Features.lua
-- Fly, WalkSpeed, JumpPower, InfJump, Noclip, ESP,
-- SelfFreeze, FakeInvis, AntiFling, BypassAC
-- ============================================================

local Features = {}

local Core = require(script.Parent.Core)
local GUI  = require(script.Parent.GUI)

local RS  = Core.Services.RunService
local UIS = Core.Services.UserInputService
local T   = Core.Theme

-- shared state (exported so Panic can read them)
Features.State = {
    isFlying    = false,
    isWalk      = false,
    isJump      = false,
    isInfJump   = false,
    isNoclip    = false,
    isESP       = false,
    isSelfFrozen = false,
    isFakeInvis  = false,
    isAntiFling  = false,
    isBypassAC   = false,
}

-- ── Fly ──────────────────────────────────────────────────────
local flyAttach, flyLV, flyConn

local function StopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyAttach and flyAttach.Parent then flyAttach:Destroy() end
    flyAttach, flyLV = nil, nil
    local char = Core.Player.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CollisionGroup = "Default" end) end
        end
    end
    local hum = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
end

function Features.ToggleFly(refs)
    local state = Features.State
    local char = Core.Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    state.isFlying = not state.isFlying
    GUI.SetBtn(refs.flyBtn, state.isFlying)
    if not state.isFlying then StopFly(); return end

    hum:ChangeState(Enum.HumanoidStateType.Physics)
    flyAttach = Instance.new("Attachment"); flyAttach.Name = Core.RandName(6); flyAttach.Parent = hrp
    flyLV = Instance.new("LinearVelocity"); flyLV.Name = Core.RandName(6)
    flyLV.Attachment0 = flyAttach; flyLV.MaxForce = 9e5; flyLV.VectorVelocity = Vector3.zero
    flyLV.RelativeTo  = Enum.ActuatorRelativeTo.World; flyLV.Parent = flyAttach

    local smooth = Vector3.zero
    flyConn = Core.Track("fly", RS.RenderStepped:Connect(function(dt)
        pcall(function()
            local c   = Core.Player.Character
            local h2  = c and c:FindFirstChild("HumanoidRootPart")
            local hm  = c and c:FindFirstChild("Humanoid")
            if not h2 or not hm or not flyAttach or not flyAttach.Parent then
                StopFly(); state.isFlying = false; GUI.SetBtn(refs.flyBtn, false); return
            end
            hm:ChangeState(Enum.HumanoidStateType.Physics)
            local dir = Vector3.zero
            local cam = Core.Camera
            if refs.currentFlyMode == "Camera" then
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            else
                local fwd = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                local rgt = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
                fwd = fwd.Magnitude > 0.01 and fwd.Unit or Vector3.zero
                rgt = rgt.Magnitude > 0.01 and rgt.Unit or Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir += fwd end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= fwd end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= rgt end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir += rgt end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
            end
            local spd = tonumber(refs.flySpeedBox.Text) or 50
            smooth = smooth:Lerp(dir.Magnitude > 0 and dir.Unit * spd or Vector3.zero, math.min(1, dt * 10))
            flyLV.VectorVelocity = smooth
            local look = cam.CFrame.LookVector
            local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude > 0.01 then h2.CFrame = CFrame.new(h2.Position, h2.Position + flat) end
        end)
    end))
end

Features.StopFly = StopFly

-- ── WalkSpeed ────────────────────────────────────────────────
local walkConn

local function ApplyWalk(refs)
    local hum = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
    if not hum then return end
    local v = tonumber(refs.walkBox.Text)
    if not v or v <= 0 then v = 16 end
    hum.WalkSpeed = math.clamp(v, 0, 500)
end

function Features.ToggleWalkSpeed(refs)
    local state = Features.State
    state.isWalk = not state.isWalk
    GUI.SetBtn(refs.walkBtn, state.isWalk)
    if state.isWalk then
        if walkConn then walkConn:Disconnect(); walkConn = nil end
        ApplyWalk(refs)
        walkConn = RS.Heartbeat:Connect(function() ApplyWalk(refs) end)
    else
        if walkConn then walkConn:Disconnect(); walkConn = nil end
        local hum = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end

Features.ApplyWalk = ApplyWalk

-- ── JumpPower ────────────────────────────────────────────────
local jumpConn

local function ApplyJump(refs)
    local hum = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
    if not hum then return end
    local v = tonumber(refs.jumpBox.Text)
    if not v or v <= 0 then v = 50 end
    hum.UseJumpPower = true
    hum.JumpPower    = math.clamp(v, 0, 1000)
end

function Features.ToggleJumpPower(refs)
    local state = Features.State
    state.isJump = not state.isJump
    GUI.SetBtn(refs.jumpBtn, state.isJump)
    if state.isJump then
        if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
        ApplyJump(refs)
        jumpConn = RS.Heartbeat:Connect(function() ApplyJump(refs) end)
    else
        if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
        local hum = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = 50 end
    end
end

Features.ApplyJump = ApplyJump

-- ── Infinite Jump ────────────────────────────────────────────
function Features.ToggleInfJump(refs)
    local state = Features.State
    state.isInfJump = not state.isInfJump
    GUI.SetBtn(refs.infJumpBtn, state.isInfJump)
    if state.isInfJump then
        Core.Track("infJump", UIS.JumpRequest:Connect(function()
            local hum = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end))
    else
        Core.Untrack("infJump")
    end
end

-- ── Noclip ───────────────────────────────────────────────────
local noclipParts = {}
Features.noclipParts = noclipParts

function Features.ToggleNoclip(refs)
    local state = Features.State
    state.isNoclip = not state.isNoclip
    GUI.SetBtn(refs.noclipBtn, state.isNoclip)
    if state.isNoclip then
        local char = Core.Player.Character
        noclipParts = {}
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then noclipParts[#noclipParts + 1] = p end
            end
        end
        Core.Track("noclip", RS.Stepped:Connect(function()
            for _, p in ipairs(noclipParts) do
                if p and p.Parent then p.CanCollide = false end
            end
        end))
    else
        Core.Untrack("noclip")
        task.spawn(function()
            local char = Core.Player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                for _, p in ipairs(noclipParts) do if p and p.Parent then p.CanCollide = true end end
                noclipParts = {}; return
            end
            local timeout = tick() + 2
            repeat
                task.wait(0.05)
                local touching   = hrp:GetTouchingParts()
                local worldTouch = false
                for _, tp in ipairs(touching) do
                    if not tp:IsDescendantOf(char) then worldTouch = true; break end
                end
                if not worldTouch then break end
            until tick() > timeout
            task.defer(function()
                for _, p in ipairs(noclipParts) do if p and p.Parent then p.CanCollide = true end end
                noclipParts = {}
            end)
        end)
    end
end

-- ── ESP ──────────────────────────────────────────────────────
local espFolder = Instance.new("Folder")
espFolder.Name   = Core.RandName(8)
espFolder.Parent = Core.Camera

local espPlayerAdded   = {}
local espPlayerRemoving = {}
local espCharAdded     = {}

local function AddESP(p)
    if p == Core.Player then return end
    local char = p.Character; if not char then return end
    for _, h in ipairs(espFolder:GetChildren()) do if h.Name == p.Name then return end end
    local hrp = char:WaitForChild("HumanoidRootPart", 2)
    if not hrp then return end

    local box = Instance.new("BoxHandleAdornment", espFolder)
    box.Name = p.Name; box.Adornee = hrp; box.Size = Vector3.new(4, 5.5, 2)
    box.ZIndex = 0; box.AlwaysOnTop = true
    box.Color3 = Color3.fromRGB(0, 170, 255); box.Transparency = 0.65; box.ZIndex = 1

    local bb = Instance.new("BillboardGui", espFolder)
    bb.Name = p.Name .. "_BB"; bb.Adornee = hrp
    bb.Size = UDim2.new(0, 100, 0, 30); bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true; bb.ResetOnSpawn = false

    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
    lbl.Text = p.DisplayName; lbl.TextColor3 = Color3.fromRGB(0, 200, 255)
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0); lbl.TextStrokeTransparency = 0
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13; lbl.TextScaled = false
end

local function RemoveESP(p)
    for _, h in ipairs(espFolder:GetChildren()) do
        if h.Name == p.Name or h.Name == p.Name .. "_BB" then h:Destroy() end
    end
end

function Features.ToggleESP(refs)
    local state = Features.State
    local P     = Core.Services.Players
    state.isESP = not state.isESP
    GUI.SetBtn(refs.espBtn, state.isESP)
    if state.isESP then
        for _, p in ipairs(P:GetPlayers()) do AddESP(p) end
        espPlayerAdded.conn   = P.PlayerAdded:Connect(function(p)
            espCharAdded[p] = p.CharacterAdded:Connect(function() task.wait(0.1); AddESP(p) end)
            AddESP(p)
        end)
        espPlayerRemoving.conn = P.PlayerRemoving:Connect(RemoveESP)
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= Core.Player then
                espCharAdded[p] = p.CharacterAdded:Connect(function() task.wait(0.1); AddESP(p) end)
            end
        end
    else
        espFolder:ClearAllChildren()
        if espPlayerAdded.conn   then espPlayerAdded.conn:Disconnect()   end
        if espPlayerRemoving.conn then espPlayerRemoving.conn:Disconnect() end
        for _, c in pairs(espCharAdded) do c:Disconnect() end
        espCharAdded = {}
    end
end

-- ── Self Freeze ──────────────────────────────────────────────
local selfFrzCF = nil

function Features.ToggleSelfFreeze(refs)
    local state = Features.State
    state.isSelfFrozen = not state.isSelfFrozen
    GUI.SetBtn(refs.selfFrzBtn, state.isSelfFrozen)

    local char = Core.Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChild("Humanoid")

    if state.isSelfFrozen then
        if not hrp then state.isSelfFrozen = false; GUI.SetBtn(refs.selfFrzBtn, false); return end
        selfFrzCF = hrp.CFrame
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.Anchored = true
        if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end
        refs.selfFrzBtn.Text = "🔥 Unfreeze Self"
        Core.Track("selfFreeze", RS.Heartbeat:Connect(function()
            local c  = Core.Player.Character
            local h2 = c and c:FindFirstChild("HumanoidRootPart")
            if not h2 then return end
            h2.Anchored = true
            h2.AssemblyLinearVelocity  = Vector3.zero
            h2.AssemblyAngularVelocity = Vector3.zero
            if (h2.Position - selfFrzCF.Position).Magnitude > 0.5 then h2.CFrame = selfFrzCF end
        end))
    else
        Core.Untrack("selfFreeze")
        local hrp2 = Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart")
        local hum2 = Core.Player.Character and Core.Player.Character:FindFirstChild("Humanoid")
        if hrp2 then hrp2.Anchored = false end
        if hum2 then
            hum2.WalkSpeed = Features.State.isWalk and (tonumber(refs.walkBox.Text) or 16) or 16
            hum2.JumpPower = Features.State.isJump and (tonumber(refs.jumpBox.Text) or 50) or 50
        end
        selfFrzCF = nil
        refs.selfFrzBtn.Text = "🧊 Freeze Self"
    end
end

-- ── Fake Invis ───────────────────────────────────────────────
local fakeInvisRot90 = CFrame.Angles(math.rad(90), 0, 0)
local fakeInvisOldCF = CFrame.new()

function Features.ToggleFakeInvis(refs)
    local state = Features.State
    state.isFakeInvis = not state.isFakeInvis
    GUI.SetBtn(refs.fakeInvisBtn, state.isFakeInvis)

    local char = Core.Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")

    if state.isFakeInvis then
        if hrp then fakeInvisOldCF = hrp.CFrame end
        RS:BindToRenderStep("FakeInvis_Cam", Enum.RenderPriority.Camera.Value - 1, function()
            local h = Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart")
            if h then h.CFrame = fakeInvisOldCF end
        end)
        Core.Track("fakeInvisSim", RS.PostSimulation:Connect(function()
            local h = Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart")
            if h then
                fakeInvisOldCF = h.CFrame
                local offset = tonumber(refs.fakeInvisBox.Text) or 7
                h.CFrame = CFrame.new(h.Position - Vector3.new(0, offset, 0)) * fakeInvisRot90
            end
        end))
    else
        RS:UnbindFromRenderStep("FakeInvis_Cam")
        Core.Untrack("fakeInvisSim")
        local h = Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart")
        if h then h.CFrame = fakeInvisOldCF end
    end
end

-- ── Anti-Fling ───────────────────────────────────────────────
function Features.ToggleAntiFling(refs)
    local state = Features.State
    state.isAntiFling = not state.isAntiFling
    GUI.SetBtn(refs.antiFlingBtn, state.isAntiFling)
    if state.isAntiFling then
        Core.Track("antiFling", RS.Stepped:Connect(function()
            local char = Core.Player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if hrp.AssemblyLinearVelocity.Magnitude > 250
                or hrp.AssemblyAngularVelocity.Magnitude > 50 then
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
            for _, p in ipairs(Core.Services.Players:GetPlayers()) do
                if p ~= Core.Player and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end))
    else
        Core.Untrack("antiFling")
    end
end

-- ── Bypass AC ────────────────────────────────────────────────
local oldIndex = nil

function Features.ToggleBypassAC(refs)
    local state = Features.State
    if not hookmetamethod then
        refs.bypassAcBtn.Text = "❌ Executor Not Supported"
        task.wait(2); refs.bypassAcBtn.Text = "🪝 Bypass Walk/Jump AC"
        return
    end
    state.isBypassAC = not state.isBypassAC
    GUI.SetBtn(refs.bypassAcBtn, state.isBypassAC)
    if state.isBypassAC and not oldIndex then
        oldIndex = hookmetamethod(game, "__index", function(t, k)
            if not checkcaller() and state.isBypassAC and t:IsA("Humanoid") then
                if k == "WalkSpeed" then return 16 end
                if k == "JumpPower" then return 50 end
            end
            return oldIndex(t, k)
        end)
    end
end

return Features
