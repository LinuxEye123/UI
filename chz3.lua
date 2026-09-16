--[[
    juanita****.club — Cheat Menu
    LuaU / Roblox GUI Implementation
    Mirrors the React/TSX design with orange accent, dark surfaces,
    draggable window, tabs, checkboxes, sliders, and dropdowns.
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ── ScreenGui (tries CoreGui for executor context, falls back to PlayerGui) ──

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "CheatMenu"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder    = 999

local ok = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ok then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ── Palette ───────────────────────────────────────────────────────────────────

local C = {
    Accent       = Color3.fromRGB(212, 90,  16),
    AccentBright = Color3.fromRGB(232, 112, 26),
    AccentDim    = Color3.fromRGB(154,  60,  8),
    Bg           = Color3.fromRGB( 22,  22, 22),
    Surface      = Color3.fromRGB( 32,  32, 32),
    Border       = Color3.fromRGB( 46,  46, 46),
    BorderDark   = Color3.fromRGB( 20,  20, 20),
    Text         = Color3.fromRGB(200, 200, 200),
    TextDim      = Color3.fromRGB(160, 160, 160),
    TextMuted    = Color3.fromRGB(112, 112, 112),
    Green        = Color3.fromRGB( 46, 204,  85),
    Red          = Color3.fromRGB(146,  32,  32),
    TabBg        = Color3.fromRGB( 18,  18, 18),
    ActiveTab    = Color3.fromRGB( 32,  32, 32),
    InputBg      = Color3.fromRGB( 20,  20, 20),
}

-- ── Tween presets ─────────────────────────────────────────────────────────────

local FAST = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local MED  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tw(inst, props, info)
    TweenService:Create(inst, info or FAST, props):Play()
end

-- ── Instance helpers ──────────────────────────────────────────────────────────

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(r, parent)
    return make("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local function stroke(thickness, color, parent)
    return make("UIStroke", {
        Thickness        = thickness,
        Color            = color,
        ApplyStrokeMode  = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function listLayout(parent, dir, spacing, halign, valign)
    return make("UIListLayout", {
        FillDirection      = dir or Enum.FillDirection.Vertical,
        Padding            = UDim.new(0, spacing or 5),
        SortOrder          = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment  = valign or Enum.VerticalAlignment.Top,
    }, parent)
end

local function padding(left, right, top, bottom, parent)
    return make("UIPadding", {
        PaddingLeft   = UDim.new(0, left   or 0),
        PaddingRight  = UDim.new(0, right  or 0),
        PaddingTop    = UDim.new(0, top    or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    }, parent)
end

-- ── State ─────────────────────────────────────────────────────────────────────

local State = {
    mainTab  = "Aimbot",
    rightTab = "Aimbot",

    aimbot = {
        enabled    = true,  silentAim  = false, fov        = 50,
        hitbox     = "Head",visible    = false,  dormant    = false,
        smokeCheck = false,  flashCheck = false,  autoWall   = false,
        autoStop   = false,  autoScope  = false,  silentWalk = false,
        noRecoil   = false,
    },
    rAimbot = {
        enabled = true, silentAim = false, autoShoot = false,
        fov = 8, smooth = 65, hitbox = "Head", trigKey = "Toggle",
    },
    visuals = {
        playerESP = true, skeleton = true, showHealth = true, showName = true,
        showDistance = false, showWeapon = false, espStyle = "Box", chams = "None",
    },
    config = { autoSave = false, configName = "default" },
    misc   = { bunnyHop = false, autoStrafe = false, radar = false, noFlash = false },
    generic = {},
}

-- ── Primitive: Divider ────────────────────────────────────────────────────────

local function mkDivider(parent)
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(44, 44, 44),
        BorderSizePixel  = 0,
    }, parent)
end

-- ── Primitive: Section label ──────────────────────────────────────────────────

local function mkSectionLabel(parent, text)
    make("TextLabel", {
        Text             = text:upper(),
        Font             = Enum.Font.GothamBold,
        TextSize         = 9,
        TextColor3       = Color3.fromRGB(120, 120, 120),
        TextXAlignment   = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 14),
    }, parent)
end

-- ── Primitive: Panel heading ──────────────────────────────────────────────────

local function mkHeading(parent, text)
    local f = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
    }, parent)
    make("Frame", {
        Size             = UDim2.new(0, 3, 0, 11),
        Position         = UDim2.new(0, 0, 0.5, -5),
        BackgroundColor3 = C.AccentBright,
        BorderSizePixel  = 0,
    }, f)
    make("TextLabel", {
        Text             = text,
        Font             = Enum.Font.GothamBold,
        TextSize         = 11,
        TextColor3       = Color3.fromRGB(200, 200, 200),
        TextXAlignment   = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 8, 0, 0),
        Size             = UDim2.new(1, -8, 1, 0),
    }, f)
    return f
