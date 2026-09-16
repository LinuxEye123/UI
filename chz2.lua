
-- JuanitaUI.luau
-- Roblox/Luau port of the supplied App.tsx UI.
-- UI-only: this module does not implement any gameplay/aimbot functionality.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}
Library.__index = Library

local ACCENT = Color3.fromRGB(212, 90, 16)
local ACCENT_BRIGHT = Color3.fromRGB(232, 112, 26)
local ACCENT_DIM = Color3.fromRGB(154, 60, 8)

local COLORS = {
	Window = Color3.fromRGB(22, 22, 22),
	Panel = Color3.fromRGB(22, 22, 22),
	Dark = Color3.fromRGB(14, 14, 14),
	Darker = Color3.fromRGB(8, 8, 8),
	Border = Color3.fromRGB(46, 46, 46),
	Text = Color3.fromRGB(200, 200, 200),
	TextBright = Color3.fromRGB(224, 224, 224),
	TextMuted = Color3.fromRGB(160, 160, 160),
	TextDim = Color3.fromRGB(112, 112, 112),
	Red = Color3.fromRGB(146, 32, 32),
	RedDark = Color3.fromRGB(96, 20, 20),
	Green = Color3.fromRGB(46, 204, 85),
}

local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold

local function New(className: string, properties: {[string]: any}?): Instance
	local object = Instance.new(className)

	if properties then
		for property, value in pairs(properties) do
			object[property] = value
		end
	end

	return object
end

local function Corner(parent: Instance, radius: number)
	return New("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius),
	})
end

local function Stroke(parent: Instance, color: Color3, thickness: number, transparency: number?)
	return New("UIStroke", {
		Parent = parent,
		Color = color,
		Thickness = thickness,
		Transparency = transparency or 0,
	})
end

local function Gradient(parent: Instance, colorA: Color3, colorB: Color3, rotation: number?)
	return New("UIGradient", {
		Parent = parent,
		Color = ColorSequence.new(colorA, colorB),
		Rotation = rotation or 90,
	})
end

local function Padding(parent: Instance, left: number, right: number, top: number, bottom: number)
	return New("UIPadding", {
		Parent = parent,
		PaddingLeft = UDim.new(0, left),
		PaddingRight = UDim.new(0, right),
		PaddingTop = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bottom),
	})
end

local function Text(parent: Instance, value: string, properties: {[string]: any}?): TextLabel
	local defaults = {
		Parent = parent,
		BackgroundTransparency = 1,
		Text = value,
		TextColor3 = COLORS.Text,
		Font = FONT,
		TextSize = 11,
		BorderSizePixel = 0,
	}

	if properties then
		for property, propertyValue in pairs(properties) do
			defaults[property] = propertyValue
		end
	end

	return New("TextLabel", defaults) :: TextLabel
end

local function Button(parent: Instance, properties: {[string]: any}?): TextButton
	local defaults = {
		Parent = parent,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		Font = FONT,
		TextSize = 11,
	}

	if properties then
		for property, propertyValue in pairs(properties) do
			defaults[property] = propertyValue
		end
	end

	return New("TextButton", defaults) :: TextButton
end

local function SetGradient(button: GuiObject, colorA: Color3, colorB: Color3, rotation: number?)
	local gradient = button:FindFirstChildOfClass("UIGradient")
	if not gradient then
		gradient = New("UIGradient", {Parent = button}) :: UIGradient
	end

	gradient.Color = ColorSequence.new(colorA, colorB)
	gradient.Rotation = rotation or 90
end

