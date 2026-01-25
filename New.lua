local RoSense = {}
local g = game
local s = {
	pl = g:GetService("Players"),
	rs = g:GetService("RunService"),
	ts = g:GetService("TweenService"),
	ui = g:GetService("UserInputService"),
	cg = g:GetService("CoreGui"),
	st = g:GetService("Stats")
}

-- Utility Functions
local function create(class, props, children)
	local inst = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	return inst
end

local function tween(obj, time, props, style, dir)
	local tw = s.ts:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

local function connect(table, signal, func)
	local conn = signal:Connect(func)
	if table then
		table[#table + 1] = conn
	end
	return conn
end

-- File System
local wf, rf, iff, ifo, mf = writefile, readfile, isfile, isfolder, makefolder
local gca = getcustomasset or getsynasset or GetCustomAsset

local function fsAvailable()
	return wf and iff and ifo and mf and gca
end

local function ensureFolder(path)
	if not fsAvailable() then return end
	if not ifo(path) then
		mf(path)
	end
end

local function httpGet(url)
	local success, result = pcall(function()
		return g:HttpGet(url)
	end)
	if success and result then return result end
	
	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if req then
		success, result = pcall(function()
			return req({Url = url, Method = "GET"})
		end)
		if success and result then
			return result.Body or result.body or result
		end
	end
	return nil
end

local function loadAsset(name, url)
	if not fsAvailable() then return nil end
	ensureFolder("RoSense")
	ensureFolder("RoSense/assets")
	
	local path = "RoSense/assets/" .. name
	if not iff(path) then
		local data = httpGet(url)
		if data then
			wf(path, data)
		end
	end
	
	if iff(path) then
		local ok, asset = pcall(gca, path)
		if ok then return asset end
	end
	return nil
end

-- Theme
RoSense.theme = {
	bg = Color3.fromRGB(21, 21, 21),
	header = Color3.fromRGB(29, 29, 29),
	content = Color3.fromRGB(29, 29, 29),
	accent = Color3.fromRGB(228, 164, 254),
	accentDark = Color3.fromRGB(165, 119, 184),
	text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(80, 80, 80),
	border = Color3.fromRGB(49, 49, 49),
	toggleBg = Color3.fromRGB(12, 12, 12),
	inputBg = Color3.fromRGB(12, 12, 12),
	success = Color3.fromRGB(139, 255, 149),
	error = Color3.fromRGB(255, 101, 104),
	warning = Color3.fromRGB(255, 193, 7)
}

-- Assets
RoSense.assets = {
	["fps.png"] = "https://files.catbox.moe/dpbo1s.png",
	["CheckToggle.png"] = "https://files.catbox.moe/oktka6.png",
	["Player.png"] = "https://files.catbox.moe/4fymry.png",
	["Misc.png"] = "https://files.catbox.moe/vqtuj6.png",
	["logo.png"] = "https://files.catbox.moe/xvikgr.png",
	["Ping.png"] = "https://files.catbox.moe/qiiccl.png"
}

-- SVG Icons (white by default)
local function createIcon(parent, iconType)
	local icon = create("Frame", {
		Parent = parent,
		Size = UDim2.new(0, 20, 0, 20),
		BackgroundTransparency = 1
	})
	
	if iconType == "Combat" then
		-- Sword icon
		local blade = create("Frame", {
			Parent = icon,
			Size = UDim2.new(0, 3, 0, 16),
			Position = UDim2.new(0.5, -1.5, 0, 2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Rotation = 45
		})
		create("UICorner", {Parent = blade, CornerRadius = UDim.new(0, 1)})
		
		local hilt = create("Frame", {
			Parent = icon,
			Size = UDim2.new(0, 8, 0, 2),
			Position = UDim2.new(0.5, -4, 1, -6),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Rotation = 45
		})
		create("UICorner", {Parent = hilt, CornerRadius = UDim.new(0, 1)})
		
	elseif iconType == "Visual" then
		-- Eye icon
		local eye = create("Frame", {
			Parent = icon,
			Size = UDim2.new(0, 16, 0, 10),
			Position = UDim2.new(0.5, -8, 0.5, -5),
			BackgroundTransparency = 1
		})
		create("UIStroke", {Parent = eye, Color = Color3.fromRGB(255, 255, 255), Thickness = 2})
		create("UICorner", {Parent = eye, CornerRadius = UDim.new(1, 0)})
		
		local pupil = create("Frame", {
			Parent = eye,
			Size = UDim2.new(0, 4, 0, 4),
			Position = UDim2.new(0.5, -2, 0.5, -2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		})
		create("UICorner", {Parent = pupil, CornerRadius = UDim.new(1, 0)})
		
	elseif iconType == "Settings" then
		-- Gear icon
		for i = 0, 7 do
			local angle = math.rad(i * 45)
			local tooth = create("Frame", {
				Parent = icon,
				Size = UDim2.new(0, 2, 0, 4),
				Position = UDim2.new(0.5, math.cos(angle) * 6 - 1, 0.5, math.sin(angle) * 6 - 2),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			})
			create("UICorner", {Parent = tooth, CornerRadius = UDim.new(0, 1)})
		end
		
		local center = create("Frame", {
			Parent = icon,
			Size = UDim2.new(0, 6, 0, 6),
			Position = UDim2.new(0.5, -3, 0.5, -3),
			BackgroundTransparency = 1
		})
		create("UIStroke", {Parent = center, Color = Color3.fromRGB(255, 255, 255), Thickness = 2})
		create("UICorner", {Parent = center, CornerRadius = UDim.new(1, 0)})
	end
	
	return icon
end

-- Drag functionality
local function makeDraggable(frame, handle, connections)
	local dragging, dragStart, startPos
	
	connect(connections, handle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	
	connect(connections, s.ui.InputChanged, function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	connect(connections, s.ui.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- Stats Calculation
local function createStatsBar(window, parent)
	local bar = create("Frame", {
		Parent = parent,
		Size = UDim2.new(0, 428, 0, 43),
		BackgroundColor3 = RoSense.theme.bg,
		BorderSizePixel = 0
	})
	
	create("UICorner", {Parent = bar, CornerRadius = UDim.new(0, 4)})
	create("UIStroke", {
		Parent = bar,
		Color = RoSense.theme.accentDark,
		Thickness = 2.4
	})
	
	local layout = create("UIListLayout", {
		Parent = bar,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 10),
		VerticalAlignment = Enum.VerticalAlignment.Center
	})
	
	create("UIPadding", {Parent = bar, PaddingLeft = UDim.new(0, 6)})
	
	-- FPS Counter
	local fpsFrame = create("Frame", {
		Parent = bar,
		Size = UDim2.new(0, 93, 0, 27),
		BackgroundTransparency = 1
	})
	
	create("UIListLayout", {
		Parent = fpsFrame,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		VerticalAlignment = Enum.VerticalAlignment.Center
	})
	
	local fpsIcon = create("ImageLabel", {
		Parent = fpsFrame,
		Size = UDim2.new(0, 25, 0, 25),
		BackgroundTransparency = 1,
		Image = loadAsset("fps.png", RoSense.assets["fps.png"]) or "",
		ImageColor3 = RoSense.theme.success
	})
	
	local fpsLabel = create("TextLabel", {
		Parent = fpsFrame,
		Size = UDim2.new(0, 65, 0, 25),
		BackgroundTransparency = 1,
		Text = "60 FPS",
		TextColor3 = RoSense.theme.success,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center
	})
	
	-- Ping Counter
	local pingFrame = create("Frame", {
		Parent = bar,
		Size = UDim2.new(0, 93, 0, 27),
		BackgroundTransparency = 1
	})
	
	create("UIListLayout", {
		Parent = pingFrame,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		VerticalAlignment = Enum.VerticalAlignment.Center
	})
	
	local pingIcon = create("ImageLabel", {
		Parent = pingFrame,
		Size = UDim2.new(0, 25, 0, 25),
		BackgroundTransparency = 1,
		Image = loadAsset("Ping.png", RoSense.assets["Ping.png"]) or "",
		ImageColor3 = RoSense.theme.error
	})
	
	local pingLabel = create("TextLabel", {
		Parent = pingFrame,
		Size = UDim2.new(0, 65, 0, 25),
		BackgroundTransparency = 1,
		Text = "0 MS",
		TextColor3 = RoSense.theme.error,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center
	})
	
	-- Game Name
	local gameFrame = create("Frame", {
		Parent = bar,
		Size = UDim2.new(0, 127, 1, 0),
		BackgroundTransparency = 1
	})
	
	local gameName = create("TextLabel", {
		Parent = gameFrame,
		Size = UDim2.new(1, 0, 0, 25),
		Position = UDim2.new(0, 0, 0.5, -12.5),
		BackgroundTransparency = 1,
		Text = g:GetService("MarketplaceService"):GetProductInfo(g.PlaceId).Name or "Game",
		TextColor3 = RoSense.theme.text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Center
	})
	
	-- Update loop
	local frameCount = 0
	local lastUpdate = tick()
	
	connect(window.connections, s.rs.RenderStepped, function()
		frameCount = frameCount + 1
		local now = tick()
		
		if now - lastUpdate >= 0.5 then
			local fps = math.floor(frameCount / (now - lastUpdate))
			fpsLabel.Text = fps .. " FPS"
			
			local success, ping = pcall(function()
				local net = s.st:FindFirstChild("Network")
				local ssi = net and net:FindFirstChild("ServerStatsItem")
				local pingItem = ssi and (ssi:FindFirstChild("Data Ping") or ssi:FindFirstChild("Ping"))
				if pingItem then
					if pingItem.GetValue then
						return pingItem:GetValue()
					elseif pingItem.GetValueString then
						local str = pingItem:GetValueString()
						return tonumber(str:match("%d+"))
					end
				end
				return 0
			end)
			
			pingLabel.Text = (success and ping or 0) .. " MS"
			
			frameCount = 0
			lastUpdate = now
		end
	end)
	
	return bar
end

-- Main Window Creation
function RoSense:CreateWindow(config)
	config = config or {}
	local window = {
		connections = {},
		tabs = {},
		currentTab = nil,
		notifications = {}
	}
	
	-- Load assets
	for name, url in pairs(self.assets) do
		loadAsset(name, url)
	end
	
	-- Create ScreenGui
	local screenGui = create("ScreenGui", {
		Parent = (gethui and gethui()) or s.cg,
		Name = "RoSenseUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	
	if syn and syn.protect_gui then
		syn.protect_gui(screenGui)
	end
	
	window.gui = screenGui
	
	-- Notification Container
	local notifContainer = create("Frame", {
		Parent = screenGui,
		Size = UDim2.new(0, 300, 1, -20),
		Position = UDim2.new(1, -310, 0, 10),
		BackgroundTransparency = 1,
		ZIndex = 100
	})
	
	create("UIListLayout", {
		Parent = notifContainer,
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Top,
		HorizontalAlignment = Enum.HorizontalAlignment.Right
	})
	
	window.notifContainer = notifContainer
	
	-- Main Frame
	local main = create("CanvasGroup", {
		Parent = screenGui,
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 1186, 0, 817),
		BackgroundColor3 = self.theme.bg,
		BorderSizePixel = 0
	})
	
	create("UICorner", {Parent = main, CornerRadius = UDim.new(0, 8)})
	
	-- Header
	local header = create("Frame", {
		Parent = main,
		Size = UDim2.new(1, 0, 0, 74),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = self.theme.header,
		BorderColor3 = self.theme.accentDark,
		BorderSizePixel = 2
	})
	
	-- Logo
	local logo = create("ImageLabel", {
		Parent = header,
		Size = UDim2.new(0, 47, 0, 47),
		Position = UDim2.new(0, 20, 0.5, -23.5),
		BackgroundTransparency = 1,
		Image = loadAsset("logo.png", self.assets["logo.png"]) or "",
		ScaleType = Enum.ScaleType.Fit
	})
	
	-- Title
	local title = create("TextLabel", {
		Parent = header,
		Size = UDim2.new(0, 192, 0, 40),
		Position = UDim2.new(0, 86, 0, 17),
		BackgroundTransparency = 1,
		Text = config.Name or "RoSense",
		TextColor3 = self.theme.accent,
		Font = Enum.Font.GothamBold,
		TextSize = 28,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Tab Container
	local tabButtons = create("Frame", {
		Parent = header,
		Size = UDim2.new(0, 820, 0, 39),
		Position = UDim2.new(0, 290, 0, 32),
		BackgroundTransparency = 1
	})
	
	create("UIListLayout", {
		Parent = tabButtons,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center
	})
	
	window.tabButtons = tabButtons
	
	-- Tab Content Container
	local tabContents = create("Frame", {
		Parent = main,
		Size = UDim2.new(0, 1142, 0, 698),
		Position = UDim2.new(0.5, 0, 0, 106),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1
	})
	
	create("UIGridLayout", {
		Parent = tabContents,
		CellSize = UDim2.new(0, 369, 0, 293),
		CellPadding = UDim2.new(0, 17, 0, 17),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top
	})
	
	create("UIPadding", {Parent = tabContents, PaddingTop = UDim.new(0, 15)})
	
	window.tabContents = tabContents
	
	-- Bottom Bar
	local bottom = create("Frame", {
		Parent = main,
		Size = UDim2.new(1, 0, 0, 42),
		Position = UDim2.new(0, 0, 1, -42),
		BackgroundColor3 = self.theme.header,
		BorderColor3 = self.theme.border,
		BorderSizePixel = 1
	})
	
	-- Stats Bar (floating)
	local statsBar = createStatsBar(window, screenGui)
	statsBar.Position = UDim2.new(0, 20, 0, 20)
	
	-- Make draggable
	makeDraggable(main, header, window.connections)
	
	-- Toggle visibility
	local visible = true
	connect(window.connections, s.ui.InputBegan, function(input, gpe)
		if gpe then return end
		if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
			visible = not visible
			main.Visible = visible
		end
	end)
	
	-- Notification System
	function window:Notify(options)
		options = options or {}
		local title = options.Title or "Notification"
		local message = options.Message or ""
		local duration = options.Duration or 3
		local type = options.Type or "info" -- info, success, error, warning
		
		local notif = create("Frame", {
			Parent = notifContainer,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = self.theme.content,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1
		})
		
		create("UICorner", {Parent = notif, CornerRadius = UDim.new(0, 6)})
		
		local stroke = create("UIStroke", {
			Parent = notif,
			Color = type == "success" and self.theme.success or 
			        type == "error" and self.theme.error or
			        type == "warning" and self.theme.warning or
			        self.theme.accentDark,
			Thickness = 2,
			Transparency = 1
		})
		
		create("UIPadding", {
			Parent = notif,
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12)
		})
		
		create("UIListLayout", {
			Parent = notif,
			Padding = UDim.new(0, 4),
			VerticalAlignment = Enum.VerticalAlignment.Top
		})
		
		local titleLabel = create("TextLabel", {
			Parent = notif,
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = self.theme.text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1
		})
		
		local msgLabel = create("TextLabel", {
			Parent = notif,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text = message,
			TextColor3 = self.theme.textDim,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTransparency = 1
		})
		
		local progressBar = create("Frame", {
			Parent = notif,
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2),
			BackgroundColor3 = stroke.Color,
			BackgroundTransparency = 1
		})
		
		create("UICorner", {Parent = progressBar, CornerRadius = UDim.new(0, 1)})
		
		-- Animate in
		tween(notif, 0.3, {BackgroundTransparency = 0}, Enum.EasingStyle.Back)
		tween(stroke, 0.3, {Transparency = 0})
		tween(titleLabel, 0.3, {TextTransparency = 0})
		tween(msgLabel, 0.3, {TextTransparency = 0})
		tween(progressBar, 0.3, {BackgroundTransparency = 0.3})
		
		-- Progress animation
		tween(progressBar, duration, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)
		
		-- Animate out
		task.delay(duration, function()
			tween(notif, 0.3, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
			tween(stroke, 0.3, {Transparency = 1})
			tween(titleLabel, 0.3, {TextTransparency = 1})
			tween(msgLabel, 0.3, {TextTransparency = 1})
			tween(progressBar, 0.3, {BackgroundTransparency = 1})
			
			task.delay(0.4, function()
				notif:Destroy()
			end)
		end)
		
		return notif
	end
	
	function window:AddTab(name, icon)
		local tab = {
			window = window,
			sections = {},
			button = nil,
			page = nil
		}
		
		-- Create tab button
		local tabBtn = create("Frame", {
			Parent = tabButtons,
			Size = UDim2.new(0, 138, 0, 31),
			BackgroundTransparency = 1
		})
		
		create("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, 4)})
		
		create("UIListLayout", {
			Parent = tabBtn,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Center
		})
		
		local iconImg
		if RoSense.assets[icon .. ".png"] then
			iconImg = create("ImageLabel", {
				Parent = tabBtn,
				Size = UDim2.new(0, 29, 0, 25),
				BackgroundTransparency = 1,
				Image = loadAsset(icon .. ".png", RoSense.assets[icon .. ".png"]) or "",
				ImageColor3 = self.theme.textDim
			})
		else
			iconImg = createIcon(tabBtn, icon)
			for _, child in pairs(iconImg:GetDescendants()) do
				if child:IsA("Frame") or child:IsA("UIStroke") then
					if child.BackgroundColor3 then
						child.BackgroundColor3 = self.theme.textDim
					end
					if child.ClassName == "UIStroke" then
						child.Color = self.theme.textDim
					end
				end
			end
		end
		
		local tabLabel = create("TextLabel", {
			Parent = tabBtn,
			Size = UDim2.new(0, 100, 0, 26),
			BackgroundTransparency = 1,
			Text = name:upper(),
			TextColor3 = self.theme.textDim,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local clickBtn = create("TextButton", {
			Parent = tabBtn,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = ""
		})
		
		tab.button = tabBtn
		tab.icon = iconImg
		tab.label = tabLabel
		
		function tab:Select()
			-- Deselect all
			for _, t in pairs(window.tabs) do
				if RoSense.assets[icon .. ".png"] then
					t.icon.ImageColor3 = RoSense.theme.textDim
				else
					for _, child in pairs(t.icon:GetDescendants()) do
						if child:IsA("Frame") or child:IsA("UIStroke") then
							if child.BackgroundColor3 then
								child.BackgroundColor3 = RoSense.theme.textDim
							end
							if child.ClassName == "UIStroke" then
								child.Color = RoSense.theme.textDim
							end
						end
					end
				end
				t.label.TextColor3 = RoSense.theme.textDim
			end
			
			-- Select this
			if RoSense.assets[icon .. ".png"] then
				iconImg.ImageColor3 = RoSense.theme.accent
			else
				for _, child in pairs(iconImg:GetDescendants()) do
					if child:IsA("Frame") or child:IsA("UIStroke") then
						if child.BackgroundColor3 then
							child.BackgroundColor3 = RoSense.theme.accent
						end
						if child.ClassName == "UIStroke" then
							child.Color = RoSense.theme.accent
						end
					end
				end
			end
			tabLabel.TextColor3 = RoSense.theme.text
			
			-- Show sections
			for _, t in pairs(window.tabs) do
				for _, section in pairs(t.sections) do
					section.frame.Visible = (t == tab)
				end
			end
		end
		
		connect(window.connections, clickBtn.MouseButton1Click, function()
			tab:Select()
		end)
		
		function tab:AddSection(sectionName)
			local section = {
				tab = tab,
				elements = {}
			}
			
			local sectionFrame = create("Frame", {
				Parent = tabContents,
				Size = UDim2.new(0, 369, 0, 293),
				BackgroundColor3 = RoSense.theme.content,
				Visible = false
			})
			
			create("UICorner", {Parent = sectionFrame, CornerRadius = UDim.new(0, 6)})
			create("UIStroke", {
				Parent = sectionFrame,
				Color = RoSense.theme.border,
				Thickness = 1.2
			})
			
			local sectionTitle = create("TextLabel", {
				Parent = sectionFrame,
				Size = UDim2.new(0, 200, 0, 25),
				Position = UDim2.new(0, 10, 0, 5),
				BackgroundTransparency = 1,
				Text = sectionName:upper(),
				TextColor3 = RoSense.theme.text,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local elementContainer = create("ScrollingFrame", {
				Parent = sectionFrame,
				Size = UDim2.new(1, -10, 1, -40),
				Position = UDim2.new(0, 5, 0, 35),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = RoSense.theme.accentDark,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y
			})
			
			create("UIListLayout", {
				Parent = elementContainer,
				Padding = UDim.new(0, 7),
				VerticalAlignment = Enum.VerticalAlignment.Top
			})
			
			section.container = elementContainer
			section.frame = sectionFrame
			
			-- Toggle
			function section:AddToggle(options)
				options = options or {}
				local toggle = create("Frame", {
					Parent = elementContainer,
					Size = UDim2.new(1, -15, 0, 38),
					BackgroundTransparency = 1
				})
				
				local nameLabel = create("TextLabel", {
					Parent = toggle,
					Size = UDim2.new(0, 200, 0, 21),
					Position = UDim2.new(0, 10, 0.5, -10.5),
					BackgroundTransparency = 1,
					Text = options.Name or "Toggle",
					TextColor3 = RoSense.theme.text,
					Font = Enum.Font.GothamBold,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local toggleBox = create("ImageButton", {
					Parent = toggle,
					Size = UDim2.new(0, 20, 0, 20),
					Position = UDim2.new(1, -30, 0.5, -10),
					BackgroundColor3 = RoSense.theme.toggleBg,
					Image = loadAsset("CheckToggle.png", RoSense.assets["CheckToggle.png"]) or "",
					ImageTransparency = 1
				})
				
				create("UICorner", {Parent = toggleBox, CornerRadius = UDim.new(0, 2)})
				
				local toggled = options.Default or false
				
				local function updateToggle()
					if toggled then
						tween(toggleBox, 0.2, {ImageTransparency = 0})
					else
						tween(toggleBox, 0.2, {ImageTransparency = 1})
					end
					
					if options.Callback then
						pcall(options.Callback, toggled)
					end
				end
				
				connect(window.connections, toggleBox.MouseButton1Click, function()
					toggled = not toggled
					updateToggle()
				end)
				
				updateToggle()
				
				return {
					Set = function(_, value)
						toggled = value
						updateToggle()
					end,
					Get = function()
						return toggled
					end
				}
			end
			
			-- Button
			function section:AddButton(options)
				options = options or {}
				local button = create("TextButton", {
					Parent = elementContainer,
					Size = UDim2.new(1, -15, 0, 38),
					BackgroundColor3 = RoSense.theme.inputBg,
					Text = options.Name or "Button",
					TextColor3 = RoSense.theme.text,
					Font = Enum.Font.GothamBold,
					TextSize = 13,
					AutoButtonColor = false
				})
				
				create("UICorner", {Parent = button, CornerRadius = UDim.new(0, 6)})
				
				local stroke = create("UIStroke", {
					Parent = button,
					Color = RoSense.theme.border,
					Thickness = 1.2
				})
				
				connect(window.connections, button.MouseEnter, function()
					tween(button, 0.2, {BackgroundColor3 = RoSense.theme.border})
					tween(stroke, 0.2, {Color = RoSense.theme.accentDark})
				end)
				
				connect(window.connections, button.MouseLeave, function()
					tween(button, 0.2, {BackgroundColor3 = RoSense.theme.inputBg})
					tween(stroke, 0.2, {Color = RoSense.theme.border})
				end)
				
				connect(window.connections, button.MouseButton1Click, function()
					if options.Callback then
						pcall(options.Callback)
					end
				end)
				
				return {
					SetText = function(_, text)
						button.Text = text
					end
				}
			end
			
			-- Slider
			function section:AddSlider(options)
				options = options or {}
				local min = options.Min or 0
				local max = options.Max or 100
				local default = options.Default or min
				local increment = options.Increment or 1
				
				local sliderFrame = create("Frame", {
					Parent = elementContainer,
					Size = UDim2.new(1, -15, 0, 50),
					BackgroundTransparency = 1
				})
				
				local nameLabel = create("TextLabel", {
					Parent = sliderFrame,
					Size = UDim2.new(0.7, 0, 0, 18),
					Position = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					Text = options.Name or "Slider",
					TextColor3 = RoSense.theme.text,
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local valueLabel = create("TextLabel", {
					Parent = sliderFrame,
					Size = UDim2.new(0.3, -10, 0, 18),
					Position = UDim2.new(0.7, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = tostring(default),
					TextColor3 = RoSense.theme.textDim,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right
				})
				
				local sliderBack = create("Frame", {
					Parent = sliderFrame,
					Size = UDim2.new(1, -20, 0, 8),
					Position = UDim2.new(0, 10, 0, 28),
					BackgroundColor3 = RoSense.theme.inputBg
				})
				
				create("UICorner", {Parent = sliderBack, CornerRadius = UDim.new(0, 4)})
				create("UIStroke", {
					Parent = sliderBack,
					Color = RoSense.theme.border,
					Thickness = 1
				})
				
				local sliderFill = create("Frame", {
					Parent = sliderBack,
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = RoSense.theme.accent
				})
				
				create("UICorner", {Parent = sliderFill, CornerRadius = UDim.new(0, 4)})
				
				local sliderKnob = create("Frame", {
					Parent = sliderBack,
					Size = UDim2.new(0, 12, 0, 12),
					Position = UDim2.new(0, -6, 0.5, -6),
					BackgroundColor3 = RoSense.theme.accent
				})
				
				create("UICorner", {Parent = sliderKnob, CornerRadius = UDim.new(1, 0)})
				create("UIStroke", {
					Parent = sliderKnob,
					Color = RoSense.theme.bg,
					Thickness = 2
				})
				
				local value = default
				local dragging = false
				
				local function setValue(val)
					value = math.floor(clamp(val, min, max) / increment + 0.5) * increment
					local percent = (value - min) / (max - min)
					
					tween(sliderFill, 0.1, {Size = UDim2.new(percent, 0, 1, 0)})
					tween(sliderKnob, 0.1, {Position = UDim2.new(percent, -6, 0.5, -6)})
					valueLabel.Text = tostring(value)
					
					if options.Callback then
						pcall(options.Callback, value)
					end
				end
				
				connect(window.connections, sliderBack.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						local percent = clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
						setValue(min + (max - min) * percent)
					end
				end)
				
				connect(window.connections, s.ui.InputChanged, function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						local percent = clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
						setValue(min + (max - min) * percent)
					end
				end)
				
				connect(window.connections, s.ui.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				
				setValue(default)
				
				return {
					Set = function(_, val)
						setValue(val)
					end,
					Get = function()
						return value
					end
				}
			end
			
			-- Dropdown
			function section:AddDropdown(options)
				options = options or {}
				local items = options.Items or {}
				local default = options.Default
				local selected = default
				
				local dropFrame = create("Frame", {
					Parent = elementContainer,
					Size = UDim2.new(1, -15, 0, 38),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				})
				
				local dropHeader = create("TextButton", {
					Parent = dropFrame,
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundColor3 = RoSense.theme.inputBg,
					Text = "",
					AutoButtonColor = false
				})
				
				create("UICorner", {Parent = dropHeader, CornerRadius = UDim.new(0, 6)})
				create("UIStroke", {
					Parent = dropHeader,
					Color = RoSense.theme.border,
					Thickness = 1.2
				})
				
				local nameLabel = create("TextLabel", {
					Parent = dropHeader,
					Size = UDim2.new(0.4, 0, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					Text = options.Name or "Dropdown",
					TextColor3 = RoSense.theme.text,
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local valueLabel = create("TextLabel", {
					Parent = dropHeader,
					Size = UDim2.new(0.5, -40, 1, 0),
					Position = UDim2.new(0.4, 10, 0, 0),
					BackgroundTransparency = 1,
					Text = selected or "...",
					TextColor3 = RoSense.theme.textDim,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd
				})
				
				local arrow = create("TextLabel", {
					Parent = dropHeader,
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -30, 0, 0),
					BackgroundTransparency = 1,
					Text = "▼",
					TextColor3 = RoSense.theme.textDim,
					Font = Enum.Font.GothamBold,
					TextSize = 10
				})
				
				local dropList = create("ScrollingFrame", {
					Parent = dropFrame,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 40),
					BackgroundColor3 = RoSense.theme.inputBg,
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = RoSense.theme.accentDark,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					BorderSizePixel = 0
				})
				
				create("UICorner", {Parent = dropList, CornerRadius = UDim.new(0, 6)})
				create("UIStroke", {
					Parent = dropList,
					Color = RoSense.theme.border,
					Thickness = 1.2
				})
				
				create("UIListLayout", {
					Parent = dropList,
					Padding = UDim.new(0, 2)
				})
				
				create("UIPadding", {
					Parent = dropList,
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4)
				})
				
				local open = false
				
				local function updateItems()
					for _, child in pairs(dropList:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end
					
					for _, item in pairs(items) do
						local itemBtn = create("TextButton", {
							Parent = dropList,
							Size = UDim2.new(1, -8, 0, 28),
							BackgroundColor3 = RoSense.theme.content,
							Text = item,
							TextColor3 = RoSense.theme.text,
							Font = Enum.Font.Gotham,
							TextSize = 11,
							AutoButtonColor = false
						})
						
						create("UICorner", {Parent = itemBtn, CornerRadius = UDim.new(0, 4)})
						
						connect(window.connections, itemBtn.MouseEnter, function()
							tween(itemBtn, 0.15, {BackgroundColor3 = RoSense.theme.border})
						end)
						
						connect(window.connections, itemBtn.MouseLeave, function()
							tween(itemBtn, 0.15, {BackgroundColor3 = RoSense.theme.content})
						end)
						
						connect(window.connections, itemBtn.MouseButton1Click, function()
							selected = item
							valueLabel.Text = item
							valueLabel.TextColor3 = RoSense.theme.accent
							
							tween(dropFrame, 0.2, {Size = UDim2.new(1, -15, 0, 38)})
							tween(dropList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
							tween(arrow, 0.2, {Rotation = 0})
							open = false
							
							if options.Callback then
								pcall(options.Callback, item)
							end
						end)
					end
				end
				
				connect(window.connections, dropHeader.MouseButton1Click, function()
					open = not open
					
					if open then
						local itemCount = #items
						local height = math.min(itemCount * 30 + 8, 150)
						tween(dropFrame, 0.25, {Size = UDim2.new(1, -15, 0, 38 + height)})
						tween(dropList, 0.25, {Size = UDim2.new(1, 0, 0, height)})
						tween(arrow, 0.2, {Rotation = 180})
					else
						tween(dropFrame, 0.2, {Size = UDim2.new(1, -15, 0, 38)})
						tween(dropList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
						tween(arrow, 0.2, {Rotation = 0})
					end
				end)
				
				updateItems()
				
				return {
					Set = function(_, value)
						selected = value
						valueLabel.Text = value
						valueLabel.TextColor3 = RoSense.theme.accent
					end,
					Get = function()
						return selected
					end,
					SetItems = function(_, newItems)
						items = newItems
						updateItems()
					end
				}
			end
			
			-- Multi-Select Dropdown
			function section:AddMultiDropdown(options)
				options = options or {}
				local items = options.Items or {}
				local selectedItems = {}
				
				local dropFrame = create("Frame", {
					Parent = elementContainer,
					Size = UDim2.new(1, -15, 0, 38),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				})
				
				local dropHeader = create("TextButton", {
					Parent = dropFrame,
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundColor3 = RoSense.theme.inputBg,
					Text = "",
					AutoButtonColor = false
				})
				
				create("UICorner", {Parent = dropHeader, CornerRadius = UDim.new(0, 6)})
				create("UIStroke", {
					Parent = dropHeader,
					Color = RoSense.theme.border,
					Thickness = 1.2
				})
				
				local nameLabel = create("TextLabel", {
					Parent = dropHeader,
					Size = UDim2.new(0.4, 0, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					Text = options.Name or "Multi Select",
					TextColor3 = RoSense.theme.text,
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local valueLabel = create("TextLabel", {
					Parent = dropHeader,
					Size = UDim2.new(0.5, -40, 1, 0),
					Position = UDim2.new(0.4, 10, 0, 0),
					BackgroundTransparency = 1,
					Text = "None",
					TextColor3 = RoSense.theme.textDim,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd
				})
				
				local arrow = create("TextLabel", {
					Parent = dropHeader,
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -30, 0, 0),
					BackgroundTransparency = 1,
					Text = "▼",
					TextColor3 = RoSense.theme.textDim,
					Font = Enum.Font.GothamBold,
					TextSize = 10
				})
				
				local dropList = create("ScrollingFrame", {
					Parent = dropFrame,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 40),
					BackgroundColor3 = RoSense.theme.inputBg,
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = RoSense.theme.accentDark,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					BorderSizePixel = 0
				})
				
				create("UICorner", {Parent = dropList, CornerRadius = UDim.new(0, 6)})
				create("UIStroke", {
					Parent = dropList,
					Color = RoSense.theme.border,
					Thickness = 1.2
				})
				
				create("UIListLayout", {
					Parent = dropList,
					Padding = UDim.new(0, 2)
				})
				
				create("UIPadding", {
					Parent = dropList,
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4)
				})
				
				local open = false
				
				local function updateLabel()
					if #selectedItems == 0 then
						valueLabel.Text = "None"
						valueLabel.TextColor3 = RoSense.theme.textDim
					else
						valueLabel.Text = table.concat(selectedItems, ", ")
						valueLabel.TextColor3 = RoSense.theme.accent
					end
				end
				
				local function updateItems()
					for _, child in pairs(dropList:GetChildren()) do
						if child:IsA("Frame") and child.Name ~= "UIPadding" then
							child:Destroy()
						end
					end
					
					for _, item in pairs(items) do
						local itemFrame = create("Frame", {
							Parent = dropList,
							Size = UDim2.new(1, -8, 0, 28),
							BackgroundColor3 = RoSense.theme.content
						})
						
						create("UICorner", {Parent = itemFrame, CornerRadius = UDim.new(0, 4)})
						
						local itemLabel = create("TextLabel", {
							Parent = itemFrame,
							Size = UDim2.new(1, -30, 1, 0),
							Position = UDim2.new(0, 8, 0, 0),
							BackgroundTransparency = 1,
							Text = item,
							TextColor3 = RoSense.theme.text,
							Font = Enum.Font.Gotham,
							TextSize = 11,
							TextXAlignment = Enum.TextXAlignment.Left
						})
						
						local checkBox = create("ImageLabel", {
							Parent = itemFrame,
							Size = UDim2.new(0, 16, 0, 16),
							Position = UDim2.new(1, -22, 0.5, -8),
							BackgroundColor3 = RoSense.theme.toggleBg,
							Image = loadAsset("CheckToggle.png", RoSense.assets["CheckToggle.png"]) or "",
							ImageTransparency = 1
						})
						
						create("UICorner", {Parent = checkBox, CornerRadius = UDim.new(0, 2)})
						
						local itemBtn = create("TextButton", {
							Parent = itemFrame,
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = ""
						})
						
						local function updateCheck()
							local isSelected = table.find(selectedItems, item) ~= nil
							tween(checkBox, 0.2, {ImageTransparency = isSelected and 0 or 1})
						end
						
						connect(window.connections, itemBtn.MouseEnter, function()
							tween(itemFrame, 0.15, {BackgroundColor3 = RoSense.theme.border})
						end)
						
						connect(window.connections, itemBtn.MouseLeave, function()
							tween(itemFrame, 0.15, {BackgroundColor3 = RoSense.theme.content})
						end)
						
						connect(window.connections, itemBtn.MouseButton1Click, function()
							local idx = table.find(selectedItems, item)
							if idx then
								table.remove(selectedItems, idx)
							else
								table.insert(selectedItems, item)
							end
							
							updateCheck()
							updateLabel()
							
							if options.Callback then
								pcall(options.Callback, selectedItems)
							end
						end)
						
						updateCheck()
					end
				end
				
				connect(window.connections, dropHeader.MouseButton1Click, function()
					open = not open
					
					if open then
						local itemCount = #items
						local height = math.min(itemCount * 30 + 8, 150)
						tween(dropFrame, 0.25, {Size = UDim2.new(1, -15, 0, 38 + height)})
						tween(dropList, 0.25, {Size = UDim2.new(1, 0, 0, height)})
						tween(arrow, 0.2, {Rotation = 180})
					else
						tween(dropFrame, 0.2, {Size = UDim2.new(1, -15, 0, 38)})
						tween(dropList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
						tween(arrow, 0.2, {Rotation = 0})
					end
				end)
				
				updateItems()
				updateLabel()
				
				return {
					Get = function()
						return selectedItems
					end,
					Set = function(_, items)
						selectedItems = items
						updateLabel()
						updateItems()
					end
				}
			end
			
			-- Textbox
			function section:AddTextbox(options)
				options = options or {}
				
				local textFrame = create("Frame", {
					Parent = elementContainer,
					Size = UDim2.new(1, -15, 0, 38),
					BackgroundTransparency = 1
				})
				
				local nameLabel = create("TextLabel", {
					Parent = textFrame,
					Size = UDim2.new(0.4, 0, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					Text = options.Name or "Textbox",
					TextColor3 = RoSense.theme.text,
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local textBox = create("TextBox", {
					Parent = textFrame,
					Size = UDim2.new(0.6, -20, 0, 32),
					Position = UDim2.new(0.4, 10, 0.5, -16),
					BackgroundColor3 = RoSense.theme.inputBg,
					Text = options.Default or "",
					TextColor3 = RoSense.theme.text,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					PlaceholderText = options.Placeholder or "Enter text...",
					PlaceholderColor3 = RoSense.theme.textDim,
					ClearTextOnFocus = false
				})
				
				create("UICorner", {Parent = textBox, CornerRadius = UDim.new(0, 6)})
				create("UIStroke", {
					Parent = textBox,
					Color = RoSense.theme.border,
					Thickness = 1.2
				})
				
				create("UIPadding", {
					Parent = textBox,
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8)
				})
				
				connect(window.connections, textBox.FocusLost, function(enterPressed)
					if options.Callback then
						pcall(options.Callback, textBox.Text, enterPressed)
					end
				end)
				
				return {
					Set = function(_, text)
						textBox.Text = text
					end,
					Get = function()
						return textBox.Text
					end
				}
			end
			
			-- Label
			function section:AddLabel(text)
				local label = create("TextLabel", {
					Parent = elementContainer,
					Size = UDim2.new(1, -15, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Text = text or "Label",
					TextColor3 = RoSense.theme.textDim,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true
				})
				
				create("UIPadding", {
					Parent = label,
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5)
				})
				
				return {
					Set = function(_, newText)
						label.Text = newText
					end
				}
			end
			
table.insert(tab.sections, section)
			
			return section
		end
		
		table.insert(window.tabs, tab)
		
		-- Select first tab by default
		if #window.tabs == 1 then
			tab:Select()
		end
		
		return tab
	end
	
	function window:Destroy()
		for _, conn in pairs(self.connections) do
			conn:Disconnect()
		end
		screenGui:Destroy()
	end
	
	return window
end

return RoSense