end

-- ── Primitive: Checkbox ───────────────────────────────────────────────────────

local function mkCheckbox(parent, label, initial, onChange)
    local checked = initial
    local row = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
    }, parent)

    local box = make("Frame", {
        Size             = UDim2.new(0, 13, 0, 13),
        Position         = UDim2.new(0, 0, 0.5, -6),
        BackgroundColor3 = checked and C.Accent or Color3.fromRGB(32, 32, 32),
        BorderSizePixel  = 0,
    }, row)
    corner(2, box)
    local boxStroke = stroke(1, checked and C.Accent or Color3.fromRGB(54, 54, 54), box)

    local check = make("TextLabel", {
        Text             = "✓",
        Font             = Enum.Font.GothamBold,
        TextSize         = 9,
        TextColor3       = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 1, 0),
        Visible          = checked,
    }, box)

    local lbl = make("TextLabel", {
        Text             = label,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextColor3       = checked and C.TextDim or C.TextMuted,
        TextXAlignment   = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 18, 0, 0),
        Size             = UDim2.new(1, -18, 1, 0),
    }, row)

    local btn = make("TextButton", {
        Text             = "",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, row)

    local function refresh()
        tw(box,      { BackgroundColor3 = checked and C.Accent or Color3.fromRGB(32, 32, 32) })
        tw(boxStroke,{ Color            = checked and C.Accent or Color3.fromRGB(54, 54, 54) })
        tw(lbl,      { TextColor3       = checked and C.TextDim or C.TextMuted })
        check.Visible = checked
    end

    btn.MouseButton1Click:Connect(function()
        checked = not checked
        refresh()
        if onChange then onChange(checked) end
    end)
    btn.MouseEnter:Connect(function()
        if not checked then
            tw(box,      { BackgroundColor3 = Color3.fromRGB(40, 40, 40) })
            tw(boxStroke,{ Color            = Color3.fromRGB(74, 74, 74) })
            tw(lbl,      { TextColor3       = Color3.fromRGB(184, 184, 184) })
        end
    end)
    btn.MouseLeave:Connect(function()
        if not checked then
            tw(box,      { BackgroundColor3 = Color3.fromRGB(32, 32, 32) })
            tw(boxStroke,{ Color            = Color3.fromRGB(54, 54, 54) })
            tw(lbl,      { TextColor3       = C.TextMuted })
        end
    end)

    return row
end

-- ── Primitive: Slider ─────────────────────────────────────────────────────────

local function mkSlider(parent, label, initial, onChange)
    local value   = initial
    local sliding = false

    local container = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
    }, parent)

    -- Label row
    local topRow = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
    }, container)
    make("TextLabel", {
        Text             = label,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextColor3       = C.TextMuted,
        TextXAlignment   = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -36, 1, 0),
    }, topRow)
    local valLabel = make("TextLabel", {
        Text             = tostring(value) .. "%",
        Font             = Enum.Font.GothamBold,
        TextSize         = 11,
        TextColor3       = C.AccentBright,
        TextXAlignment   = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        Position         = UDim2.new(1, -36, 0, 0),
        Size             = UDim2.new(0, 36, 1, 0),
    }, topRow)

    -- Track
    local track = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 5),
        Position         = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel  = 0,
    }, container)
    corner(3, track)
    stroke(1, Color3.fromRGB(46, 46, 46), track)

    local fill = make("Frame", {
        Size             = UDim2.new(value / 100, 0, 1, 0),
        BackgroundColor3 = C.Accent,
        BorderSizePixel  = 0,
    }, track)
    corner(3, fill)

    local thumb = make("Frame", {
        Size             = UDim2.new(0, 9, 0, 9),
        Position         = UDim2.new(value / 100, -4, 0.5, -4),
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, track)
    corner(5, thumb)
    stroke(1, C.Accent, thumb)

    -- Invisible hit zone over track
    local hitZone = make("TextButton", {
        Text             = "",
        Size             = UDim2.new(1, 0, 0, 18),
        Position         = UDim2.new(0, 0, 0.5, -9),
        BackgroundTransparency = 1,
        ZIndex           = 4,
    }, track)

    local function setVal(v)
        v = math.clamp(math.round(v), 0, 100)
        value = v
        valLabel.Text     = tostring(v) .. "%"
        fill.Size         = UDim2.new(v / 100, 0, 1, 0)
        thumb.Position    = UDim2.new(v / 100, -4, 0.5, -4)
        if onChange then onChange(v) end
    end

    hitZone.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            local rel = (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            setVal(rel * 100)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            setVal(rel * 100)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)

    return container
end

-- ── Primitive: Dropdown ───────────────────────────────────────────────────────

local function mkDropdown(parent, initial, options, onChange)
    local value  = initial
    local isOpen = false

    local container = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        ZIndex           = 20,
        ClipsDescendants = false,
    }, parent)

    local trigger = make("TextButton", {
        Text             = "",
        Size             = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel  = 0,
        ZIndex           = 21,
    }, container)
    corner(3, trigger)
    local trigStroke = stroke(1, Color3.fromRGB(58, 58, 58), trigger)

    local valLabel = make("TextLabel", {
        Text             = value,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextColor3       = C.Text,
        TextXAlignment   = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 8, 0, 0),
        Size             = UDim2.new(1, -24, 1, 0),
        ZIndex           = 22,
    }, trigger)

    local arrow = make("TextLabel", {
        Text             = "▾",
        Font             = Enum.Font.GothamBold,
        TextSize         = 10,
        TextColor3       = Color3.fromRGB(136, 136, 136),
        BackgroundTransparency = 1,
        Position         = UDim2.new(1, -18, 0, 0),
        Size             = UDim2.new(0, 14, 1, 0),
        ZIndex           = 22,
    }, trigger)

    local listHeight = #options * 22
    local dropList = make("Frame", {
        Name             = "DropList",
        Size             = UDim2.new(1, 0, 0, listHeight),
        Position         = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 60,
        ClipsDescendants = true,
    }, container)
    corner(3, dropList)
    stroke(1, C.Accent, dropList)

    for i, opt in ipairs(options) do
        local optBtn = make("TextButton", {
            Text             = "",
            Size             = UDim2.new(1, 0, 0, 22),
            Position         = UDim2.new(0, 0, 0, (i - 1) * 22),
            BackgroundColor3 = Color3.fromRGB(38, 18, 6),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 61,
        }, dropList)

        local accentBar = make("Frame", {
            Size             = UDim2.new(0, 2, 1, 0),
            BackgroundColor3 = C.Accent,
            BorderSizePixel  = 0,
            Visible          = false,
            ZIndex           = 62,
        }, optBtn)

        make("TextLabel", {
            Text             = opt,
            Font             = opt == value and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize         = 11,
            TextColor3       = opt == value and C.AccentBright or Color3.fromRGB(184, 184, 184),
            TextXAlignment   = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position         = UDim2.new(0, 10, 0, 0),
            Size             = UDim2.new(1, -10, 1, 0),
            ZIndex           = 62,
        }, optBtn)

        optBtn.MouseEnter:Connect(function()
            tw(optBtn, { BackgroundTransparency = 0 })
            accentBar.Visible = true
        end)
        optBtn.MouseLeave:Connect(function()
            tw(optBtn, { BackgroundTransparency = 1 })
            accentBar.Visible = false
        end)
        optBtn.MouseButton1Click:Connect(function()
            value = opt
            valLabel.Text = opt
            isOpen = false
            dropList.Visible = false
            arrow.Text = "▾"
            tw(trigStroke, { Color = Color3.fromRGB(58, 58, 58) })
            if onChange then onChange(opt) end
        end)
    end

    trigger.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropList.Visible = isOpen
        arrow.Text = isOpen and "▴" or "▾"
        tw(trigStroke, { Color = isOpen and C.Accent or Color3.fromRGB(58, 58, 58) })
    end)

    return container
