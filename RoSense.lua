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
    notifications = {},
    tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    fastTween = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
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

local notifContainer = create("Frame", {
    Name = "Notifications",
    Size = UDim2.new(0, 280, 1, -20),
    Position = UDim2.new(1, -290, 0, 10),
    BackgroundTransparency = 1,
    Parent = sg
})

create("UIListLayout", {
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Parent = notifContainer
})

local statsBar = create("Frame", {
    Name = "StatsBar",
    Size = UDim2.new(0, 160, 0, 32),
    Position = UDim2.new(0.5, -80, 0, 12),
    BackgroundColor3 = Color3.fromRGB(8, 8, 12),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Parent = sg
})

create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = statsBar})
create("UIStroke", {Color = Color3.fromRGB(60, 60, 70), Thickness = 1, Transparency = 0.4, Parent = statsBar})

local statsGradient = create("UIGradient", {
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 16)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12))
    },
    Rotation = 90,
    Parent = statsBar
})

local fpsLabel = create("TextLabel", {
    Size = UDim2.new(0.5, -8, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "60 FPS",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(100, 220, 100),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = statsBar
})

local pingLabel = create("TextLabel", {
    Size = UDim2.new(0.5, -8, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "0ms",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(100, 220, 100),
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = statsBar
})

create("UIPadding", {PaddingRight = UDim.new(0, 12), Parent = statsBar})

local main = create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(10, 10, 14),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = sg
})

create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = main})
create("UIStroke", {Color = Color3.fromRGB(60, 60, 75), Thickness = 1.5, Transparency = 0.3, Parent = main})

local mainGradient = create("UIGradient", {
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 18)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 14))
    },
    Rotation = 135,
    Parent = main
})

local topBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(12, 12, 16),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Parent = main
})

create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = topBar})
create("UIStroke", {Color = Color3.fromRGB(70, 70, 85), Thickness = 1, Transparency = 0.5, Parent = topBar})

local topBarMask = create("Frame", {
    Size = UDim2.new(1, 0, 0, 12),
    Position = UDim2.new(0, 0, 1, -12),
    BackgroundColor3 = Color3.fromRGB(12, 12, 16),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Parent = topBar
})

local title = create("TextLabel", {
    Size = UDim2.new(0, 120, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
    BackgroundTransparency = 1,
    Text = "RoSense",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = Color3.fromRGB(220, 220, 230),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = topBar
})

local minimizeBtn = create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -34, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(18, 18, 24),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Text = "─",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(180, 180, 190),
    Parent = topBar
})

create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = minimizeBtn})

minimizeBtn.MouseEnter:Connect(function()
    tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(70, 50, 110), BackgroundTransparency = 0}, RoSense.fastTween)
end)

minimizeBtn.MouseLeave:Connect(function()
    tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.3}, RoSense.fastTween)
end)

minimizeBtn.MouseButton1Click:Connect(function()
    RoSense.minimized = not RoSense.minimized
    if RoSense.minimized then
        tween(main, {Size = UDim2.new(0, 580, 0, 40)})
        minimizeBtn.Text = "+"
    else
        tween(main, {Size = UDim2.new(0, 580, 0, 360)})
        minimizeBtn.Text = "─"
    end
end)

local content = create("Frame", {
    Size = UDim2.new(1, -20, 1, -54),
    Position = UDim2.new(0, 10, 0, 44),
    BackgroundTransparency = 1,
    Parent = main
})

local sidebar = create("Frame", {
    Size = UDim2.new(0, 52, 1, 0),
    BackgroundTransparency = 1,
    Parent = content
})

local tabScroll = create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = sidebar
})

create("UIListLayout", {Padding = UDim.new(0, 6), Parent = tabScroll})

local tabContent = create("Frame", {
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.new(0, 60, 0, 0),
    BackgroundColor3 = Color3.fromRGB(12, 12, 16),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Parent = content
})

create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = tabContent})
create("UIStroke", {Color = Color3.fromRGB(50, 50, 60), Thickness = 1, Transparency = 0.6, Parent = tabContent})

local componentLib = {}

