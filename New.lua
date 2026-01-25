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
	success = Color3.fromRGB(139, 255, 149),
	error = Color3.fromRGB(255, 101, 104)
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
			
			-- Get ping
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
		currentTab = nil
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
		
		local iconImg = create("ImageLabel", {
			Parent = tabBtn,
			Size = UDim2.new(0, 29, 0, 25),
			BackgroundTransparency = 1,
			Image = loadAsset(icon .. ".png", RoSense.assets[icon .. ".png"]) or "",
			ImageColor3 = self.theme.textDim
		})
		
		local tabLabel = create("TextLabel", {
			Parent = tabBtn,
			Size = UDim2.new(0, 124, 0, 26),
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
				t.icon.ImageColor3 = RoSense.theme.textDim
				t.label.TextColor3 = RoSense.theme.textDim
			end
			
			-- Select this
			iconImg.ImageColor3 = RoSense.theme.accent
			tabLabel.TextColor3 = RoSense.theme.text
			
			-- Show page
			for _, t in pairs(window.tabs) do
				if t.page then
					t.page.Visible = (t == tab)
				end
			end
		end
		
		connect(window.connections, clickBtn.MouseButton1Click, function()
			tab:Select()
		end)
		
		-- Create page (will hold sections)
		local page = create("Frame", {
			Parent = tabContents,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false
		})
		
		tab.page = page
		
		function tab:AddSection(sectionName)
			local section = {
				tab = tab,
				elements = {}
			}
			
			local sectionFrame = create("Frame", {
				Parent = tabContents,
				Size = UDim2.new(0, 369, 0, 293),
				BackgroundColor3 = RoSense.theme.content
			})
			
			create("UICorner", {Parent = sectionFrame, CornerRadius = UDim.new(0, 6)})
			create("UIStroke", {
				Parent = sectionFrame,
				Color = RoSense.theme.border,
				Thickness = 1.2
			})
			
			local sectionTitle = create("TextLabel", {
				Parent = sectionFrame,
				Size = UDim2.new(0, 107, 0, 25),
				Position = UDim2.new(0, 10, 0, 5),
				BackgroundTransparency = 1,
				Text = sectionName:upper(),
				TextColor3 = RoSense.theme.text,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local elementContainer = create("Frame", {
				Parent = sectionFrame,
				Size = UDim2.new(1, 0, 1, -35),
				Position = UDim2.new(0, 0, 0, 35),
				BackgroundTransparency = 1
			})
			
			create("UIListLayout", {
				Parent = elementContainer,
				Padding = UDim.new(0, 7),
				VerticalAlignment = Enum.VerticalAlignment.Top
			})
			
			section.container = elementContainer
			section.frame = sectionFrame
			
			function section:AddToggle(options)
				local toggle = create("Frame", {
					Parent = elementContainer,
					Size = UDim2.new(1, -20, 0, 38),
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
						options.Callback(toggled)
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
			
			table.insert(tab.sections, section)
			return section
		end
		
		table.insert(window.tabs, tab)
		
		if #window.tabs == 1 then
			tab:Select()
		end
		
		return tab
	end
	
	function window:Destroy()
		for _, conn in pairs(window.connections) do
			pcall(function() conn:Disconnect() end)
		end
		screenGui:Destroy()
	end
	
	return window
end

return RoSense
