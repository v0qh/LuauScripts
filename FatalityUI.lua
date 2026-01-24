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
	local q = s.ts:Create(o, TweenInfo.new(t, e or Enum.EasingStyle.Sine, d or Enum.EasingDirection.Out), p)
	q:Play()
	return q
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

local function cx(t, sgn, f)
	local c = sgn:Connect(f)
	if t then
		t[#t + 1] = c
	end
	return c
end

local wf, rf, iff, ifo, mf = writefile, readfile, isfile, isfolder, makefolder
local gca = getcustomasset or getsynasset or GetCustomAsset
local ad = "RoSense/assets"

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
	if not ifo(ad) then
		mf(ad)
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

local function asset_url(name, url)
	if not fsok() or not gca then
		return nil
	end
	mkd()
	local p = ad .. "/" .. name
	if not iff(p) then
		local d = httpget(url)
		if d then
			wf(p, d)
		end
	end
	if iff(p) then
		local ok, r = pcall(gca, p)
		if ok then
			return r
		end
	end
	return nil
end

local function fn(s)
	local v = tostring(s or ""):gsub("[^%w]", "")
	if v == "" then
		return tostring(math.random(1000, 9999))
	end
	return v:sub(1, 24)
end

	rs.th = {
		bg = Color3.fromRGB(7, 7, 11),
		b2 = Color3.fromRGB(12, 10, 16),
		b3 = Color3.fromRGB(19, 17, 25),
		b4 = Color3.fromRGB(26, 22, 33),
		acc = Color3.fromRGB(197, 140, 255),
		acc2 = Color3.fromRGB(211, 124, 255),
		txt = Color3.fromRGB(230, 226, 238),
		sub = Color3.fromRGB(150, 144, 168),
		st = Color3.fromRGB(62, 55, 82),
		ln = Color3.fromRGB(33, 28, 39)
	}

rs.as = {}
rs.lu = "https://files.catbox.moe/5vlagq.png"
rs.iconAssets = {
	main = "https://cdn.jsdelivr.net/gh/encharm/Font-Awesome-SVG-PNG@master/black/png/32/home.png",
	config = "https://cdn.jsdelivr.net/gh/encharm/Font-Awesome-SVG-PNG@master/black/png/32/cogs.png",
	list = "https://cdn.jsdelivr.net/gh/encharm/Font-Awesome-SVG-PNG@master/black/png/32/list.png"
}
rs.ic = rs.ic or {}

local icm = setmetatable({}, { __mode = "k" })

local function ic(nm, pr, col)
	local c = col or rs.th.acc
	local f = n("Frame", { Parent = pr, Size = UDim2.new(0, 20, 0, 20), BackgroundTransparency = 1 })
	local pt = {}
	local function add(x)
		pt[#pt + 1] = x
		return x
	end
	local function stroke(x, th)
		return add(n("UIStroke", { Parent = x, Color = c, Thickness = th or 1.5 }))
	end
	
	if nm == "main" or nm == "fatality" then
		local base = add(n("Frame", { Parent = f, Size = UDim2.new(0, 14, 0, 10), Position = UDim2.new(0.5, -7, 1, -11), BackgroundColor3 = c }))
		n("UICorner", { Parent = base, CornerRadius = UDim.new(0, 2) })
		local roof = add(n("Frame", { Parent = f, Size = UDim2.new(0, 16, 0, 2), Position = UDim2.new(0.5, -8, 0, 5), BackgroundColor3 = c, Rotation = 45 }))
		local roof2 = add(n("Frame", { Parent = f, Size = UDim2.new(0, 16, 0, 2), Position = UDim2.new(0.5, -8, 0, 5), BackgroundColor3 = c, Rotation = -45 }))
		
	elseif nm == "config" or nm == "gear" then
		local center = n("Frame", { Parent = f, Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0.5, -4, 0.5, -4), BackgroundTransparency = 1 })
		stroke(center, 2)
		n("UICorner", { Parent = center, CornerRadius = UDim.new(1, 0) })
		
		for i = 0, 7 do
			local theta = math.rad(i * 45)
			local dist = 6
			local arm = add(n("Frame", {
				Parent = f,
				Size = UDim2.new(0, 3, 0, 5),
				Position = UDim2.new(0.5, math.cos(theta) * dist - 1.5, 0.5, math.sin(theta) * dist - 2.5),
				BackgroundColor3 = c
			}))
			n("UICorner", { Parent = arm, CornerRadius = UDim.new(0, 1) })
		end
		
	elseif nm == "list" or nm == "queue" then
		local y = 3
		for i = 1, 3 do
			local bar = add(n("Frame", { Parent = f, Size = UDim2.new(0, 14, 0, 3), Position = UDim2.new(0.5, -7, 0, y), BackgroundColor3 = c }))
			n("UICorner", { Parent = bar, CornerRadius = UDim.new(0, 1.5) })
			y = y + 6
		end
		
	elseif nm == "user" then
		local head = add(n("Frame", { Parent = f, Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0.5, -4, 0, 2), BackgroundColor3 = c }))
		n("UICorner", { Parent = head, CornerRadius = UDim.new(1, 0) })
		local body = add(n("Frame", { Parent = f, Size = UDim2.new(0, 14, 0, 8), Position = UDim2.new(0.5, -7, 1, -9), BackgroundColor3 = c }))
		n("UICorner", { Parent = body, CornerRadius = UDim.new(1, 0) })
		
	else
		local sq = n("Frame", { Parent = f, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0.5, -7, 0.5, -7), BackgroundTransparency = 1 })
		stroke(sq, 2)
		n("UICorner", { Parent = sq, CornerRadius = UDim.new(0, 3) })
	end
	
	icm[f] = pt
	return f
