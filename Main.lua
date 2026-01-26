
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

local function n(class, props, children)
	local inst = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	if children then
		for _, ch in ipairs(children) do
			ch.Parent = inst
		end
	end
	return inst
end

local function tw(obj, t, props, style, dir)
	local tween = s.ts:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

local function cl(v, a, b)
	if v < a then
		return a
	end
	if v > b then
		return b
	end
	return v
end

local function cx(list, signal, fn)
	local con = signal:Connect(fn)
	if list then
		list[#list + 1] = con
	end
	return con
end

local wf, rf, iff, ifo, mf = writefile, readfile, isfile, isfolder, makefolder
local gca = getcustomasset or getsynasset or GetCustomAsset
local asset_dir = "RoSense/assets"

local function fsok()
	return wf and iff and ifo and mf
end

local function mkd()
	if not fsok() then
		return
	end
	if not ifo("RoSense") then
		mf("RoSense")
	end
	if not ifo(asset_dir) then
		mf(asset_dir)
	end
end

local function httpget(url)
	local ok, res
	if g and g.HttpGet then
		ok, res = pcall(function()
			return g:HttpGet(url)
		end)
		if ok and res and #res > 0 then
			return res
		end
	end
	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if req then
		ok, res = pcall(function()
			return req({ Url = url, Method = "GET" })
		end)
		if ok and res then
			local body = res.Body or res.body or res
			if type(body) == "string" then
				return body
			end
		end
	end
	return nil
end

local function sanitize(name)
	local v = tostring(name or ""):gsub("[^%w]", "")
	if v == "" then
		return tostring(math.random(1000, 9999))
	end
	return v:sub(1, 24)
end

local function asset_url(name, url)
	if not url or url == "" then
		return nil
	end
	if not fsok() or not gca then
		return url
	end
	mkd()
	local path = asset_dir .. "/" .. name
	local need = not iff(path)
	if not need then
		local ok, data = pcall(rf, path)
		if not ok or type(data) ~= "string" or #data < 16 then
			need = true
		end
	end
	if need then
		local data = httpget(url)
		if data then
			wf(path, data)
		end
	end
	if iff(path) then
		local ok, res = pcall(gca, path)
		if ok then
			return res
		end
	end
	return url
end

local function icon_asset(key, url)
	if not url or url == "" then
		return nil
	end
	local nm = "icon_" .. sanitize(key) .. ".png"
	return asset_url(nm, url)
end

rs.th = {
	bg = Color3.fromRGB(12, 12, 14),
	panel = Color3.fromRGB(18, 18, 22),
	panel2 = Color3.fromRGB(22, 22, 27),
	panel3 = Color3.fromRGB(28, 28, 34),
	stroke = Color3.fromRGB(44, 44, 52),
	stroke2 = Color3.fromRGB(60, 60, 70),
	acc = Color3.fromRGB(197, 140, 255),
	acc2 = Color3.fromRGB(220, 160, 255),
	txt = Color3.fromRGB(235, 235, 240),
	sub = Color3.fromRGB(170, 170, 180),
	muted = Color3.fromRGB(120, 120, 130)
}

rs.assets = {}
rs.logo = "https://files.catbox.moe/xvikgr.png"
rs.iconAssets = {
	main = "https://files.catbox.moe/4fymry.png",
	config = "https://files.catbox.moe/x810qe.png",
	player = "https://files.catbox.moe/4fymry.png",
	misc = "https://files.catbox.moe/vqtuj6.png",
	fps = "https://files.catbox.moe/dpbo1s.png",
	ping = "https://files.catbox.moe/r4u0xe.png",
	aimbot = "https://files.catbox.moe/m49w6o.png",
	visuals = "https://files.catbox.moe/ip8cim.png",
	check = "https://files.catbox.moe/oktka6.png"
}
rs.statsIcons = {
	stats_fps = "https://files.catbox.moe/dpbo1s.png",
	stats_ping = "https://files.catbox.moe/r4u0xe.png",
	stats_player = "https://files.catbox.moe/q0v8yr.png"
}

local function tohex(c)
	return string.format("%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function fromhex(sx)
	local s2 = sx:gsub("#", "")
	if #s2 ~= 6 then
		return nil
	end
	local r = tonumber(s2:sub(1, 2), 16)
	local g2 = tonumber(s2:sub(3, 4), 16)
	local b = tonumber(s2:sub(5, 6), 16)
	if not r or not g2 or not b then
		return nil
	end
	return Color3.fromRGB(r, g2, b)
end

local function drag(frame, handle, list)
	local dragging = false
	local startPos
	local startInput
	cx(list, handle.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startPos = frame.Position
			startInput = i.Position
		end
	end)
	cx(list, s.ui.InputChanged, function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local dx = i.Position.X - startInput.X
			local dy = i.Position.Y - startInput.Y
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
		end
	end)
	cx(list, s.ui.InputEnded, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local function fmt_num(v)
	if math.floor(v) == v then
		return tostring(v)
	end
	return string.format("%.2f", v)
end

rs.el = {}

local function row(parent, height)
	return n("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1 })
end

rs.el.btn = function(sc, text, cb)
	local r = row(sc.f, 26)
	local b = n("TextButton", {
		Parent = r,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = rs.th.panel3,
		Text = text or "Button",
		TextColor3 = rs.th.sub,
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		AutoButtonColor = false
	})
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 5) })
	local st = n("UIStroke", { Parent = b, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
	local function hov(x)
		if x then
			tw(b, 0.12, { BackgroundColor3 = rs.th.panel2 })
			tw(st, 0.12, { Color = rs.th.acc, Transparency = 0.2 })
			b.TextColor3 = rs.th.acc
		else
			tw(b, 0.12, { BackgroundColor3 = rs.th.panel3 })
			tw(st, 0.12, { Color = rs.th.stroke, Transparency = 0.4 })
			b.TextColor3 = rs.th.sub
		end
	end
	hov(false)
	cx(sc.w.cx, b.MouseEnter, function()
		hov(true)
	end)
	cx(sc.w.cx, b.MouseLeave, function()
		hov(false)
	end)
	cx(sc.w.cx, b.MouseButton1Click, function()
		if cb then
			cb()
		end
	end)
	return { b = b, Set = function(_, t) b.Text = t end }
end

rs.el.tog = function(sc, text, def, cb)
	local r = row(sc.f, 26)
	local b = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = rs.th.panel3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 5) })
	n("UIStroke", { Parent = b, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })

	local l = n("TextLabel", {
		Parent = b,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = text or "Toggle",
		TextColor3 = rs.th.txt,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local box = n("Frame", { Parent = b, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -20, 0.5, -7), BackgroundColor3 = rs.th.panel2 })
	n("UICorner", { Parent = box, CornerRadius = UDim.new(0, 4) })
	local bs = n("UIStroke", { Parent = box, Color = rs.th.stroke2, Thickness = 1, Transparency = 0.2 })
	local chk = n("ImageLabel", {
		Parent = box,
		Size = UDim2.new(0, 10, 0, 10),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = icon_asset("check", rs.iconAssets and rs.iconAssets.check) or "",
		ImageTransparency = 1,
		ImageColor3 = rs.th.acc
	})

	local v = def and true or false
	local function set(x, nb)
		v = x and true or false
		if v then
			tw(chk, 0.12, { ImageTransparency = 0 })
			tw(bs, 0.12, { Color = rs.th.acc, Transparency = 0 })
			box.BackgroundColor3 = rs.th.panel2
		else
			tw(chk, 0.12, { ImageTransparency = 1 })
			tw(bs, 0.12, { Color = rs.th.stroke2, Transparency = 0.2 })
			box.BackgroundColor3 = rs.th.panel2
		end
		if not nb and cb then
			cb(v)
		end
	end
	local function hov(x)
		if x then
			tw(b, 0.12, { BackgroundColor3 = rs.th.panel2 })
		else
			tw(b, 0.12, { BackgroundColor3 = rs.th.panel3 })
		end
	end
	hov(false)
	set(v, true)
	cx(sc.w.cx, b.MouseEnter, function()
		hov(true)
	end)
	cx(sc.w.cx, b.MouseLeave, function()
		hov(false)
	end)
	cx(sc.w.cx, b.MouseButton1Click, function()
		set(not v)
	end)
	return { b = b, Set = function(_, x) set(x, true) end, Get = function() return v end }
end

rs.el.box = function(sc, text, def, cb)
	local r = row(sc.f, 26)
	local l = n("TextLabel", {
		Parent = r,
		Size = UDim2.new(0.45, -6, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = text or "Textbox",
		TextColor3 = rs.th.txt,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local b = n("TextBox", {
		Parent = r,
		Size = UDim2.new(0.55, -12, 1, -8),
		Position = UDim2.new(0.45, 6, 0, 4),
		BackgroundColor3 = rs.th.panel2,
		TextColor3 = rs.th.txt,
		Text = def or "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		ClearTextOnFocus = false
	})
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })
	n("UIStroke", { Parent = b, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
	cx(sc.w.cx, b.FocusLost, function(enter)
		if cb then
			cb(b.Text, enter)
		end
	end)
	return { b = b, Set = function(_, x) b.Text = x end, Get = function() return b.Text end }
end

rs.el.sl = function(sc, text, min, max, def, cb)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
	local l = n("TextLabel", { Parent = r, Size = UDim2.new(1, -60, 0, 14), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = text or "Slider", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
	local v = n("TextLabel", { Parent = r, Size = UDim2.new(0, 60, 0, 14), Position = UDim2.new(1, -60, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right })
	local bar = n("Frame", { Parent = r, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 22), BackgroundColor3 = rs.th.panel3 })
	n("UICorner", { Parent = bar, CornerRadius = UDim.new(0, 3) })
	n("UIStroke", { Parent = bar, Color = rs.th.stroke, Thickness = 1, Transparency = 0.5 })
	local fill = n("Frame", { Parent = bar, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = rs.th.acc })
	n("UICorner", { Parent = fill, CornerRadius = UDim.new(0, 3) })
	local knob = n("Frame", { Parent = bar, Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = rs.th.acc })
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	n("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })
	n("UIStroke", { Parent = knob, Color = rs.th.panel2, Thickness = 1, Transparency = 0.2 })
	local dragging = false
	local mn = tonumber(min) or 0
	local mx = tonumber(max) or 100
	local cur = tonumber(def) or mn
	local function set(x, skip)
		cur = cl(x, mn, mx)
		local pct = (cur - mn) / (mx - mn)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		knob.Position = UDim2.new(pct, 0, 0.5, 0)
		v.Text = fmt_num(cur)
		if cb and not skip then
			cb(cur)
		end
	end
	set(cur, true)
	local function setFromInput(pos)
		local rel = (pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
		set(mn + (mx - mn) * cl(rel, 0, 1))
	end
	cx(sc.w.cx, bar.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			setFromInput(i.Position)
		end
	end)
	cx(sc.w.cx, bar.InputEnded, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	cx(sc.w.cx, s.ui.InputChanged, function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			setFromInput(i.Position)
		end
	end)
	return { b = r, Set = function(_, x) set(x, true) end, Get = function() return cur end }
end
local function make_option_button(conns, list, text, selected, onClick)
	local b2 = n("TextButton", {
		Parent = list,
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundColor3 = rs.th.panel3,
		Text = text,
		TextColor3 = rs.th.txt,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		AutoButtonColor = false
	})
	n("UICorner", { Parent = b2, CornerRadius = UDim.new(0, 4) })
	local s2 = n("UIStroke", { Parent = b2, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
	local function setSel(on)
		if on then
			tw(s2, 0.12, { Color = rs.th.acc, Transparency = 0.1 })
			tw(b2, 0.12, { BackgroundColor3 = rs.th.panel2 })
		else
			tw(s2, 0.12, { Color = rs.th.stroke, Transparency = 0.4 })
			tw(b2, 0.12, { BackgroundColor3 = rs.th.panel3 })
		end
	end
	setSel(selected)
	cx(conns, b2.MouseEnter, function()
		if not selected then
			tw(b2, 0.1, { BackgroundColor3 = rs.th.panel2 })
		end
	end)
	cx(conns, b2.MouseLeave, function()
		if not selected then
			tw(b2, 0.1, { BackgroundColor3 = rs.th.panel3 })
		end
	end)
	cx(conns, b2.MouseButton1Click, function()
		onClick()
	end)
	return b2, setSel
end

rs.el.dd = function(sc, text, opts, def, cb)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, ClipsDescendants = true })
	local h = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = rs.th.panel3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = h, CornerRadius = UDim.new(0, 5) })
	local hs = n("UIStroke", { Parent = h, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
	local l = n("TextLabel", { Parent = h, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text or "Dropdown", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
	local v = n("TextLabel", { Parent = h, Size = UDim2.new(0, 160, 1, 0), Position = UDim2.new(1, -190, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right })
	local arr = n("TextLabel", { Parent = h, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, Text = "v", TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 10 })
	local list = n("ScrollingFrame", {
		Parent = r,
		Position = UDim2.new(0, 0, 0, 26),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = rs.th.panel2,
		ClipsDescendants = true,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = rs.th.sub,
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	n("UICorner", { Parent = list, CornerRadius = UDim.new(0, 5) })
	n("UIStroke", { Parent = list, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
	n("UIListLayout", { Parent = list, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = list, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
	local open = false
	local sel
	local function fit()
		local c = 0
		for _, ch in ipairs(list:GetChildren()) do
			if ch:IsA("TextButton") then
				c = c + 1
			end
		end
		if c == 0 then
			return 0
		end
		return c * 22 + (c - 1) * 4 + 12
	end
	local function openList(x)
		open = x
		local h2 = x and math.min(fit(), 150) or 0
		tw(list, 0.2, { Size = UDim2.new(1, 0, 0, h2) })
		tw(r, 0.2, { Size = UDim2.new(1, 0, 0, 26 + h2) })
		arr.Text = x and "^" or "v"
		if x then
			tw(hs, 0.15, { Color = rs.th.acc, Transparency = 0.15 })
		else
			tw(hs, 0.15, { Color = rs.th.stroke, Transparency = 0.4 })
		end
	end
	local function addopt(t2)
		local btn, setSel = make_option_button(sc.w.cx, list, t2, sel == t2, function()
			sel = t2
			v.Text = t2
			v.TextColor3 = rs.th.acc
			openList(false)
			if cb then
				cb(t2)
			end
		end)
		if sel == t2 then
			setSel(true)
		end
	end
	local function setopts(t3)
		for _, ch in ipairs(list:GetChildren()) do
			if ch:IsA("TextButton") then
				ch:Destroy()
			end
		end
		for _, it in ipairs(t3 or {}) do
			addopt(it)
		end
		if sel then
			v.Text = sel
			v.TextColor3 = rs.th.acc
		else
			v.TextColor3 = rs.th.sub
		end
	end
	setopts(opts or {})
	if def then
		sel = def
		v.Text = def
		v.TextColor3 = rs.th.acc
	end
	local function hov(x)
		if x and not open then
			tw(h, 0.12, { BackgroundColor3 = rs.th.panel2 })
		elseif not open then
			tw(h, 0.12, { BackgroundColor3 = rs.th.panel3 })
		end
	end
	hov(false)
	cx(sc.w.cx, h.MouseEnter, function()
		hov(true)
	end)
	cx(sc.w.cx, h.MouseLeave, function()
		hov(false)
	end)
	cx(sc.w.cx, h.MouseButton1Click, function()
		openList(not open)
	end)
	return {
		b = h,
		Set = function(_, t4)
			sel = t4
			v.Text = t4 or ""
			v.TextColor3 = t4 and rs.th.acc or rs.th.sub
		end,
		Get = function()
			return sel
		end,
		Options = function(_, t5)
			setopts(t5)
			if open then
				openList(true)
			end
		end
	}
end

rs.el.mdd = function(sc, text, opts, def, cb)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, ClipsDescendants = true })
	local h = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = rs.th.panel3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = h, CornerRadius = UDim.new(0, 5) })
	local hs = n("UIStroke", { Parent = h, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
	local l = n("TextLabel", { Parent = h, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text or "Multi Dropdown", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
	local v = n("TextLabel", { Parent = h, Size = UDim2.new(0, 180, 1, 0), Position = UDim2.new(1, -210, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right })
	local arr = n("TextLabel", { Parent = h, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, Text = "v", TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 10 })
	local list = n("ScrollingFrame", {
		Parent = r,
		Position = UDim2.new(0, 0, 0, 26),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = rs.th.panel2,
		ClipsDescendants = true,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = rs.th.sub,
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	n("UICorner", { Parent = list, CornerRadius = UDim.new(0, 5) })
	n("UIStroke", { Parent = list, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
	n("UIListLayout", { Parent = list, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = list, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
	local open = false
	local selected = {}
	local function fit()
		local c = 0
		for _, ch in ipairs(list:GetChildren()) do
			if ch:IsA("TextButton") then
				c = c + 1
			end
		end
		if c == 0 then
			return 0
		end
		return c * 22 + (c - 1) * 4 + 12
	end
	local function buildLabel()
		local arr2 = {}
		for k, v2 in pairs(selected) do
			if v2 then
				arr2[#arr2 + 1] = k
			end
		end
		table.sort(arr2)
		if #arr2 == 0 then
			v.Text = ""
			v.TextColor3 = rs.th.sub
		else
			local joined = table.concat(arr2, ", ")
			if #joined > 24 then
				v.Text = #arr2 .. " selected"
			else
				v.Text = joined
			end
			v.TextColor3 = rs.th.acc
		end
		if cb then
			cb(arr2)
		end
	end
	local function openList(x)
		open = x
		local h2 = x and math.min(fit(), 160) or 0
		tw(list, 0.2, { Size = UDim2.new(1, 0, 0, h2) })
		tw(r, 0.2, { Size = UDim2.new(1, 0, 0, 26 + h2) })
		arr.Text = x and "^" or "v"
		if x then
			tw(hs, 0.15, { Color = rs.th.acc, Transparency = 0.15 })
		else
			tw(hs, 0.15, { Color = rs.th.stroke, Transparency = 0.4 })
		end
	end
	local function addopt(t2)
		local btn, setSel = make_option_button(sc.w.cx, list, t2, selected[t2], function()
			selected[t2] = not selected[t2]
			setSel(selected[t2])
			buildLabel()
		end)
		if selected[t2] then
			setSel(true)
		end
	end
	local function setopts(t3)
		for _, ch in ipairs(list:GetChildren()) do
			if ch:IsA("TextButton") then
				ch:Destroy()
			end
		end
		for _, it in ipairs(t3 or {}) do
			addopt(it)
		end
		buildLabel()
	end
	if def then
		for _, v2 in ipairs(def) do
			selected[v2] = true
		end
	end
	setopts(opts or {})
	local function hov(x)
		if x and not open then
			tw(h, 0.12, { BackgroundColor3 = rs.th.panel2 })
		elseif not open then
			tw(h, 0.12, { BackgroundColor3 = rs.th.panel3 })
		end
	end
	hov(false)
	cx(sc.w.cx, h.MouseEnter, function()
		hov(true)
	end)
	cx(sc.w.cx, h.MouseLeave, function()
		hov(false)
	end)
	cx(sc.w.cx, h.MouseButton1Click, function()
		openList(not open)
	end)
	return {
		b = h,
		Get = function()
			local out = {}
			for k, v2 in pairs(selected) do
				if v2 then
					out[#out + 1] = k
				end
			end
			table.sort(out)
			return out
		end,
		Set = function(_, arr)
			selected = {}
			for _, v2 in ipairs(arr or {}) do
				selected[v2] = true
			end
			setopts(opts or {})
		end,
		Options = function(_, t5)
			opts = t5
			setopts(t5)
			if open then
				openList(true)
			end
		end
	}
end
rs.el.cp = function(sc, text, def, cb)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, ClipsDescendants = true })
	local h = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = rs.th.panel3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = h, CornerRadius = UDim.new(0, 5) })
	local hs = n("UIStroke", { Parent = h, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
	local l = n("TextLabel", { Parent = h, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text or "Color", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
	local pv = n("Frame", { Parent = h, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0.5, -10), BackgroundColor3 = def or rs.th.acc })
	n("UICorner", { Parent = pv, CornerRadius = UDim.new(0, 4) })
	n("UIStroke", { Parent = pv, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })

	local pop = n("Frame", { Parent = r, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = rs.th.panel2, ClipsDescendants = true })
	n("UICorner", { Parent = pop, CornerRadius = UDim.new(0, 6) })
	n("UIStroke", { Parent = pop, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })

	local sat = n("Frame", { Parent = pop, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 150, 0, 100), BackgroundColor3 = Color3.new(1, 1, 1) })
	n("UICorner", { Parent = sat, CornerRadius = UDim.new(0, 4) })
	local satGrad = n("UIGradient", { Parent = sat, Rotation = 0, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 0, 0)) })
	local val = n("Frame", { Parent = sat, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0) })
	n("UICorner", { Parent = val, CornerRadius = UDim.new(0, 4) })
	n("UIGradient", { Parent = val, Rotation = 90, Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }) })
	local sp = n("Frame", { Parent = sat, Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = rs.th.txt })
	n("UICorner", { Parent = sp, CornerRadius = UDim.new(1, 0) })
	n("UIStroke", { Parent = sp, Color = rs.th.panel, Thickness = 1 })

	local hue = n("Frame", { Parent = pop, Position = UDim2.new(0, 170, 0, 10), Size = UDim2.new(0, 10, 0, 100), BackgroundColor3 = Color3.new(1, 1, 1) })
	n("UICorner", { Parent = hue, CornerRadius = UDim.new(0, 4) })
	n("UIGradient", {
		Parent = hue,
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
		})
	})
	local hp = n("Frame", { Parent = hue, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = rs.th.txt })
	local hx = n("TextBox", { Parent = pop, Size = UDim2.new(0, 90, 0, 22), Position = UDim2.new(0, 10, 0, 118), BackgroundColor3 = rs.th.panel3, Text = "", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 11, ClearTextOnFocus = false })
	n("UICorner", { Parent = hx, CornerRadius = UDim.new(0, 4) })
	n("UIStroke", { Parent = hx, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })

	local open = false
	local h2, s2, v2 = Color3.toHSV(def or rs.th.acc)
	local function upd(nb)
		local col = Color3.fromHSV(h2, s2, v2)
		satGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h2, 1, 1))
		sp.Position = UDim2.new(s2, -4, 1 - v2, -4)
		hp.Position = UDim2.new(0, 0, h2, -1)
		pv.BackgroundColor3 = col
		hx.Text = tohex(col)
		if not nb and cb then
			cb(col)
		end
	end
	upd(true)
	local function setsv(pos)
		local ax = (pos.X - sat.AbsolutePosition.X) / sat.AbsoluteSize.X
		local ay = (pos.Y - sat.AbsolutePosition.Y) / sat.AbsoluteSize.Y
		s2 = cl(ax, 0, 1)
		v2 = 1 - cl(ay, 0, 1)
		upd()
	end
	local function seth(pos)
		local ay = (pos.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y
		h2 = cl(ay, 0, 1)
		upd()
	end
	local ds = false
	local dh = false
	cx(sc.w.cx, sat.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			ds = true
			setsv(i.Position)
		end
	end)
	cx(sc.w.cx, hue.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dh = true
			seth(i.Position)
		end
	end)
	cx(sc.w.cx, s.ui.InputChanged, function(i)
		if ds and i.UserInputType == Enum.UserInputType.MouseMovement then
			setsv(i.Position)
		end
		if dh and i.UserInputType == Enum.UserInputType.MouseMovement then
			seth(i.Position)
		end
	end)
	cx(sc.w.cx, s.ui.InputEnded, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			ds = false
			dh = false
		end
	end)
	cx(sc.w.cx, hx.FocusLost, function()
		local c2 = fromhex(hx.Text)
		if c2 then
			h2, s2, v2 = Color3.toHSV(c2)
			upd()
		else
			upd(true)
		end
	end)
	local function hov(x)
		if x and not open then
			tw(h, 0.12, { BackgroundColor3 = rs.th.panel2 })
		elseif not open then
			tw(h, 0.12, { BackgroundColor3 = rs.th.panel3 })
		end
	end
	hov(false)
	local function openPop(x)
		open = x
		local ph = x and 150 or 0
		tw(pop, 0.2, { Size = UDim2.new(1, 0, 0, ph) })
		tw(r, 0.2, { Size = UDim2.new(1, 0, 0, 26 + ph) })
		if x then
			tw(hs, 0.15, { Color = rs.th.acc, Transparency = 0.15 })
		else
			tw(hs, 0.15, { Color = rs.th.stroke, Transparency = 0.4 })
		end
	end
	cx(sc.w.cx, h.MouseEnter, function()
		hov(true)
	end)
	cx(sc.w.cx, h.MouseLeave, function()
		hov(false)
	end)
	cx(sc.w.cx, h.MouseButton1Click, function()
		openPop(not open)
	end)
	return {
		b = h,
		Set = function(_, c2)
			h2, s2, v2 = Color3.toHSV(c2)
			upd()
		end,
		Get = function()
			return Color3.fromHSV(h2, s2, v2)
		end
	}
end
rs.el.list = function(sc, text, opt)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
	n("UIListLayout", { Parent = r, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	local l = n("TextLabel", { Parent = r, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = tostring(text or "List"):upper(), TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
	local box = n("Frame", { Parent = r, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
	n("UIListLayout", { Parent = box, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	opt = opt or {}
	local function additem(t2, cb)
		local it = n("Frame", { Parent = box, Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = rs.th.panel3 })
		n("UICorner", { Parent = it, CornerRadius = UDim.new(0, 4) })
		n("UIStroke", { Parent = it, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
		local tx = n("TextLabel", { Parent = it, Size = UDim2.new(1, -56, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = t2, TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
		local act = n("TextButton", { Parent = it, Size = UDim2.new(0, 22, 0, 18), Position = UDim2.new(1, -50, 0.5, -9), BackgroundColor3 = rs.th.panel2, Text = opt.btn or ">", TextColor3 = rs.th.txt, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false })
		n("UICorner", { Parent = act, CornerRadius = UDim.new(0, 4) })
		n("UIStroke", { Parent = act, Color = rs.th.acc, Thickness = 1, Transparency = 0.2 })
		local rm = n("TextButton", { Parent = it, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -24, 0.5, -9), BackgroundColor3 = rs.th.panel2, Text = "x", TextColor3 = rs.th.sub, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false })
		n("UICorner", { Parent = rm, CornerRadius = UDim.new(0, 4) })
		n("UIStroke", { Parent = rm, Color = rs.th.stroke2, Thickness = 1, Transparency = 0.4 })
		cx(sc.w.cx, act.MouseButton1Click, function()
			if opt.on then
				opt.on(t2)
			end
			if cb then
				cb(t2)
			end
		end)
		cx(sc.w.cx, rm.MouseButton1Click, function()
			it:Destroy()
			if opt.onr then
				opt.onr(t2)
			end
		end)
		return it
	end
	local lo = {}
	function lo:Add(t2, cb2)
		return additem(t2, cb2)
	end
	function lo:Clear()
		for _, ch in ipairs(box:GetChildren()) do
			if ch:IsA("Frame") then
				ch:Destroy()
			end
		end
	end
	function lo:Set(arr)
		lo:Clear()
		for _, v2 in ipairs(arr or {}) do
			additem(v2)
		end
	end
	return lo
end

local function mkstats(w, parent, radius, icons)
	local rr = radius and math.max(6, radius - 2) or 8
	local bar = n("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = rs.th.panel, ClipsDescendants = true })
	n("UICorner", { Parent = bar, CornerRadius = UDim.new(0, rr) })
	n("UIStroke", { Parent = bar, Color = rs.th.stroke, Thickness = 1, Transparency = 0.5 })
	n("UIListLayout", { Parent = bar, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = bar, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

	local function statItem(key, label, col)
		local it = n("Frame", { Parent = bar, Size = UDim2.new(0, 110, 1, 0), BackgroundTransparency = 1 })
		local short = key:gsub("^stats_", "")
		local iconSrc = (icons and (icons[key] or icons[short])) or (rs.statsIcons and (rs.statsIcons[key] or rs.statsIcons[short])) or (rs.iconAssets and (rs.iconAssets[key] or rs.iconAssets[short]))
		local icon = icon_asset(key, iconSrc)
		if icon then
			n("ImageLabel", { Parent = it, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundTransparency = 1, Image = icon, ImageColor3 = col, ScaleType = Enum.ScaleType.Fit })
		end
		return n("TextLabel", { Parent = it, Size = UDim2.new(1, -22, 1, 0), Position = UDim2.new(0, 22, 0, 0), BackgroundTransparency = 1, Text = label or "", TextColor3 = col, Font = Enum.Font.GothamSemibold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
	end

	local lf = statItem("stats_fps", "FPS --", Color3.fromRGB(139, 255, 149))
	local lp = statItem("stats_ping", "PING --", Color3.fromRGB(255, 101, 104))
	local lpl = statItem("stats_player", "PLAYERS --", Color3.fromRGB(138, 200, 255))
	local lu = tick()
	local fc = 0
	local function gping()
		local ok, v = pcall(function()
			local n2 = s.st:FindFirstChild("Network")
			local ssi = n2 and n2:FindFirstChild("ServerStatsItem")
			local p2 = ssi and (ssi:FindFirstChild("Data Ping") or ssi:FindFirstChild("Ping"))
			if p2 and p2.GetValue then
				return p2:GetValue()
			end
			if p2 and p2.GetValueString then
				local s3 = p2:GetValueString()
				local num = tonumber(s3 and s3:match("%d+"))
				return num
			end
			return nil
		end)
		if ok then
			return v
		end
		return nil
	end
	cx(w.cx, s.rs.RenderStepped, function()
		fc = fc + 1
		local now = tick()
		if now - lu >= 0.3 then
			local fps = math.floor(fc / (now - lu))
			local ping = gping()
			local pc = #s.pl:GetPlayers()
			lf.Text = "FPS " .. fps
			lp.Text = "PING " .. (ping and math.floor(ping) or "--")
			lpl.Text = "PLAYERS " .. pc
			fc = 0
			lu = now
		end
	end)
	return bar
end
function rs.new(o)
	o = o or {}
	local w = { cx = {}, tabs = {} }
	if o.th then
		for k, v in pairs(o.th) do
			rs.th[k] = v
		end
	end

	local root = (gethui and gethui()) or s.cg
	local sg = n("ScreenGui", { Parent = root, Name = "RoSense", IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
	if syn and syn.protect_gui then
		syn.protect_gui(sg)
	end
	w.sg = sg

	local nt = n("Frame", { Parent = sg, Name = "Notify", Size = UDim2.new(0, 320, 1, -20), Position = UDim2.new(1, -12, 0, 10), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, ZIndex = 70 })
	n("UIListLayout", { Parent = nt, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top })
	local ni = 0
	function w:Notify(tt, bd, tm)
		local icon = nil
		local tint = rs.th.acc
		if type(tt) == "table" then
			local d = tt
			tt = d.title or d[1] or "Notice"
			bd = d.text or d.body or d[2] or ""
			tm = d.time or d[3]
			icon = d.icon
			tint = d.color or tint
		end
		ni = ni + 1
		local fr = n("Frame", { Parent = nt, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = rs.th.panel, BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 51, LayoutOrder = ni })
		n("UICorner", { Parent = fr, CornerRadius = UDim.new(0, 6) })
		local st = n("UIStroke", { Parent = fr, Color = rs.th.stroke, Thickness = 1, Transparency = 1 })
		n("UIPadding", { Parent = fr, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
		n("UIListLayout", { Parent = fr, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
		local row = n("Frame", { Parent = fr, Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1 })
		if icon then
			local iconUrl = (type(icon) == "string" and rs.iconAssets and rs.iconAssets[icon:lower()]) or icon
			local id = icon_asset("notify", iconUrl)
			n("ImageLabel", { Parent = row, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 0, 0, -1), BackgroundTransparency = 1, Image = id or "", ImageColor3 = tint })
		end
		local tl = n("TextLabel", { Parent = row, Size = icon and UDim2.new(1, -22, 1, 0) or UDim2.new(1, 0, 1, 0), Position = icon and UDim2.new(0, 22, 0, 0) or UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = tt or "Notice", TextColor3 = rs.th.txt, Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1 })
		local bl = n("TextLabel", { Parent = fr, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = bd or "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, TextTransparency = 1 })
		local pb = n("Frame", { Parent = fr, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(1, 0, 1, -2), AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = tint, BackgroundTransparency = 1 })
		n("UICorner", { Parent = pb, CornerRadius = UDim.new(0, 2) })
		tw(fr, 0.2, { BackgroundTransparency = 0 })
		tw(st, 0.2, { Transparency = 0.5 })
		tw(tl, 0.2, { TextTransparency = 0 })
		tw(bl, 0.2, { TextTransparency = 0 })
		tw(pb, 0.2, { BackgroundTransparency = 0.2 })
		local d = tm or 3
		tw(pb, d, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
		task.delay(d, function()
			tw(fr, 0.2, { BackgroundTransparency = 1 })
			tw(st, 0.2, { Transparency = 1 })
			tw(tl, 0.2, { TextTransparency = 1 })
			tw(bl, 0.2, { TextTransparency = 1 })
			tw(pb, 0.2, { BackgroundTransparency = 1 })
			task.delay(0.25, function()
				if fr then
					fr:Destroy()
				end
			end)
		end)
		return fr
	end

	local lg = asset_url("logo.png", o.logo or rs.logo)
	if lg then
		rs.assets.logo = lg
	end

	local headerH = o.headerHeight or 48
	local statsH = (o.stats == false) and 0 or 30
	local cr = o.cr or 8
	local sz = o.size or Vector2.new(900, 580)
	local sx = typeof(sz) == "UDim2" and sz.X.Offset or sz.X
	local sy = typeof(sz) == "UDim2" and sz.Y.Offset or sz.Y
	local ms = typeof(sz) == "UDim2" and sz or UDim2.new(0, sx, 0, sy)

	local main = n("Frame", { Parent = sg, Name = "Main", Size = ms, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = rs.th.bg, ClipsDescendants = true })
	n("UICorner", { Parent = main, CornerRadius = UDim.new(0, cr) })
	n("UIStroke", { Parent = main, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })

	local body = n("Frame", { Parent = main, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ClipsDescendants = true })
	n("UICorner", { Parent = body, CornerRadius = UDim.new(0, cr) })

	local top = n("Frame", { Parent = body, Size = UDim2.new(1, 0, 0, headerH), BackgroundColor3 = rs.th.panel, Active = true })
	n("UICorner", { Parent = top, CornerRadius = UDim.new(0, cr) })
	n("UIStroke", { Parent = top, Color = rs.th.stroke, Thickness = 1, Transparency = 0.5 })
	local topLine = n("Frame", { Parent = top, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = rs.th.acc, BackgroundTransparency = 0.7 })

	local left = n("Frame", { Parent = top, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1 })
	n("UIListLayout", { Parent = left, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = left, PaddingLeft = UDim.new(0, 8) })

	n("ImageLabel", {
		Parent = left,
		Size = UDim2.new(0, 36, 0, 36),
		BackgroundTransparency = 1,
		Image = rs.assets.logo or "",
		ScaleType = Enum.ScaleType.Fit
	})
	n("TextLabel", {
		Parent = left,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = o.name or "RoSense",
		TextColor3 = rs.th.acc,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local right = n("Frame", { Parent = top, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0) })
	n("UIListLayout", { Parent = right, FillDirection = Enum.FillDirection.Vertical, VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 0) })
	if o.user then
		n("TextLabel", { Parent = right, Size = UDim2.new(0, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = o.user, TextColor3 = rs.th.txt, Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right })
	end
	if o.sub or o.expire then
		n("TextLabel", { Parent = right, Size = UDim2.new(0, 0, 0, 12), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = o.sub or o.expire, TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right })
	end

	local tlist = n("Frame", { Parent = top, BackgroundTransparency = 1 })
	n("UIListLayout", { Parent = tlist, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder })

	local function layoutTop()
		local lw = left.AbsoluteSize.X
		local rw = right.AbsoluteSize.X
		local pad = 12
		tlist.Position = UDim2.new(0, lw + pad, 0, 0)
		tlist.Size = UDim2.new(1, -(lw + rw + pad * 2), 1, 0)
	end
	layoutTop()
	cx(w.cx, left:GetPropertyChangedSignal("AbsoluteSize"), layoutTop)
	cx(w.cx, right:GetPropertyChangedSignal("AbsoluteSize"), layoutTop)
	cx(w.cx, top:GetPropertyChangedSignal("AbsoluteSize"), layoutTop)

	local pages = n("Frame", { Parent = body, Position = UDim2.new(0, 0, 0, headerH), Size = UDim2.new(1, 0, 1, -(headerH + statsH)), BackgroundTransparency = 1 })
	local pl = n("UIPageLayout", { Parent = pages, TweenTime = 0.2, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out, SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal })
	pl.ScrollWheelInputEnabled = false

	if o.stats ~= false then
		mkstats(w, n("Frame", { Parent = body, Position = UDim2.new(0, 0, 1, -statsH), Size = UDim2.new(1, 0, 0, statsH), BackgroundTransparency = 1 }), cr, o.statsIcons or rs.statsIcons)
	end

	local sc = n("UIScale", { Parent = main, Scale = 1 })
	local cam = workspace.CurrentCamera
	local function res()
		local v = cam and cam.ViewportSize or Vector2.new(800, 600)
		local s2 = math.min(1, math.min(v.X / (sx + 40), v.Y / (sy + 40)))
		sc.Scale = s2
	end
	res()
	if cam then
		cx(w.cx, cam:GetPropertyChangedSignal("ViewportSize"), res)
	else
		cx(w.cx, workspace:GetPropertyChangedSignal("CurrentCamera"), function()
			cam = workspace.CurrentCamera
			res()
			if cam then
				cx(w.cx, cam:GetPropertyChangedSignal("ViewportSize"), res)
			end
		end)
	end
	drag(main, top, w.cx)

	local vis = true
	local function setvis(x)
		vis = x
		if x then
			main.Visible = true
			sc.Scale = 0.98
			tw(sc, 0.2, { Scale = 1 })
		else
			tw(sc, 0.15, { Scale = 0.98 })
			task.delay(0.16, function()
				if not vis then
					main.Visible = false
				end
			end)
		end
	end
	cx(w.cx, s.ui.InputBegan, function(i, g2)
		if g2 then
			return
		end
		local k = o.key or Enum.KeyCode.RightShift
		if i.KeyCode == k then
			setvis(not vis)
		end
	end)

	function w:Tab(name, icon, cols)
		local t = { w = w }
		local b = n("TextButton", { Parent = tlist, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "", AutoButtonColor = false })
		local pill = n("Frame", { Parent = b, Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0.5, -14), BackgroundColor3 = rs.th.panel2, BackgroundTransparency = 1 })
		n("UICorner", { Parent = pill, CornerRadius = UDim.new(0, 6) })
		n("UIPadding", { Parent = pill, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
		local row = n("Frame", { Parent = pill, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
		n("UIListLayout", { Parent = row, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

		local ib = n("Frame", { Parent = row, Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1 })
		local im = nil
		local src = nil
		local key = (type(icon) == "string" and icon:lower()) or nil
		if type(icon) == "string" then
			src = (o.iconAssets and o.iconAssets[key]) or (rs.iconAssets and rs.iconAssets[key]) or (o.icons and o.icons[key]) or (rs.icons and rs.icons[key])
		end
		if not src and type(icon) == "string" and icon:match("^https?://") then
			src = icon
		end
		if src then
			local id = icon_asset("tab_" .. sanitize(icon), src)
			if id then
				im = n("ImageLabel", { Parent = ib, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = id, ImageColor3 = rs.th.sub, ScaleType = Enum.ScaleType.Fit })
			end
		end
		if not im then
			im = n("ImageLabel", { Parent = ib, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = "", ImageTransparency = 1 })
		end

		local tlb = n("TextLabel", { Parent = row, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = (name or "Tab"):upper(), TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
		local line = n("Frame", { Parent = b, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = rs.th.acc, BackgroundTransparency = 1 })
		n("UICorner", { Parent = line, CornerRadius = UDim.new(0, 1) })

		local pg = n("ScrollingFrame", { Parent = pages, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = rs.th.acc })
		pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
		n("UIPadding", { Parent = pg, PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0) })
		local outerPad = 12
		local wrap = n("Frame", { Parent = pg, Size = UDim2.new(1, -(outerPad * 2), 0, 0), Position = UDim2.new(0, outerPad, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
		n("UIListLayout", { Parent = wrap, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })
		local cc = cols or o.cols or 3
		local gap = 12
		local off = -((cc - 1) * gap) / cc
		local cols2 = {}
		for i = 1, cc do
			local cf = n("Frame", { Parent = wrap, Size = UDim2.new(1 / cc, off, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
			local cll = n("UIListLayout", { Parent = cf, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })
			cols2[#cols2 + 1] = { f = cf, ll = cll }
		end
		local function pick()
			local m = math.huge
			local idx = 1
			for i, c in ipairs(cols2) do
				local h2 = c.ll.AbsoluteContentSize.Y
				if h2 < m then
					m = h2
					idx = i
				end
			end
			return cols2[idx]
		end
		local active = false
		local function act(x)
			active = x
			if x then
				tlb.TextColor3 = rs.th.acc
				im.ImageColor3 = rs.th.acc
				tw(pill, 0.2, { BackgroundTransparency = 0.15 })
				tw(line, 0.2, { BackgroundTransparency = 0 })
			else
				tlb.TextColor3 = rs.th.sub
				im.ImageColor3 = rs.th.sub
				tw(pill, 0.2, { BackgroundTransparency = 1 })
				tw(line, 0.2, { BackgroundTransparency = 1 })
			end
		end
		cx(w.cx, b.MouseEnter, function()
			if not active then
				tlb.TextColor3 = rs.th.txt
				im.ImageColor3 = rs.th.txt
			end
		end)
		cx(w.cx, b.MouseLeave, function()
			if not active then
				tlb.TextColor3 = rs.th.sub
				im.ImageColor3 = rs.th.sub
			end
		end)
		cx(w.cx, b.MouseButton1Click, function()
			pl:JumpTo(pg)
			for _, t2 in ipairs(w.tabs) do
				if t2.act then
					t2.act(false)
				end
			end
			act(true)
		end)
		t.act = act
		t.pg = pg
		t.cols = cols2

		function t:Sec(title, ci)
			local sc2 = { w = w, f = nil }
			local c = cols2[ci] or pick()
			local fr = n("Frame", { Parent = c.f, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = rs.th.panel2, AutomaticSize = Enum.AutomaticSize.Y })
			n("UICorner", { Parent = fr, CornerRadius = UDim.new(0, 6) })
			n("UIStroke", { Parent = fr, Color = rs.th.stroke, Thickness = 1, Transparency = 0.4 })
			n("UIPadding", { Parent = fr, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
			n("UIListLayout", { Parent = fr, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
			if title and title ~= "" then
				n("TextLabel", { Parent = fr, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = tostring(title):upper(), TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
				n("Frame", { Parent = fr, Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = rs.th.stroke })
			end
			sc2.f = fr
			function sc2:Add(k, ...)
				local f = rs.el[k]
				if f then
					return f(sc2, ...)
				end
			end
			function sc2:Button(a1, b1)
				return rs.el.btn(sc2, a1, b1)
			end
			function sc2:Toggle(a1, b1, c1)
				return rs.el.tog(sc2, a1, b1, c1)
			end
			function sc2:Textbox(a1, b1, c1)
				return rs.el.box(sc2, a1, b1, c1)
			end
			function sc2:Dropdown(a1, b1, c1, d1)
				return rs.el.dd(sc2, a1, b1, c1, d1)
			end
			function sc2:MultiDropdown(a1, b1, c1, d1)
				return rs.el.mdd(sc2, a1, b1, c1, d1)
			end
			function sc2:Color(a1, b1, c1)
				return rs.el.cp(sc2, a1, b1, c1)
			end
			function sc2:Slider(a1, b1, c1, d1, e1)
				return rs.el.sl(sc2, a1, b1, c1, d1, e1)
			end
			function sc2:List(a1, b1)
				return rs.el.list(sc2, a1, b1)
			end
			return sc2
		end
		function t:Col(i)
			return cols2[i] and cols2[i].f or nil
		end
		w.tabs[#w.tabs + 1] = t
		if #w.tabs == 1 then
			act(true)
			pl:JumpTo(pg)
		end
		return t
	end

	function w:Destroy()
		for _, c in ipairs(w.cx) do
			pcall(function()
				c:Disconnect()
			end)
		end
		if w.sg then
			w.sg:Destroy()
		end
	end

	return w
end

return rs