function componentLib.Toggle(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -46, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Toggle",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 210, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local toggle = create("Frame", {
        Size = UDim2.new(0, 38, 0, 20),
        Position = UDim2.new(1, -38, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(22, 22, 28),
        BorderSizePixel = 0,
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggle})
    create("UIStroke", {Color = Color3.fromRGB(45, 45, 55), Thickness = 1.5, Transparency = 0.5, Parent = toggle})
    
    local knob = create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(180, 180, 190),
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
            tween(toggle, {BackgroundColor3 = Color3.fromRGB(75, 55, 120)})
            tween(knob, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(240, 240, 250)})
        else
            tween(toggle, {BackgroundColor3 = Color3.fromRGB(22, 22, 28)})
            tween(knob, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(180, 180, 190)})
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
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(16, 16, 22),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Text = props.text or "Button",
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 210, 220),
        Parent = props.parent
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
    create("UIStroke", {Color = Color3.fromRGB(55, 55, 65), Thickness = 1, Transparency = 0.5, Parent = btn})
    
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(75, 55, 120), BackgroundTransparency = 0}, RoSense.fastTween)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.4}, RoSense.fastTween)
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
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Parent = container
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -45, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Slider",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 210, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local value = create("TextLabel", {
        Size = UDim2.new(0, 40, 1, 0),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(props.default or props.min or 0),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(160, 140, 200),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = header
    })
    
    local track = create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BorderSizePixel = 0,
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
    
    local fill = create("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(75, 55, 120),
        BorderSizePixel = 0,
        Parent = track
    })
    
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
    
    local knob = create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(240, 240, 250),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = track
    })
    
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})
    create("UIStroke", {Color = Color3.fromRGB(75, 55, 120), Thickness = 2, Transparency = 0.3, Parent = knob})
    
    local min = props.min or 0
    local max = props.max or 100
    local current = props.default or min
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        current = math.floor(min + (max - min) * pos)
        value.Text = tostring(current)
        tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, RoSense.fastTween)
        tween(knob, {Position = UDim2.new(pos, -7, 0.5, -7)}, RoSense.fastTween)
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
    knob.Position = UDim2.new(initPos, -7, 0.5, -7)
    
    return container
end

function componentLib.Dropdown(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 5,
        Parent = props.parent
    })
    
    local dropdown = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(16, 16, 22),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Text = "",
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = dropdown})
    create("UIStroke", {Color = Color3.fromRGB(55, 55, 65), Thickness = 1, Transparency = 0.5, Parent = dropdown})
    create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = dropdown})
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Text = props.options[1] or "Select",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 210, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown
    })
    
    local arrow = create("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = Color3.fromRGB(160, 140, 200),
        Parent = dropdown
    })
    
    local list = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Color3.fromRGB(14, 14, 18),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = list})
    create("UIStroke", {Color = Color3.fromRGB(65, 65, 75), Thickness = 1.5, Transparency = 0.4, Parent = list})
    
    local listLayout = create("UIListLayout", {Padding = UDim.new(0, 2), Parent = list})
    create("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = list})
    
    for _, opt in ipairs(props.options) do
        local optBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Color3.fromRGB(18, 18, 24),
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            Text = opt,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(200, 200, 210),
            ZIndex = 11,
            Parent = list
        })
        
        create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = optBtn})
        
        optBtn.MouseEnter:Connect(function()
            tween(optBtn, {BackgroundColor3 = Color3.fromRGB(75, 55, 120), BackgroundTransparency = 0}, RoSense.fastTween)
        end)
        
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, {BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.6}, RoSense.fastTween)
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
            local height = math.min(#props.options * 30 + 8, 160)
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
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -42, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Color",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 210, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local preview = create("TextButton", {
        Size = UDim2.new(0, 36, 0, 22),
        Position = UDim2.new(1, -36, 0.5, -11),
        BackgroundColor3 = props.default or Color3.fromRGB(75, 55, 120),
        BorderSizePixel = 0,
        Text = "",
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = preview})
    create("UIStroke", {Color = Color3.fromRGB(220, 220, 230), Thickness = 1.5, Transparency = 0.4, Parent = preview})
    
    preview.MouseEnter:Connect(function()
        tween(preview, {Size = UDim2.new(0, 40, 0, 26)}, RoSense.fastTween)
    end)
    
    preview.MouseLeave:Connect(function()
        tween(preview, {Size = UDim2.new(0, 36, 0, 22)}, RoSense.fastTween)
    end)
    
    preview.MouseButton1Click:Connect(function()
        if props.callback then
            props.callback(preview.BackgroundColor3)
        end
    end)
    
    return container
end

function componentLib.TextBox(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local box = create("TextBox", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(16, 16, 22),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Text = props.placeholder or "",
        PlaceholderText = props.placeholder or "Enter text...",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 210, 220),
        PlaceholderColor3 = Color3.fromRGB(120, 120, 130),
        ClearTextOnFocus = false,
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = box})
    create("UIStroke", {Color = Color3.fromRGB(55, 55, 65), Thickness = 1, Transparency = 0.5, Parent = box})
    create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = box})
    
    box.Focused:Connect(function()
        tween(box, {BackgroundColor3 = Color3.fromRGB(20, 20, 28), BackgroundTransparency = 0.2})
    end)
    
    box.FocusLost:Connect(function()
        tween(box, {BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.4})
        if props.callback then
            props.callback(box.Text)
        end
    end)
    
    return container
