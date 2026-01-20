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

local function tw(o, t, p)
	local q = s.ts:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
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

local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64d(data)
	data = data:gsub("%s", "")
	return (data:gsub(".", function(x)
		if x == "=" then
			return ""
		end
		local r = ""
		local f = b:find(x) - 1
		for i = 6, 1, -1 do
			r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
		end
		return r
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
		if #x ~= 8 then
			return ""
		end
		local c = 0
		for i = 1, 8 do
			c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
		end
		return string.char(c)
	end))
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

local function asset(name, data)
	if not fsok() or not gca then
		return nil
	end
	mkd()
	local p = ad .. "/" .. name
	if not iff(p) then
		wf(p, b64d(data))
	end
	local ok, r = pcall(gca, p)
	if ok then
		return r
	end
	return nil
end

rs.th = {
	bg = Color3.fromRGB(16, 10, 24),
	b2 = Color3.fromRGB(22, 14, 32),
	b3 = Color3.fromRGB(30, 18, 44),
	acc = Color3.fromRGB(150, 90, 255),
	acc2 = Color3.fromRGB(190, 130, 255),
	txt = Color3.fromRGB(235, 230, 255),
	sub = Color3.fromRGB(160, 150, 190),
	st = Color3.fromRGB(90, 80, 110)
}

rs.as = {}
local b64n = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAC3ElEQVR42hWT51YiQRCF+0lYGYIIDLhwUBEUEARRgqiMzj6JORDMEgwg5gDGY/YB9+sffWi6qm7de6tG3NzcWBYWFtI7Ozvq5uam9fHx0Xx/f5/++voKr6ysRI+OjrqIm8rlsvP09DTGPVIqlSZub2/Hz87OBgRFg5eXl+7X19f8/Px8hl9bu932HxwcuDc2NhxPT0/e1dVVU61WM1cqlRlObHt7O7e4uJg6OTkJi7W1NZ2g6fz8vPft7S1+fX2tfXx8+C4uLuydTkchcYwm2d3dXdP7+7uTmJl8N8Vx8n2iUCj4QHXc3d256axDP7G8vBxDmg2Kqa2tLRvJfUjUeRunkZMcD8XZ5+dno5QwRZfc/v5+P0kKWud+f39HPj8/J3hzoHWoXq9r39/fCYC6oW8FNA1QmHtaoN+PYVGSfNJEjBrCvMzS0lIeed2SycvLSxIzYzDrg34MoBDFEeT8ExiXfHh4sEBLg3IGFlm6einupUjSNxDXOC7AM8VicRg2Zorje3t704IOw1dXV3Yc9+G41J39+fkJkWTg3dNsNv9Io6vVqobuHEUq7FQkjiDVJKCbImkKehlZvL6+bsXQIMEIBrtarVYeID/e6JIhTMblHgDUT15CgDyIB6Hj42ML5jgB8rIsUek2/jiRqDDOOF1lbBbD8+yIghwVuWOC7g6QrSDrkhbzDwI02Wg0coeHh3aWyEwnP6P28z+A9hRgSXxKEDMK3E+BmJMLQqEdemHYWDGwhw4B3vJ4ovAmc2ZgZgYgQdNp2JkEwQwbpqJ3ADZBtOYBnSXJxsgMHBc5k4wywDb6WbYU9wisJsjvFnTspciI3jSoRj4mD8XyfxCdc4CHADdyl6vcI7eUk4SNSiOLwG0N3SoFMQwaZSoDoEd5C7GJOgsj11xupcq9nymNof8v++GR7KUEBS0BPqIRTFFg4aCbi0Qd4zS6afjgg74NH6aJyxGO8tUmGLHhPw5o+WGwlq84AAAAAElFTkSuQmCC"
rs.as.noise = asset("noise.png", b64n)

