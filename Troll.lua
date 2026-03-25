-- ============================================================
-- LAI ADMIN v3.5 | Troll.lua
-- Freeze, Fling, TouchFling, NanFling, Weld, Spin, Follow,
-- Teleport, Mouse Tween TP, Emotes
-- ============================================================

local Troll = {}

local Core = require(script.Parent.Core)
local GUI  = require(script.Parent.GUI)

local RS  = Core.Services.RunService
local UIS = Core.Services.UserInputService
local TS  = Core.Services.TweenService
local T   = Core.Theme

-- ── Helpers ──────────────────────────────────────────────────
local function SafeTP(hrp, cf)
    task.wait(0.05 + math.random() * 0.08)
    hrp.CFrame = cf * CFrame.new((math.random() - 0.5) * 1.5, 0, 3 + (math.random() - 0.5) * 1.5)
end

-- ── Teleport ─────────────────────────────────────────────────
function Troll.SetupTP(refs)
    refs.tpInstant.MouseButton1Click:Connect(function()
        local t = Core.FindPlayer(refs.tpBox.Text)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local h = Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart")
            if h then SafeTP(h, t.Character.HumanoidRootPart.CFrame) end
        else
            refs.tpBox.Text = "Not found!"; task.wait(1); refs.tpBox.Text = ""
        end
    end)

    refs.tpDash.MouseButton1Click:Connect(function()
        local t = Core.FindPlayer(refs.tpBox.Text)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local h = Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart")
            if h then
                local d = (h.Position - t.Character.HumanoidRootPart.Position).Magnitude
                TS:Create(h, TweenInfo.new(math.clamp(d / 150, 0.3, 3), Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    {CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
            end
        else
            refs.tpBox.Text = "Not found!"; task.wait(1); refs.tpBox.Text = ""
        end
    end)
end

-- ── Mouse Tween TP ───────────────────────────────────────────
local isMouseTween = false

function Troll.ToggleMouseTween(refs)
    isMouseTween = not isMouseTween
    if isMouseTween then
        refs.mouseTpBtn.BackgroundColor3 = T.AccentON
        refs.mouseTpBtn.TextColor3       = Color3.fromRGB(20, 20, 20)
        refs.mouseTpBtn.Text             = "🖱️ Mouse TP: Hold Ctrl + Click!"
        Core.Track("mouseTween", UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then
                    local char = Core.Player.Character
                    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and Core.Mouse.Hit then
                        local hitPos   = Core.Mouse.Hit
                        local target   = CFrame.new(hitPos.X, hitPos.Y + 3, hitPos.Z, select(4, hrp.CFrame:components()))
                        local speed    = tonumber(refs.mouseTpSpeedBox.Text) or 150
                        if speed <= 0 then speed = 150 end
                        local dist = (hrp.Position - hitPos.Position).Magnitude
                        TS:Create(hrp, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = target}):Play()
                    end
                end
            end
        end))
    else
        Core.Untrack("mouseTween")
        refs.mouseTpBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 100)
        refs.mouseTpBtn.TextColor3       = T.TextMain
        refs.mouseTpBtn.Text             = "🖱️ Ctrl+Click TP Tween (Toggle)"
    end
end

Troll.isMouseTween = function() return isMouseTween end

-- ── Freeze Player ────────────────────────────────────────────
local freezeConn, frozenTarget, frozenCF = nil, nil, nil

