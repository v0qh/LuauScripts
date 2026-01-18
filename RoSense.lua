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
    fastTween = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    toggleKey = Enum.KeyCode.RightControl
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
    Size = UDim2.new(0, 200, 0, 36),
    Position = UDim2.new(0.5, 0, 0, 12),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = Color3.fromRGB(8, 8, 12),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Parent = sg
})

create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = statsBar})
create("UIStroke", {Color = Color3.fromRGB(75, 55, 120), Thickness = 1.5, Transparency = 0.3, Parent = statsBar})

local statsGradient = create("UIGradient", {
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 16)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12))
    },
    Rotation = 90,
    Parent = statsBar
})

local fpsLabel = create("TextLabel", {
    Size = UDim2.new(0.45, -8, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "60 FPS",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(80, 180, 80),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = statsBar
})

local divider = create("TextLabel", {
    Size = UDim2.new(0, 2, 0.6, 0),
    Position = UDim2.new(0.5, -1, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Text = "|",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(75, 55, 120),
    Parent = statsBar
})

local pingLabel = create("TextLabel", {
    Size = UDim2.new(0.45, -8, 1, 0),
    Position = UDim2.new(0.55, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "0ms",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(80, 180, 80),
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
        tween(main, {Size = UDim2.new(0, 0, 0, 0)})
        tween(statsBar, {Size = UDim2.new(0, 0, 0, 0)})
        minimizeBtn.Text = "+"
        RoSense:Notify({
            title = "UI Hidden",
            description = "Press " .. RoSense.toggleKey.Name .. " to show again",
            duration = 2
        })
    else
        tween(main, {Size = UDim2.new(0, 580, 0, 360)})
        tween(statsBar, {Size = UDim2.new(0, 200, 0, 36)})
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
    if not props or not props.options or #props.options == 0 then
        props = props or {}
        props.options = {"No Options"}
    end
    
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
    
local options = props.options or {"Option 1"}
for _, opt in ipairs(options) do
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
    
    local currentColor = props.default or Color3.fromRGB(75, 55, 120)
    
    local preview = create("TextButton", {
        Size = UDim2.new(0, 36, 0, 22),
        Position = UDim2.new(1, -36, 0.5, -11),
        BackgroundColor3 = currentColor,
        BorderSizePixel = 0,
        Text = "",
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = preview})
    create("UIStroke", {Color = Color3.fromRGB(220, 220, 230), Thickness = 1.5, Transparency = 0.4, Parent = preview})
    
    local pickerOpen = false
    local picker = create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Color3.fromRGB(14, 14, 18),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 20,
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = picker})
    create("UIStroke", {Color = Color3.fromRGB(75, 55, 120), Thickness = 1.5, Transparency = 0.3, Parent = picker})
    
    local rLabel = create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = "R",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 100, 100),
        Parent = picker
    })
    
    local rSlider = create("Frame", {
        Size = UDim2.new(1, -40, 0, 6),
        Position = UDim2.new(0, 35, 0, 17),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BorderSizePixel = 0,
        Parent = picker
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = rSlider})
    
    local rFill = create("Frame", {
        Size = UDim2.new(currentColor.R, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 100, 100),
        BorderSizePixel = 0,
        Parent = rSlider
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = rFill})
    
    local gLabel = create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        Text = "G",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(100, 255, 100),
        Parent = picker
    })
    
    local gSlider = create("Frame", {
        Size = UDim2.new(1, -40, 0, 6),
        Position = UDim2.new(0, 35, 0, 47),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BorderSizePixel = 0,
        Parent = picker
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = gSlider})
    
    local gFill = create("Frame", {
        Size = UDim2.new(currentColor.G, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(100, 255, 100),
        BorderSizePixel = 0,
        Parent = gSlider
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = gFill})
    
    local bLabel = create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundTransparency = 1,
        Text = "B",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(100, 100, 255),
        Parent = picker
    })
    
    local bSlider = create("Frame", {
        Size = UDim2.new(1, -40, 0, 6),
        Position = UDim2.new(0, 35, 0, 77),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BorderSizePixel = 0,
        Parent = picker
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bSlider})
    
    local bFill = create("Frame", {
        Size = UDim2.new(currentColor.B, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(100, 100, 255),
        BorderSizePixel = 0,
        Parent = bSlider
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bFill})
    
    local r, g, b = math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255)
    
    local function updateColor()
        currentColor = Color3.fromRGB(r, g, b)
        preview.BackgroundColor3 = currentColor
        rFill.Size = UDim2.new(r / 255, 0, 1, 0)
        gFill.Size = UDim2.new(g / 255, 0, 1, 0)
        bFill.Size = UDim2.new(b / 255, 0, 1, 0)
        if props.callback then
            props.callback(currentColor)
        end
    end
    
    local draggingR, draggingG, draggingB = false, false, false
    
    local function updateR(input)
        local pos = math.clamp((input.Position.X - rSlider.AbsolutePosition.X) / rSlider.AbsoluteSize.X, 0, 1)
        r = math.floor(pos * 255)
        updateColor()
    end
    
    local function updateG(input)
        local pos = math.clamp((input.Position.X - gSlider.AbsolutePosition.X) / gSlider.AbsoluteSize.X, 0, 1)
        g = math.floor(pos * 255)
        updateColor()
    end
    
    local function updateB(input)
        local pos = math.clamp((input.Position.X - bSlider.AbsolutePosition.X) / bSlider.AbsoluteSize.X, 0, 1)
        b = math.floor(pos * 255)
        updateColor()
    end
    
    rSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingR = true
            updateR(input)
        end
    end)
    
    rSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingR = false
        end
    end)
    
    gSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingG = true
            updateG(input)
        end
    end)
    
    gSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingG = false
        end
    end)
    
    bSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingB = true
            updateB(input)
        end
    end)
    
    bSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingB = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingR then updateR(input) end
            if draggingG then updateG(input) end
            if draggingB then updateB(input) end
        end
    end)
    
    preview.MouseEnter:Connect(function()
        tween(preview, {Size = UDim2.new(0, 40, 0, 26)}, RoSense.fastTween)
    end)
    
    preview.MouseLeave:Connect(function()
        tween(preview, {Size = UDim2.new(0, 36, 0, 22)}, RoSense.fastTween)
    end)
    
    preview.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        picker.Visible = pickerOpen
        if pickerOpen then
            tween(picker, {Size = UDim2.new(1, 0, 0, 95)})
        else
            tween(picker, {Size = UDim2.new(1, 0, 0, 0)})
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

