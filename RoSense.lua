local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local RoSense = {
    config = {},
    tabs = {},
    currentTab = nil,
    minimized = false,
    tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    fastTween = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
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

local function createCorner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 10),
        Parent = parent
    })
end

local function createStroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Color3.fromRGB(100, 70, 180),
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        Parent = parent
    })
end

local sg = create("ScreenGui", {
    Name = "RoSense",
    Parent = game:GetService("CoreGui"),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false
})

local main = create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 720, 0, 480),
    Position = UDim2.new(0.5, -360, 0.5, -240),
    BackgroundColor3 = Color3.fromRGB(12, 12, 16),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Parent = sg
})

createCorner(main, 16)
createStroke(main, Color3.fromRGB(100, 70, 180), 1.2, 0.4)

local mainShadow = create("ImageLabel", {
    Size = UDim2.new(1, 40, 1, 40),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.7,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(10, 10, 118, 118),
    Parent = main,
    ZIndex = 0
})

local topBar = create("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(18, 18, 24),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Parent = main
})

createCorner(topBar, 16)

local topBarMask = create("Frame", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 1, -16),
    BackgroundColor3 = Color3.fromRGB(18, 18, 24),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Parent = topBar
})

local title = create("TextLabel", {
    Name = "Title",
    Size = UDim2.new(0, 150, 1, 0),
    Position = UDim2.new(0, 20, 0, 0),
    BackgroundTransparency = 1,
    Text = "RoSense",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(140, 110, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = topBar
})

local statsContainer = create("Frame", {
    Name = "Stats",
    Size = UDim2.new(0, 160, 0, 32),
    Position = UDim2.new(1, -170, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(22, 22, 30),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Parent = topBar
})

createCorner(statsContainer, 8)
createStroke(statsContainer, Color3.fromRGB(80, 60, 150), 1, 0.6)

local fpsLabel = create("TextLabel", {
    Name = "FPS",
    Size = UDim2.new(0.5, -4, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1,
    Text = "60 FPS",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(180, 180, 200),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = statsContainer
})

local pingLabel = create("TextLabel", {
    Name = "Ping",
    Size = UDim2.new(0.5, -4, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "0ms",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(180, 180, 200),
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = statsContainer
})

create("UIPadding", {
    PaddingRight = UDim.new(0, 8),
    Parent = statsContainer
})

local minimizeBtn = create("TextButton", {
    Name = "Minimize",
    Size = UDim2.new(0, 36, 0, 36),
    Position = UDim2.new(1, -44, 0.5, -18),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Text = "─",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(180, 180, 200),
    Parent = topBar
})

createCorner(minimizeBtn, 8)

minimizeBtn.MouseEnter:Connect(function()
    tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(100, 70, 180), BackgroundTransparency = 0}, RoSense.fastTween)
end)

minimizeBtn.MouseLeave:Connect(function()
    tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 35), BackgroundTransparency = 0.2}, RoSense.fastTween)
end)

minimizeBtn.MouseButton1Click:Connect(function()
    RoSense.minimized = not RoSense.minimized
    if RoSense.minimized then
        tween(main, {Size = UDim2.new(0, 720, 0, 50)})
        minimizeBtn.Text = "□"
    else
        tween(main, {Size = UDim2.new(0, 720, 0, 480)})
        minimizeBtn.Text = "─"
    end
end)

local contentArea = create("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -24, 1, -66),
    Position = UDim2.new(0, 12, 0, 58),
    BackgroundTransparency = 1,
    Parent = main
})

local tabBar = create("ScrollingFrame", {
    Name = "TabBar",
    Size = UDim2.new(0, 160, 1, 0),
    BackgroundColor3 = Color3.fromRGB(16, 16, 22),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(100, 70, 180),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = contentArea
})

createCorner(tabBar, 12)

local tabList = create("UIListLayout", {
    Padding = UDim.new(0, 6),
    Parent = tabBar
})

create("UIPadding", {
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    Parent = tabBar
})

