-- ============================================================
-- LAI ADMIN v3.5 | GUI.lua
-- Window setup, tab system, widget builders
-- ============================================================

local GUI = {}

local Core = require(script.Parent.Core)
local T    = Core.Theme
local UIS  = Core.Services.UserInputService
local TS   = Core.Services.TweenService

-- ── Secure Container ─────────────────────────────────────────
local function getSecureContainer()
    if type(gethui) == "function" then
        local s, ui = pcall(gethui)
        if s and ui then return ui end
    end
    if type(cloneref) == "function" then
        local s, core = pcall(function() return cloneref(game:GetService("CoreGui")) end)
        if s and core then return core end
    end
    local s, core = pcall(function() return game:GetService("CoreGui") end)
    if s and core then return core end
    return Core.Player:WaitForChild("PlayerGui")
end

-- ── Build ScreenGui ──────────────────────────────────────────
function GUI.Build()
    local gui = Instance.new("ScreenGui")
    gui.Name           = Core.RandName(16)
    gui.ResetOnSpawn   = false
    gui.IgnoreGuiInset = true

    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui)
        elseif type(protectgui)  == "function" then protectgui(gui)
        elseif type(protect_gui) == "function" then protect_gui(gui)
        end
    end)
    gui.Parent = getSecureContainer()

    -- Shadow
    local shadow = Instance.new("Frame", gui)
    shadow.Size                   = UDim2.new(0, 292, 0, 512)
    shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.55
    shadow.BorderSizePixel        = 0
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 14)

    -- Main frame
    local main = Instance.new("Frame", gui)
    main.Size                   = UDim2.new(0, 280, 0, 500)
    main.BackgroundColor3       = T.MainBG
    main.BackgroundTransparency = 0.08
    main.BorderSizePixel        = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local isMenuOpen  = true
    local openPos     = UDim2.new(0, 20,   0.5, -250)
    local closedPos   = UDim2.new(0, -320, 0.5, -250)
    local openShadow  = UDim2.new(0, 14,   0.5, -253)
    local closedShadow= UDim2.new(0, -326, 0.5, -253)
    main.Position   = openPos
    shadow.Position = openShadow

    local outerStroke = Instance.new("UIStroke", main)
    outerStroke.Color     = T.Border
    outerStroke.Thickness = 1

    local accentBar = Instance.new("Frame", main)
    accentBar.Size                   = UDim2.new(1, -24, 0, 1)
    accentBar.Position               = UDim2.new(0, 12, 0, 0)
    accentBar.BackgroundColor3       = T.AccentLine
    accentBar.BackgroundTransparency = 0.3
    accentBar.BorderSizePixel        = 0

    -- Title bar
    local titleF = Instance.new("Frame", main)
    titleF.Size                 = UDim2.new(1, 0, 0, 44)
    titleF.BackgroundTransparency = 1
    titleF.BorderSizePixel      = 0

    local titleDot = Instance.new("Frame", titleF)
    titleDot.Size             = UDim2.new(0, 6, 0, 6)
    titleDot.Position         = UDim2.new(0, 14, 0.5, -3)
    titleDot.BackgroundColor3 = T.AccentON
    titleDot.BorderSizePixel  = 0
    Instance.new("UICorner", titleDot).CornerRadius = UDim.new(1, 0)

    local titleLbl = Instance.new("TextLabel", titleF)
    titleLbl.Size               = UDim2.new(0, 140, 1, 0)
    titleLbl.Position           = UDim2.new(0, 26, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text               = "LAI ADMIN"
    titleLbl.TextColor3         = T.TextMain
    titleLbl.Font               = Enum.Font.GothamBlack
    titleLbl.TextSize           = 13
    titleLbl.TextXAlignment     = Enum.TextXAlignment.Left

    local titleSub = Instance.new("TextLabel", titleF)
    titleSub.Size               = UDim2.new(0, 100, 1, 0)
    titleSub.Position           = UDim2.new(0, 112, 0, 0)
    titleSub.BackgroundTransparency = 1
    titleSub.Text               = "v3.5"
    titleSub.TextColor3         = T.TextDim
    titleSub.Font               = Enum.Font.Gotham
    titleSub.TextSize           = 11
    titleSub.TextXAlignment     = Enum.TextXAlignment.Left

    local menuBindBtn = Instance.new("TextButton", titleF)
    menuBindBtn.Size             = UDim2.new(0, 44, 0, 22)
    menuBindBtn.Position         = UDim2.new(1, -54, 0.5, -11)
    menuBindBtn.BackgroundColor3 = T.ElemBG
    menuBindBtn.TextColor3       = T.AccentON
    menuBindBtn.Font             = Enum.Font.GothamBold
    menuBindBtn.TextSize         = 10
    menuBindBtn.Text             = Core.Keybinds.Menu.Name
    menuBindBtn.BorderSizePixel  = 0
    Instance.new("UICorner", menuBindBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", menuBindBtn).Color = T.AccentDim

    local titleSep = Instance.new("Frame", main)
    titleSep.Size             = UDim2.new(1, -20, 0, 1)
    titleSep.Position         = UDim2.new(0, 10, 0, 44)
    titleSep.BackgroundColor3 = T.Border
    titleSep.BorderSizePixel  = 0

    -- Drag
    local dragging, dragStart, startPos = false, nil, nil
    titleF.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta  = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            main.Position   = newPos
            shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 6,
                                        newPos.Y.Scale, newPos.Y.Offset - 3)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Tab bar
    local tabBar = Instance.new("Frame", main)
    tabBar.Size                 = UDim2.new(1, 0, 0, 34)
    tabBar.Position             = UDim2.new(0, 0, 0, 46)
    tabBar.BackgroundTransparency = 1

    local tabLine = Instance.new("Frame", tabBar)
    tabLine.Size             = UDim2.new(1, -20, 0, 1)
    tabLine.Position         = UDim2.new(0, 10, 1, -1)
    tabLine.BackgroundColor3 = T.Border
    tabLine.BorderSizePixel  = 0

    local tabIndicator = Instance.new("Frame", tabBar)
    tabIndicator.Size             = UDim2.new(0.25, -10, 0, 2)
    tabIndicator.Position         = UDim2.new(0, 5, 1, -2)
    tabIndicator.BackgroundColor3 = T.AccentON
    tabIndicator.BorderSizePixel  = 0
    Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(1, 0)

    local function mkTab(text, x, col)
        local b = Instance.new("TextButton", tabBar)
        b.Size                 = UDim2.new(0.25, 0, 1, -2)
        b.Position             = UDim2.new(x, 0, 0, 0)
        b.BackgroundTransparency = 1
        b.Text                 = text
        b.TextColor3           = col or T.TextSub
        b.Font                 = Enum.Font.GothamSemibold
        b.TextSize             = 11
        return b
    end
    local tabMain   = mkTab("Main",   0,    T.TextMain)
    local tabTP     = mkTab("TP",     0.25)
    local tabEmotes = mkTab("Emotes", 0.50)
    local tabTroll  = mkTab("Troll",  0.75, T.Troll)

    -- Scroll containers
    local function mkContainer(visible)
        local sf = Instance.new("ScrollingFrame", main)
        sf.Size                = UDim2.new(1, 0, 1, -82)
        sf.Position            = UDim2.new(0, 0, 0, 82)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel     = 0
        sf.ScrollBarThickness  = 2
        sf.ScrollBarImageColor3 = T.AccentDim
        sf.Visible             = visible
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.CanvasSize          = UDim2.new(0, 0, 0, 0)
        local l = Instance.new("UIListLayout", sf)
        l.Padding              = UDim.new(0, 6)
        l.HorizontalAlignment  = Enum.HorizontalAlignment.Center
        l.SortOrder            = Enum.SortOrder.LayoutOrder
        local p = Instance.new("UIPadding", sf)
        p.PaddingTop    = UDim.new(0, 8)
        p.PaddingBottom = UDim.new(0, 12)
        return sf
    end

    local cMain   = mkContainer(true)
    local cTP     = mkContainer(false)
    local cEmotes = mkContainer(false)
    local cTroll  = mkContainer(false)

    -- Tab switch
    local tabs = {
        {btn = tabMain,   c = cMain,   x = 0},
        {btn = tabTP,     c = cTP,     x = 0.25},
        {btn = tabEmotes, c = cEmotes, x = 0.50},
        {btn = tabTroll,  c = cTroll,  x = 0.75},
    }
    local function switchTab(ab, ac, ax)
        for _, t in ipairs(tabs) do
            t.c.Visible            = false
            t.btn.BackgroundTransparency = 1
            t.btn.TextColor3       = (t.btn == tabTroll) and Color3.fromRGB(180, 50, 65) or T.TextDim
            t.btn.Font             = Enum.Font.GothamSemibold
        end
        ac.Visible        = true
        ab.TextColor3     = (ab == tabTroll) and T.Troll or T.TextMain
        ab.Font           = Enum.Font.GothamBold
        tabIndicator.Position         = UDim2.new(ax, 5, 1, -2)
        tabIndicator.Size             = UDim2.new(0.25, -10, 0, 2)
        tabIndicator.BackgroundColor3 = (ab == tabTroll) and T.Troll or T.AccentON
    end
    for _, t in ipairs(tabs) do
        local tt = t
        t.btn.MouseButton1Click:Connect(function() switchTab(tt.btn, tt.c, tt.x) end)
    end
    switchTab(tabMain, cMain, 0)

    -- Menu toggle (exposed for input handler)
    local function toggleMenu()
        isMenuOpen = not isMenuOpen
        local pos  = isMenuOpen and openPos    or closedPos
        local spos = isMenuOpen and openShadow or closedShadow
        local ti   = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TS:Create(main,   ti, {Position = pos}):Play()
        TS:Create(shadow, ti, {Position = spos}):Play()
    end

    return {
        gui          = gui,
        main         = main,
        shadow       = shadow,
        titleLbl     = titleLbl,
        menuBindBtn  = menuBindBtn,
        toggleMenu   = toggleMenu,
        cMain        = cMain,
        cTP          = cTP,
        cEmotes      = cEmotes,
        cTroll       = cTroll,
    }
end

-- ── Widget Builders ──────────────────────────────────────────
local function stroke(obj, col, thick)
    local s = Instance.new("UIStroke", obj)
    s.Color     = col   or T.Border
    s.Thickness = thick or 1
end

function GUI.MkRow(parent, text, action, order, updateBindTexts)
    local row = Instance.new("Frame", parent)
    row.Size                 = UDim2.new(0.92, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.LayoutOrder          = order

    local tog = Instance.new("TextButton", row)
    tog.Size             = UDim2.new(1, -50, 1, 0)
    tog.BackgroundColor3 = T.ElemBG
    tog.TextColor3       = T.TextMain
    tog.Font             = Enum.Font.GothamSemibold
    tog.TextSize         = 12
    tog.Text             = text
    tog.BorderSizePixel  = 0
    Instance.new("UICorner", tog).CornerRadius = UDim.new(0, 6)
    stroke(tog)

    local bind = Instance.new("TextButton", row)
    bind.Size             = UDim2.new(0, 44, 1, 0)
    bind.Position         = UDim2.new(1, -44, 0, 0)
    bind.BackgroundColor3 = T.ElemBG
    bind.TextColor3       = T.AccentON
    bind.Font             = Enum.Font.GothamBold
    bind.TextSize         = 10
    bind.BorderSizePixel  = 0
    Instance.new("UICorner", bind).CornerRadius = UDim.new(0, 6)
    stroke(bind, T.AccentDim)

    local function updateBindText()
        local kb = Core.Keybinds[action]
        bind.Text = (kb and kb ~= Enum.KeyCode.Unknown) and kb.Name or "-"
    end
    if updateBindTexts then updateBindTexts[action] = updateBindText end
    updateBindText()

    bind.MouseButton1Click:Connect(function()
        Core._listeningForAction = action
        Core._listeningButton    = bind
        bind.Text                = "..."
        bind.TextColor3          = T.Warn
    end)
    return tog
end

function GUI.MkInput(parent, ph, order)
    local b = Instance.new("TextBox", parent)
    b.Size                 = UDim2.new(0.92, 0, 0, 28)
    b.BackgroundColor3     = T.ElemBG
    b.TextColor3           = T.AccentON
    b.Font                 = Enum.Font.GothamBold
    b.TextSize             = 12
    b.LayoutOrder          = order
    b.PlaceholderText      = ph
    b.PlaceholderColor3    = T.TextDim
    b.Text                 = ""
    b.BorderSizePixel      = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    stroke(b)
    return b
end

function GUI.MkBtn(parent, text, bg, order)
    local b = Instance.new("TextButton", parent)
    b.Size             = UDim2.new(0.92, 0, 0, 30)
    b.BackgroundColor3 = bg or T.ElemBG
    b.TextColor3       = T.TextMain
    b.Font             = Enum.Font.GothamSemibold
    b.TextSize         = 12
    b.Text             = text
    b.LayoutOrder      = order
    b.BorderSizePixel  = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    stroke(b)
    return b
end

function GUI.MkPresets(parent, label, vals, box, order)
    local row = Instance.new("Frame", parent)
    row.Size                 = UDim2.new(0.92, 0, 0, 22)
    row.BackgroundTransparency = 1
    row.LayoutOrder          = order

    local lbl = Instance.new("TextLabel", row)
    lbl.Size                 = UDim2.new(0.28, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                 = label
    lbl.TextColor3           = T.TextDim
    lbl.Font                 = Enum.Font.Gotham
    lbl.TextSize             = 10
    lbl.TextXAlignment       = Enum.TextXAlignment.Left

    local w = 0.72 / #vals
    for i, v in ipairs(vals) do
        local b = Instance.new("TextButton", row)
        b.Size             = UDim2.new(w, -3, 1, 0)
        b.Position         = UDim2.new(0.28 + w * (i - 1), 2, 0, 0)
        b.BackgroundColor3 = T.ElemBG
        b.TextColor3       = T.TextSub
        b.Font             = Enum.Font.GothamBold
        b.TextSize         = 10
        b.Text             = tostring(v)
        b.BorderSizePixel  = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        stroke(b)
        b.MouseButton1Click:Connect(function()
            box.Text = tostring(v)
            b.TextColor3 = T.AccentON
            task.delay(0.3, function() b.TextColor3 = T.TextSub end)
        end)
    end
end

function GUI.MkLabel(parent, text, order)
    local l = Instance.new("TextLabel", parent)
    l.Size                 = UDim2.new(0.92, 0, 0, 16)
    l.BackgroundTransparency = 1
    l.Text                 = text
    l.TextColor3           = T.TextDim
    l.Font                 = Enum.Font.GothamSemibold
    l.TextSize             = 10
    l.TextXAlignment       = Enum.TextXAlignment.Left
    l.LayoutOrder          = order
    return l
end

function GUI.MkPoseFrame(parent, order)
    local f = Instance.new("Frame", parent)
    f.Size                 = UDim2.new(0.9, 0, 0, 30)
    f.BackgroundTransparency = 1
    f.LayoutOrder          = order
    local l = Instance.new("UIListLayout", f)
    l.FillDirection = Enum.FillDirection.Horizontal
    l.Padding       = UDim.new(0, 4)
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    return f
end

function GUI.MkPoseBtn(parent, text, order)
    local b = Instance.new("TextButton", parent)
    b.Size             = UDim2.new(0, 60, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    b.TextColor3       = T.TextMain
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 11
    b.Text             = text
    b.LayoutOrder      = order
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

function GUI.SetBtn(btn, on)
    btn.BackgroundColor3 = on and T.AccentON or T.ElemBG
    btn.TextColor3       = on and Color3.fromRGB(25, 25, 30) or T.TextMain
end

-- Player list widget
function GUI.MkPlayerList(parent, targetBox, layoutOrder)
    local P = Core.Services.Players

    local wrap = Instance.new("Frame", parent)
    wrap.Size                 = UDim2.new(0.9, 0, 0, 135)
    wrap.BackgroundTransparency = 1
    wrap.LayoutOrder          = layoutOrder

    local sBox = GUI.MkInput(wrap, "🔍 Search Player...", 1)
    sBox.Size     = UDim2.new(1, 0, 0, 22)
    sBox.Position = UDim2.new(0, 0, 0, 0)

    local frame = Instance.new("Frame", wrap)
    frame.Size             = UDim2.new(1, 0, 1, -26)
    frame.Position         = UDim2.new(0, 0, 0, 26)
    frame.BackgroundColor3 = T.ElemBG
    frame.BorderSizePixel  = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local sf = Instance.new("ScrollingFrame", frame)
    sf.Size                = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel     = 0
    sf.ScrollBarThickness  = 3
    sf.ScrollBarImageColor3 = T.AccentON
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize          = UDim2.new(0, 0, 0, 0)
    local ll = Instance.new("UIListLayout", sf)
    ll.Padding    = UDim.new(0, 2)
    ll.SortOrder  = Enum.SortOrder.Name
    local pp = Instance.new("UIPadding", sf)
    pp.PaddingTop    = UDim.new(0, 4); pp.PaddingBottom = UDim.new(0, 4)
    pp.PaddingLeft   = UDim.new(0, 4); pp.PaddingRight  = UDim.new(0, 4)

    local btns = {}
    local function refresh()
        for _, b in pairs(btns) do pcall(function() b:Destroy() end) end
        btns = {}
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= Core.Player then
                local b = Instance.new("TextButton", sf)
                b.Size             = UDim2.new(1, -6, 0, 24)
                b.BackgroundColor3 = T.ElemHover
                b.TextColor3       = T.TextMain
                b.Font             = Enum.Font.GothamSemibold
                b.TextSize         = 12
                b.Text             = p.DisplayName .. " (@" .. p.Name .. ")"
                b.TextXAlignment   = Enum.TextXAlignment.Left
                b.BorderSizePixel  = 0
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
                local pad = Instance.new("UIPadding", b)
                pad.PaddingLeft = UDim.new(0, 6)
                b.MouseButton1Click:Connect(function()
                    targetBox.Text = p.Name
                    for _, ob in pairs(btns) do
                        ob.BackgroundColor3 = T.ElemHover
                        ob.TextColor3       = T.TextMain
                    end
                    b.BackgroundColor3 = T.AccentON
                    b.TextColor3       = Color3.fromRGB(20, 20, 25)
                end)
                btns[p.Name] = b
            end
        end
    end
    sBox:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = sBox.Text:lower()
        for _, b in pairs(btns) do
            b.Visible = (txt == "" or string.find(b.Text:lower(), txt) ~= nil)
        end
    end)

    return wrap, btns, refresh
end

return GUI
