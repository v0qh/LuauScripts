local rs = {}
local g = game
local s = {
	pl = g:GetService("Players"),
	rs = g:GetService("RunService"),
	ts = g:GetService("TweenService"),
	ui = g:GetService("UserInputService"),
	cg = g:GetService("CoreGui"),
	st = g:GetService("Stats")
}

local function n(c, p, k)
	local i = Instance.new(c)
	if p then
		for a, b in pairs(p) do
			i[a] = b
		end
	end
	if k then
		for _, v in ipairs(k) do
			v.Parent = i
		end
	end
	return i
end

local function tw(o, t, p, e, d)
	local q = s.ts:Create(o, TweenInfo.new(t, e or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out), p)
	q:Play()
	return q
end

local function cl(v, a, b)
	return math.clamp(v, a, b)
end

local function cx(t, sgn, f)
	local c = sgn:Connect(f)
	if t then
		t[#t + 1] = c
	end
	return c
end

-- Modern dark theme with purple accent
rs.th = {
	bg = Color3.fromRGB(15, 15, 17),
	panel = Color3.fromRGB(20, 20, 23),
	panel2 = Color3.fromRGB(25, 25, 28),
	header = Color3.fromRGB(28, 28, 31),
	accent = Color3.fromRGB(186, 143, 255),
	accentDim = Color3.fromRGB(150, 108, 236),
	txt = Color3.fromRGB(240, 240, 245),
	txtDim = Color3.fromRGB(155, 155, 165),
	txtDisabled = Color3.fromRGB(100, 100, 110),
	border = Color3.fromRGB(40, 40, 45),
	success = Color3.fromRGB(80, 200, 120),
	warning = Color3.fromRGB(255, 180, 60)
}

rs.el = {}

function rs.reg(k, f)
	rs.el[k] = f
end

local function row(p, h)
	return n("Frame", {
		Parent = p,
		Size = UDim2.new(1, 0, 0, h or 36),
		BackgroundTransparency = 1
	})
end

-- Enhanced Toggle (matches reference checkboxes)
rs.el.tog = function(sc, txt, def, cb)
	local r = row(sc.f, 32)
	local container = n("Frame", {
		Parent = r,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = rs.th.panel2,
		BorderSizePixel = 0
	})
	n("UICorner", { Parent = container, CornerRadius = UDim.new(0, 4) })
	
	local btn = n("TextButton", {
		Parent = container,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false
	})
	
	local label = n("TextLabel", {
		Parent = btn,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = txt or "Toggle",
		TextColor3 = rs.th.txt,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local check = n("Frame", {
		Parent = btn,
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -26, 0.5, -8),
		BackgroundColor3 = rs.th.bg,
		BorderSizePixel = 0
	})
	n("UICorner", { Parent = check, CornerRadius = UDim.new(0, 3) })
	n("UIStroke", { Parent = check, Color = rs.th.border, Thickness = 1 })
	
	local checkmark = n("TextLabel", {
		Parent = check,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "✓",
		TextColor3 = rs.th.txt,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextTransparency = 1
	})
	
	local v = def and true or false
	
	local function set(x, nb)
		v = x and true or false
		if v then
			tw(check, 0.15, { BackgroundColor3 = rs.th.accent })
			tw(checkmark, 0.15, { TextTransparency = 0 })
		else
			tw(check, 0.15, { BackgroundColor3 = rs.th.bg })
			tw(checkmark, 0.15, { TextTransparency = 1 })
		end
		if not nb and cb then
			cb(v)
		end
	end
	
	local function hov(x)
		if x then
			tw(container, 0.12, { BackgroundColor3 = rs.th.header })
		else
			tw(container, 0.12, { BackgroundColor3 = rs.th.panel2 })
		end
	end
	
	set(v, true)
	
	cx(sc.w.cx, btn.MouseEnter, function() hov(true) end)
	cx(sc.w.cx, btn.MouseLeave, function() hov(false) end)
	cx(sc.w.cx, btn.MouseButton1Click, function() set(not v) end)
	
	return {
		b = btn,
		Set = function(_, x) set(x, true) end,
		Get = function() return v end
	}
end

-- Enhanced Dropdown
rs.el.dd = function(sc, txt, opts, def, cb)
	local r = n("Frame", {
		Parent = sc.f,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		ClipsDescendants = true
	})
	
	local h = n("TextButton", {
		Parent = r,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = rs.th.panel2,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0
	})
	n("UICorner", { Parent = h, CornerRadius = UDim.new(0, 4) })
	
	local l = n("TextLabel", {
		Parent = h,
		Size = UDim2.new(0.4, -10, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = txt or "Dropdown",
		TextColor3 = rs.th.txt,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local v = n("TextLabel", {
		Parent = h,
		Size = UDim2.new(0.6, -40, 1, 0),
		Position = UDim2.new(0.4, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = def or "",
		TextColor3 = rs.th.txtDim,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right
	})
	
	local arr = n("TextLabel", {
		Parent = h,
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -24, 0, 0),
		BackgroundTransparency = 1,
		Text = "▼",
		TextColor3 = rs.th.txtDim,
		Font = Enum.Font.Gotham,
		TextSize = 8
	})
	
	local list = n("Frame", {
		Parent = r,
		Position = UDim2.new(0, 0, 0, 34),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = rs.th.panel,
		BorderSizePixel = 0,
		ClipsDescendants = true
	})
	n("UICorner", { Parent = list, CornerRadius = UDim.new(0, 4) })
	n("UIStroke", { Parent = list, Color = rs.th.border, Thickness = 1 })
	n("UIListLayout", { Parent = list, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", {
		Parent = list,
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4)
	})
	
	local o = false
	local sel = def
	
	local function fit()
		local c = 0
		for _, ch in ipairs(list:GetChildren()) do
			if ch:IsA("TextButton") then c = c + 1 end
		end
		return c == 0 and 0 or (c * 28 + (c - 1) * 2 + 8)
	end
	
	local function open(x)
		o = x
		local h2 = x and fit() or 0
		tw(list, 0.15, { Size = UDim2.new(1, 0, 0, h2) })
		tw(r, 0.15, { Size = UDim2.new(1, 0, 0, 32 + h2) })
		arr.Text = x and "▲" or "▼"
	end
	
	local function addopt(t2)
		local b2 = n("TextButton", {
			Parent = list,
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = rs.th.panel2,
			Text = t2,
			TextColor3 = rs.th.txt,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			AutoButtonColor = false,
			BorderSizePixel = 0
		})
		n("UICorner", { Parent = b2, CornerRadius = UDim.new(0, 3) })
		
		cx(sc.w.cx, b2.MouseEnter, function()
			tw(b2, 0.1, { BackgroundColor3 = rs.th.header })
		end)
		cx(sc.w.cx, b2.MouseLeave, function()
			tw(b2, 0.1, { BackgroundColor3 = rs.th.panel2 })
		end)
		cx(sc.w.cx, b2.MouseButton1Click, function()
			sel = t2
			v.Text = t2
			v.TextColor3 = rs.th.txt
			open(false)
			if cb then cb(t2) end
		end)
	end
	
	local function setopts(t3)
		for _, ch in ipairs(list:GetChildren()) do
			if ch:IsA("TextButton") then ch:Destroy() end
		end
		for _, it in ipairs(t3 or {}) do
			addopt(it)
		end
	end
	
	setopts(opts or {})
	if def then
		v.Text = def
		v.TextColor3 = rs.th.txt
	end
	
	cx(sc.w.cx, h.MouseButton1Click, function() open(not o) end)
	
	return {
		b = h,
		Set = function(_, t4)
			sel = t4
			v.Text = t4 or ""
			v.TextColor3 = t4 and rs.th.txt or rs.th.txtDim
		end,
		Get = function() return sel end,
		Options = function(_, t5)
			setopts(t5)
			if o then open(true) end
		end
	}
end

-- Enhanced Slider
rs.el.slider = function(sc, txt, min, max, def, cb)
	local r = row(sc.f, 50)
	
	local container = n("Frame", {
		Parent = r,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = rs.th.panel2,
		BorderSizePixel = 0
	})
	n("UICorner", { Parent = container, CornerRadius = UDim.new(0, 4) })
	
	local label = n("TextLabel", {
		Parent = container,
		Size = UDim2.new(0.5, -10, 0, 20),
		Position = UDim2.new(0, 12, 0, 8),
		BackgroundTransparency = 1,
		Text = txt or "Slider",
		TextColor3 = rs.th.txt,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local valueLabel = n("TextLabel", {
		Parent = container,
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(1, -52, 0, 8),
		BackgroundTransparency = 1,
		Text = tostring(def or min),
		TextColor3 = rs.th.txtDim,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right
	})
	
	local track = n("Frame", {
		Parent = container,
		Size = UDim2.new(1, -24, 0, 4),
		Position = UDim2.new(0, 12, 1, -16),
		BackgroundColor3 = rs.th.bg,
		BorderSizePixel = 0
	})
	n("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })
	
	local fill = n("Frame", {
		Parent = track,
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = rs.th.accent,
		BorderSizePixel = 0
	})
	n("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })
	
	local thumb = n("Frame", {
		Parent = track,
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(0, -6, 0.5, -6),
		BackgroundColor3 = rs.th.txt,
		BorderSizePixel = 0
	})
	n("UICorner", { Parent = thumb, CornerRadius = UDim.new(1, 0) })
	
	min = min or 0
	max = max or 100
	local v = def or min
	
	local function set(val, nb)
		v = cl(val, min, max)
		local pct = (v - min) / (max - min)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		thumb.Position = UDim2.new(pct, -6, 0.5, -6)
		valueLabel.Text = tostring(math.floor(v))
		if not nb and cb then cb(v) end
	end
	
	local dragging = false
	
	local function update(input)
		local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
		pos = cl(pos, 0, 1)
		set(min + (max - min) * pos)
	end
	
	cx(sc.w.cx, track.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			update(input)
		end
	end)
	
	cx(sc.w.cx, s.ui.InputChanged, function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
	
	cx(sc.w.cx, s.ui.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	set(v, true)
	
	return {
		Set = function(_, val) set(val, true) end,
		Get = function() return v end
	}
end

-- Enhanced Button
rs.el.btn = function(sc, txt, cb)
	local r = row(sc.f, 32)
	local b = n("TextButton", {
		Parent = r,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = rs.th.accent,
		Text = txt or "Button",
		TextColor3 = rs.th.txt,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		AutoButtonColor = false,
		BorderSizePixel = 0
	})
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })
	
	local function hov(x)
		if x then
			tw(b, 0.12, { BackgroundColor3 = rs.th.accentDim })
		else
			tw(b, 0.12, { BackgroundColor3 = rs.th.accent })
		end
	end
	
	cx(sc.w.cx, b.MouseEnter, function() hov(true) end)
	cx(sc.w.cx, b.MouseLeave, function() hov(false) end)
	cx(sc.w.cx, b.MouseButton1Click, function()
		if cb then cb() end
	end)
	
	return {
		b = b,
		Set = function(_, t) b.Text = t end
	}
end

-- Main window creation
function rs.new(o)
	o = o or {}
	local w = { cx = {}, tabs = {} }
	
	local root = (gethui and gethui()) or s.cg
	local sg = n("ScreenGui", {
		Parent = root,
		Name = "ModernUI",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	
	w.sg = sg
	
	local sz = o.size or Vector2.new(880, 580)
	local main = n("Frame", {
		Parent = sg,
		Name = "Main",
		Size = UDim2.new(0, sz.X, 0, sz.Y),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = rs.th.bg,
		BorderSizePixel = 0,
		ClipsDescendants = true
	})
	n("UICorner", { Parent = main, CornerRadius = UDim.new(0, 8) })
	n("UIStroke", { Parent = main, Color = rs.th.border, Thickness = 1 })
	
	-- Top bar
	local topBar = n("Frame", {
		Parent = main,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = rs.th.panel,
		BorderSizePixel = 0
	})
	n("UICorner", { Parent = topBar, CornerRadius = UDim.new(0, 8) })
	
	local topBarBottom = n("Frame", {
		Parent = topBar,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 1, -8),
		BackgroundColor3 = rs.th.panel,
		BorderSizePixel = 0
	})
	
	local divider = n("Frame", {
		Parent = topBar,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = rs.th.border,
		BorderSizePixel = 0
	})
	
	local title = n("TextLabel", {
		Parent = topBar,
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Text = o.name or "FATALITY",
		TextColor3 = rs.th.txt,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local subtitle = n("TextLabel", {
		Parent = topBar,
		Size = UDim2.new(0, 200, 0, 14),
		Position = UDim2.new(1, -220, 0, 8),
		BackgroundTransparency = 1,
		Text = "NoHyper",
		TextColor3 = rs.th.txtDim,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right
	})
	
	local expiry = n("TextLabel", {
		Parent = topBar,
		Size = UDim2.new(0, 200, 0, 14),
		Position = UDim2.new(1, -220, 0, 24),
		BackgroundTransparency = 1,
		Text = "expires: 16 days",
		TextColor3 = rs.th.txtDim,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right
	})
	
	-- Tab container
	local tabContainer = n("Frame", {
		Parent = main,
		Position = UDim2.new(0, 0, 0, 52),
		Size = UDim2.new(0, 160, 1, -52),
		BackgroundColor3 = rs.th.panel,
		BorderSizePixel = 0
	})
	
	local tabDivider = n("Frame", {
		Parent = tabContainer,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = rs.th.border,
		BorderSizePixel = 0
	})
	
	local tabList = n("ScrollingFrame", {
		Parent = tabContainer,
		Size = UDim2.new(1, -1, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	n("UIListLayout", {
		Parent = tabList,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	n("UIPadding", {
		Parent = tabList,
		PaddingTop = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8)
	})
	
	-- Content area
	local content = n("Frame", {
		Parent = main,
		Position = UDim2.new(0, 160, 0, 52),
		Size = UDim2.new(1, -160, 1, -52),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	
	local pages = n("Frame", {
		Parent = content,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	})
	
	local pl = n("UIPageLayout", {
		Parent = pages,
		TweenTime = 0.2,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out,
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	pl.ScrollWheelInputEnabled = false
	
	function w:Tab(nm, icon)
		local t = { w = w }
		
		local tabBtn = n("TextButton", {
			Parent = tabList,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = rs.th.panel2,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0
		})
		n("UICorner", { Parent = tabBtn, CornerRadius = UDim.new(0, 4) })
		
		local tabLabel = n("TextLabel", {
			Parent = tabBtn,
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Text = nm or "Tab",
			TextColor3 = rs.th.txtDim,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local pg = n("ScrollingFrame", {
			Parent = pages,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = rs.th.border
		})
		pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
		n("UIPadding", {
			Parent = pg,
			PaddingTop = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16)
		})
		
		local wrap = n("Frame", {
			Parent = pg,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1
		})
		n("UIListLayout", {
			Parent = wrap,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 16),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		
		local cols = {}
		for i = 1, 3 do
			local cf = n("Frame", {
				Parent = wrap,
				Size = UDim2.new(0.33, -11, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1
			})
			local cl = n("UIListLayout", {
				Parent = cf,
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
			cols[#cols + 1] = { f = cf, ll = cl }
		end
		
		local function pick()
			local m = math.huge
			local idx = 1
			for i, c in ipairs(cols) do
				local h2 = c.ll.AbsoluteContentSize.Y
				if h2 < m then
					m = h2
					idx = i
				end
			end
			return cols[idx]
		end
		
		local a = false
		local function act(x)
			a = x
			if x then
				tabLabel.TextColor3 = rs.th.txt
				tw(tabBtn, 0.15, { BackgroundColor3 = rs.th.header })
			else
				tabLabel.TextColor3 = rs.th.txtDim
				tw(tabBtn, 0.15, { BackgroundColor3 = rs.th.panel2 })
			end
		end
		
		cx(w.cx, tabBtn.MouseEnter, function()
			if not a then
				tw(tabBtn, 0.12, { BackgroundColor3 = rs.th.header })
			end
		end)
		
		cx(w.cx, tabBtn.MouseLeave, function()
			if not a then
				tw(tabBtn, 0.12, { BackgroundColor3 = rs.th.panel2 })
			end
		end)
		
		cx(w.cx, tabBtn.MouseButton1Click, function()
			pl:JumpTo(pg)
			for _, t2 in ipairs(w.tabs) do
				if t2.act then t2.act(false) end
			end
			act(true)
		end)
		
		t.act = act
		t.pg = pg
		t.cols = cols
		
		function t:Sec(tt)
			local sc2 = { w = w, f = nil }
			local c = pick()
			
			local fr = n("Frame", {
				Parent = c.f,
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = rs.th.panel,
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0
			})