local function Animate(instance: Instance, properties: {[string]: any}, duration: number?)
	TweenService:Create(
		instance,
		TweenInfo.new(duration or 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		properties
	):Play()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Checkbox
-- ─────────────────────────────────────────────────────────────────────────────

function Library:_Checkbox(parent: Instance, label: string, initial: boolean, callback)
	local row = Button(parent, {
		Size = UDim2.new(1, 0, 0, 18),
		Text = "",
	})

	local box = New("Frame", {
		Parent = row,
		Size = UDim2.fromOffset(13, 13),
		Position = UDim2.new(0, 0, 0.5, -6),
		BorderSizePixel = 0,
	})
	Corner(box, 2)

	local check = Text(box, "✓", {
		Size = UDim2.fromScale(1, 1),
		TextColor3 = Color3.new(1, 1, 1),
		Font = FONT_BOLD,
		TextSize = 10,
		Visible = initial,
	})

	local textLabel = Text(row, label, {
		Position = UDim2.fromOffset(21, 0),
		Size = UDim2.new(1, -21, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = initial and Color3.fromRGB(216, 216, 216) or COLORS.TextMuted,
	})

	local state = initial

	local function render(hovered: boolean?)
		box.BackgroundColor3 = state and ACCENT_DIM or (hovered and Color3.fromRGB(32, 32, 32) or Color3.fromRGB(28, 28, 28))
		Stroke(box, state and ACCENT or (hovered and Color3.fromRGB(74, 74, 74) or Color3.fromRGB(54, 54, 54)), 1)
		check.Visible = state
		textLabel.TextColor3 = state and Color3.fromRGB(216, 216, 216) or (hovered and Color3.fromRGB(184, 184, 184) or COLORS.TextMuted)
	end

	render(false)

	row.MouseEnter:Connect(function()
		render(true)
	end)

	row.MouseLeave:Connect(function()
		render(false)
	end)

	row.Activated:Connect(function()
		state = not state
		render(false)
		if callback then
			callback(state)
		end
	end)

	return {
		Object = row,
		Get = function()
			return state
		end,
		Set = function(_, value: boolean)
			state = value
			render(false)
			if callback then
				callback(state)
			end
		end,
	}
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Slider
-- ─────────────────────────────────────────────────────────────────────────────

function Library:_Slider(parent: Instance, label: string, initial: number, callback, suffix: string?)
	local container = New("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
	})

	local labelText = Text(container, label, {
		Size = UDim2.new(0.7, 0, 0, 13),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = COLORS.TextMuted,
	})

	local valueText = Text(container, tostring(initial) .. (suffix or "%"), {
		Position = UDim2.new(0.7, 0, 0, 0),
		Size = UDim2.new(0.3, 0, 0, 13),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = ACCENT_BRIGHT,
		Font = FONT_BOLD,
	})

	local track = New("Frame", {
		Parent = container,
		Position = UDim2.new(0, 0, 0, 17),
		Size = UDim2.new(1, 0, 0, 5),
		BackgroundColor3 = Color3.fromRGB(16, 16, 16),
		BorderSizePixel = 0,
	})
	Corner(track, 3)
	Stroke(track, Color3.fromRGB(46, 46, 46), 1)

	local fill = New("Frame", {
		Parent = track,
		Size = UDim2.new(math.clamp(initial, 0, 100) / 100, 0, 1, 0),
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
	})
	Corner(fill, 3)
	Gradient(fill, ACCENT_DIM, ACCENT_BRIGHT, 0)

	local knob = New("Frame", {
		Parent = track,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(math.clamp(initial, 0, 100) / 100, 0, 0.5, 0),
		Size = UDim2.fromOffset(9, 9),
		BackgroundColor3 = Color3.fromRGB(190, 190, 190),
		BorderSizePixel = 0,
		ZIndex = 3,
	})
	Corner(knob, 5)
	Stroke(knob, ACCENT, 1)

	local hit = Button(track, {
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4,
	})

	local value = math.clamp(initial, 0, 100)

	local function updateFromX(x: number)
		local relative = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		value = math.round(relative * 100)
		fill.Size = UDim2.new(relative, 0, 1, 0)
		knob.Position = UDim2.new(relative, 0, 0.5, 0)
		valueText.Text = tostring(value) .. (suffix or "%")

		if callback then
			callback(value)
		end
	end

	hit.Activated:Connect(function()
		updateFromX(UserInputService:GetMouseLocation().X)
	end)

	local dragging = false

	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return {
		Object = container,
		Get = function()
			return value
		end,
		Set = function(_, newValue: number)
			value = math.clamp(newValue, 0, 100)
			local relative = value / 100
			fill.Size = UDim2.new(relative, 0, 1, 0)
			knob.Position = UDim2.new(relative, 0, 0.5, 0)
			valueText.Text = tostring(value) .. (suffix or "%")
			if callback then
				callback(value)
			end
		end,
	}
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Dropdown
-- ─────────────────────────────────────────────────────────────────────────────

function Library:_Dropdown(parent: Instance, options: {string}, initial: string, callback)
	local container = New("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 23),
		ZIndex = 20,
	})

	local selected = initial or options[1]
	local opened = false

	local main = Button(container, {
		Size = UDim2.new(1, 0, 0, 23),
		BackgroundColor3 = Color3.fromRGB(31, 31, 31),
		Text = "",
		ZIndex = 21,
	})
	Corner(main, 3)
	Stroke(main, Color3.fromRGB(58, 58, 58), 1)
	Gradient(main, Color3.fromRGB(35, 35, 35), Color3.fromRGB(26, 26, 26), 90)

	local valueText = Text(main, selected, {
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -28, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 22,
	})

	local arrow = Text(main, "⌄", {
		Position = UDim2.new(1, -19, 0, 0),
		Size = UDim2.fromOffset(14, 23),
		TextColor3 = Color3.fromRGB(136, 136, 136),
		TextSize = 12,
		ZIndex = 22,
	})

	local menu = New("Frame", {
		Parent = container,
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 0, #options * 20 + 2),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 100,
	})
	Corner(menu, 3)
	Stroke(menu, ACCENT, 1)

	local layout = New("UIListLayout", {
		Parent = menu,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local function choose(option: string)
		selected = option
		valueText.Text = option
		opened = false
		menu.Visible = false
		arrow.Text = "⌄"

		if callback then
			callback(option)
		end
	end

	for index, option in ipairs(options) do
		local optionButton = Button(menu, {
			Size = UDim2.new(1, 0, 0, 20),
			LayoutOrder = index,
			Text = option,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = option == selected and ACCENT_BRIGHT or Color3.fromRGB(184, 184, 184),
			Font = option == selected and FONT_BOLD or FONT,
			TextSize = 11,
			ZIndex = 101,
		})

		Padding(optionButton, 8, 4, 0, 0)

		optionButton.MouseEnter:Connect(function()
			optionButton.BackgroundColor3 = Color3.fromRGB(43, 31, 25)
			optionButton.TextColor3 = Color3.fromRGB(221, 221, 221)
		end)

		optionButton.MouseLeave:Connect(function()
			optionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			optionButton.TextColor3 = option == selected and ACCENT_BRIGHT or Color3.fromRGB(184, 184, 184)
		end)

		optionButton.Activated:Connect(function()
			choose(option)
		end)
	end

	main.Activated:Connect(function()
		opened = not opened
		menu.Visible = opened
		arrow.Text = opened and "⌃" or "⌄"
		Stroke(main, opened and ACCENT or Color3.fromRGB(58, 58, 58), 1)
	end)

	return {
		Object = container,
		Get = function()
			return selected
		end,
		Set = function(_, option: string)
			if table.find(options, option) then
				choose(option)
			end
		end,
	}
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Key bind / color swatch / labels
-- ─────────────────────────────────────────────────────────────────────────────

function Library:_KeyBind(parent: Instance, value: string)
	local button = Button(parent, {
		Size = UDim2.fromOffset(28, 17),
		Text = value,
		TextColor3 = Color3.fromRGB(192, 192, 192),
		Font = FONT_BOLD,
		TextSize = 10,
	})
	Corner(button, 2)
	Stroke(button, Color3.fromRGB(74, 74, 74), 1)
	Gradient(button, Color3.fromRGB(44, 44, 44), Color3.fromRGB(32, 32, 32), 90)

	button.MouseButton1Down:Connect(function()
		button.TextColor3 = Color3.new(1, 1, 1)
		Stroke(button, ACCENT, 1)
		SetGradient(button, Color3.fromRGB(26, 26, 26), Color3.fromRGB(36, 36, 36))
	end)

	button.MouseButton1Up:Connect(function()
		button.TextColor3 = Color3.fromRGB(192, 192, 192)
		Stroke(button, Color3.fromRGB(74, 74, 74), 1)
		SetGradient(button, Color3.fromRGB(44, 44, 44), Color3.fromRGB(32, 32, 32))
	end)

	return button
end

function Library:_ColorSwatch(parent: Instance, color: Color3, borderColor: Color3)
	local swatch = New("Frame", {
		Parent = parent,
		Size = UDim2.fromOffset(20, 13),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	})
	Corner(swatch, 2)
	Stroke(swatch, borderColor, 1)
	return swatch
end

function Library:_Divider(parent: Instance)
	local divider = New("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(48, 48, 48),
		BorderSizePixel = 0,
	})
	return divider
end

function Library:_SectionLabel(parent: Instance, value: string)
	return Text(parent, string.upper(value), {
		Size = UDim2.new(1, 0, 0, 14),
		TextColor3 = Color3.fromRGB(120, 120, 120),
		Font = FONT,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

function Library:_PanelHeading(parent: Instance, value: string)
	local row = New("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
	})

	local accent = New("Frame", {
		Parent = row,
		Position = UDim2.fromOffset(0, 2),
		Size = UDim2.fromOffset(3, 11),
		BackgroundColor3 = ACCENT_BRIGHT,
		BorderSizePixel = 0,
	})
	Corner(accent, 1)
	Gradient(accent, ACCENT_BRIGHT, ACCENT_DIM, 90)

	Text(row, value, {
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -8, 1, 0),
		TextColor3 = COLORS.Text,
		Font = FONT_BOLD,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	return row
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Tabs
-- ─────────────────────────────────────────────────────────────────────────────

function Library:_Tab(parent: Instance, label: string, size: "normal" | "small", callback)
	local width = size == "small" and 46 or 60
	local height = size == "small" and 19 or 23

	local button = Button(parent, {
		Size = UDim2.fromOffset(width, height),
		Text = label,
		TextColor3 = COLORS.TextDim,
		Font = FONT,
		TextSize = size == "small" and 10 or 11,
	})

	Corner(button, 3)

	local active = false

	local function render(isActive: boolean, hovered: boolean?)
		active = isActive

		if isActive then
			button.TextColor3 = COLORS.TextBright
			SetGradient(button, Color3.fromRGB(42, 42, 42), Color3.fromRGB(28, 28, 28), 90)
			Stroke(button, ACCENT, 1)
		elseif hovered then
			button.TextColor3 = Color3.fromRGB(184, 184, 184)
			SetGradient(button, Color3.fromRGB(34, 34, 34), Color3.fromRGB(26, 26, 26), 90)
			Stroke(button, Color3.fromRGB(64, 64, 64), 1)
		else
			button.TextColor3 = COLORS.TextDim
			SetGradient(button, Color3.fromRGB(28, 28, 28), Color3.fromRGB(20, 20, 20), 90)
			Stroke(button, Color3.fromRGB(40, 40, 40), 1)
		end
	end

	render(false, false)

	button.MouseEnter:Connect(function()
		render(active, true)
	end)

	button.MouseLeave:Connect(function()
		render(active, false)
	end)

	button.Activated:Connect(function()
		if callback then
			callback()
		end
	end)

	return {
		Object = button,
		SetActive = function(_, value: boolean)
			render(value, false)
		end,
	}
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Content helpers
-- ─────────────────────────────────────────────────────────────────────────────

function Library:_Clear(parent: Instance)
	for _, child in ipairs(parent:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
end

function Library:_List(parent: Instance, gap: number)
	local list = New("UIListLayout", {
		Parent = parent,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, gap),
	})
	return list
end

function Library:_AimbotLeft(parent: Instance)
	self:_Clear(parent)
	self:_PanelHeading(parent, "Aimbot")

	local enabledRow = New("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
	})

	self:_Checkbox(enabledRow, "Enabled", true, function(value)
		self.State.AimbotEnabled = value
	end)

	local actions = New("Frame", {
		Parent = enabledRow,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 1),
		Size = UDim2.fromOffset(53, 18),
		BackgroundTransparency = 1,
	})
	local actionLayout = self:_List(actions, 4)
	actionLayout.FillDirection = Enum.FillDirection.Horizontal
	actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

	self:_KeyBind(actions, "m1")
	self:_ColorSwatch(actions, Color3.fromRGB(46, 204, 85), Color3.fromRGB(26, 122, 40))

	self:_Checkbox(parent, "Silent Aim", false, function(value)
		self.State.SilentAim = value
	end)

	self:_Slider(parent, "FOV", 50, function(value)
		self.State.FOV = value
	end)

	self:_Divider(parent)
	self:_SectionLabel(parent, "Hitbox")

	self:_Dropdown(parent, {"Head", "Neck", "Body", "Legs", "Arms"}, "Head", function(value)
		self.State.Hitbox = value
	end)

	self:_Divider(parent)

	local checks = {
		{"Enabled", "enabled"},
		{"Visible", "visible"},
		{"Dormant", "dormant"},
		{"Smoke Check", "smokeCheck"},
		{"Flash Check", "flashCheck"},
		{"Auto Wall", "autoWall"},
		{"Auto Stop", "autoStop"},
		{"Auto Scope", "autoScope"},
		{"Silent Walk", "silentWalk"},
		{"No Recoil", "noRecoil"},
	}

	for _, item in ipairs(checks) do
		local label, key = item[1], item[2]
		self:_Checkbox(parent, label, key == "enabled", function(value)
			self.State.Checks[key] = value
		end)
	end
end

function Library:_GenericLeft(parent: Instance, tab: string)
	self:_Clear(parent)
	self:_PanelHeading(parent, tab)

	local options = {
		ESP = {"Enable ESP", "Glow ESP", "Box ESP", "Name ESP", "Health ESP", "Distance ESP", "Weapon ESP", "Snapline"},
		Misc = {"Bunny Hop", "Auto Strafe", "Radar Hack", "Skin Changer", "Rank Reveal", "Vote Reveal", "Spectator List", "Clock Tag"},
		Visuals = {"Fullbright", "No Flash", "No Smoke", "Night Mode", "Aspect Ratio", "Zoom", "FOV Override", "Remove Recoil Anim"},
		World = {"Bullet Tracers", "Bullet Impacts", "Hit Marker", "Spread Crosshair", "Attack Indicator", "Event Logger"},
		Config = {"Load Config", "Save Config", "Reset Config", "Config Name"},
	}

	local state = self.State.Generic[tab] or {}
	self.State.Generic[tab] = state

	for _, option in ipairs(options[tab] or {}) do
		self:_Checkbox(parent, option, state[option] == true, function(value)
			state[option] = value
		end)
	end
end

function Library:_RightAimbot(parent: Instance)
	self:_Clear(parent)
	self:_PanelHeading(parent, "Aimbot")

	self:_Checkbox(parent, "Enabled", true, function(value)
		self.State.Right.AimbotEnabled = value
	end)

	self:_Checkbox(parent, "Silent Aim", false, function(value)
		self.State.Right.SilentAim = value
	end)

	self:_Checkbox(parent, "Auto Shoot", false, function(value)
		self.State.Right.AutoShoot = value
	end)

	self:_Slider(parent, "FOV", 8, function(value)
		self.State.Right.RightFOV = value
	end)

	self:_Slider(parent, "Smooth", 65, function(value)
		self.State.Right.Smooth = value
	end)

	self:_SectionLabel(parent, "Hitbox")
	self:_Dropdown(parent, {"Head", "Neck", "Body", "Legs"}, "Head", function(value)
		self.State.Right.Hitbox = value
	end)

	self:_SectionLabel(parent, "Trigger Key")
	self:_Dropdown(parent, {"Always", "Hold", "Toggle"}, "Toggle", function(value)
		self.State.Right.TriggerKey = value
	end)
end

function Library:_RightVisuals(parent: Instance)
	self:_Clear(parent)
	self:_PanelHeading(parent, "Visuals")

	local entries = {
		{"Player ESP", true, "PlayerESP"},
		{"Skeleton", true, "Skeleton"},
		{"Show Health", true, "ShowHealth"},
		{"Show Name", true, "ShowName"},
		{"Show Distance", false, "ShowDistance"},
		{"Show Weapon", false, "ShowWeapon"},
	}

	for _, entry in ipairs(entries) do
		local label, initial, key = entry[1], entry[2], entry[3]
		self:_Checkbox(parent, label, initial, function(value)
			self.State.Right[key] = value
		end)
	end

	self:_SectionLabel(parent, "ESP Style")
	self:_Dropdown(parent, {"Box", "Corner Box", "3D Box", "None"}, "Box", function(value)
		self.State.Right.ESPStyle = value
	end)

	self:_SectionLabel(parent, "Chams")
	self:_Dropdown(parent, {"None", "Flat", "Shaded", "Wireframe"}, "None", function(value)
		self.State.Right.Chams = value
	end)
end

function Library:_RightConfig(parent: Instance)
	self:_Clear(parent)
	self:_PanelHeading(parent, "Config")

	self:_SectionLabel(parent, "Config Name")

	local box = New("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		BorderSizePixel = 0,
	})
	Corner(box, 3)
	Stroke(box, Color3.fromRGB(58, 58, 58), 1)
	Gradient(box, Color3.fromRGB(20, 20, 20), Color3.fromRGB(28, 28, 28), 90)

	local input = New("TextBox", {
		Parent = box,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "default",
		PlaceholderText = "Config Name",
		TextColor3 = COLORS.Text,
		PlaceholderColor3 = COLORS.TextDim,
		Font = FONT,
		TextSize = 11,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	input.Focused:Connect(function()
		Stroke(box, ACCENT, 1)
	end)

	input.FocusLost:Connect(function()
		Stroke(box, Color3.fromRGB(58, 58, 58), 1)
		self.State.ConfigName = input.Text
	end)

	self:_Checkbox(parent, "Auto Save", false, function(value)
		self.State.AutoSave = value
	end)

	local actions = {"Save Config", "Load Config", "Reset Config"}

	for _, label in ipairs(actions) do
		local action = Button(parent, {
			Size = UDim2.new(1, 0, 0, 24),
			Text = label,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = label == "Reset Config" and Color3.fromRGB(208, 96, 80) or Color3.fromRGB(184, 184, 184),
			TextSize = 11,
		})
		Corner(action, 3)
		Stroke(action, label == "Reset Config" and Color3.fromRGB(90, 32, 32) or Color3.fromRGB(58, 58, 58), 1)
		Gradient(action, Color3.fromRGB(37, 37, 37), Color3.fromRGB(28, 28, 28), 90)
		Padding(action, 10, 5, 0, 0)

		action.MouseEnter:Connect(function()
			SetGradient(action, Color3.fromRGB(46, 46, 46), Color3.fromRGB(36, 36, 36), 90)
			Stroke(action, label == "Reset Config" and Color3.fromRGB(138, 42, 42) or ACCENT, 1)
		end)

		action.MouseLeave:Connect(function()
			SetGradient(action, Color3.fromRGB(37, 37, 37), Color3.fromRGB(28, 28, 28), 90)
			Stroke(action, label == "Reset Config" and Color3.fromRGB(90, 32, 32) or Color3.fromRGB(58, 58, 58), 1)
		end)

		action.Activated:Connect(function()
			if self.Callbacks[label] then
				self.Callbacks[label](self.State)
			end
		end)
	end
end

function Library:_RightMisc(parent: Instance)
	self:_Clear(parent)
	self:_PanelHeading(parent, "Misc")

	local entries = {
		{"Bunny Hop", "BunnyHop"},
		{"Auto Strafe", "AutoStrafe"},
		{"Radar Hack", "Radar"},
		{"No Flash", "NoFlash"},
	}

	for _, entry in ipairs(entries) do
		local label, key = entry[1], entry[2]
		self:_Checkbox(parent, label, false, function(value)
			self.State.Right[key] = value
		end)
	end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Window
-- ─────────────────────────────────────────────────────────────────────────────

function Library.new(options: {[string]: any}?)
	options = options or {}

	local self = setmetatable({}, Library)

	self.State = {
		MainTab = "Aimbot",
		RightTab = "Aimbot",
		AimbotEnabled = true,
		SilentAim = false,
		FOV = 50,
		Hitbox = "Head",
		Checks = {
			enabled = true,
			visible = false,
			dormant = false,
			smokeCheck = false,
			flashCheck = false,
			autoWall = false,
			autoStop = false,
			autoScope = false,
			silentWalk = false,
			noRecoil = false,
		},
		Right = {},
		Generic = {},
		ConfigName = "default",
		AutoSave = false,
	}

	self.Callbacks = options.Callbacks or {}
	self.Visible = true
	self.Destroyed = false

	local playerGui: Instance

	-- Prefer executor UI containers when available, otherwise PlayerGui.
	local gethuiFunction = (gethui :: any)
	if typeof(gethuiFunction) == "function" then
		local success, result = pcall(gethuiFunction)
		if success and typeof(result) == "Instance" then
			playerGui = result
		end
	end

	if not playerGui then
		playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	local old = playerGui:FindFirstChild(options.Name or "JuanitaUI")
	if old then
		old:Destroy()
	end

	local screenGui = New("ScreenGui", {
		Name = options.Name or "JuanitaUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = options.DisplayOrder or 100,
		Parent = playerGui,
	})

	self.ScreenGui = screenGui

	-- Background matching the TSX radial background.
	local background = New("Frame", {
		Parent = screenGui,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
		BorderSizePixel = 0,
	})

	local bgGradient = Gradient(background, Color3.fromRGB(26, 18, 24), Color3.fromRGB(8, 8, 8), 45)
	bgGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 0),
	})

	local window = New("Frame", {
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(options.Width or 420, options.Height or 360),
		BackgroundColor3 = COLORS.Window,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	Corner(window, 4)
	Stroke(window, Color3.fromRGB(46, 46, 46), 1)

	self.Window = window

	-- Title bar.
	local titleBar = New("Frame", {
		Parent = window,
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundColor3 = Color3.fromRGB(31, 31, 31),
		BorderSizePixel = 0,
	})
	Gradient(titleBar, Color3.fromRGB(42, 42, 42), Color3.fromRGB(26, 26, 26), 90)
	Stroke(titleBar, Color3.fromRGB(10, 10, 10), 1)

	local icon = Text(titleBar, "◆", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.fromOffset(12, 25),
		TextColor3 = ACCENT_BRIGHT,
		Font = FONT_BOLD,
		TextSize = 8,
	})

	local title = Text(titleBar, options.Title or "juanita****.club", {
		Position = UDim2.fromOffset(25, 0),
		Size = UDim2.new(1, -75, 1, 0),
		TextColor3 = COLORS.Text,
		Font = FONT,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local controls = New("Frame", {
		Parent = titleBar,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 5),
		Size = UDim2.fromOffset(39, 15),
		BackgroundTransparency = 1,
	})

	local controlLayout = self:_List(controls, 3)
	controlLayout.FillDirection = Enum.FillDirection.Horizontal
	controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

	local minimize = Button(controls, {
		Size = UDim2.fromOffset(18, 14),
		Text = "−",
		TextColor3 = Color3.fromRGB(144, 144, 144),
		TextSize = 9,
	})
	Corner(minimize, 2)
	Stroke(minimize, Color3.fromRGB(72, 72, 72), 1)
	Gradient(minimize, Color3.fromRGB(46, 46, 46), Color3.fromRGB(34, 34, 34), 90)

	local close = Button(controls, {
		Size = UDim2.fromOffset(18, 14),
		Text = "×",
		TextColor3 = Color3.fromRGB(238, 238, 238),
		TextSize = 9,
	})
	Corner(close, 2)
	Stroke(close, Color3.fromRGB(106, 16, 16), 1)
	Gradient(close, Color3.fromRGB(146, 32, 32), Color3.fromRGB(96, 20, 20), 90)

	close.Activated:Connect(function()
		self:Destroy()
	end)

	minimize.Activated:Connect(function()
		self:SetVisible(not self.Visible)
	end)

	-- Dragging.
	local dragging = false
	local dragInput: InputObject?
	local dragStart: Vector2
	local startPosition: UDim2

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragInput = input
			dragStart = input.Position
			startPosition = window.Position
		end
	end)

	titleBar.InputEnded:Connect(function(input)
		if input == dragInput then
			dragging = false
			dragInput = nil
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local delta = input.Position - dragStart
		window.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	-- Main tab strip.
	local mainTabBar = New("Frame", {
		Parent = window,
		Position = UDim2.fromOffset(0, 25),
		Size = UDim2.new(1, 0, 0, 29),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderSizePixel = 0,
	})
	Gradient(mainTabBar, Color3.fromRGB(22, 22, 22), Color3.fromRGB(18, 18, 18), 90)
	Stroke(mainTabBar, COLORS.Border, 1)
	Padding(mainTabBar, 6, 6, 5, 0)

	local mainTabLayout = self:_List(mainTabBar, 2)
	mainTabLayout.FillDirection = Enum.FillDirection.Horizontal
	mainTabLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	local body = New("Frame", {
		Parent = window,
		Position = UDim2.fromOffset(0, 54),
		Size = UDim2.new(1, 0, 1, -79),
		BackgroundColor3 = COLORS.Panel,
		BorderSizePixel = 0,
	})

	-- Left panel.
	local left = New("ScrollingFrame", {
		Parent = body,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -190, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(42, 42, 42),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})
	Padding(left, 12, 12, 10, 12)
	self.LeftContent = left

	local leftLayout = self:_List(left, 5)
	leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

	-- Right panel.
	local right = New("Frame", {
		Parent = body,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(190, body.AbsoluteSize.Y),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	Padding(right, 10, 10, 8, 12)
	self.RightPanel = right

	local rightTabBar = New("Frame", {
		Parent = right,
		Size = UDim2.new(1, 0, 0, 23),
		BackgroundTransparency = 1,
	})
	local rightTabLayout = self:_List(rightTabBar, 1)
	rightTabLayout.FillDirection = Enum.FillDirection.Horizontal
	rightTabLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	local rightContent = New("ScrollingFrame", {
		Parent = right,
		Position = UDim2.fromOffset(0, 31),
		Size = UDim2.new(1, 0, 1, -31),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(42, 42, 42),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})
	self.RightContent = rightContent

	local rightLayout = self:_List(rightContent, 6)
	rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

	-- Footer.
	local footer = New("Frame", {
		Parent = window,
		Position = UDim2.new(0, 0, 1, -25),
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundColor3 = Color3.fromRGB(14, 14, 14),
		BorderSizePixel = 0,
	})
	Gradient(footer, Color3.fromRGB(18, 18, 18), Color3.fromRGB(14, 14, 14), 90)
	Stroke(footer, Color3.fromRGB(30, 30, 30), 1)

	Text(footer, options.Build or "build 2.4.1", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.fromOffset(100, 25),
		TextColor3 = Color3.fromRGB(62, 62, 62),
		Font = FONT,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local connected = Text(footer, "●  CONNECTED", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.fromOffset(100, 25),
		TextColor3 = Color3.fromRGB(62, 62, 62),
		Font = FONT,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	connected.RichText = true
	connected.Text = '<font color="#2ecc55">●</font>  CONNECTED'

	local mainTabs = {"Aimbot", "ESP", "Misc", "Visuals", "World", "Config"}
	local rightTabs = {"Aimbot", "Visuals", "Config", "Misc"}

	local mainTabButtons = {}
	local rightTabButtons = {}

	local function renderMainTab(tab: string)
		self.State.MainTab = tab

		for name, tabObject in pairs(mainTabButtons) do
			tabObject:SetActive(name == tab)
		end

		if tab == "Aimbot" then
			self:_AimbotLeft(left)
		else
			self:_GenericLeft(left, tab)
		end
	end

	local function renderRightTab(tab: string)
		self.State.RightTab = tab

		for name, tabObject in pairs(rightTabButtons) do
			tabObject:SetActive(name == tab)
		end

		if tab == "Aimbot" then
			self:_RightAimbot(rightContent)
		elseif tab == "Visuals" then
			self:_RightVisuals(rightContent)
		elseif tab == "Config" then
			self:_RightConfig(rightContent)
		elseif tab == "Misc" then
			self:_RightMisc(rightContent)
		end
	end

	for _, tab in ipairs(mainTabs) do
		mainTabButtons[tab] = self:_Tab(mainTabBar, tab, "normal", function()
			renderMainTab(tab)
		end)
	end

	for _, tab in ipairs(rightTabs) do
		rightTabButtons[tab] = self:_Tab(rightTabBar, tab, "small", function()
			renderRightTab(tab)
		end)
	end

	renderMainTab("Aimbot")
	renderRightTab("Aimbot")

	self.MainTabs = mainTabButtons
	self.RightTabs = rightTabButtons

	-- Keep the right panel height correct when the window/body changes.
	body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if right.Parent then
			right.Size = UDim2.new(0, 190, 1, 0)
		end
	end)

	return self
end

function Library:SetVisible(value: boolean)
	if self.Destroyed then
		return
	end

	self.Visible = value
	self.Window.Visible = value
end

function Library:Toggle()
	self:SetVisible(not self.Visible)
end

function Library:SetMainTab(tab: string)
	if self.MainTabs and self.MainTabs[tab] then
		self.MainTabs[tab].Object:Activate()
	end
end

function Library:SetRightTab(tab: string)
	if self.RightTabs and self.RightTabs[tab] then
		self.RightTabs[tab].Object:Activate()
	end
end

function Library:GetState()
	return self.State
end

function Library:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true

	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

return Library