local tabContainer = create("Frame", {
    Name = "TabContainer",
    Size = UDim2.new(1, -172, 1, 0),
    Position = UDim2.new(0, 172, 0, 0),
    BackgroundColor3 = Color3.fromRGB(16, 16, 22),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Parent = contentArea
})

createCorner(tabContainer, 12)

local componentLib = {}

function componentLib.Toggle(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = props.parent
    })
    
    createCorner(container, 8)
    
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = container
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -56, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Toggle",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local toggle = create("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -44, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0,
        Parent = container
    })
    
    createCorner(toggle, 12)
    createStroke(toggle, Color3.fromRGB(60, 60, 80), 1.5, 0.5)
    
    local knob = create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(200, 200, 210),
        BorderSizePixel = 0,
        Parent = toggle
    })
    
    createCorner(knob, 9)
    
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = toggle
    })
    
    local enabled = props.default or false
    
    local function update()
        if enabled then
            tween(toggle, {BackgroundColor3 = Color3.fromRGB(100, 70, 180)})
            tween(knob, {Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        else
            tween(toggle, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)})
            tween(knob, {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(200, 200, 210)})
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
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = props.text or "Button",
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        Parent = props.parent
    })
    
    createCorner(btn, 8)
    createStroke(btn, Color3.fromRGB(100, 70, 180), 1.2, 0.5)
    
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(100, 70, 180), BackgroundTransparency = 0}, RoSense.fastTween)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(25, 25, 35), BackgroundTransparency = 0.3}, RoSense.fastTween)
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
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = props.parent
    })
    
    createCorner(container, 8)
    
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = container
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 16),
        BackgroundTransparency = 1,
        Text = props.text or "Slider",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local value = create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 16),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(props.default or props.min or 0),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(140, 110, 220),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    local sliderBg = create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0,
        Parent = container
    })
    
    createCorner(sliderBg, 4)
    
    local fill = create("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(100, 70, 180),
        BorderSizePixel = 0,
        Parent = sliderBg
    })
    
    createCorner(fill, 4)
    
    local knob = create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = sliderBg,
        ZIndex = 2
    })
    
    createCorner(knob, 8)
    createStroke(knob, Color3.fromRGB(100, 70, 180), 2, 0.3)
    
    local min = props.min or 0
    local max = props.max or 100
    local current = props.default or min
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        current = math.floor(min + (max - min) * pos)
        value.Text = tostring(current)
        tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, RoSense.fastTween)
        tween(knob, {Position = UDim2.new(pos, -8, 0.5, -8)}, RoSense.fastTween)
        if props.callback then
            props.callback(current)
        end
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
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
    knob.Position = UDim2.new(initPos, -8, 0.5, -8)
    
    return container
end

function componentLib.Dropdown(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = props.parent,
        ClipsDescendants = false,
        ZIndex = 5
    })
    
    local dropdown = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "",
        Parent = container
    })
    
    createCorner(dropdown, 8)
    createStroke(dropdown, Color3.fromRGB(70, 60, 120), 1, 0.5)
    
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = dropdown
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        Text = props.options[1] or "Select",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown
    })
    
    local arrow = create("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(140, 110, 220),
        Parent = dropdown
    })
    
    local listContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        Parent = container,
        ZIndex = 10
    })
    
    createCorner(listContainer, 8)
    createStroke(listContainer, Color3.fromRGB(100, 70, 180), 1.2, 0.3)
    
    local listLayout = create("UIListLayout", {
        Padding = UDim.new(0, 2),
        Parent = listContainer
    })
    
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = listContainer
    })
    
    for _, opt in ipairs(props.options) do
        local optBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Color3.fromRGB(25, 25, 35),
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            Text = opt,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(200, 200, 210),
            Parent = listContainer,
            ZIndex = 11
        })
        
        createCorner(optBtn, 6)
        
        optBtn.MouseEnter:Connect(function()
            tween(optBtn, {BackgroundColor3 = Color3.fromRGB(100, 70, 180), BackgroundTransparency = 0}, RoSense.fastTween)
        end)
        
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 35), BackgroundTransparency = 0.6}, RoSense.fastTween)
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            label.Text = opt
            listContainer.Visible = false
            tween(listContainer, {Size = UDim2.new(1, 0, 0, 0)})
            tween(arrow, {Rotation = 0})
            if props.callback then
                props.callback(opt)
            end
        end)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        listContainer.Visible = not listContainer.Visible
        if listContainer.Visible then
            local height = math.min(#props.options * 34 + 8, 200)
            tween(listContainer, {Size = UDim2.new(1, 0, 0, height)})
            tween(arrow, {Rotation = 180})
        else
            tween(listContainer, {Size = UDim2.new(1, 0, 0, 0)})
            tween(arrow, {Rotation = 0})
        end
    end)
    
    return container