end

local iconMap = {
    combat = "https://www.svgrepo.com/show/309858/fight.svg",
    visuals = "https://www.svgrepo.com/show/532994/eye.svg",
    movement = "https://www.svgrepo.com/show/474465/run.svg",
    misc = "https://www.svgrepo.com/show/532960/cog.svg",
    teleport = "https://www.svgrepo.com/show/533067/map-pin.svg",
    config = "https://www.svgrepo.com/show/532870/adjustments.svg"
}

function RoSense:CreateTab(name, iconKey)
    local tab = {name = name, button = nil, container = nil}
    
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Color3.fromRGB(16, 16, 22),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = "",
        Parent = tabScroll
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})
    
local icon = create("ImageLabel", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(0.5, -12, 0.5, -12),
    BackgroundTransparency = 1,
    Image = iconMap[iconKey] or "",
    ImageColor3 = Color3.fromRGB(160, 140, 200),
    Parent = btn
})

btn.MouseEnter:Connect(function()
    tween(btn, {BackgroundColor3 = Color3.fromRGB(75, 55, 120), BackgroundTransparency = 0.2}, RoSense.fastTween)
    tween(icon, {ImageColor3 = Color3.fromRGB(240, 240, 250)}, RoSense.fastTween)
end)

btn.MouseLeave:Connect(function()
    tween(btn, {BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.5}, RoSense.fastTween)
    tween(icon, {ImageColor3 = Color3.fromRGB(160, 140, 200)}, RoSense.fastTween)
end)

btn.MouseButton1Click:Connect(function()
    RoSense:SelectTab(tab)
end)

tab.button = btn

local container = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Visible = false,
    Parent = tabContent
})

create("UIListLayout", {Padding = UDim.new(0, 8), Parent = container})
create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), Parent = container})

tab.container = container

table.insert(RoSense.tabs, tab)

if not RoSense.currentTab then
    RoSense:SelectTab(tab)
end

return tab
end

function RoSense:SelectTab(tab)
    if RoSense.currentTab then
        tween(RoSense.currentTab.button, {BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.5}, RoSense.fastTween)
        RoSense.currentTab.container.Visible = false
    end
    
    RoSense.currentTab = tab
    tween(tab.button, {BackgroundColor3 = Color3.fromRGB(75, 55, 120), BackgroundTransparency = 0.1}, RoSense.fastTween)
    tab.container.Visible = true
end

function RoSense:Notify(message, duration)
    duration = duration or 3
    
    local notification = create("Frame", {
        Size = UDim2.new(0, 260, 0, 60),
        BackgroundColor3 = Color3.fromRGB(14, 14, 18),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = notifContainer
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = notification})
    create("UIStroke", {Color = Color3.fromRGB(75, 55, 120), Thickness = 1.5, Transparency = 0.3, Parent = notification})
    create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), Parent = notification})
    
    local text = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = message,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(210, 210, 220),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = notification
    })
    
    game:GetService("Debris"):AddItem(notification, duration)
    
    tween(notification, {Position = notification.Position - UDim2.new(0, 0, 0, 70)}, RoSense.tweenInfo)
    
    wait(duration - 0.3)
    tween(notification, {BackgroundTransparency = 1}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In))
end

-- Example tab creation
RoSense:CreateTab("Combat", "combat")
RoSense:CreateTab("Visuals", "visuals")
RoSense:CreateTab("Movement", "movement")
RoSense:CreateTab("Misc", "misc")

-- Example component usage in first tab
if RoSense.currentTab then
    componentLib.Toggle({
        parent = RoSense.currentTab.container,
        text = "Example Toggle",
        default = false,
        callback = function(enabled)
            print("Toggle:", enabled)
        end
    })
    
    componentLib.Slider({
        parent = RoSense.currentTab.container,
        text = "Example Slider",
        min = 0,
        max = 100,
        default = 50,
        callback = function(value)
            print("Slider:", value)
        end
    })
    
    componentLib.Dropdown({
        parent = RoSense.currentTab.container,
        options = {"Option 1", "Option 2", "Option 3"},
        callback = function(selected)
            print("Selected:", selected)
        end
    })
    
    componentLib.Button({
        parent = RoSense.currentTab.container,
        text = "Example Button",
        callback = function()
            RoSense:Notify("Button clicked!", 2)
        end
    })
end


print("RoSense Admin Panel loaded successfully!")