end

-- ── Primitive: KeyBind pill ───────────────────────────────────────────────────

local function mkKeyBind(parent, label)
    local btn = make("TextButton", {
        Text             = label,
        Font             = Enum.Font.GothamBold,
        TextSize         = 9,
        TextColor3       = Color3.fromRGB(192, 192, 192),
        Size             = UDim2.new(0, 24, 0, 14),
        BackgroundColor3 = Color3.fromRGB(44, 44, 44),
        BorderSizePixel  = 0,
    }, parent)
    corner(2, btn)
    stroke(1, Color3.fromRGB(74, 74, 74), btn)
    btn.MouseEnter:Connect(function() tw(btn, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) }) end)
    btn.MouseLeave:Connect(function() tw(btn, { BackgroundColor3 = Color3.fromRGB(44, 44, 44) }) end)
    return btn
end

-- ── Primitive: Color swatch ───────────────────────────────────────────────────

local function mkSwatch(parent, r, g, b)
    local s = make("Frame", {
        Size             = UDim2.new(0, 20, 0, 13),
        BackgroundColor3 = Color3.fromRGB(r, g, b),
        BorderSizePixel  = 0,
    }, parent)
    corner(2, s)
    return s
end

-- ── Primitive: Row (checkbox + keybind + swatch) ──────────────────────────────