end

local function icc(f, col)
	local p = icm[f]
	if not p then
		return
	end
	for _, v in ipairs(p) do
		if v:IsA("UIStroke") then
			v.Color = col
		else
			v.BackgroundColor3 = col
		end
	end
end

local function tohex(c)
	return string.format("%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function fromhex(sx)
	local s2 = sx:gsub("#", "")
	if #s2 ~= 6 then
		return nil
	end
	local r = tonumber(s2:sub(1, 2), 16)
	local g = tonumber(s2:sub(3, 4), 16)
	local b2 = tonumber(s2:sub(5, 6), 16)
	if not r or not g or not b2 then
		return nil
	end
	return Color3.fromRGB(r, g, b2)
end

local function drag(fr, h, t)
	local d = false
	local sp = nil
	local mp = nil
	cx(t, h.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			d = true
			sp = fr.Position
			mp = i.Position
		end
	end)
	cx(t, s.ui.InputChanged, function(i)
		if d and i.UserInputType == Enum.UserInputType.MouseMovement then
			local dx = i.Position.X - mp.X
			local dy = i.Position.Y - mp.Y
			fr.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dx, sp.Y.Scale, sp.Y.Offset + dy)
		end
	end)
	cx(t, s.ui.InputEnded, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			d = false
		end
	end)
end

rs.el = {}

function rs.reg(k, f)
	rs.el[k] = f
end

local function row(p, h)
	return n("Frame", { Parent = p, Size = UDim2.new(1, 0, 0, h or 32), BackgroundTransparency = 1 })
end

rs.el.btn = function(sc, txt, cb)
	local r = row(sc.f, 30)
	local b = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = rs.th.b3, Text = txt or "Button", TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 13, AutoButtonColor = false })
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 6) })
	local st = n("UIStroke", { Parent = b, Color = rs.th.b4, Thickness = 1, Transparency = 0.6 })
	local function hov(x)
		if x then
			tw(b, 0.12, { BackgroundColor3 = rs.th.b4 })
			tw(st, 0.12, { Color = rs.th.acc, Transparency = 0.2 })
			b.TextColor3 = rs.th.acc
		else
			tw(b, 0.12, { BackgroundColor3 = rs.th.b3 })
			tw(st, 0.12, { Color = rs.th.b4, Transparency = 0.6 })
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