function Troll.SetupFreeze(refs)
    refs.freezeBtn.MouseButton1Click:Connect(function()
        local t = Core.FindPlayer(refs.trollBox.Text)
        if not (t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")) then
            refs.trollBox.Text = "Not found!"; task.wait(1); refs.trollBox.Text = ""; return
        end
        Core.Untrack("freeze"); freezeConn = nil
        frozenTarget = t; frozenCF = t.Character.HumanoidRootPart.CFrame
        freezeConn = Core.Track("freeze", RS.Heartbeat:Connect(function()
            if not frozenTarget or not frozenTarget.Character then Core.Untrack("freeze"); freezeConn = nil; return end
            local hrp = frozenTarget.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = frozenCF end
        end))
        refs.freezeBtn.Text = "🧊 Frozen: " .. t.Name
    end)

    refs.unfrzBtn.MouseButton1Click:Connect(function()
        Core.Untrack("freeze"); freezeConn = nil; frozenTarget = nil; frozenCF = nil
        refs.freezeBtn.Text = "🧊 Freeze Player"
    end)
end

function Troll.ResetFreeze(refs)
    Core.Untrack("freeze"); freezeConn = nil; frozenTarget = nil; frozenCF = nil
    refs.freezeBtn.Text = "🧊 Freeze Player"
end

-- ── Fling ────────────────────────────────────────────────────
local isFlingActive = false
local flingOldPos   = nil
local FPDH          = workspace.FallenPartsDestroyHeight

function Troll.SetupFling(refs)
    local isModernFling = false

    refs.modernFlingBtn.MouseButton1Click:Connect(function()
        isModernFling = not isModernFling
        refs.modernFlingBtn.BackgroundColor3 = isModernFling and Color3.fromRGB(80, 100, 200) or Color3.fromRGB(60, 60, 80)
        refs.modernFlingBtn.Text = isModernFling and "⚙️ Modern Fling: ON" or "⚙️ Modern Fling: OFF"
    end)

    local function doFling(targetPlayer)
        local myChar = Core.Player.Character
        local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local myHrp  = myHum and myHum.RootPart
        if not myChar or not myHum or not myHrp then return end
        local tChar  = targetPlayer.Character; if not tChar then return end
        local tHum   = tChar:FindFirstChildOfClass("Humanoid")
        local tHrp   = tHum and tHum.RootPart
        local tHead  = tChar:FindFirstChild("Head")
        local acc    = tChar:FindFirstChildOfClass("Accessory")
        local handle = acc and acc:FindFirstChild("Handle")
        if myHrp.Velocity.Magnitude < 50 then flingOldPos = myHrp.CFrame end
        if tHum and tHum.Sit then return end
        if not tChar:FindFirstChildWhichIsA("BasePart") then return end
        if tHead then workspace.CurrentCamera.CameraSubject = tHead
        elseif tHum then workspace.CurrentCamera.CameraSubject = tHum end

        local mover
        if isModernFling then
            mover = Instance.new("Attachment", myHrp)
            local lv = Instance.new("LinearVelocity", mover)
            lv.Attachment0 = mover; lv.MaxForce = math.huge
            lv.VectorVelocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            local av = Instance.new("AngularVelocity", mover)
            av.Attachment0 = mover; av.MaxTorque = math.huge
            av.AngularVelocity = Vector3.new(9e8, 9e8, 9e8)
        else
            mover = Instance.new("BodyVelocity", myHrp)
            mover.Velocity  = Vector3.zero
            mover.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
        end

        local function FPos(bp, pos, ang)
            myHrp.CFrame = CFrame.new(bp.Position) * pos * ang
            pcall(function() myChar:PivotTo(CFrame.new(bp.Position) * pos * ang) end)
            if not isModernFling then
                myHrp.Velocity    = Vector3.new(9e7, 9e7 * 10, 9e7)
                myHrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end
        end

        local function SFBasePart(bp)
            local deadline = tick() + 2; local angle = 0
            repeat
                if not myHrp or not tHum then break end
                if bp.Velocity.Magnitude < 50 then
                    angle = angle + 100
                    local cf = CFrame.Angles(math.rad(angle), 0, 0)
                    local mv = tHum.MoveDirection * bp.Velocity.Magnitude / 1.25
                    FPos(bp, CFrame.new(0,  1.5, 0) + mv, cf); task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0) + mv, cf); task.wait()
                    FPos(bp, CFrame.new(0,  1.5, 0) + mv, cf); task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0) + mv, cf); task.wait()
                    FPos(bp, CFrame.new(0,  1.5, 0) + tHum.MoveDirection, cf); task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0) + tHum.MoveDirection, cf); task.wait()
                else
                    local ws = tHum.WalkSpeed
                    FPos(bp, CFrame.new(0,  1.5,  ws), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(bp, CFrame.new(0, -1.5, -ws), CFrame.new()); task.wait()
                    FPos(bp, CFrame.new(0,  1.5,  ws), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(bp, CFrame.new(0, -1.5,  0),  CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(bp, CFrame.new(0, -1.5,  0),  CFrame.new()); task.wait()
                    FPos(bp, CFrame.new(0, -1.5,  0),  CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(bp, CFrame.new(0, -1.5,  0),  CFrame.new()); task.wait()
                end
            until tick() > deadline or not isFlingActive
        end

        workspace.FallenPartsDestroyHeight = 0 / 0
        myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if tHrp then SFBasePart(tHrp) elseif tHead then SFBasePart(tHead) elseif handle then SFBasePart(handle) end
        mover:Destroy()
        myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = myHum
        if flingOldPos then
            local tries = 0
            repeat
                tries += 1
                myHrp.CFrame = flingOldPos * CFrame.new(0, 0.5, 0)
                pcall(function() myChar:PivotTo(flingOldPos * CFrame.new(0, 0.5, 0)) end)
                myHum:ChangeState(Enum.HumanoidStateType.GettingUp)
                for _, p in ipairs(myChar:GetChildren()) do
                    if p:IsA("BasePart") then p.Velocity = Vector3.zero; p.RotVelocity = Vector3.zero end
                end
                task.wait()
            until (myHrp.Position - flingOldPos.Position).Magnitude < 25 or tries > 60
            workspace.FallenPartsDestroyHeight = FPDH
        end
    end

    refs.flingBtn.MouseButton1Click:Connect(function()
        if isFlingActive then
            isFlingActive = false
            refs.flingBtn.Text             = "💥 Fling Player"
            refs.flingBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 50)
            return
        end
        local t = Core.FindPlayer(refs.trollBox.Text)
        if not (t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")) then
            refs.trollBox.Text = "Not found!"; task.wait(1); refs.trollBox.Text = ""; return
        end
        isFlingActive = true
        refs.flingBtn.Text             = "⏹ Stop Fling"
        refs.flingBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        task.spawn(function()
            while isFlingActive do pcall(doFling, t); task.wait(0.1) end
            refs.flingBtn.Text             = "💥 Fling Player"
            refs.flingBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 50)
        end)
    end)
end

-- ── Touch Fling ──────────────────────────────────────────────
local isTouchFling = false

function Troll.SetupTouchFling(refs)
    refs.touchFlingBtn.MouseButton1Click:Connect(function()
        isTouchFling = not isTouchFling
        if isTouchFling then
            refs.touchFlingBtn.BackgroundColor3 = T.Troll
            refs.touchFlingBtn.TextColor3       = Color3.fromRGB(20, 20, 20)
            refs.touchFlingBtn.Text             = "👆 Touch Fling: ON"
            local movel = 0.1
            Core.Track("touchFling", RS.Heartbeat:Connect(function()
                local c   = Core.Player.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local vel = hrp.Velocity
                hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                RS.RenderStepped:Wait(); hrp.Velocity = vel
                RS.Stepped:Wait();      hrp.Velocity = vel + Vector3.new(0, movel, 0)
                movel = -movel
            end))
        else
            Core.Untrack("touchFling")
            refs.touchFlingBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 10)
            refs.touchFlingBtn.TextColor3       = T.TextMain
            refs.touchFlingBtn.Text             = "👆 Touch Fling (Toggle)"
        end
    end)
end

function Troll.ResetTouchFling(refs)
    if isTouchFling then
        isTouchFling = false; Core.Untrack("touchFling")
        refs.touchFlingBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 10)
        refs.touchFlingBtn.TextColor3       = T.TextMain
        refs.touchFlingBtn.Text             = "👆 Touch Fling (Toggle)"
    end
end

-- ── NaN Fling ────────────────────────────────────────────────
local isNanFling = false
local nanMode    = "area"
local nanFlingTarget = nil
local hasSHP         = (typeof(sethiddenproperty) == "function")
local NAN_VEC        = Vector3.new(0 / 0, 0 / 0, 0 / 0)

local function ApplyNanFling(targetHrp, myHrp, myHum)
    myHrp.CFrame = targetHrp.CFrame
    myHrp.AssemblyLinearVelocity  = NAN_VEC
    myHrp.AssemblyAngularVelocity = NAN_VEC
    pcall(function() myHum.PlatformStand = true end)
    pcall(function() myHum:Move(NAN_VEC) end)
    if hasSHP then pcall(function() sethiddenproperty(myHrp, "PhysicsRepRootPart", targetHrp) end) end
end

function Troll.SetupNanFling(refs)
    local function setNanMode(m)
        nanMode = m
        if m == "area" then
            refs.nanModeBtn.Text             = "Mode: Area (gần mình)"
            refs.nanModeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        else
            refs.nanModeBtn.Text             = "Mode: Target (" .. (refs.trollBox.Text ~= "" and refs.trollBox.Text or "chọn player") .. ")"
            refs.nanModeBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
        end
    end

    refs.nanModeBtn.MouseButton1Click:Connect(function()
        setNanMode(nanMode == "area" and "target" or "area")
    end)

    refs.nanFlingBtn.MouseButton1Click:Connect(function()
        isNanFling = not isNanFling
        if isNanFling then
            if nanMode == "target" then
                local t = Core.FindPlayer(refs.trollBox.Text)
                if not (t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")) then
                    refs.trollBox.Text = "Not found!"; task.wait(1); refs.trollBox.Text = ""
                    isNanFling = false; return
                end
                nanFlingTarget = t
            end
            refs.nanFlingBtn.BackgroundColor3 = T.Troll
            refs.nanFlingBtn.TextColor3       = Color3.fromRGB(20, 20, 20)
            refs.nanFlingBtn.Text             = "☠️ NaN Fling: ON" .. (hasSHP and " [SHP]" or "")
            Core.Track("nanFling", RS.Heartbeat:Connect(function()
                local myChar = Core.Player.Character
                local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
                local myHrp  = myHum and myHum.RootPart
                if not myChar or not myHrp then return end
                if nanMode == "target" then
                    if not (nanFlingTarget and nanFlingTarget.Character) then
                        isNanFling = false; Core.Untrack("nanFling")
                        refs.nanFlingBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
                        refs.nanFlingBtn.TextColor3       = T.TextMain
                        refs.nanFlingBtn.Text             = "☠️ NaN Fling (Toggle)"
                        pcall(function() myHum.PlatformStand = false end); return
                    end
                    local tHrp = nanFlingTarget.Character:FindFirstChild("HumanoidRootPart")
                    if tHrp then ApplyNanFling(tHrp, myHrp, myHum) end
                else
                    for _, p in ipairs(Core.Services.Players:GetPlayers()) do
                        if p ~= Core.Player and p.Character then
                            local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if tHrp then
                                local dist = (myHrp.Position - tHrp.Position).Magnitude
                                if dist <= 15 then ApplyNanFling(tHrp, myHrp, myHum) end
                            end
                        end
                    end
                end
            end))
        else
            Core.Untrack("nanFling"); nanFlingTarget = nil
            local myHum = Core.Player.Character and Core.Player.Character:FindFirstChildOfClass("Humanoid")
            pcall(function() if myHum then myHum.PlatformStand = false end end)
            refs.nanFlingBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
            refs.nanFlingBtn.TextColor3       = T.TextMain
            refs.nanFlingBtn.Text             = "☠️ NaN Fling (Toggle)"
        end
    end)
end

function Troll.ResetNanFling(refs)
    if isNanFling then
        isNanFling = false; Core.Untrack("nanFling"); nanFlingTarget = nil
        local myHum = Core.Player.Character and Core.Player.Character:FindFirstChildOfClass("Humanoid")
        pcall(function() if myHum then myHum.PlatformStand = false end end)
        refs.nanFlingBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        refs.nanFlingBtn.TextColor3       = T.TextMain
        refs.nanFlingBtn.Text             = "☠️ NaN Fling (Toggle)"
    end
end

-- ── Welder ───────────────────────────────────────────────────
local currentWeld  = nil
local weldThread   = nil
local WELD_FPDH    = workspace.FallenPartsDestroyHeight
local WELD_GROUP   = Core.RandName(12)

pcall(function()
    local PS = game:GetService("PhysicsService")
    PS:RegisterCollisionGroup(WELD_GROUP)
    PS:CollisionGroupSetCollidable(WELD_GROUP, WELD_GROUP, true)
end)

local function StopWeld()
    if weldThread then task.cancel(weldThread); weldThread = nil end
    if currentWeld then
        pcall(function() if currentWeld.part and currentWeld.part.Parent then currentWeld.part:Destroy() end end)
        local myChar = Core.Player.Character
        if myChar and currentWeld.oldCharProps then
            for part, props in pairs(currentWeld.oldCharProps) do
                pcall(function() if part and part.Parent then part.CollisionGroup = props.group; part.CanCollide = props.collide end end)
            end
        end
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if myHum then pcall(function() myHum.RequiresNeck = true end) end
        if currentWeld.animTrack then pcall(function() currentWeld.animTrack:Stop() end) end
        currentWeld = nil
    end
    workspace.FallenPartsDestroyHeight = WELD_FPDH
end

local function StartWeld(targetPart, offset, animId)
    StopWeld()
    local myChar = Core.Player.Character
    local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myRoot = myHum and myHum.RootPart
    if not myChar or not myRoot then return end
    workspace.FallenPartsDestroyHeight = 0 / 0

    local weldPart = Instance.new("Part")
    weldPart.Name           = Core.RandName(6)
    weldPart.Size           = Vector3.new(25, 3, 25)
    weldPart.Anchored       = false
    weldPart.CanCollide     = true
    weldPart.Transparency   = 1
    weldPart.CastShadow     = false
    weldPart.CollisionGroup = WELD_GROUP
    weldPart.Parent         = workspace.Terrain

    local oldCharProps = {}
    for _, p in ipairs(myChar:GetDescendants()) do
        if p:IsA("BasePart") then
            oldCharProps[p] = {group = p.CollisionGroup, collide = p.CanCollide}
            p.CollisionGroup = WELD_GROUP; p.CanCollide = true
        end
    end
    pcall(function() myHum.RequiresNeck = false end)

    local animTrack = nil
    if animId and animId ~= 0 then
        pcall(function()
            local animator = myChar:FindFirstChildWhichIsA("Animator", true)
            if animator then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. tostring(animId)
                animTrack = animator:LoadAnimation(anim)
                animTrack:Play()
            end
        end)
    end

    currentWeld = {part = weldPart, oldCharProps = oldCharProps, animTrack = animTrack}
    weldThread  = task.spawn(function()
        while currentWeld do
            if not targetPart or not targetPart.Parent then StopWeld(); break end
            local tCF = targetPart.CFrame
            weldPart.CFrame = tCF; myRoot.CFrame = tCF * offset
            weldPart.AssemblyLinearVelocity  = Vector3.zero
            weldPart.AssemblyAngularVelocity = Vector3.zero
            myRoot.AssemblyLinearVelocity    = Vector3.zero
            myRoot.AssemblyAngularVelocity   = Vector3.zero
            RS.RenderStepped:Wait()
            weldPart.CFrame = tCF; myRoot.CFrame = tCF * CFrame.new(0, 4, 0)
            weldPart.AssemblyLinearVelocity  = Vector3.zero
            weldPart.AssemblyAngularVelocity = Vector3.zero
            task.wait()
        end
    end)
end

function Troll.SetupWelder(refs)
    local function weldToPose(poseName, activeBtn)
        local t = Core.FindPlayer(refs.trollBox.Text)
        if not (t and t.Character) then
            refs.trollBox.Text = "Not found!"; task.wait(1); refs.trollBox.Text = ""; return
        end
        local char   = t.Character
        local myChar = Core.Player.Character
        local tHum   = char:FindFirstChildOfClass("Humanoid")
        local tRoot  = (tHum and tHum.RootPart)
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("Torso")
            or char:FindFirstChild("HumanoidRootPart")
        if not tRoot then return end

        local offset, animId
        if poseName == "bang" then
            offset = CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(180), 0); animId = 148840371
        elseif poseName == "behind" then
            offset = CFrame.new(0, 0, 2); animId = 0
        elseif poseName == "stand" then
            if Core.IsR15(myChar) then offset = CFrame.new(1.8, 1.8, 2);  animId = 96658788627102
            else                       offset = CFrame.new(1.5, 1.25, 2); animId = 313762630 end
        elseif poseName == "attack" then
            local r180 = CFrame.Angles(0, math.rad(180), 0)
            if Core.IsR15(myChar) then offset = CFrame.new(0, 0.5, -2.55) * r180; animId = 117183737438245
            else                       offset = CFrame.new(0, 0, -1.25)   * r180; animId = 259438880 end
        elseif poseName == "headsit" then
            offset = CFrame.new(0, 3, 0); animId = 178130996
        elseif poseName == "backpack" then
            offset = CFrame.new(0, 0, 1.05) * CFrame.Angles(0, math.rad(180), 0); animId = 178130996
        elseif poseName == "carpet" then
            offset = CFrame.new(0, -1, 0); animId = 282574440
        end

        StartWeld(tRoot, offset, animId)
        local poseBtns = {refs.weldBangBtn, refs.weldStandBtn, refs.weldAttackBtn,
                          refs.weldHeadBtn, refs.weldBackBtn, refs.weldCarpetBtn, refs.weldBehindBtn}
        for _, b in ipairs(poseBtns) do b.BackgroundColor3 = Color3.fromRGB(40, 40, 60); b.TextColor3 = T.TextMain end
        activeBtn.BackgroundColor3 = T.AccentON; activeBtn.TextColor3 = Color3.fromRGB(20, 20, 25)
    end

    refs.weldBangBtn.MouseButton1Click:Connect(function()   weldToPose("bang",    refs.weldBangBtn) end)
    refs.weldStandBtn.MouseButton1Click:Connect(function()  weldToPose("stand",   refs.weldStandBtn) end)
    refs.weldAttackBtn.MouseButton1Click:Connect(function() weldToPose("attack",  refs.weldAttackBtn) end)
    refs.weldHeadBtn.MouseButton1Click:Connect(function()   weldToPose("headsit", refs.weldHeadBtn) end)
    refs.weldBackBtn.MouseButton1Click:Connect(function()   weldToPose("backpack",refs.weldBackBtn) end)
    refs.weldCarpetBtn.MouseButton1Click:Connect(function() weldToPose("carpet",  refs.weldCarpetBtn) end)
    refs.weldBehindBtn.MouseButton1Click:Connect(function() weldToPose("behind",  refs.weldBehindBtn) end)
    refs.weldUnweldBtn.MouseButton1Click:Connect(StopWeld)

    -- Push
    local isPushing = false
    refs.weldPushBtn.MouseButton1Click:Connect(function()
        isPushing = not isPushing
        if isPushing then
            local t = Core.FindPlayer(refs.trollBox.Text)
            if not (t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")) then
                refs.trollBox.Text = "Not found!"; task.wait(1); refs.trollBox.Text = ""; isPushing = false; return
            end
            refs.weldPushBtn.BackgroundColor3 = T.Troll
            refs.weldPushBtn.TextColor3       = Color3.fromRGB(20, 20, 25)
            refs.weldPushBtn.Text             = "👊 Pushing..."
            local tHrp = t.Character.HumanoidRootPart; local pushForce = 0
            Core.Track("weldPush", RS.Heartbeat:Connect(function()
                if not t.Character or not tHrp.Parent then
                    isPushing = false; Core.Untrack("weldPush")
                    refs.weldPushBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                    refs.weldPushBtn.TextColor3       = T.TextMain; refs.weldPushBtn.Text = "👊 Push"; return
                end
                pushForce = math.min(pushForce + 2, 80)
                tHrp.AssemblyLinearVelocity = tHrp.CFrame.LookVector * pushForce
                local myHrp = Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and currentWeld then myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 1.5) end
            end))
        else
            Core.Untrack("weldPush"); isPushing = false
            refs.weldPushBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            refs.weldPushBtn.TextColor3       = T.TextMain; refs.weldPushBtn.Text = "👊 Push"
        end
    end)

    -- Custom weld
    refs.weldCustomBtn.MouseButton1Click:Connect(function()
        local parts = refs.trollBox.Text:split(" ")
        local x, y, z = tonumber(parts[2]) or 0, tonumber(parts[3]) or 0, tonumber(parts[4]) or 1.3
        local t2 = Core.FindPlayer(parts[1])
        if not (t2 and t2.Character) then
            refs.trollBox.Text = "Format: name x y z"; task.wait(1.5); refs.trollBox.Text = ""; return
        end
        local tRoot2 = t2.Character:FindFirstChild("HumanoidRootPart")
        if tRoot2 then StartWeld(tRoot2, CFrame.new(x, y, z), 0); refs.weldCustomBtn.BackgroundColor3 = T.AccentON end
    end)

    return StopWeld
end

-- ── Spin ─────────────────────────────────────────────────────
function Troll.SetupSpin(refs)
    local isSpinning, spinTarget = false, nil
    refs.spinBtn.MouseButton1Click:Connect(function()
        isSpinning = not isSpinning
        if isSpinning then
            local t = Core.FindPlayer(refs.trollBox.Text)
            if t and t.Character then
                spinTarget = t
                refs.spinBtn.BackgroundColor3 = T.Troll
                refs.spinBtn.Text             = "🌀 Stop Spin: " .. t.Name
                Core.Track("spin", RS.Stepped:Connect(function()
                    if spinTarget and spinTarget.Character then
                        local hrp = spinTarget.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0) end
                    else
                        isSpinning = false
                        refs.spinBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 140)
                        refs.spinBtn.Text             = "🌀 Spin Player (Toggle)"
                        Core.Untrack("spin")
                    end
                end))
            else
                isSpinning = false; refs.trollBox.Text = "Not found!"; task.wait(1); refs.trollBox.Text = ""
            end
        else
            refs.spinBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 140)
            refs.spinBtn.Text             = "🌀 Spin Player (Toggle)"
            spinTarget = nil; Core.Untrack("spin")
        end
    end)

    return function() -- reset
        isSpinning = false; spinTarget = nil; Core.Untrack("spin")
        refs.spinBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 140)
        refs.spinBtn.Text             = "🌀 Spin Player (Toggle)"
    end