local function ic(nm, pr, col)
	local c = col or rs.th.acc
	local f = n("Frame", { Parent = pr, Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1 })
	if nm == "home" then
		local base = n("Frame", { Parent = f, Size = UDim2.new(0, 12, 0, 8), Position = UDim2.new(0.5, -6, 0.5, 2), BackgroundColor3 = c })
		n("UICorner", { Parent = base, CornerRadius = UDim.new(0, 2) })
		local roof = n("Frame", { Parent = f, Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0.5, -5, 0.5, -7), BackgroundColor3 = c, Rotation = 45 })
		n("UICorner", { Parent = roof, CornerRadius = UDim.new(0, 2) })
		local door = n("Frame", { Parent = f, Size = UDim2.new(0, 3, 0, 5), Position = UDim2.new(0.5, -1, 0.5, 3), BackgroundColor3 = rs.th.b3 })
		n("UICorner", { Parent = door, CornerRadius = UDim.new(0, 1) })
	elseif nm == "gear" then
		local ring = n("Frame", { Parent = f, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0.5, -6, 0.5, -6), BackgroundTransparency = 1 })
		n("UIStroke", { Parent = ring, Color = c, Thickness = 2 })
		n("UICorner", { Parent = ring, CornerRadius = UDim.new(1, 0) })
		n("Frame", { Parent = f, Size = UDim2.new(0, 2, 0, 6), Position = UDim2.new(0.5, -1, 0, 1), BackgroundColor3 = c })
		n("Frame", { Parent = f, Size = UDim2.new(0, 2, 0, 6), Position = UDim2.new(0.5, -1, 1, -7), BackgroundColor3 = c })
		n("Frame", { Parent = f, Size = UDim2.new(0, 6, 0, 2), Position = UDim2.new(0, 1, 0.5, -1), BackgroundColor3 = c })
		n("Frame", { Parent = f, Size = UDim2.new(0, 6, 0, 2), Position = UDim2.new(1, -7, 0.5, -1), BackgroundColor3 = c })
	elseif nm == "list" then
		local y = 2
		for _ = 1, 3 do
			n("Frame", { Parent = f, Size = UDim2.new(0, 14, 0, 2), Position = UDim2.new(0.5, -7, 0, y), BackgroundColor3 = c })
			y = y + 6
		end
	elseif nm == "user" then
		local head = n("Frame", { Parent = f, Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0.5, -4, 0, 1), BackgroundColor3 = c })
		n("UICorner", { Parent = head, CornerRadius = UDim.new(1, 0) })
		local body = n("Frame", { Parent = f, Size = UDim2.new(0, 12, 0, 7), Position = UDim2.new(0.5, -6, 1, -8), BackgroundColor3 = c })
		n("UICorner", { Parent = body, CornerRadius = UDim.new(1, 0) })
	else
		local sq = n("Frame", { Parent = f, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0.5, -6, 0.5, -6), BackgroundTransparency = 1 })
		n("UIStroke", { Parent = sq, Color = c, Thickness = 2 })
		n("UICorner", { Parent = sq, CornerRadius = UDim.new(0, 2) })
	end
	return f
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
	return n("Frame", { Parent = p, Size = UDim2.new(1, 0, 0, h or 36), BackgroundTransparency = 1 })
end

rs.el.btn = function(sc, txt, cb)
	local r = row(sc.f, 34)
	local b = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = rs.th.acc, Text = txt or "Button", TextColor3 = rs.th.txt, Font = Enum.Font.GothamSemibold, TextSize = 14, AutoButtonColor = false })
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 8) })
	n("UIStroke", { Parent = b, Color = rs.th.acc2, Thickness = 1, Transparency = 0.4 })
	cx(sc.w.cx, b.MouseButton1Click, function()
		if cb then
			cb()
		end
	end)
	return { b = b, Set = function(_, t) b.Text = t end }
end