local function mkEnabledRow(parent, label, initial, keyLabel, sr, sg, sb, onChange)
    local row = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
    }, parent)
    -- checkbox fills left side
    local cbWrap = make("Frame", {
        Size             = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
    }, row)
    mkCheckbox(cbWrap, label, initial, onChange)

    -- right side: keybind + swatch
    local right = make("Frame", {
        Size             = UDim2.new(0, 56, 1, 0),
        Position         = UDim2.new(1, -56, 0, 0),
        BackgroundTransparency = 1,
    }, row)
    listLayout(right, Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
    mkKeyBind(right, keyLabel)
    mkSwatch(right, sr, sg, sb)
    return row
end

-- ── Primitive: Action button ──────────────────────────────────────────────────

local function mkButton(parent, label, isDestructive)
    local bg    = Color3.fromRGB(37, 37, 37)
    local bgHov = Color3.fromRGB(48, 48, 48)
    local btn   = make("TextButton", {
        Text             = label,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextColor3       = isDestructive and Color3.fromRGB(208, 96, 80) or Color3.fromRGB(184, 184, 184),
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = bg,
        BorderSizePixel  = 0,
    }, parent)
    corner(3, btn)
    stroke(1, isDestructive and Color3.fromRGB(90, 32, 32) or Color3.fromRGB(58, 58, 58), btn)
    padding(8, 0, 0, 0, btn)
    btn.MouseEnter:Connect(function() tw(btn, { BackgroundColor3 = bgHov }) end)
    btn.MouseLeave:Connect(function() tw(btn, { BackgroundColor3 = bg }) end)
    return btn
end

-- ── Tab button ────────────────────────────────────────────────────────────────

local function mkTab(strip, label, order, small)
    local fontSize = small and 10 or 11
    local padH     = small and 9 or 12
    local height   = small and 20 or 24

    local btn = make("TextButton", {
        Name             = "Tab_" .. label,
        Text             = label,
        Font             = Enum.Font.Gotham,
        TextSize         = fontSize,
        TextColor3       = C.TextMuted,
        AutomaticSize    = Enum.AutomaticSize.X,
        Size             = UDim2.new(0, 0, 0, height),
        BackgroundColor3 = C.TabBg,
        BorderSizePixel  = 0,
        LayoutOrder      = order,
        ZIndex           = 5,
    }, strip)
    padding(padH, padH, 0, 0, btn)

    local topAccent = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel  = 0,
        ZIndex           = 6,
    }, btn)

    -- covers the bottom border line when active
    local cover = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.Bg,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 7,
    }, btn)

    local function setActive(active)
        tw(btn, {
            BackgroundColor3 = active and C.ActiveTab or C.TabBg,
            TextColor3       = active and Color3.fromRGB(224, 224, 224) or C.TextMuted,
        })
        tw(topAccent, { BackgroundColor3 = active and C.Accent or Color3.fromRGB(40, 40, 40) })
        btn.Font  = active and Enum.Font.GothamBold or Enum.Font.Gotham
        cover.Visible = active
    end

    return btn, setActive
end

-- ── Window shell ──────────────────────────────────────────────────────────────

local WIN_W, WIN_H = 420, 340

local Window = make("Frame", {
    Name             = "Window",
    Size             = UDim2.new(0, WIN_W, 0, WIN_H),
    Position         = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
    BackgroundColor3 = C.Bg,
    BorderSizePixel  = 0,
    ClipsDescendants = true,
}, ScreenGui)
corner(4, Window)
stroke(1, C.BorderDark, Window)