function componentLib.Label(props)
    local parent = props.parent
    parent:SetAttribute("Order", (parent:GetAttribute("Order") or 0) + 1)

    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = props.text or "Label",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(200, 180, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = parent:GetAttribute("Order"),
        Parent = parent
    })
    
    return label
end



function componentLib.Divider(props)
    local parent = props.parent
    parent:SetAttribute("Order", (parent:GetAttribute("Order") or 0) + 1)

    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        LayoutOrder = parent:GetAttribute("Order"),
        Parent = parent
    })
    
    local divider = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = container
    })
    
    return container
end


function componentLib.Keybind(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Keybind",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 210, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local currentKey = props.default or Enum.KeyCode.RightControl
    local listening = false
    
    local keybindBtn = create("TextButton", {
        Size = UDim2.new(0, 75, 0, 26),
        Position = UDim2.new(1, -75, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(16, 16, 22),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Text = currentKey.Name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(210, 210, 220),
        Parent = container
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = keybindBtn})
    create("UIStroke", {Color = Color3.fromRGB(55, 55, 65), Thickness = 1, Transparency = 0.5, Parent = keybindBtn})
    
    keybindBtn.MouseButton1Click:Connect(function()
        listening = true
        keybindBtn.Text = "..."
        tween(keybindBtn, {BackgroundColor3 = Color3.fromRGB(75, 55, 120), BackgroundTransparency = 0}, RoSense.fastTween)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            currentKey = input.KeyCode
            keybindBtn.Text = currentKey.Name
            tween(keybindBtn, {BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.4}, RoSense.fastTween)
            
            if props.callback then
                props.callback(currentKey)
            end
        end
    end)
    
    return container
end

local iconMap = {
    combat = "rbxassetid://101624956453146",
    visuals = "rbxassetid://83223275262417",
    movement = "rbxassetid://102367403102077",
    misc = "rbxassetid://132133837275144",
    teleport = "rbxassetid://102367403102077",
    config = "rbxassetid://86900062844999"
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
    create("UIStroke", {Color = Color3.fromRGB(45, 45, 55), Thickness = 1, Transparency = 0.6, Parent = btn})
    
    local icon = create("ImageLabel", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0.5, -14, 0.5, -14),
        BackgroundTransparency = 1,
        Image = iconMap[iconKey] or "rbxassetid://132133837275144",
        ImageColor3 = Color3.fromRGB(180, 160, 200),
        Parent = btn
    })
    
    local container = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(75, 55, 120),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = tabContent
    })
    
    create("UIListLayout", {Padding = UDim.new(0, 8), Parent = container})
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = container
    })
    
    tab.button = btn
    tab.container = container
    
    btn.MouseEnter:Connect(function()
        if RoSense.currentTab ~= tab then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(22, 22, 30), BackgroundTransparency = 0.3}, RoSense.fastTween)
            tween(icon, {ImageColor3 = Color3.fromRGB(200, 180, 220)}, RoSense.fastTween)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if RoSense.currentTab ~= tab then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.5}, RoSense.fastTween)
            tween(icon, {ImageColor3 = Color3.fromRGB(180, 160, 200)}, RoSense.fastTween)
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        RoSense:SelectTab(tab)
    end)
    
    table.insert(RoSense.tabs, tab)
    
    if #RoSense.tabs == 1 then
        RoSense:SelectTab(tab)
    end
    
    return {
        AddToggle = function(props) return componentLib.Toggle({parent = container, text = props.text, default = props.default, callback = props.callback}) end,
        AddButton = function(props) return componentLib.Button({parent = container, text = props.text, callback = props.callback}) end,
        AddSlider = function(props) return componentLib.Slider({parent = container, text = props.text, min = props.min, max = props.max, default = props.default, callback = props.callback}) end,
        AddDropdown = function(props) return componentLib.Dropdown({parent = container, options = props.options, callback = props.callback}) end,
        AddColorPicker = function(props) return componentLib.ColorPicker({parent = container, text = props.text, default = props.default, callback = props.callback}) end,
        AddTextBox = function(props) return componentLib.TextBox({parent = container, placeholder = props.placeholder, callback = props.callback}) end,
        AddLabel = function(props) return componentLib.Label({parent = container, text = props.text}) end,
        AddDivider = function() return componentLib.Divider({parent = container}) end,
        AddKeybind = function(props) return componentLib.Keybind({parent = container, text = props.text, default = props.default, callback = props.callback}) end
    }