rs.el.tog = function(sc, txt, def, cb)
	local r = row(sc.f, 34)
	local b = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = rs.th.b3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 8) })
	n("UIStroke", { Parent = b, Color = rs.th.b2, Thickness = 1, Transparency = 0.4 })
	local l = n("TextLabel", { Parent = b, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = txt or "Toggle", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
	local t = n("Frame", { Parent = b, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = rs.th.st })
	n("UICorner", { Parent = t, CornerRadius = UDim.new(1, 0) })
	local k = n("Frame", { Parent = t, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = rs.th.txt })
	n("UICorner", { Parent = k, CornerRadius = UDim.new(1, 0) })
	local v = def and true or false
	local function set(x, nb)
		v = x and true or false
		if v then
			tw(t, 0.15, { BackgroundColor3 = rs.th.acc })
			tw(k, 0.15, { Position = UDim2.new(1, -18, 0.5, -8) })
		else
			tw(t, 0.15, { BackgroundColor3 = rs.th.st })
			tw(k, 0.15, { Position = UDim2.new(0, 2, 0.5, -8) })
		end
		if not nb and cb then
			cb(v)
		end
	end
	set(v, true)
	cx(sc.w.cx, b.MouseButton1Click, function()
		set(not v)
	end)
	return { b = b, Set = function(_, x) set(x, true) end, Get = function() return v end }
end

rs.el.box = function(sc, txt, def, cb)
	local r = row(sc.f, 34)
	local l = n("TextLabel", { Parent = r, Size = UDim2.new(0.5, -8, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = txt or "Textbox", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
	local b = n("TextBox", { Parent = r, Size = UDim2.new(0.5, -12, 1, -8), Position = UDim2.new(0.5, 4, 0, 4), BackgroundColor3 = rs.th.b3, TextColor3 = rs.th.txt, Text = def or "", Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false })
	n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 6) })
	n("UIStroke", { Parent = b, Color = rs.th.b2, Thickness = 1, Transparency = 0.4 })
	cx(sc.w.cx, b.FocusLost, function(enter)
		if cb then
			cb(b.Text, enter)
		end
	end)
	return { b = b, Set = function(_, x) b.Text = x end, Get = function() return b.Text end }
end

rs.el.dd = function(sc, txt, opts, def, cb)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, ClipsDescendants = true })
	local h = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = rs.th.b3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = h, CornerRadius = UDim.new(0, 8) })
	n("UIStroke", { Parent = h, Color = rs.th.b2, Thickness = 1, Transparency = 0.4 })
	local l = n("TextLabel", { Parent = h, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = txt or "Dropdown", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
	local v = n("TextLabel", { Parent = h, Size = UDim2.new(0, 120, 1, 0), Position = UDim2.new(1, -140, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right })
	local arr = n("TextLabel", { Parent = h, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, Text = "v", TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 12 })
	local list = n("Frame", { Parent = r, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = rs.th.b2, ClipsDescendants = true })
	n("UICorner", { Parent = list, CornerRadius = UDim.new(0, 8) })
	local lp = n("UIListLayout", { Parent = list, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
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
		local h2 = x and fit() or 0
		tw(list, 0.2, { Size = UDim2.new(1, 0, 0, h2) })
		tw(r, 0.2, { Size = UDim2.new(1, 0, 0, 36 + h2) })
		arr.Text = x and "^" or "v"
	end
	local function addopt(t2)
		local b2 = n("TextButton", { Parent = list, Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = rs.th.b3, Text = t2, TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 13, AutoButtonColor = false })
		n("UICorner", { Parent = b2, CornerRadius = UDim.new(0, 6) })
		cx(sc.w.cx, b2.MouseButton1Click, function()
			sel = t2
			v.Text = t2
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
		end
	end
	setopts(opts or {})
	if def then
		sel = def
		v.Text = def
	end
	cx(sc.w.cx, h.MouseButton1Click, function()
		open(not o)
	end)
	return {
		b = h,
		Set = function(_, t4)
			sel = t4
			v.Text = t4 or ""
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
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, ClipsDescendants = true })
	local h = n("TextButton", { Parent = r, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = rs.th.b3, Text = "", AutoButtonColor = false })
	n("UICorner", { Parent = h, CornerRadius = UDim.new(0, 8) })
	n("UIStroke", { Parent = h, Color = rs.th.b2, Thickness = 1, Transparency = 0.4 })
	local l = n("TextLabel", { Parent = h, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = txt or "Color", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
	local pv = n("Frame", { Parent = h, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -34, 0.5, -12), BackgroundColor3 = def or rs.th.acc })
	n("UICorner", { Parent = pv, CornerRadius = UDim.new(0, 6) })
	local pop = n("Frame", { Parent = r, Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = rs.th.b2, ClipsDescendants = true })
	n("UICorner", { Parent = pop, CornerRadius = UDim.new(0, 10) })
	n("UIStroke", { Parent = pop, Color = rs.th.b3, Thickness = 1, Transparency = 0.5 })
	local sat = n("Frame", { Parent = pop, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 160, 0, 120), BackgroundColor3 = Color3.new(1, 1, 1) })
	n("UICorner", { Parent = sat, CornerRadius = UDim.new(0, 6) })
	local sg = n("UIGradient", { Parent = sat, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 0, 1)) })
	local val = n("Frame", { Parent = sat, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0) })
	n("UICorner", { Parent = val, CornerRadius = UDim.new(0, 6) })
	n("UIGradient", { Parent = val, Rotation = 90, Transparency = NumberSequence.new(0, 1) })
	local sp = n("Frame", { Parent = sat, Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = rs.th.txt })
	n("UICorner", { Parent = sp, CornerRadius = UDim.new(1, 0) })
	n("UIStroke", { Parent = sp, Color = rs.th.bg, Thickness = 1 })
	local hue = n("Frame", { Parent = pop, Position = UDim2.new(0, 180, 0, 10), Size = UDim2.new(0, 12, 0, 120), BackgroundColor3 = Color3.new(1, 1, 1) })
	n("UICorner", { Parent = hue, CornerRadius = UDim.new(0, 6) })
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
	local hx = n("TextBox", { Parent = pop, Size = UDim2.new(0, 80, 0, 24), Position = UDim2.new(0, 10, 0, 138), BackgroundColor3 = rs.th.b3, Text = "", TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false })
	n("UICorner", { Parent = hx, CornerRadius = UDim.new(0, 6) })
	n("UIStroke", { Parent = hx, Color = rs.th.b2, Thickness = 1, Transparency = 0.4 })
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
	local function open(x)
		o = x
		local ph = x and 170 or 0
		tw(pop, 0.2, { Size = UDim2.new(1, 0, 0, ph) })
		tw(r, 0.2, { Size = UDim2.new(1, 0, 0, 36 + ph) })
	end
	cx(sc.w.cx, h.MouseButton1Click, function()
		open(not o)
	end)
	return { b = h, Set = function(_, c2) h2, s2, v2 = Color3.toHSV(c2); upd() end, Get = function() return Color3.fromHSV(h2, s2, v2) end }
end

rs.el.list = function(sc, txt, opt)
	local r = n("Frame", { Parent = sc.f, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
	n("UIListLayout", { Parent = r, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	local l = n("TextLabel", { Parent = r, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = txt or "List", TextColor3 = rs.th.txt, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
	local box = n("Frame", { Parent = r, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
	local ll = n("UIListLayout", { Parent = box, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	opt = opt or {}
	local function additem(t2, cb)
		local it = n("Frame", { Parent = box, Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = rs.th.b3 })
		n("UICorner", { Parent = it, CornerRadius = UDim.new(0, 6) })
		local tx = n("TextLabel", { Parent = it, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = t2, TextColor3 = rs.th.txt, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
		local act = n("TextButton", { Parent = it, Size = UDim2.new(0, 24, 0, 20), Position = UDim2.new(1, -54, 0.5, -10), BackgroundColor3 = rs.th.acc, Text = opt.btn or ">", TextColor3 = rs.th.txt, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false })
		n("UICorner", { Parent = act, CornerRadius = UDim.new(0, 4) })
		local rm = n("TextButton", { Parent = it, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -26, 0.5, -10), BackgroundColor3 = rs.th.st, Text = "x", TextColor3 = rs.th.txt, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false })
		n("UICorner", { Parent = rm, CornerRadius = UDim.new(0, 4) })
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

local function mkstats(w, p)
	local bar = n("Frame", { Parent = p, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = rs.th.b2 })
	n("UIStroke", { Parent = bar, Color = rs.th.b3, Thickness = 1, Transparency = 0.5 })
	n("UIListLayout", { Parent = bar, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = bar, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) })
	local function lab()
		return n("TextLabel", { Parent = bar, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "", TextColor3 = rs.th.sub, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
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
	local main = n("Frame", { Parent = sg, Name = "Main", Size = UDim2.new(0, 720, 0, 520), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = rs.th.bg })
	n("UICorner", { Parent = main, CornerRadius = UDim.new(0, 14) })
	n("UIStroke", { Parent = main, Color = rs.th.acc, Thickness = 1, Transparency = 0.6 })
	n("UIGradient", { Parent = main, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, rs.th.bg), ColorSequenceKeypoint.new(1, rs.th.b3) }) })
	local noise = n("ImageLabel", { Parent = main, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = rs.as.noise or "", ImageTransparency = 0.85, ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 64, 0, 64), Active = false, ZIndex = 0 })
	n("UICorner", { Parent = noise, CornerRadius = UDim.new(0, 14) })
	local top = n("Frame", { Parent = main, Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 })
	local ttl = n("TextLabel", { Parent = top, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundTransparency = 1, Text = o.name or "RoSense", TextColor3 = rs.th.txt, Font = Enum.Font.GothamBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left })
	local side = n("Frame", { Parent = main, Position = UDim2.new(0, 0, 0, 48), Size = UDim2.new(0, 84, 1, -88), BackgroundColor3 = rs.th.b2 })
	local tlist = n("Frame", { Parent = side, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
	n("UIListLayout", { Parent = tlist, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
	n("UIPadding", { Parent = tlist, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
	local pages = n("Frame", { Parent = main, Position = UDim2.new(0, 84, 0, 48), Size = UDim2.new(1, -84, 1, -88), BackgroundTransparency = 1 })
	local pl = n("UIPageLayout", { Parent = pages, TweenTime = 0.25, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out, SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal })
	pl.ScrollWheelInputEnabled = false
	mkstats(w, n("Frame", { Parent = main, Position = UDim2.new(0, 0, 1, -40), Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 }))
	local sc = n("UIScale", { Parent = main, Scale = 1 })
	local cam = workspace.CurrentCamera
	local function res()
		local v = cam and cam.ViewportSize or Vector2.new(800, 600)
		local s2 = math.min(1, math.min(v.X / 760, v.Y / 560))
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
	cx(w.cx, s.ui.InputBegan, function(i, g2)
		if g2 then
			return
		end
		local k = o.key or Enum.KeyCode.RightShift
		if i.KeyCode == k then
			main.Visible = not main.Visible
		end
	end)
	function w:Tab(nm, icon)
		local t = { w = w }
		local b = n("TextButton", { Parent = tlist, Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = rs.th.b3, Text = "", AutoButtonColor = false })
		n("UICorner", { Parent = b, CornerRadius = UDim.new(0, 10) })
		local ib = n("Frame", { Parent = b, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 8, 0.5, -10), BackgroundTransparency = 1 })
		ic(icon or "box", ib, rs.th.sub)
		local tl = n("TextLabel", { Parent = b, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1, Text = nm or "Tab", TextColor3 = rs.th.sub, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
		local line = n("Frame", { Parent = b, Size = UDim2.new(0, 3, 1, -12), Position = UDim2.new(0, 0, 0, 6), BackgroundColor3 = rs.th.acc, BackgroundTransparency = 1 })
		n("UICorner", { Parent = line, CornerRadius = UDim.new(0, 3) })
		local pg = n("ScrollingFrame", { Parent = pages, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 3, ScrollBarImageColor3 = rs.th.acc })
		pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
		local lay = n("UIListLayout", { Parent = pg, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })
		n("UIPadding", { Parent = pg, PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) })
		local function act(x)
			if x then
				tw(b, 0.15, { BackgroundColor3 = rs.th.b2 })
				tl.TextColor3 = rs.th.txt
				line.BackgroundTransparency = 0
			else
				tw(b, 0.15, { BackgroundColor3 = rs.th.b3 })
				tl.TextColor3 = rs.th.sub
				line.BackgroundTransparency = 1
			end
		end
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
		function t:Sec(tt)
			local sc2 = { w = w, f = nil }
			local fr = n("Frame", { Parent = pg, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = rs.th.b2, AutomaticSize = Enum.AutomaticSize.Y })
			n("UICorner", { Parent = fr, CornerRadius = UDim.new(0, 10) })
			n("UIStroke", { Parent = fr, Color = rs.th.b3, Thickness = 1, Transparency = 0.5 })
			n("UIPadding", { Parent = fr, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
			n("UIListLayout", { Parent = fr, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
			if tt and tt ~= "" then
				n("TextLabel", { Parent = fr, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = tt, TextColor3 = rs.th.txt, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
			end
			sc2.f = fr
			function sc2:Add(k, ...)
				local f = rs.el[k]
				if f then
					return f(sc2, ...)
				end
			end
			function sc2:Button(a, b2)
				return rs.el.btn(sc2, a, b2)
			end
			function sc2:Toggle(a, b2, c2)
				return rs.el.tog(sc2, a, b2, c2)
			end
			function sc2:Textbox(a, b2, c2)
				return rs.el.box(sc2, a, b2, c2)
			end
			function sc2:Dropdown(a, b2, c2, d2)
				return rs.el.dd(sc2, a, b2, c2, d2)
			end
			function sc2:Color(a, b2, c2)
				return rs.el.cp(sc2, a, b2, c2)
			end
			function sc2:List(a, b2)
				return rs.el.list(sc2, a, b2)
			end
			return sc2
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
