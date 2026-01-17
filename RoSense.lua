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
    tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    fastTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent
    })
end

local function createStroke(parent, color, thickness)
    return create("UIStroke", {
        Color = color or Color3.fromRGB(120, 80, 200),
        Thickness = thickness or 1,
        Transparency = 0.6,
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
    Size = UDim2.new(0, 650, 0, 450),
    Position = UDim2.new(0.5, -325, 0.5, -225),
    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Parent = sg
})

createCorner(main, 12)
createStroke(main, Color3.fromRGB(120, 80, 200), 1.5)

local blur = create("ImageLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.5,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(10, 10, 118, 118),
    Parent = main,
    ZIndex = 0
})

createCorner(blur, 12)

local topBar = create("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = Color3.fromRGB(10, 10, 15),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Parent = main
})

createCorner(topBar, 12)
createStroke(topBar, Color3.fromRGB(120, 80, 200), 1)

local title = create("TextLabel", {
    Name = "Title",
    Size = UDim2.new(0, 120, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "RoSense",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(160, 120, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = topBar
})

local fpsLabel = create("TextLabel", {
    Name = "FPS",
    Size = UDim2.new(0, 80, 1, 0),
    Position = UDim2.new(1, -180, 0, 0),
    BackgroundTransparency = 1,
    Text = "FPS: 60",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = topBar
})

local pingLabel = create("TextLabel", {
    Name = "Ping",
    Size = UDim2.new(0, 80, 1, 0),
    Position = UDim2.new(1, -90, 0, 0),
    BackgroundTransparency = 1,
    Text = "PING: 0",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = topBar
})

local minimizeBtn = create("TextButton", {
    Name = "Minimize",
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -38, 0, 7.5),
    BackgroundColor3 = Color3.fromRGB(20, 20, 30),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Text = "─",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(200, 200, 200),
    Parent = topBar
})

createCorner(minimizeBtn, 6)

minimizeBtn.MouseEnter:Connect(function()
    tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(120, 80, 200)}, RoSense.fastTween)
end)

minimizeBtn.MouseLeave:Connect(function()
    tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}, RoSense.fastTween)
end)

minimizeBtn.MouseButton1Click:Connect(function()
    RoSense.minimized = not RoSense.minimized
    if RoSense.minimized then
        tween(main, {Size = UDim2.new(0, 650, 0, 45)})
        minimizeBtn.Text = "□"
    else
        tween(main, {Size = UDim2.new(0, 650, 0, 450)})
        minimizeBtn.Text = "─"
    end
end)

local tabBar = create("Frame", {
    Name = "TabBar",
    Size = UDim2.new(0, 140, 1, -60),
    Position = UDim2.new(0, 10, 0, 55),
    BackgroundTransparency = 1,
    Parent = main
})

local tabContainer = create("Frame", {
    Name = "TabContainer",
    Size = UDim2.new(1, -160, 1, -60),
    Position = UDim2.new(0, 155, 0, 55),
    BackgroundTransparency = 1,
    Parent = main
})

local componentLib = {}

function componentLib.Toggle(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Toggle",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local toggle = create("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0,
        Parent = container
    })
    
    createCorner(toggle, 10)
    createStroke(toggle, Color3.fromRGB(60, 60, 80), 1)
    
    local knob = create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(200, 200, 200),
        BorderSizePixel = 0,
        Parent = toggle
    })
    
    createCorner(knob, 7)
    
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = toggle
    })
    
    local enabled = props.default or false
    
    local function update()
        if enabled then
            tween(toggle, {BackgroundColor3 = Color3.fromRGB(120, 80, 200)})
            tween(knob, {Position = UDim2.new(1, -17, 0.5, -7)})
        else
            tween(toggle, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)})
            tween(knob, {Position = UDim2.new(0, 3, 0.5, -7)})
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
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = props.text or "Button",
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Parent = props.parent
    })
    
    createCorner(btn, 6)
    createStroke(btn, Color3.fromRGB(120, 80, 200), 1)
    
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(120, 80, 200)}, RoSense.fastTween)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}, RoSense.fastTween)
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
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 18),
        BackgroundTransparency = 1,
        Text = props.text or "Slider",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local value = create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 18),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(props.default or props.min or 0),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(160, 120, 220),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    local slider = create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0,
        Parent = container
    })
    
    createCorner(slider, 3)
    
    local fill = create("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(120, 80, 200),
        BorderSizePixel = 0,
        Parent = slider
    })
    
    createCorner(fill, 3)
    
    local min = props.min or 0
    local max = props.max or 100
    local current = props.default or min
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        current = math.floor(min + (max - min) * pos)
        value.Text = tostring(current)
        tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, RoSense.fastTween)
        if props.callback then
            props.callback(current)
        end
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    return container
end