end

function componentLib.ColorPicker(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = props.parent
    })
    
    createCorner(container, 8)
    
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = container
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -56, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Color",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local preview = create("TextButton", {
        Size = UDim2.new(0, 44, 0, 26),
        Position = UDim2.new(1, -44, 0.5, -13),
        BackgroundColor3 = props.default or Color3.fromRGB(100, 70, 180),
        BorderSizePixel = 0,
        Text = "",
        Parent = container
    })
    
    createCorner(preview, 7)
    createStroke(preview, Color3.fromRGB(255, 255, 255), 2, 0.4)
    
    preview.MouseEnter:Connect(function()
        tween(preview, {Size = UDim2.new(0, 48, 0, 30)}, RoSense.fastTween)
    end)
    
    preview.MouseLeave:Connect(function()
        tween(preview, {Size = UDim2.new(0, 44, 0, 26)}, RoSense.fastTween)
    end)
    
    preview.MouseButton1Click:Connect(function()
        if props.callback then
            props.callback(preview.BackgroundColor3)
        end
    end)
    
    return container
end

function RoSense:CreateTab(name, icon)
    local tab = {
        name = name,
        button = nil,
        container = nil,
        content = {}
    }
    
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(22, 22, 30),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = "",
        Parent = tabBar
    })
    
    createCorner(btn, 10)
    
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = btn
    })
    
    local iconLabel = create("TextLabel", {
        Size = UDim2.new(0, 28, 1, 0),
        BackgroundTransparency = 1,
        Text = icon or "◆",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(140, 110, 220),
        Parent = btn
    })
    
    local nameLabel = create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn
    })
    
    local content = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Color3.fromRGB(100, 70, 180),
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = tabContainer
    })
    
    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = content
    })
    
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = content
    })
    
    tab.button = btn
    tab.container = content
    
    btn.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    btn.MouseEnter:Connect(function()
        if self.currentTab ~= tab then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 42), BackgroundTransparency = 0.3}, RoSense.fastTween)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if self.currentTab ~= tab then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(22, 22, 30), BackgroundTransparency = 0.5}, RoSense.fastTween)
        end
    end)
    
    table.insert(self.tabs, tab)
    
    if not self.currentTab then
        self:SwitchTab(tab)
    end
    
    return {
        AddToggle = function(_, props) return componentLib.Toggle({parent = content, text = props.text, default = props.default, callback = props.callback}) end,
        AddButton = function(_, props) return componentLib.Button({parent = content, text = props.text, callback = props.callback}) end,
        AddSlider = function(_, props) return componentLib.Slider({parent = content, text = props.text, min = props.min, max = props.max, default = props.default, callback = props.callback}) end,
        AddDropdown = function(_, props) return componentLib.Dropdown({parent = content, options = props.options, callback = props.callback}) end,
        AddColorPicker = function(_, props) return componentLib.ColorPicker({parent = content, text = props.text, default = props.default, callback = props.callback}) end
    }
end

function RoSense:SwitchTab(tab)
    if self.currentTab then
        self.currentTab.container.Visible = false
        tween(self.currentTab.button, {BackgroundColor3 = Color3.fromRGB(22, 22, 30), BackgroundTransparency = 0.5})
    end
    
    self.currentTab = tab
    tab.container.Visible = true
    tween(tab.button, {BackgroundColor3 = Color3.fromRGB(100, 70, 180), BackgroundTransparency = 0})
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
local dragInput, dragStart, startPos

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
        fpsLabel.Text = frames .. " FPS"
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