end

-- ── Follow ───────────────────────────────────────────────────
function Troll.SetupFollow(refs)
    local isFollowing, followTarget = false, nil
    refs.followBtn.MouseButton1Click:Connect(function()
        isFollowing = not isFollowing
        if isFollowing then
            local t = Core.FindPlayer(refs.trollBox.Text)
            if t and t.Character then
                followTarget = t
                refs.followBtn.BackgroundColor3 = T.Troll
                refs.followBtn.Text             = "👁 Stop Follow: " .. t.Name
                Core.Track("follow", RS.Heartbeat:Connect(function()
                    if not followTarget or not followTarget.Character then
                        isFollowing = false
                        refs.followBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 80)
                        refs.followBtn.Text             = "👁 Follow Player (Toggle)"
                        Core.Untrack("follow"); return
                    end
                    local tHrp = followTarget.Character:FindFirstChild("HumanoidRootPart")
                    local mHrp = Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart")
                    if tHrp and mHrp then
                        if (mHrp.Position - tHrp.Position).Magnitude > 8 then
                            mHrp.CFrame = tHrp.CFrame * CFrame.new(2, 0, 3)
                        end
                    end
                end))
            else
                isFollowing = false; refs.trollBox.Text = "Not found!"; task.wait(1); refs.trollBox.Text = ""
            end
        else
            refs.followBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 80)
            refs.followBtn.Text             = "👁 Follow Player (Toggle)"
            followTarget = nil; Core.Untrack("follow")
        end
    end)

    return function() -- reset
        isFollowing = false; followTarget = nil; Core.Untrack("follow")
        refs.followBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 80)
        refs.followBtn.Text             = "👁 Follow Player (Toggle)"
    end
end

-- ── Emotes ───────────────────────────────────────────────────
function Troll.SetupEmotes(emoteBtns)
    for name, btn in pairs(emoteBtns) do
        btn.MouseButton1Click:Connect(function()
            local char = Core.Player.Character
            if char and char:FindFirstChild("Animate") then
                local pe = char.Animate:FindFirstChild("PlayEmote")
                if pe and pe:IsA("BindableFunction") then
                    pe:Invoke(name)
                    btn.BackgroundColor3 = T.AccentON
                    task.delay(0.4, function() btn.BackgroundColor3 = T.ElemBG end)
                end
            end
        end)
    end
end

return Troll
