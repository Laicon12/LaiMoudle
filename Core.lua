-- ============================================================
-- LAI ADMIN v3.5 | Core.lua
-- Services, Utils, Connections, Theme, Config
-- ============================================================

local Core = {}

-- ── Services ─────────────────────────────────────────────────
Core.Services = {
    Players         = game:GetService("Players"),
    RunService      = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService    = game:GetService("TweenService"),
    Workspace       = game:GetService("Workspace"),
    HttpService     = game:GetService("HttpService"),
}

-- ── Player / Camera shortcuts ────────────────────────────────
Core.Player = Core.Services.Players.LocalPlayer
Core.Camera = Core.Services.Workspace.CurrentCamera
Core.Mouse  = Core.Player:GetMouse()

-- ── Utils ────────────────────────────────────────────────────
math.randomseed(math.floor(tick() * 1000) + math.floor(os.clock() * 1000))

function Core.RandName(len)
    len = math.max(4, len or 8)
    local bytes, pool = {}, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    for _ = 1, len do
        bytes[#bytes + 1] = pool:sub(math.random(1, #pool), math.random(1, #pool))
    end
    return table.concat(bytes)
end

function Core.FindPlayer(partial)
    if not partial or partial == "" then return nil end
    local low = partial:lower()
    for _, p in ipairs(Core.Services.Players:GetPlayers()) do
        if p ~= Core.Player then
            if p.Name:lower():sub(1, #low) == low
            or p.DisplayName:lower():sub(1, #low) == low then
                return p
            end
        end
    end
end

function Core.IsR15(char)
    return char and char:FindFirstChild("UpperTorso") ~= nil
end

-- ── Connection Manager ───────────────────────────────────────
Core.Connections = {}

function Core.Track(label, conn)
    if Core.Connections[label] and Core.Connections[label].Connected then
        Core.Connections[label]:Disconnect()
    end
    Core.Connections[label] = conn
    return conn
end

function Core.Untrack(label)
    if Core.Connections[label] then
        if Core.Connections[label].Connected then
            Core.Connections[label]:Disconnect()
        end
        Core.Connections[label] = nil
    end
end

-- ── Theme ────────────────────────────────────────────────────
Core.Theme = {
    MainBG      = Color3.fromRGB(10, 11, 15),
    ElemBG      = Color3.fromRGB(20, 21, 28),
    ElemHover   = Color3.fromRGB(28, 30, 40),
    ElemActive  = Color3.fromRGB(18, 40, 65),
    AccentON    = Color3.fromRGB(80, 180, 255),
    AccentDim   = Color3.fromRGB(40, 90, 140),
    AccentLine  = Color3.fromRGB(50, 130, 210),
    TextMain    = Color3.fromRGB(240, 242, 248),
    TextSub     = Color3.fromRGB(120, 128, 155),
    TextDim     = Color3.fromRGB(70, 75, 100),
    Border      = Color3.fromRGB(30, 32, 45),
    Troll       = Color3.fromRGB(255, 65, 85),
    Warn        = Color3.fromRGB(255, 180, 50),
}

-- ── Keybinds ─────────────────────────────────────────────────
Core.Keybinds = {
    Menu        = Enum.KeyCode.Insert,
    Fly         = Enum.KeyCode.C,
    WalkSpeed   = Enum.KeyCode.V,
    SelfFreeze  = Enum.KeyCode.B,
    JumpPower   = Enum.KeyCode.Unknown,
    InfJump     = Enum.KeyCode.Unknown,
    ESP         = Enum.KeyCode.Unknown,
    Noclip      = Enum.KeyCode.Unknown,
    Freeze      = Enum.KeyCode.Unknown,
    FakeInvis   = Enum.KeyCode.Unknown,
    AntiFling   = Enum.KeyCode.Unknown,
    BypassAC    = Enum.KeyCode.Unknown,
}

-- ── Config ───────────────────────────────────────────────────
Core.ConfigName = "LaiAdmin_Config.json"

function Core.SaveConfig(refs)
    local ok, err = pcall(function()
        if not writefile then error("No writefile") end
        local cfg = {
            Keybinds        = {},
            WalkSpeed       = refs.walkBox.Text,
            JumpPower       = refs.jumpBox.Text,
            FlySpeed        = refs.flySpeedBox.Text,
            MouseTPSpeed    = refs.mouseTpSpeedBox.Text,
            FakeInvisOffset = refs.fakeInvisBox.Text,
        }
        for k, v in pairs(Core.Keybinds) do cfg.Keybinds[k] = v.Name end
        writefile(Core.ConfigName, Core.Services.HttpService:JSONEncode(cfg))
    end)
    return ok, err
end

function Core.LoadConfig(refs, updateBindTexts)
    pcall(function()
        if not isfile or not isfile(Core.ConfigName) then return end
        local raw = readfile(Core.ConfigName)
        if not raw or raw == "" then return end
        local s, cfg = pcall(function() return Core.Services.HttpService:JSONDecode(raw) end)
        if s and cfg then
            if cfg.Keybinds then
                for k, v in pairs(cfg.Keybinds) do
                    if Core.Keybinds[k] then
                        pcall(function()
                            Core.Keybinds[k] = Enum.KeyCode[v]
                            if updateBindTexts[k] then updateBindTexts[k]() end
                        end)
                    end
                end
            end
            if cfg.WalkSpeed       then refs.walkBox.Text        = cfg.WalkSpeed       end
            if cfg.JumpPower       then refs.jumpBox.Text        = cfg.JumpPower       end
            if cfg.FlySpeed        then refs.flySpeedBox.Text    = cfg.FlySpeed        end
            if cfg.MouseTPSpeed    then refs.mouseTpSpeedBox.Text = cfg.MouseTPSpeed   end
            if cfg.FakeInvisOffset then refs.fakeInvisBox.Text   = cfg.FakeInvisOffset end
        end
    end)
end

return Core
