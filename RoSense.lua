local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local RoSense = {
    config = {},
    tabs = {},
    currentTab = nil,
    minimized = false,
    tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    fastTween = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
}

local function tween(obj, props, info)
    TweenService:Create(obj, info or RoSense.tweenInfo, props):Play()
end

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local sg = create("ScreenGui", {
    Name = "RoSense",
    Parent = game:GetService("CoreGui"),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false
})

local statsBar = create("Frame", {
    Name = "StatsBar",
    Size = UDim2.new(0, 140, 0, 26),
    Position = UDim2.new(0.5, -70, 0, 10),
    BackgroundColor3 = Color3.fromRGB(8, 8, 12),
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Parent = sg
})

create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = statsBar})
create("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Thickness = 1, Transparency = 0.7, Parent = statsBar})

local fpsLabel = create("TextLabel", {
    Size = UDim2.new(0.5, -4, 1, 0),
    Position = UDim2.new(0, 6, 0, 0),
    BackgroundTransparency = 1,
    Text = "60",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = Color3.fromRGB(160, 160, 170),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = statsBar
})

local pingLabel = create("TextLabel", {
    Size = UDim2.new(0.5, -4, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "0ms",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = Color3.fromRGB(160, 160, 170),
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = statsBar
})

create("UIPadding", {PaddingRight = UDim.new(0, 6), Parent = statsBar})

local main = create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 560, 0, 340),
    Position = UDim2.new(0.5, -280, 0.5, -170),
    BackgroundColor3 = Color3.fromRGB(10, 10, 14),
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Parent = sg
})

create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = main})
create("UIStroke", {Color = Color3.fromRGB(45, 45, 55), Thickness = 1, Transparency = 0.6, Parent = main})

local topBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = Color3.fromRGB(14, 14, 18),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Parent = main
})

create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = topBar})

local topBarBase = create("Frame", {
    Size = UDim2.new(1, 0, 0, 8),
    Position = UDim2.new(0, 0, 1, -8),
    BackgroundColor3 = Color3.fromRGB(14, 14, 18),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Parent = topBar
})

local title = create("TextLabel", {
    Size = UDim2.new(0, 100, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "RoSense",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(200, 200, 210),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = topBar
})

local minimizeBtn = create("TextButton", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -30, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(20, 20, 26),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Text = "_",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(160, 160, 170),
    Parent = topBar
})

create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = minimizeBtn})

minimizeBtn.MouseEnter:Connect(function()
    tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(70, 50, 110)}, RoSense.fastTween)
end)

minimizeBtn.MouseLeave:Connect(function()
    tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(20, 20, 26)}, RoSense.fastTween)
end)

minimizeBtn.MouseButton1Click:Connect(function()
    RoSense.minimized = not RoSense.minimized
    if RoSense.minimized then
        tween(main, {Size = UDim2.new(0, 560, 0, 36)})
        minimizeBtn.Text = "+"
    else
        tween(main, {Size = UDim2.new(0, 560, 0, 340)})
        minimizeBtn.Text = "_"
    end
end)

local content = create("Frame", {
    Size = UDim2.new(1, -16, 1, -48),
    Position = UDim2.new(0, 8, 0, 40),
    BackgroundTransparency = 1,
    Parent = main
})

local sidebar = create("Frame", {
    Size = UDim2.new(0, 110, 1, 0),
    BackgroundTransparency = 1,
    Parent = content
})

local tabScroll = create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(70, 50, 110),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = sidebar
})

create("UIListLayout", {Padding = UDim.new(0, 4), Parent = tabScroll})
create("UIPadding", {PaddingTop = UDim.new(0, 2), Parent = tabScroll})

local tabContent = create("Frame", {
    Size = UDim2.new(1, -118, 1, 0),
    Position = UDim2.new(0, 118, 0, 0),
    BackgroundColor3 = Color3.fromRGB(12, 12, 16),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Parent = content
})

create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabContent})

local componentLib = {}

function componentLib.Toggle(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -42, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Toggle",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local toggle = create("Frame", {
        Size = UDim2.new(0, 34, 0, 18),
        Position = UDim2.new(1, -34, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(25, 25, 32),
        BorderSizePixel = 0,
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggle})
    create("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Thickness = 1, Transparency = 0.7, Parent = toggle})
    
    local knob = create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(160, 160, 170),
        BorderSizePixel = 0,
        Parent = toggle
    })
    
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})
    
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = toggle
    })
    
    local enabled = props.default or false
    
    local function update()
        if enabled then
            tween(toggle, {BackgroundColor3 = Color3.fromRGB(70, 50, 110)})
            tween(knob, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(230, 230, 240)})
        else
            tween(toggle, {BackgroundColor3 = Color3.fromRGB(25, 25, 32)})
            tween(knob, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(160, 160, 170)})
        end
        if props.callback then
            props.callback(enabled)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        update()
    end)
    
    update()
    return container