rs.el.tog = function(sc, txt, def, cb)
	local r = row(sc.f, 30)
	local b = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = rs.th.b3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 6) })
	n("UIStroke", { Parent = b, Color = rs.th.b4, Thickness = 1, Transparency = 0.6 })
	local l = n("TextLabel", { Parent = b, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = txt or "Toggle", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
	local box = n("Frame", { Parent = b, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -28, 0.5, -9), BackgroundColor3 = rs.th.b2 })
	n("UICorner", { Parent = box, CornerRadius = UDim.new(0, 4) })
	local bs = n("UIStroke", { Parent = box, Color = rs.th.st, Thickness = 1, Transparency = 0.2 })
	local dot = n("Frame", { Parent = box, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = rs.th.acc, BackgroundTransparency = 1 })
	n("UICorner", { Parent = dot, CornerRadius = UDim.new(1, 0) })
	local v = def and true or false
	local function set(x, nb)
		v = x and true or false
		if v then
			tw(dot, 0.12, { Size = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 0 })
			tw(box, 0.12, { BackgroundColor3 = rs.th.b4 })
			tw(bs, 0.12, { Color = rs.th.acc })
		else
			tw(dot, 0.12, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
			tw(box, 0.12, { BackgroundColor3 = rs.th.b2 })
			tw(bs, 0.12, { Color = rs.th.st })
		end
		if not nb and cb then
			cb(v)
		end
	end
	local function hov(x)
		if x then
			tw(b, 0.12, { BackgroundColor3 = rs.th.b4 })
		else
			tw(b, 0.12, { BackgroundColor3 = rs.th.b3 })
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

rs.el.box = function(sc, txt, def, cb)
	local r = row(sc.f, 30)
	local l = n("TextLabel", { Parent = r, Size = UDim2.new(0.45, -6, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = txt or "Textbox", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
	local b = n("TextBox", { Parent = r, Size = UDim2.new(0.55, -14, 1, -6), Position = UDim2.new(0.45, 6, 0, 3), BackgroundColor3 = rs.th.b4, TextColor3 = rs.th.txt, Text = def or "", Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false })
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 5) })
	n("UIStroke", { Parent = b, Color = rs.th.b3, Thickness = 1, Transparency = 0.4 })
	cx(sc.w.cx, b.FocusLost, function(enter)
		if cb then
			cb(b.Text, enter)
		end
	end)
	return { b = b, Set = function(_, x) b.Text = x end, Get = function() return b.Text end }
end

rs.el.sl = function(sc, txt, min, max, def, cb)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1 })
	local l = n("TextLabel", { Parent = r, Size = UDim2.new(1, -60, 0, 16), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = txt or "Slider", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
	local v = n("TextLabel", { Parent = r, Size = UDim2.new(0, 50, 0, 16), Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right })
	local bar = n("Frame", { Parent = r, Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 0, 24), BackgroundColor3 = rs.th.b3 })
	n("UICorner", { Parent = bar, CornerRadius = UDim.new(0, 4) })
	n("UIStroke", { Parent = bar, Color = rs.th.b4, Thickness = 1, Transparency = 0.6 })
	local fill = n("Frame", { Parent = bar, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = rs.th.acc })
	n("UICorner", { Parent = fill, CornerRadius = UDim.new(0, 4) })
	local knob = n("Frame", { Parent = bar, Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = rs.th.acc })
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	n("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })
	n("UIStroke", { Parent = knob, Color = rs.th.b4, Thickness = 1, Transparency = 0.4 })
	local dragging = false
	local mn = tonumber(min) or 0
	local mx = tonumber(max) or 100
	local cur = tonumber(def) or mn
	local function set(x, skip)
		cur = cl(x, mn, mx)
		local pct = (cur - mn) / (mx - mn)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		knob.Position = UDim2.new(pct, 0, 0.5, 0)
		v.Text = string.format("%.2f", cur)
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

rs.el.dd = function(sc, txt, opts, def, cb)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, ClipsDescendants = true })
	local h = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = rs.th.b3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = h, CornerRadius = UDim.new(0, 6) })
	local hs = n("UIStroke", { Parent = h, Color = rs.th.b4, Thickness = 1, Transparency = 0.6 })
	local l = n("TextLabel", { Parent = h, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = txt or "Dropdown", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
	local v = n("TextLabel", { Parent = h, Size = UDim2.new(0, 140, 1, 0), Position = UDim2.new(1, -160, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right })
	local arr = n("TextLabel", { Parent = h, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, Text = "v", TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 11 })
	local list = n("ScrollingFrame", { Parent = r, Position = UDim2.new(0, 0, 0, 32), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = rs.th.b2, ClipsDescendants = true, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 4, ScrollBarImageColor3 = rs.th.sub, AutomaticCanvasSize = Enum.AutomaticSize.Y })
	n("UICorner", { Parent = list, CornerRadius = UDim.new(0, 6) })
	n("UIStroke", { Parent = list, Color = rs.th.b4, Thickness = 1, Transparency = 0.6 })
	n("UIListLayout", { Parent = list, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = list, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
	local o = false
	local sel = nil
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
		return c * 28 + (c - 1) * 4 + 12
	end
	local function open(x)
		o = x
		local h2 = x and math.min(fit(), 160) or 0
		tw(list, 0.2, { Size = UDim2.new(1, 0, 0, h2) })
		tw(r, 0.2, { Size = UDim2.new(1, 0, 0, 32 + h2) })
		arr.Text = x and "^" or "v"
		if x then
			tw(hs, 0.15, { Color = rs.th.acc, Transparency = 0.2 })
		else
			tw(hs, 0.15, { Color = rs.th.b4, Transparency = 0.6 })
		end
	end
	local function addopt(t2)
		local b2 = n("TextButton", { Parent = list, Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = rs.th.b3, Text = t2, TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 12, AutoButtonColor = false })
		n("UICorner", { Parent = b2, CornerRadius = UDim.new(0, 5) })
		local s2 = n("UIStroke", { Parent = b2, Color = rs.th.b4, Thickness = 1, Transparency = 0.6 })
		cx(sc.w.cx, b2.MouseEnter, function()
			tw(b2, 0.12, { BackgroundColor3 = rs.th.b4 })
			tw(s2, 0.12, { Color = rs.th.acc, Transparency = 0.2 })
		end)
		cx(sc.w.cx, b2.MouseLeave, function()
			tw(b2, 0.12, { BackgroundColor3 = rs.th.b3 })
			tw(s2, 0.12, { Color = rs.th.b4, Transparency = 0.6 })
		end)
		cx(sc.w.cx, b2.MouseButton1Click, function()
			sel = t2
			v.Text = t2
			v.TextColor3 = rs.th.acc
			open(false)
			if cb then
				cb(t2)
			end
		end)
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
		if x and not o then
			tw(h, 0.12, { BackgroundColor3 = rs.th.b4 })
		elseif not o then
			tw(h, 0.12, { BackgroundColor3 = rs.th.b3 })
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
		open(not o)
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
			if o then
				open(true)
			end
		end
	}
end

rs.el.cp = function(sc, txt, def, cb)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, ClipsDescendants = true })
	local h = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = rs.th.b3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = h, CornerRadius = UDim.new(0, 6) })
	local hs = n("UIStroke", { Parent = h, Color = rs.th.b4, Thickness = 1, Transparency = 0.6 })
	local l = n("TextLabel", { Parent = h, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = txt or "Color", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
	local pv = n("Frame", { Parent = h, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0.5, -10), BackgroundColor3 = def or rs.th.acc })
	n("UICorner", { Parent = pv, CornerRadius = UDim.new(0, 5) })
	n("UIStroke", { Parent = pv, Color = rs.th.b4, Thickness = 1, Transparency = 0.4 })
	local pop = n("Frame", { Parent = r, Position = UDim2.new(0, 0, 0, 34), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = rs.th.b2, ClipsDescendants = true })
	n("UICorner", { Parent = pop, CornerRadius = UDim.new(0, 8) })
	n("UIStroke", { Parent = pop, Color = rs.th.b4, Thickness = 1, Transparency = 0.6 })
	local sat = n("Frame", { Parent = pop, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 150, 0, 110), BackgroundColor3 = Color3.new(1, 1, 1) })
	n("UICorner", { Parent = sat, CornerRadius = UDim.new(0, 5) })
	local sg = n("UIGradient", { Parent = sat, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 0, 1)) })
	local val = n("Frame", { Parent = sat, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0) })
	n("UICorner", { Parent = val, CornerRadius = UDim.new(0, 6) })
	n("UIGradient", { Parent = val, Rotation = 90, Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}) })
	local sp = n("Frame", { Parent = sat, Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = rs.th.txt })
	n("UICorner", { Parent = sp, CornerRadius = UDim.new(1, 0) })
	n("UIStroke", { Parent = sp, Color = rs.th.bg, Thickness = 1 })
	local hue = n("Frame", { Parent = pop, Position = UDim2.new(0, 170, 0, 10), Size = UDim2.new(0, 10, 0, 110), BackgroundColor3 = Color3.new(1, 1, 1) })
	n("UICorner", { Parent = hue, CornerRadius = UDim.new(0, 5) })
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
	local hx = n("TextBox", { Parent = pop, Size = UDim2.new(0, 80, 0, 22), Position = UDim2.new(0, 10, 0, 126), BackgroundColor3 = rs.th.b4, Text = "", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 11, ClearTextOnFocus = false })
	n("UICorner", { Parent = hx, CornerRadius = UDim.new(0, 5) })
	n("UIStroke", { Parent = hx, Color = rs.th.b3, Thickness = 1, Transparency = 0.4 })
	local o = false
	local h2, s2, v2 = Color3.toHSV(def or rs.th.acc)
	local function upd(nb)
		local col = Color3.fromHSV(h2, s2, v2)
		sg.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h2, 1, 1))
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
		if x and not o then
			tw(h, 0.12, { BackgroundColor3 = rs.th.b4 })
		elseif not o then
			tw(h, 0.12, { BackgroundColor3 = rs.th.b3 })
		end
	end
	hov(false)
	local function open(x)
		o = x
		local ph = x and 160 or 0
		tw(pop, 0.2, { Size = UDim2.new(1, 0, 0, ph) })
		tw(r, 0.2, { Size = UDim2.new(1, 0, 0, 32 + ph) })
		if x then
			tw(hs, 0.15, { Color = rs.th.acc, Transparency = 0.2 })
		else
			tw(hs, 0.15, { Color = rs.th.b4, Transparency = 0.6 })
		end
	end
	cx(sc.w.cx, h.MouseEnter, function()
		hov(true)
	end)
	cx(sc.w.cx, h.MouseLeave, function()
		hov(false)
	end)
	cx(sc.w.cx, h.MouseButton1Click, function()
		open(not o)
	end)
	return { b = h, Set = function(_, c2) h2, s2, v2 = Color3.toHSV(c2); upd() end, Get = function() return Color3.fromHSV(h2, s2, v2) end }