end

function RoSense:SelectTab(tab)
    if RoSense.currentTab then
        tween(RoSense.currentTab.button, {BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.5})
        tween(RoSense.currentTab.button:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = Color3.fromRGB(180, 160, 200)})
        RoSense.currentTab.container.Visible = false
    end
    
    RoSense.currentTab = tab
    tween(tab.button, {BackgroundColor3 = Color3.fromRGB(75, 55, 120), BackgroundTransparency = 0})
    tween(tab.button:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = Color3.fromRGB(240, 240, 250)})
    tab.container.Visible = true
end

function RoSense:Notify(options)
    local notif = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = notifContainer
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = notif})
    create("UIStroke", {Color = Color3.fromRGB(75, 55, 120), Thickness = 1.5, Transparency = 0.3, Parent = notif})
    
    local gradient = create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 16, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 16))
        },
        Rotation = 90,
        Parent = notif
    })
    
    local accent = create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Color3.fromRGB(75, 55, 120),
        BorderSizePixel = 0,
        Parent = notif
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = accent})
    
    local titleLabel = create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text = options.title or "Notification",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    local descLabel = create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 12, 0, 26),
        BackgroundTransparency = 1,
        Text = options.description or "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(180, 180, 190),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notif
    })
    
    tween(notif, {Size = UDim2.new(1, 0, 0, 50)})
    
    task.delay(options.duration or 3, function()
        tween(notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        tween(accent, {BackgroundTransparency = 1})
        tween(titleLabel, {TextTransparency = 1})
        tween(descLabel, {TextTransparency = 1})
        task.wait(0.3)
        notif:Destroy()
    end)
end

function RoSense:Init()
    tween(main, {Size = UDim2.new(0, 580, 0, 360)})
    tween(statsBar, {Size = UDim2.new(0, 200, 0, 36)})
    
    local fps = 0
    local lastUpdate = tick()
    
    RunService.RenderStepped:Connect(function()
        fps = fps + 1
        if tick() - lastUpdate >= 1 then
            fpsLabel.Text = fps .. " FPS"
            local color = fps >= 50 and Color3.fromRGB(80, 180, 80) or fps >= 30 and Color3.fromRGB(180, 160, 80) or Color3.fromRGB(180, 80, 80)
            fpsLabel.TextColor3 = color
            fps = 0
            lastUpdate = tick()
        end
    end)
    
    task.spawn(function()
        while task.wait(1) do
            local ping = math.floor(player:GetNetworkPing() * 1000)
            pingLabel.Text = ping .. "ms"
            local color = ping <= 50 and Color3.fromRGB(80, 180, 80) or ping <= 100 and Color3.fromRGB(180, 160, 80) or Color3.fromRGB(180, 80, 80)
            pingLabel.TextColor3 = color
        end
    end)
    
    local dragging, dragInput, dragStart, startPos
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == self.toggleKey then
            self.minimized = not self.minimized
            if self.minimized then
                tween(main, {Size = UDim2.new(0, 0, 0, 0)})
                tween(statsBar, {Size = UDim2.new(0, 0, 0, 0)})
                self:Notify({
                    title = "UI Hidden",
                    description = "Press " .. self.toggleKey.Name .. " to show again",
                    duration = 2
                })
            else
                tween(main, {Size = UDim2.new(0, 580, 0, 360)})
                tween(statsBar, {Size = UDim2.new(0, 200, 0, 36)})
                self:Notify({
                    title = "UI Shown",
                    description = "Welcome back!",
                    duration = 2
                })
            end
        end
    end)
    
    self:Notify({
        title = "RoSense Loaded",
        description = "Press " .. self.toggleKey.Name .. " to toggle UI",
        duration = 3
    })
    
    return self
end

return RoSense