-- Title bar
local TitleBar = make("Frame", {
    Size             = UDim2.new(1, 0, 0, 26),
    BackgroundColor3 = Color3.fromRGB(38, 38, 38),
    BorderSizePixel  = 0,
    ZIndex           = 10,
}, Window)

make("TextLabel", {
    Text             = "juanita",
    Font             = Enum.Font.GothamMedium,
    TextSize         = 11,
    TextColor3       = C.Text,
    TextXAlignment   = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position         = UDim2.new(0, 10, 0, 0),
    Size             = UDim2.new(0, 46, 1, 0),
    ZIndex           = 11,
}, TitleBar)

make("TextLabel", {
    Text             = "****",
    Font             = Enum.Font.GothamBold,
    TextSize         = 11,
    TextColor3       = C.AccentBright,
    TextXAlignment   = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position         = UDim2.new(0, 50, 0, 0),
    Size             = UDim2.new(0, 30, 1, 0),
    ZIndex           = 11,
}, TitleBar)

make("TextLabel", {
    Text             = ".club",
    Font             = Enum.Font.GothamMedium,
    TextSize         = 11,
    TextColor3       = C.Text,
    TextXAlignment   = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position         = UDim2.new(0, 76, 0, 0),
    Size             = UDim2.new(0, 36, 1, 0),
    ZIndex           = 11,
}, TitleBar)

-- Window buttons
local ctrlFrame = make("Frame", {
    Size             = UDim2.new(0, 44, 0, 14),
    Position         = UDim2.new(1, -50, 0.5, -7),
    BackgroundTransparency = 1,
    ZIndex           = 11,
}, TitleBar)

local minBtn = make("TextButton", {
    Text             = "─",
    Font             = Enum.Font.GothamBold,
    TextSize         = 8,
    TextColor3       = Color3.fromRGB(160, 160, 160),
    Size             = UDim2.new(0, 18, 0, 14),
    BackgroundColor3 = Color3.fromRGB(46, 46, 46),
    BorderSizePixel  = 0,
    ZIndex           = 12,
}, ctrlFrame)
corner(2, minBtn)

local closeBtn = make("TextButton", {
    Text             = "✕",
    Font             = Enum.Font.GothamBold,
    TextSize         = 9,
    TextColor3       = Color3.fromRGB(238, 238, 238),
    Size             = UDim2.new(0, 18, 0, 14),
    Position         = UDim2.new(0, 22, 0, 0),
    BackgroundColor3 = C.Red,
    BorderSizePixel  = 0,
    ZIndex           = 12,
}, ctrlFrame)
corner(2, closeBtn)

minBtn.MouseEnter:Connect(function()  tw(minBtn,   { BackgroundColor3 = Color3.fromRGB(60, 60, 60) }) end)
minBtn.MouseLeave:Connect(function()  tw(minBtn,   { BackgroundColor3 = Color3.fromRGB(46, 46, 46) }) end)
closeBtn.MouseEnter:Connect(function() tw(closeBtn, { BackgroundColor3 = Color3.fromRGB(176, 42, 42) }) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, { BackgroundColor3 = C.Red }) end)
closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tw(Window, { Size = UDim2.new(0, WIN_W, 0, minimized and 26 or WIN_H) }, MED)
end)

-- ── Dragging ──────────────────────────────────────────────────────────────────

local dragging, dragStart, startPos = false, nil, nil

TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = inp.Position
        startPos  = Window.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        Window.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ── Body: main tab strip ──────────────────────────────────────────────────────

local TITLE_H  = 26
local FOOTER_H = 18
local TAB_H    = 28
local BODY_H   = WIN_H - TITLE_H

local Body = make("Frame", {
    Size             = UDim2.new(1, 0, 0, BODY_H),
    Position         = UDim2.new(0, 0, 0, TITLE_H),
    BackgroundColor3 = C.Bg,
    BorderSizePixel  = 0,
}, Window)

local MainTabStrip = make("Frame", {
    Size             = UDim2.new(1, 0, 0, TAB_H),
    BackgroundColor3 = C.TabBg,
    BorderSizePixel  = 0,
    ZIndex           = 5,
}, Body)
listLayout(MainTabStrip, Enum.FillDirection.Horizontal, 2)
padding(6, 0, 0, 0, MainTabStrip)
make("Frame", {
    Size             = UDim2.new(1, 0, 0, 1),
    Position         = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = C.Border,
    BorderSizePixel  = 0,
    ZIndex           = 6,
}, MainTabStrip)