function componentLib.Dropdown(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local dropdown = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "",
        Parent = container
    })
    
    createCorner(dropdown, 6)
    createStroke(dropdown, Color3.fromRGB(60, 60, 80), 1)
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = props.options[1] or "Select",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown
    })
    
    local arrow = create("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -25, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(160, 120, 220),
        Parent = dropdown
    })
    
    local list = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = Color3.fromRGB(20, 20, 30),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        Parent = container,
        ZIndex = 10
    })
    
    createCorner(list, 6)
    createStroke(list, Color3.fromRGB(120, 80, 200), 1)
    
    local listLayout = create("UIListLayout", {
        Padding = UDim.new(0, 2),
        Parent = list
    })
    
    for _, opt in ipairs(props.options) do
        local optBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(25, 25, 35),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Text = opt,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Parent = list
        })
        
        optBtn.MouseEnter:Connect(function()
            tween(optBtn, {BackgroundColor3 = Color3.fromRGB(120, 80, 200)}, RoSense.fastTween)
        end)
        
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}, RoSense.fastTween)
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            label.Text = opt
            list.Visible = false
            tween(list, {Size = UDim2.new(1, 0, 0, 0)})
            if props.callback then
                props.callback(opt)
            end
        end)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        if list.Visible then
            tween(list, {Size = UDim2.new(1, 0, 0, #props.options * 32)})
        else
            tween(list, {Size = UDim2.new(1, 0, 0, 0)})
        end
    end)
    
    return container
end

function componentLib.ColorPicker(props)
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Parent = props.parent
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = props.text or "Color",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local preview = create("TextButton", {
        Size = UDim2.new(0, 40, 0, 25),
        Position = UDim2.new(1, -40, 0.5, -12.5),
        BackgroundColor3 = props.default or Color3.fromRGB(120, 80, 200),
        BorderSizePixel = 0,
        Text = "",
        Parent = container
    })
    
    createCorner(preview, 6)
    createStroke(preview, Color3.fromRGB(255, 255, 255), 1.5)
    
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
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(20, 20, 30),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = "",
        Parent = tabBar
    })
    
    createCorner(btn, 8)
    
    local iconLabel = create("TextLabel", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = icon or "◆",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(160, 120, 220),
        Parent = btn
    })
    
    local nameLabel = create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 45, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn
    })
    
    local content = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(120, 80, 200),
        Visible = false,
        Parent = tabContainer
    })
    
    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = content
    })
    
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        Parent = content
    })
    
    tab.button = btn
    tab.container = content
    
    btn.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    btn.MouseEnter:Connect(function()
        if self.currentTab ~= tab then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 45)}, RoSense.fastTween)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if self.currentTab ~= tab then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}, RoSense.fastTween)
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
        tween(self.currentTab.button, {BackgroundColor3 = Color3.fromRGB(20, 20, 30)})
    end
    
    self.currentTab = tab
    tab.container.Visible = true
    tween(tab.button, {BackgroundColor3 = Color3.fromRGB(120, 80, 200)})
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

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - main.AbsolutePosition.Y <= 45 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        tween(main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, RoSense.fastTween)
    end
end)

local lastUpdate = tick()
local frames = 0

RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastUpdate >= 1 then
        fpsLabel.Text = "FPS: " .. frames
        pingLabel.Text = "PING: " .. math.floor(player:GetNetworkPing() * 1000)
        frames = 0
        lastUpdate = tick()
    end
end)

local mainTab = RoSense:CreateTab("Main", "●")
mainTab:AddToggle({text = "Example Toggle", default = false, callback = function(v) end})
mainTab:AddButton({text = "Example Button", callback = function() end})
mainTab:AddSlider({text = "Example Slider", min = 0, max = 100, default = 50, callback = function(v) end})
mainTab:AddDropdown({options = {"Option 1", "Option 2", "Option 3"}, callback = function(v) end})
mainTab:AddColorPicker({text = "Example Color", default = Color3.fromRGB(120, 80, 200), callback = function(v) end})

RoSense:CreateConfigUI()

RoSense.CustomIncludes = function(tabName)
    return RoSense:CreateTab(tabName, "★")
end

return RoSense