end

function componentLib.Button(props)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = props.text or "Button",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        Parent = props.parent
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = btn})
    create("UIStroke", {Color = Color3.fromRGB(50, 50, 60), Thickness = 1, Transparency = 0.6, Parent = btn})
    
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(70, 50, 110), BackgroundTransparency = 0}, RoSense.fastTween)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.5}, RoSense.fastTween)
    end)
    
    btn.MouseButton1Click:Connect(function()
        if props.callback then
            props.callback()
        end
    end)
    
    return btn
end

function componentLib.Slider(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Parent = container
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Slider",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local value = create("TextLabel", {
        Size = UDim2.new(0, 35, 1, 0),
        Position = UDim2.new(1, -35, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(props.default or props.min or 0),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(150, 140, 180),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = header
    })
    
    local track = create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Color3.fromRGB(20, 20, 26),
        BorderSizePixel = 0,
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
    
    local fill = create("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(70, 50, 110),
        BorderSizePixel = 0,
        Parent = track
    })
    
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
    
    local knob = create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0.5, -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(230, 230, 240),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = track
    })
    
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})
    create("UIStroke", {Color = Color3.fromRGB(70, 50, 110), Thickness = 1.5, Transparency = 0.4, Parent = knob})
    
    local min = props.min or 0
    local max = props.max or 100
    local current = props.default or min
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        current = math.floor(min + (max - min) * pos)
        value.Text = tostring(current)
        tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, RoSense.fastTween)
        tween(knob, {Position = UDim2.new(pos, -6, 0.5, -6)}, RoSense.fastTween)
        if props.callback then
            props.callback(current)
        end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    local initPos = (current - min) / (max - min)
    fill.Size = UDim2.new(initPos, 0, 1, 0)
    knob.Position = UDim2.new(initPos, -6, 0.5, -6)
    
    return container
end

function componentLib.Dropdown(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 5,
        Parent = props.parent
    })
    
    local dropdown = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = "",
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = dropdown})
    create("UIStroke", {Color = Color3.fromRGB(50, 50, 60), Thickness = 1, Transparency = 0.6, Parent = dropdown})
    create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = dropdown})
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Text = props.options[1] or "Select",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown
    })
    
    local arrow = create("TextLabel", {
        Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -14, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextColor3 = Color3.fromRGB(150, 140, 180),
        Parent = dropdown
    })
    
    local list = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 3),
        BackgroundColor3 = Color3.fromRGB(16, 16, 20),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = list})
    create("UIStroke", {Color = Color3.fromRGB(60, 60, 70), Thickness = 1, Transparency = 0.5, Parent = list})
    
    local listLayout = create("UIListLayout", {Padding = UDim.new(0, 2), Parent = list})
    create("UIPadding", {PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), Parent = list})
    
    for _, opt in ipairs(props.options) do
        local optBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = Color3.fromRGB(20, 20, 26),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Text = opt,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = Color3.fromRGB(190, 190, 200),
            ZIndex = 11,
            Parent = list
        })
        
        create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = optBtn})
        
        optBtn.MouseEnter:Connect(function()
            tween(optBtn, {BackgroundColor3 = Color3.fromRGB(70, 50, 110), BackgroundTransparency = 0}, RoSense.fastTween)
        end)
        
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, {BackgroundColor3 = Color3.fromRGB(20, 20, 26), BackgroundTransparency = 0.7}, RoSense.fastTween)
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            label.Text = opt
            list.Visible = false
            tween(list, {Size = UDim2.new(1, 0, 0, 0)})
            tween(arrow, {Rotation = 0})
            if props.callback then
                props.callback(opt)
            end
        end)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        if list.Visible then
            local height = math.min(#props.options * 26 + 6, 150)
            tween(list, {Size = UDim2.new(1, 0, 0, height)})
            tween(arrow, {Rotation = 180})
        else
            tween(list, {Size = UDim2.new(1, 0, 0, 0)})
            tween(arrow, {Rotation = 0})
        end
    end)
    
    return container