end

rs.el.list = function(sc, txt, opt)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
	n("UIListLayout", { Parent = r, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	local l = n("TextLabel", { Parent = r, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = txt or "List", TextColor3 = rs.th.txt, Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
	local box = n("Frame", { Parent = r, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
	local ll = n("UIListLayout", { Parent = box, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	opt = opt or {}
	local function additem(t2, cb)
		local it = n("Frame", { Parent = box, Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = rs.th.b3 })
		n("UICorner", { Parent = it, CornerRadius = UDim.new(0, 5) })
		n("UIStroke", { Parent = it, Color = rs.th.b4, Thickness = 1, Transparency = 0.6 })
		local tx = n("TextLabel", { Parent = it, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = t2, TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
		local act = n("TextButton", { Parent = it, Size = UDim2.new(0, 24, 0, 20), Position = UDim2.new(1, -54, 0.5, -10), BackgroundColor3 = rs.th.b4, Text = opt.btn or ">", TextColor3 = rs.th.txt, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false })
		n("UICorner", { Parent = act, CornerRadius = UDim.new(0, 4) })
		local as = n("UIStroke", { Parent = act, Color = rs.th.acc, Thickness = 1, Transparency = 0.2 })
		local rm = n("TextButton", { Parent = it, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -26, 0.5, -10), BackgroundColor3 = rs.th.b4, Text = "x", TextColor3 = rs.th.sub, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false })
		n("UICorner", { Parent = rm, CornerRadius = UDim.new(0, 4) })
		local rs2 = n("UIStroke", { Parent = rm, Color = rs.th.st, Thickness = 1, Transparency = 0.4 })
		cx(sc.w.cx, act.MouseEnter, function()
			tw(act, 0.12, { BackgroundColor3 = rs.th.b3 })
			tw(as, 0.12, { Transparency = 0 })
		end)
		cx(sc.w.cx, act.MouseLeave, function()
			tw(act, 0.12, { BackgroundColor3 = rs.th.b4 })
			tw(as, 0.12, { Transparency = 0.2 })
		end)
		cx(sc.w.cx, rm.MouseEnter, function()
			tw(rm, 0.12, { BackgroundColor3 = rs.th.b3 })
			tw(rs2, 0.12, { Color = rs.th.acc2, Transparency = 0.2 })
		end)
		cx(sc.w.cx, rm.MouseLeave, function()
			tw(rm, 0.12, { BackgroundColor3 = rs.th.b4 })
			tw(rs2, 0.12, { Color = rs.th.st, Transparency = 0.4 })
		end)
		cx(sc.w.cx, act.MouseButton1Click, function()
			if cb then
				cb(t2)
			end
			if opt.on then
				opt.on(t2)
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
	function lo:Add(t2, cb)
		return additem(t2, cb)
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

local function mkstats(w, p, cr)
	local rr = cr and math.max(6, cr - 2) or 10
	local bar = n("Frame", { Parent = p, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = rs.th.b2, ClipsDescendants = true })
	n("UICorner", { Parent = bar, CornerRadius = UDim.new(0, rr) })
	n("UIStroke", { Parent = bar, Color = rs.th.ln, Thickness = 1, Transparency = 0.5 })
	n("UIGradient", { Parent = bar, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, rs.th.b2), ColorSequenceKeypoint.new(1, rs.th.b3) }) })
	n("UIListLayout", { Parent = bar, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = bar, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
	local function lab()
		return n("TextLabel", { Parent = bar, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
	end
	local lf = lab()
	local lp = lab()
	local lm = lab()
	local lpl = lab()
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
		if now - lu >= 0.25 then
			local fps = math.floor(fc / (now - lu))
			local ping = gping()
			local mem = collectgarbage("count") / 1024
			local pc = #s.pl:GetPlayers()
			lf.Text = "FPS " .. fps
			lp.Text = "PING " .. (ping and math.floor(ping) or "--")
			lm.Text = "MEM " .. string.format("%.1f", mem) .. " MB"
			lpl.Text = "PLR " .. pc
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
		ni = ni + 1
		local fr = n("Frame", { Parent = nt, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = rs.th.b2, BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 51, LayoutOrder = ni })
		n("UICorner", { Parent = fr, CornerRadius = UDim.new(0, 6) })
		local st = n("UIStroke", { Parent = fr, Color = rs.th.ln, Thickness = 1, Transparency = 1 })
		n("UIGradient", {
			Parent = fr,
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, rs.th.b3),
				ColorSequenceKeypoint.new(1, rs.th.b2)
			})
		})
		local scn = n("UIScale", { Parent = fr, Scale = 0.96 })
		n("UIPadding", { Parent = fr, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
		n("UIListLayout", { Parent = fr, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
		local tl = n("TextLabel", { Parent = fr, Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = tt or "Notice", TextColor3 = rs.th.txt, Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1 })
		local bl = n("TextLabel", { Parent = fr, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = bd or "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, TextTransparency = 1 })
		local pb = n("Frame", { Parent = fr, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(1, 0, 1, -2), AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = rs.th.acc, BackgroundTransparency = 1 })
		n("UICorner", { Parent = pb, CornerRadius = UDim.new(0, 2) })
		tw(scn, 0.2, { Scale = 1 })
		tw(fr, 0.2, { BackgroundTransparency = 0 })
		tw(st, 0.2, { Transparency = 0.5 })
		tw(tl, 0.2, { TextTransparency = 0 })
		tw(bl, 0.2, { TextTransparency = 0 })
		tw(pb, 0.2, { BackgroundTransparency = 0.2 })
		local d = tm or 3
		tw(pb, d, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
		task.delay(d, function()
			tw(scn, 0.2, { Scale = 0.96 })
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
	local lg = asset_url("logo.png", o.logo or rs.lu)
	if lg then
		rs.as.logo = lg
	end
	local th = o.thh or 64
	local sh = 34
	local cr = o.cr or 12
	local sz = o.size or Vector2.new(860, 560)
	local sx = typeof(sz) == "UDim2" and sz.X.Offset or sz.X
	local sy = typeof(sz) == "UDim2" and sz.Y.Offset or sz.Y
	local ms = typeof(sz) == "UDim2" and sz or UDim2.new(0, sx, 0, sy)
	local main = n("Frame", { Parent = sg, Name = "Main", Size = ms, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = rs.th.bg, ClipsDescendants = true })
	n("UICorner", { Parent = main, CornerRadius = UDim.new(0, cr) })
	n("UIGradient", { Parent = main, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, rs.th.bg), ColorSequenceKeypoint.new(1, rs.th.b3) }) })
	local body = n("Frame", { Parent = main, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ClipsDescendants = true })
	n("UICorner", { Parent = body, CornerRadius = UDim.new(0, cr) })
	local bodyGlow = n("Frame", { Parent = body, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
	n("UIGradient", {
		Parent = bodyGlow,
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 16)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 16, 24))
		})
	})
	local top = n("Frame", { Parent = body, Size = UDim2.new(1, 0, 0, th), BackgroundColor3 = rs.th.b2, Active = true })
	n("UIGradient", { Parent = top, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, rs.th.b2), ColorSequenceKeypoint.new(1, rs.th.b3) }), Rotation = 90 })
	n("UICorner", { Parent = top, CornerRadius = UDim.new(0, cr) })

	local left = n("Frame", { Parent = top, Size = UDim2.new(0, 170, 1, 0), BackgroundTransparency = 1 })
	n("UIListLayout", { Parent = left, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = left, PaddingLeft = UDim.new(0, 1) })

	local lgm = n("ImageLabel", {
		Parent = left,
		Size = UDim2.new(0, 72, 0, 40),
		BackgroundTransparency = 1,
		Image = rs.as.logo or "",
		ScaleType = Enum.ScaleType.Fit
	})
	local ttl = n("TextLabel", {
		Parent = left,
		Size = UDim2.new(0, 120, 0, 28),
		BackgroundTransparency = 1,
		Text = o.name or "RoSense",
		TextColor3 = Color3.fromRGB(225, 168, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local tlist = n("Frame", { Parent = top, Size = UDim2.new(1, -170, 1, 0), Position = UDim2.new(0, 170, 0, 0), BackgroundTransparency = 1 })
	n("UIListLayout", { Parent = tlist, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = tlist, PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 12) })

	local headerDivider = n("Frame", { Parent = body, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, th), BackgroundColor3 = Color3.fromRGB(225, 168, 255), ZIndex = 2 })
	local pages = n("Frame", { Parent = body, Position = UDim2.new(0, 0, 0, th + 1), Size = UDim2.new(1, 0, 1, -(th + 1 + sh)), BackgroundTransparency = 1 })
	local pl = n("UIPageLayout", { Parent = pages, TweenTime = 0.2, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out, SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal })
	pl.ScrollWheelInputEnabled = false
	mkstats(w, n("Frame", { Parent = body, Position = UDim2.new(0, 0, 1, -sh), Size = UDim2.new(1, 0, 0, sh), BackgroundTransparency = 1 }), cr)
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
	function w:Tab(nm, icon, cols)
		local t = { w = w }
	local b = n("TextButton", { Parent = tlist, Size = UDim2.new(0, 110, 0, 40), BackgroundTransparency = 1, Text = "", AutoButtonColor = false })
	b.AutomaticSize = Enum.AutomaticSize.X
	
	local bg = n("Frame", { Parent = b, Size = UDim2.new(1, 0, 1, -4), Position = UDim2.new(0, 0, 0, 2), BackgroundColor3 = rs.th.b4, BackgroundTransparency = 1 })
	n("UICorner", { Parent = bg, CornerRadius = UDim.new(0, 8) })
	n("UIPadding", { Parent = b, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 14) })
	
	local ib = n("Frame", { Parent = b, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 10, 0.5, -10), BackgroundTransparency = 1 })
	
	local icn = icon or "main"
	local im = nil
	local ico = nil
	local src = nil
	local key = (type(icn) == "string" and icn:lower()) or nil
	
	if type(icn) == "string" then
		src = (o.iconAssets and o.iconAssets[key]) or (rs.iconAssets and rs.iconAssets[key]) or (o.icons and o.icons[key]) or (rs.icons and rs.icons[key])
	end
	if not src and type(icn) == "string" and icn:match("^https?://") then
		src = icn
	end
	
	if src then
		local id = asset_url("tab_" .. fn(icn) .. ".png", src)
		if id then
			im = n("ImageLabel", { Parent = ib, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = id, ImageColor3 = rs.th.sub, ScaleType = Enum.ScaleType.Fit })
		end
	end
	
	if not im then
		ico = ic(icn, ib, rs.th.sub)
	end
	
	local tlb = n("TextLabel", { Parent = b, Size = UDim2.new(1, -34, 1, 0), Position = UDim2.new(0, 34, 0, 0), BackgroundTransparency = 1, Text = nm or "Tab", TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
	
	local line = n("Frame", { Parent = b, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -4), BackgroundColor3 = rs.th.acc, BackgroundTransparency = 1 })
	n("UICorner", { Parent = line, CornerRadius = UDim.new(0, 1) })
		local pg = n("ScrollingFrame", { Parent = pages, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = rs.th.acc })
		pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
		n("UIPadding", { Parent = pg, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) })
		local wrap = n("Frame", { Parent = pg, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
		n("UIListLayout", { Parent = wrap, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })
		local cc = cols or o.cols or 3
		local gap = 12
		local off = -((cc - 1) * gap) / cc
		local cols2 = {}
		for i = 1, cc do
			local cf = n("Frame", { Parent = wrap, Size = UDim2.new(1 / cc, off, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
			local cl = n("UIListLayout", { Parent = cf, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })
			cols2[#cols2 + 1] = { f = cf, ll = cl }
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
		local a = false
		local function act(x)
			a = x
			if x then
				tlb.TextColor3 = rs.th.txt
				if im then
					im.ImageColor3 = rs.th.acc
				else
					icc(ico, rs.th.acc)
				end
				tw(bg, 0.15, { BackgroundTransparency = 0.2 })
				tw(line, 0.2, { BackgroundTransparency = 0 })
			else
				tlb.TextColor3 = rs.th.sub
				if im then
					im.ImageColor3 = rs.th.sub
				else
					icc(ico, rs.th.sub)
				end
				tw(bg, 0.15, { BackgroundTransparency = 1 })
				tw(line, 0.2, { BackgroundTransparency = 1 })
			end
		end
		cx(w.cx, b.MouseEnter, function()
			if not a then
				tlb.TextColor3 = rs.th.txt
				if im then
					im.ImageColor3 = rs.th.txt
				else
					icc(ico, rs.th.txt)
				end
				tw(bg, 0.12, { BackgroundTransparency = 0.6 })
			end
		end)
		cx(w.cx, b.MouseLeave, function()
			if not a then
				tlb.TextColor3 = rs.th.sub
				if im then
					im.ImageColor3 = rs.th.sub
				else
					icc(ico, rs.th.sub)
				end
				tw(bg, 0.12, { BackgroundTransparency = 1 })
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
		function t:Sec(tt, ci)
			local sc2 = { w = w, f = nil }
			local c = cols2[ci] or pick()
			local fr = n("Frame", { Parent = c.f, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = rs.th.b2, AutomaticSize = Enum.AutomaticSize.Y })
			n("UICorner", { Parent = fr, CornerRadius = UDim.new(0, 6) })
			n("UIStroke", { Parent = fr, Color = rs.th.ln, Thickness = 1, Transparency = 0.5 })
			n("UIGradient", { Parent = fr, Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, rs.th.b2), ColorSequenceKeypoint.new(1, rs.th.b3) }) })
			n("UIPadding", { Parent = fr, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
			n("UIListLayout", { Parent = fr, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
			if tt and tt ~= "" then
				n("TextLabel", { Parent = fr, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = tt, TextColor3 = rs.th.txt, Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
				n("Frame", { Parent = fr, Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = rs.th.ln })
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