-- Content area (below tabs, above footer)
local CONTENT_H = BODY_H - TAB_H - FOOTER_H

local ContentArea = make("Frame", {
    Size             = UDim2.new(1, 0, 0, CONTENT_H),
    Position         = UDim2.new(0, 0, 0, TAB_H),
    BackgroundColor3 = C.Bg,
    BorderSizePixel  = 0,
    ClipsDescendants = true,
}, Body)

local LEFT_W  = WIN_W - 190
local RIGHT_W = 190

-- Left scrolling panel
local LeftScroll = make("ScrollingFrame", {
    Size                  = UDim2.new(0, LEFT_W, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel       = 0,
    ScrollBarThickness    = 3,
    ScrollBarImageColor3  = Color3.fromRGB(60, 60, 60),
    CanvasSize            = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize   = Enum.AutomaticSize.Y,
    ClipsDescendants      = true,
}, ContentArea)

-- Divider between panels
make("Frame", {
    Size             = UDim2.new(0, 1, 1, 0),
    Position         = UDim2.new(0, LEFT_W, 0, 0),
    BackgroundColor3 = Color3.fromRGB(32, 32, 32),
    BorderSizePixel  = 0,
}, ContentArea)

-- Right panel
local RightPanel = make("Frame", {
    Size             = UDim2.new(0, RIGHT_W, 1, 0),
    Position         = UDim2.new(0, LEFT_W + 1, 0, 0),
    BackgroundColor3 = C.Bg,
    BorderSizePixel  = 0,
}, ContentArea)

-- ── Footer ────────────────────────────────────────────────────────────────────

local Footer = make("Frame", {
    Size             = UDim2.new(1, 0, 0, FOOTER_H),
    Position         = UDim2.new(0, 0, 0, BODY_H - FOOTER_H),
    BackgroundColor3 = Color3.fromRGB(14, 14, 14),
    BorderSizePixel  = 0,
}, Body)
make("Frame", {
    Size             = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel  = 0,
}, Footer)
make("TextLabel", {
    Text             = "build 2.4.1",
    Font             = Enum.Font.Gotham,
    TextSize         = 9,
    TextColor3       = Color3.fromRGB(62, 62, 62),
    TextXAlignment   = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position         = UDim2.new(0, 10, 0, 0),
    Size             = UDim2.new(0.5, 0, 1, 0),
}, Footer)

local dot = make("Frame", {
    Size             = UDim2.new(0, 6, 0, 6),
    Position         = UDim2.new(1, -76, 0.5, -3),
    BackgroundColor3 = C.Green,
    BorderSizePixel  = 0,
}, Footer)
corner(3, dot)

make("TextLabel", {
    Text             = "CONNECTED",
    Font             = Enum.Font.GothamBold,
    TextSize         = 9,
    TextColor3       = Color3.fromRGB(62, 62, 62),
    TextXAlignment   = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1,
    Position         = UDim2.new(1, -70, 0, 0),
    Size             = UDim2.new(0, 64, 1, 0),
}, Footer)

-- ── Right panel: sub-tabs ─────────────────────────────────────────────────────

local RIGHT_TAB_H = 24

local RightTabStrip = make("Frame", {
    Size             = UDim2.new(1, 0, 0, RIGHT_TAB_H),
    BackgroundColor3 = C.TabBg,
    BorderSizePixel  = 0,
    ZIndex           = 5,
}, RightPanel)
listLayout(RightTabStrip, Enum.FillDirection.Horizontal, 1)

make("Frame", {
    Size             = UDim2.new(1, 0, 0, 1),
    Position         = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = C.Border,
    BorderSizePixel  = 0,
    ZIndex           = 6,
}, RightTabStrip)

local RightContent = make("ScrollingFrame", {
    Size                  = UDim2.new(1, 0, 1, -RIGHT_TAB_H),
    Position              = UDim2.new(0, 0, 0, RIGHT_TAB_H),
    BackgroundTransparency = 1,
    BorderSizePixel       = 0,
    ScrollBarThickness    = 3,
    ScrollBarImageColor3  = Color3.fromRGB(60, 60, 60),
    CanvasSize            = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize   = Enum.AutomaticSize.Y,
    ClipsDescendants      = true,
}, RightPanel)

-- ── Panel rebuild functions (forward declared) ────────────────────────────────

local rebuildLeft, rebuildRight

-- ── Build main tabs ───────────────────────────────────────────────────────────

local MAIN_TABS  = { "Aimbot", "ESP", "Misc", "Visuals", "World", "Config" }
local RIGHT_TABS = { "Aimbot", "Visuals", "Config", "Misc" }

local mainSetters  = {}
local rightSetters = {}

for i, name in ipairs(MAIN_TABS) do
    local btn, setActive = mkTab(MainTabStrip, name, i, false)
    mainSetters[name] = setActive
    btn.MouseButton1Click:Connect(function()
        State.mainTab = name
        for _, n in ipairs(MAIN_TABS) do mainSetters[n](n == name) end
        rebuildLeft()
    end)
end
mainSetters["Aimbot"](true)

for i, name in ipairs(RIGHT_TABS) do
    local btn, setActive = mkTab(RightTabStrip, name, i, true)
    rightSetters[name] = setActive
    btn.MouseButton1Click:Connect(function()
        State.rightTab = name
        for _, n in ipairs(RIGHT_TABS) do rightSetters[n](n == name) end
        rebuildRight()
    end)
end
rightSetters["Aimbot"](true)

-- ── Left panel content ────────────────────────────────────────────────────────

local function clearPanel(panel)
    for _, child in ipairs(panel:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
end

rebuildLeft = function()
    clearPanel(LeftScroll)
    padding(10, 10, 10, 10, LeftScroll)
    listLayout(LeftScroll, Enum.FillDirection.Vertical, 5)

    local tab = State.mainTab
    mkHeading(LeftScroll, tab)

    if tab == "Aimbot" then
        mkEnabledRow(LeftScroll, "Enabled", State.aimbot.enabled, "m1", 46, 204, 85,
            function(v) State.aimbot.enabled = v end)

        mkCheckbox(LeftScroll, "Silent Aim", State.aimbot.silentAim,
            function(v) State.aimbot.silentAim = v end)

        mkSlider(LeftScroll, "FOV", State.aimbot.fov,
            function(v) State.aimbot.fov = v end)

        mkDivider(LeftScroll)
        mkSectionLabel(LeftScroll, "Hitbox")
        mkDropdown(LeftScroll, State.aimbot.hitbox, { "Head","Neck","Body","Legs","Arms" },
            function(v) State.aimbot.hitbox = v end)
        mkDivider(LeftScroll)

        local items = {
            {"visible","Visible"},{"dormant","Dormant"},{"smokeCheck","Smoke Check"},
            {"flashCheck","Flash Check"},{"autoWall","Auto Wall"},{"autoStop","Auto Stop"},
            {"autoScope","Auto Scope"},{"silentWalk","Silent Walk"},{"noRecoil","No Recoil"},
        }
        for _, item in ipairs(items) do
            local key, lbl = item[1], item[2]
            mkCheckbox(LeftScroll, lbl, State.aimbot[key], function(v) State.aimbot[key] = v end)
        end
    else
        local opts = {
            ESP     = {"Enable ESP","Glow ESP","Box ESP","Name ESP","Health ESP","Distance ESP","Weapon ESP","Snapline"},
            Misc    = {"Bunny Hop","Auto Strafe","Radar Hack","Skin Changer","Rank Reveal","Vote Reveal","Spectator List","Clock Tag"},
            Visuals = {"Fullbright","No Flash","No Smoke","Night Mode","Aspect Ratio","Zoom","FOV Override","Remove Recoil Anim"},
            World   = {"Bullet Tracers","Bullet Impacts","Hit Marker","Spread Crosshair","Attack Indicator","Event Logger"},
            Config  = {"Load Config","Save Config","Reset Config","Config Name"},
        }
        if not State.generic[tab] then State.generic[tab] = {} end
        for _, opt in ipairs(opts[tab] or {}) do
            mkCheckbox(LeftScroll, opt, State.generic[tab][opt] or false, function(v)
                State.generic[tab][opt] = v
            end)
        end
    end
end

-- ── Right panel content ───────────────────────────────────────────────────────

rebuildRight = function()
    clearPanel(RightContent)
    padding(10, 10, 10, 10, RightContent)
    listLayout(RightContent, Enum.FillDirection.Vertical, 5)

    local tab = State.rightTab

    if tab == "Aimbot" then
        mkEnabledRow(RightContent, "Enabled", State.rAimbot.enabled, "m1", 232, 80, 32,
            function(v) State.rAimbot.enabled = v end)
        mkCheckbox(RightContent, "Silent Aim", State.rAimbot.silentAim,
            function(v) State.rAimbot.silentAim = v end)
        mkCheckbox(RightContent, "Auto Shoot", State.rAimbot.autoShoot,
            function(v) State.rAimbot.autoShoot = v end)
        mkSlider(RightContent, "FOV", State.rAimbot.fov,
            function(v) State.rAimbot.fov = v end)
        mkSlider(RightContent, "Smooth", State.rAimbot.smooth,
            function(v) State.rAimbot.smooth = v end)
        mkSectionLabel(RightContent, "Hitbox")
        mkDropdown(RightContent, State.rAimbot.hitbox, { "Head","Neck","Body","Legs" },
            function(v) State.rAimbot.hitbox = v end)
        mkSectionLabel(RightContent, "Trigger Key")
        mkDropdown(RightContent, State.rAimbot.trigKey, { "Always","Hold","Toggle" },
            function(v) State.rAimbot.trigKey = v end)

    elseif tab == "Visuals" then
        mkEnabledRow(RightContent, "Player ESP", State.visuals.playerESP, "--", 0, 170, 221,
            function(v) State.visuals.playerESP = v end)
        mkCheckbox(RightContent, "Skeleton", State.visuals.skeleton,
            function(v) State.visuals.skeleton = v end)
        mkCheckbox(RightContent, "Show Health", State.visuals.showHealth,
            function(v) State.visuals.showHealth = v end)
        mkCheckbox(RightContent, "Show Name", State.visuals.showName,
            function(v) State.visuals.showName = v end)
        mkCheckbox(RightContent, "Show Distance", State.visuals.showDistance,
            function(v) State.visuals.showDistance = v end)
        mkCheckbox(RightContent, "Show Weapon", State.visuals.showWeapon,
            function(v) State.visuals.showWeapon = v end)
        mkSectionLabel(RightContent, "ESP Style")
        mkDropdown(RightContent, State.visuals.espStyle, { "Box","Corner Box","3D Box","None" },
            function(v) State.visuals.espStyle = v end)
        mkSectionLabel(RightContent, "Chams")
        mkDropdown(RightContent, State.visuals.chams, { "None","Flat","Shaded","Wireframe" },
            function(v) State.visuals.chams = v end)

    elseif tab == "Config" then
        mkSectionLabel(RightContent, "Config Name")

        local inputFrame = make("Frame", {
            Size             = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = C.InputBg,
            BorderSizePixel  = 0,
        }, RightContent)
        corner(3, inputFrame)
        stroke(1, Color3.fromRGB(58, 58, 58), inputFrame)

        local inputBox = make("TextBox", {
            Text              = State.config.configName,
            Font              = Enum.Font.Gotham,
            TextSize          = 11,
            TextColor3        = C.Text,
            PlaceholderText   = "config name...",
            PlaceholderColor3 = C.TextMuted,
            TextXAlignment    = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ClearTextOnFocus  = false,
            Size              = UDim2.new(1, -16, 1, 0),
            Position          = UDim2.new(0, 8, 0, 0),
        }, inputFrame)
        inputBox.FocusLost:Connect(function()
            State.config.configName = inputBox.Text
        end)

        mkCheckbox(RightContent, "Auto Save", State.config.autoSave,
            function(v) State.config.autoSave = v end)
        mkButton(RightContent, "Save Config",  false)
        mkButton(RightContent, "Load Config",  false)
        mkButton(RightContent, "Reset Config", true)

    elseif tab == "Misc" then
        mkCheckbox(RightContent, "Bunny Hop",   State.misc.bunnyHop,   function(v) State.misc.bunnyHop   = v end)
        mkCheckbox(RightContent, "Auto Strafe", State.misc.autoStrafe, function(v) State.misc.autoStrafe = v end)
        mkCheckbox(RightContent, "Radar Hack",  State.misc.radar,      function(v) State.misc.radar      = v end)
        mkCheckbox(RightContent, "No Flash",    State.misc.noFlash,    function(v) State.misc.noFlash    = v end)
    end
end

-- ── Initial render ────────────────────────────────────────────────────────────

rebuildLeft()
rebuildRight()