end

function componentLib.ColorPicker(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -38, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Color",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local preview = create("TextButton", {
        Size = UDim2.new(0, 32, 0, 20),
        Position = UDim2.new(1, -32, 0.5, -10),
        BackgroundColor3 = props.default or Color3.fromRGB(70, 50, 110),
        BorderSizePixel = 0,
        Text = "",
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = preview})
    create("UIStroke", {Color = Color3.fromRGB(200, 200, 210), Thickness = 1, Transparency = 0.5, Parent = preview})
    
    preview.MouseEnter:Connect(function()
        tween(preview, {Size = UDim2.new(0, 36, 0, 24)}, RoSense.fastTween)
    end)
    
    preview.MouseLeave:Connect(function()
        tween(preview, {Size = UDim2.new(0, 32, 0, 20)}, RoSense.fastTween)
    end)
    
    preview.MouseButton1Click:Connect(function()
        if props.callback then
            props.callback(preview.BackgroundColor3)
        end
    end)
    
    return container
end

function RoSense:CreateTab(name, icon)
    local tab = {name = name, button = nil, container = nil}
    
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Text = "",
        Parent = tabScroll
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
    create("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = btn})
    
    local iconLabel = create("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        BackgroundTransparency = 1,
        Text = icon or "•",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(150, 140, 180),
        Parent = btn
    })
    
    local nameLabel = create("TextLabel", {
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(190, 190, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn
    })
    
    local scroll = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(70, 50, 110),
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = tabContent
    })
    
    create("UIListLayout", {Padding = UDim.new(0, 6), Parent = scroll})
    create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = scroll})
    
    tab.button = btn
    tab.container = scroll
    
    btn.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    btn.MouseEnter:Connect(function()
        if self.currentTab ~= tab then
            tween(btn, {BackgroundTransparency = 0.4}, RoSense.fastTween)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if self.currentTab ~= tab then
            tween(btn, {BackgroundTransparency = 0.6}, RoSense.fastTween)
        end
    end)
    
    table.insert(self.tabs, tab)
    
    if not self.currentTab then
        self:SwitchTab(tab)
    end
    
    return {
        AddToggle = function(_, p) return componentLib.Toggle({parent = scroll, text = p.text, default = p.default, callback = p.callback}) end,
        AddButton = function(_, p) return componentLib.Button({parent = scroll, text = p.text, callback = p.callback}) end,
        AddSlider = function(_, p) return componentLib.Slider({parent = scroll, text = p.text, min = p.min, max = p.max, default = p.default, callback = p.callback}) end,
        AddDropdown = function(_, p) return componentLib.Dropdown({parent = scroll, options = p.options, callback = p.callback}) end,
        AddColorPicker = function(_, p) return componentLib.ColorPicker({parent = scroll, text = p.text, default = p.default, callback = p.callback}) end
    }
end

function RoSense:SwitchTab(tab)
    if self.currentTab then
        self.currentTab.container.Visible = false
        tween(self.currentTab.button, {BackgroundTransparency = 0.6})
    end
    self.currentTab = tab
    tab.container.Visible = true
    tween(tab.button, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(70, 50, 110)})
end

function RoSense:SaveConfig(name)
    self.config[name] = {}
    writefile(name .. ".json", HttpService:JSONEncode(self.config[name]))
end

function RoSense:LoadConfig(name)
    if isfile(name .. ".json") then
        self.config[name] = HttpService:JSONDecode(readfile(name .. ".json"))
    end
end

function RoSense:CreateConfigUI()
    local configTab = self:CreateTab("Config", "⚙")
    
    configTab:AddButton({
        text = "Save Config",
        callback = function()
            self:SaveConfig("default")
        end
    })
    
    configTab:AddButton({
        text = "Load Config",
        callback = function()
            self:LoadConfig("default")
        end
    })
    
    configTab:AddButton({
        text = "Reset to Default",
        callback = function()
            self.config = {}
        end
    })
end

local dragging = false
local dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local lastUpdate = tick()
local frames = 0

RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastUpdate >= 1 then
        fpsLabel.Text = tostring(frames)
        pingLabel.Text = math.floor(player:GetNetworkPing() * 1000) .. "ms"
        frames = 0
        lastUpdate = tick()
    end
end)

RoSense:CreateConfigUI()

RoSense.CustomIncludes = function(tabName, icon)
    return RoSense:CreateTab(tabName, icon or "★")
end

return RoSense
