local RS = {}
RS.Ver = "1.0.0"
RS.Tabs = {}
RS.Cfg = {}

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local clr = {
    bg1 = Color3.fromRGB(20, 15, 25),
    bg2 = Color3.fromRGB(30, 25, 35),
    bg3 = Color3.fromRGB(40, 35, 45),
    accent = Color3.fromRGB(160, 80, 220),
    accent2 = Color3.fromRGB(120, 60, 180),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(180, 180, 180),
    border = Color3.fromRGB(80, 60, 100),
    success = Color3.fromRGB(100, 200, 100),
    error = Color3.fromRGB(220, 80, 80)
}

local tw = function(obj, info, props)
    return TweenService:Create(obj, TweenInfo.new(info.t or 0.2, info.s or Enum.EasingStyle.Quad, info.d or Enum.EasingDirection.Out), props)
end

local mkEl = function(cls, props)
    local el = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            el[k] = v
        end
    end
    if props.Parent then
        el.Parent = props.Parent
    end
    return el
end

local mkCorner = function(parent, rad)
    return mkEl("UICorner", {CornerRadius = UDim.new(0, rad or 4), Parent = parent})
end

local mkStroke = function(parent, clr, thick)
    return mkEl("UIStroke", {
        Color = clr or clr.border,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local mkPad = function(parent, all)
    return mkEl("UIPadding", {
        PaddingTop = UDim.new(0, all),
        PaddingBottom = UDim.new(0, all),
        PaddingLeft = UDim.new(0, all),
        PaddingRight = UDim.new(0, all),
        Parent = parent
    })
end

local mkList = function(parent, pad, sort)
    return mkEl("UIListLayout", {
        Padding = UDim.new(0, pad or 5),
        SortOrder = sort or Enum.SortOrder.LayoutOrder,
        Parent = parent
    })
end

local fps = 0
local fpsCount = 0
local fpsTimer = 0

RunService.RenderStepped:Connect(function(dt)
    fpsCount = fpsCount + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 1 then
        fps = fpsCount
        fpsCount = 0
        fpsTimer = 0
    end
end)

local getPing = function()
    local ping = 0
    pcall(function()
        ping = LP:GetNetworkPing() * 1000
    end)
    return math.floor(ping)
end

function RS:New(cfg)
    local win = {}
    
    local sg = mkEl("ScreenGui", {
        Name = "RoSense",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    local main = mkEl("Frame", {
        Name = "Main",
        Parent = sg,
        BackgroundColor3 = clr.bg1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        Active = true,
        Draggable = false
    })
    mkCorner(main, 6)
    mkStroke(main, clr.border, 2)
    
    local topBar = mkEl("Frame", {
        Name = "TopBar",
        Parent = main,
        BackgroundColor3 = clr.bg2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
    })
    mkCorner(topBar, 6)
    
    local titleLbl = mkEl("TextLabel", {
        Name = "Title",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = cfg.name or "RoSense",
        TextColor3 = clr.accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local closeBtn = mkEl("TextButton", {
        Name = "Close",
        Parent = topBar,
        BackgroundColor3 = clr.bg3,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = clr.error,
        TextSize = 14
    })
    mkCorner(closeBtn, 4)
    
    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)
    
    local statsBar = mkEl("Frame", {
        Name = "Stats",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -200, 0, 0),
        Size = UDim2.new(0, 165, 1, 0)
    })
    
    local fpsLbl = mkEl("TextLabel", {
        Name = "FPS",
        Parent = statsBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.33, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "FPS: 0",
        TextColor3 = clr.textDim,
        TextSize = 11
    })
    
    local pingLbl = mkEl("TextLabel", {
        Name = "Ping",
        Parent = statsBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.33, 0, 0, 0),
        Size = UDim2.new(0.33, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "PING: 0",
        TextColor3 = clr.textDim,
        TextSize = 11
    })
    
    local timeLbl = mkEl("TextLabel", {
        Name = "Time",
        Parent = statsBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.66, 0, 0, 0),
        Size = UDim2.new(0.34, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "00:00",
        TextColor3 = clr.textDim,
        TextSize = 11
    })
    
    spawn(function()
        while sg.Parent do
            fpsLbl.Text = "FPS: " .. fps
            pingLbl.Text = "PING: " .. getPing()
            local t = os.date("*t")
            timeLbl.Text = string.format("%02d:%02d", t.hour, t.min)
            wait(0.5)
        end
    end)
    
    local tabBar = mkEl("Frame", {
        Name = "TabBar",
        Parent = main,
        BackgroundColor3 = clr.bg2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 60, 1, -35)
    })
    
    local tabList = mkList(tabBar, 5)
    mkPad(tabBar, 10)
    
    local contentArea = mkEl("Frame", {
        Name = "Content",
        Parent = main,
        BackgroundColor3 = clr.bg1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 60, 0, 35),
        Size = UDim2.new(1, -60, 1, -35)
    })
    
    local drg = false
    local drgIn
    local drgSt
    local stPos
    
    topBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drg = true
            drgSt = inp.Position
            stPos = main.Position
            
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    drg = false
                end
            end)
        end
    end)
    
    UIS.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement and drg then
            local delta = inp.Position - drgSt
            main.Position = UDim2.new(stPos.X.Scale, stPos.X.Offset + delta.X, stPos.Y.Scale, stPos.Y.Offset + delta.Y)
        end
    end)
    
    local curTab
    
    function win:Tab(cfg)
        local tab = {}
        local tabBtn = mkEl("TextButton", {
            Name = cfg.name,
            Parent = tabBar,
            BackgroundColor3 = clr.bg3,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 40),
            Font = Enum.Font.GothamBold,
            Text = "",
            TextColor3 = clr.text,
            TextSize = 12,
            AutoButtonColor = false
        })
        mkCorner(tabBtn, 4)
        
        local icon = mkEl("ImageLabel", {
            Name = "Icon",
            Parent = tabBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -12, 0.5, -12),
            Size = UDim2.new(0, 24, 0, 24),
            Image = cfg.icon or "rbxassetid://7734053426",
            ImageColor3 = clr.textDim
        })
        
        local tabContent = mkEl("Frame", {
            Name = cfg.name .. "Content",
            Parent = contentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false
        })
        
        local scroll = mkEl("ScrollingFrame", {
            Name = "Scroll",
            Parent = tabContent,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = clr.accent
        })
        mkPad(scroll, 15)
        
        local sectList = mkList(scroll, 10)
        
        sectList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, sectList.AbsoluteContentSize.Y + 30)
        end)
        
        local function setTab(active)
            if active then
                tabBtn.BackgroundColor3 = clr.accent
                icon.ImageColor3 = clr.text
                tabContent.Visible = true
                curTab = tabContent
            else
                tabBtn.BackgroundColor3 = clr.bg3
                icon.ImageColor3 = clr.textDim
                tabContent.Visible = false
            end
        end
        
        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(contentArea:GetChildren()) do
                if t:IsA("Frame") then
                    t.Visible = false
                end
            end
            for _, b in pairs(tabBar:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = clr.bg3
                    local ic = b:FindFirstChild("Icon")
                    if ic then
                        ic.ImageColor3 = clr.textDim
                    end
                end
            end
            setTab(true)
        end)
        
        if not curTab then
            setTab(true)
        end
        
        function tab:Sect(cfg)
            local sect = {}
            
            local sectFrame = mkEl("Frame", {
                Name = cfg.name,
                Parent = scroll,
                BackgroundColor3 = clr.bg2,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40)
            })
            mkCorner(sectFrame, 4)
            mkStroke(sectFrame, clr.border)
            
            local sectTitle = mkEl("TextLabel", {
                Name = "Title",
                Parent = sectFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -30, 0, 30),
                Font = Enum.Font.GothamBold,
                Text = cfg.name,
                TextColor3 = clr.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sectContainer = mkEl("Frame", {
                Name = "Container",
                Parent = sectFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 1, -40)
            })
            
            local sectList = mkList(sectContainer, 8)
            
            sectList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectFrame.Size = UDim2.new(1, 0, 0, sectList.AbsoluteContentSize.Y + 45)
            end)
            
            function sect:Toggle(cfg)
                local tog = {val = cfg.def or false}
                
                local togFrame = mkEl("Frame", {
                    Name = cfg.name,
                    Parent = sectContainer,
                    BackgroundColor3 = clr.bg3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                mkCorner(togFrame, 4)
                
                local togLbl = mkEl("TextLabel", {
                    Name = "Label",
                    Parent = togFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = cfg.name,
                    TextColor3 = clr.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local togBtn = mkEl("TextButton", {
                    Name = "Toggle",
                    Parent = togFrame,
                    BackgroundColor3 = tog.val and clr.accent or clr.bg1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -35, 0.5, -10),
                    Size = UDim2.new(0, 30, 0, 20),
                    Text = "",
                    AutoButtonColor = false
                })
                mkCorner(togBtn, 10)
                
                local togInd = mkEl("Frame", {
                    Name = "Indicator",
                    Parent = togBtn,
                    BackgroundColor3 = clr.text,
                    BorderSizePixel = 0,
                    Position = tog.val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                mkCorner(togInd, 8)
                
                togBtn.MouseButton1Click:Connect(function()
                    tog.val = not tog.val
                    
                    tw(togBtn, {t = 0.15}, {BackgroundColor3 = tog.val and clr.accent or clr.bg1}):Play()
                    tw(togInd, {t = 0.15}, {Position = tog.val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                    
                    if cfg.callback then
                        cfg.callback(tog.val)
                    end
                end)
                
                function tog:Set(val)
                    tog.val = val
                    tw(togBtn, {t = 0.15}, {BackgroundColor3 = tog.val and clr.accent or clr.bg1}):Play()
                    tw(togInd, {t = 0.15}, {Position = tog.val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                end
                
                return tog
            end
            
            function sect:Button(cfg)
                local btn = {}
                
                local btnFrame = mkEl("TextButton", {
                    Name = cfg.name,
                    Parent = sectContainer,
                    BackgroundColor3 = clr.bg3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.name,
                    TextColor3 = clr.text,
                    TextSize = 12,
                    AutoButtonColor = false
                })
                mkCorner(btnFrame, 4)
                
                btnFrame.MouseEnter:Connect(function()
                    tw(btnFrame, {t = 0.15}, {BackgroundColor3 = clr.accent2}):Play()
                end)
                
                btnFrame.MouseLeave:Connect(function()
                    tw(btnFrame, {t = 0.15}, {BackgroundColor3 = clr.bg3}):Play()
                end)
                
                btnFrame.MouseButton1Click:Connect(function()
                    tw(btnFrame, {t = 0.1}, {BackgroundColor3 = clr.accent}):Play()
                    wait(0.1)
                    tw(btnFrame, {t = 0.1}, {BackgroundColor3 = clr.accent2}):Play()
                    
                    if cfg.callback then
                        cfg.callback()
                    end
                end)
                
                return btn
            end
            
            function sect:Textbox(cfg)
                local txtbox = {val = cfg.def or ""}
                
                local txtFrame = mkEl("Frame", {
                    Name = cfg.name,
                    Parent = sectContainer,
                    BackgroundColor3 = clr.bg3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 60)
                })
                mkCorner(txtFrame, 4)
                
                local txtLbl = mkEl("TextLabel", {
                    Name = "Label",
                    Parent = txtFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = cfg.name,
                    TextColor3 = clr.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local txtInput = mkEl("TextBox", {
                    Name = "Input",
                    Parent = txtFrame,
                    BackgroundColor3 = clr.bg1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 25),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = cfg.placeholder or "Enter text...",
                    PlaceholderColor3 = clr.textDim,
                    Text = txtbox.val,
                    TextColor3 = clr.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })
                mkCorner(txtInput, 4)
                mkPad(txtInput, 8)
                
                txtInput.FocusLost:Connect(function()
                    txtbox.val = txtInput.Text
                    if cfg.callback then
                        cfg.callback(txtbox.val)
                    end
                end)
                
                function txtbox:Set(val)
                    txtbox.val = val
                    txtInput.Text = val
                end
                
                return txtbox
            end
            
            function sect:Dropdown(cfg)
                local dd = {val = cfg.def or cfg.options[1], open = false}
                
                local ddFrame = mkEl("Frame", {
                    Name = cfg.name,
                    Parent = sectContainer,
                    BackgroundColor3 = clr.bg3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 60),
                    ClipsDescendants = true
                })
                mkCorner(ddFrame, 4)
                
                local ddLbl = mkEl("TextLabel", {
                    Name = "Label",
                    Parent = ddFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = cfg.name,
                    TextColor3 = clr.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ddBtn = mkEl("TextButton", {
                    Name = "Button",
                    Parent = ddFrame,
                    BackgroundColor3 = clr.bg1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = dd.val,
                    TextColor3 = clr.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                mkCorner(ddBtn, 4)
                mkPad(ddBtn, 8)
                
                local ddArrow = mkEl("TextLabel", {
                    Name = "Arrow",
                    Parent = ddBtn,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = clr.textDim,
                    TextSize = 10
                })
                
                local ddList = mkEl("Frame", {
                    Name = "List",
                    Parent = ddFrame,
                    BackgroundColor3 = clr.bg1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 58),
                    Size = UDim2.new(1, -20, 0, 0),
                    ClipsDescendants = true
                })
                mkCorner(ddList, 4)
                
                local ddScroll = mkEl("ScrollingFrame", {
                    Name = "Scroll",
                    Parent = ddList,
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = clr.accent
                })
                
                local ddLayout = mkList(ddScroll, 2)
                
                ddLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ddScroll.CanvasSize = UDim2.new(0, 0, 0, ddLayout.AbsoluteContentSize.Y)
                end)
                
                for _, opt in pairs(cfg.options) do
                    local optBtn = mkEl("TextButton", {
                        Name = opt,
                        Parent = ddScroll,
                        BackgroundColor3 = clr.bg2,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 25),
                        Font = Enum.Font.Gotham,
                        Text = opt,
                        TextColor3 = clr.text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false
                    })
                    mkCorner(optBtn, 3)
                    mkPad(optBtn, 8)
                    
                    optBtn.MouseEnter:Connect(function()
                        tw(optBtn, {t = 0.1}, {BackgroundColor3 = clr.accent2}):Play()
                    end)
                    
                    optBtn.MouseLeave:Connect(function()
                        tw(optBtn, {t = 0.1}, {BackgroundColor3 = clr.bg2}):Play()
                    end)
                    
                    optBtn.MouseButton1Click:Connect(function()
                        dd.val = opt
                        ddBtn.Text = opt
                        dd.open = false
                        
                        tw(ddFrame, {t = 0.2}, {Size = UDim2.new(1, 0, 0, 60)}):Play()
                        tw(ddList, {t = 0.2}, {Size = UDim2.new(1, -20, 0, 0)}):Play()
                        tw(ddArrow, {t = 0.2}, {Rotation = 0}):Play()
                        
                        if cfg.callback then
                            cfg.callback(dd.val)
                        end
                    end)
                end
                
                ddBtn.MouseButton1Click:Connect(function()
                    dd.open = not dd.open
                    
                    if dd.open then
                        local h = math.min(#cfg.options * 27, 150)
                        tw(ddFrame, {t = 0.2}, {Size = UDim2.new(1, 0, 0, 60 + h + 3)}):Play()
                        tw(ddList, {t = 0.2}, {Size = UDim2.new(1, -20, 0, h)}):Play()
                        tw(ddArrow, {t = 0.2}, {Rotation = 180}):Play()
                    else
                        tw(ddFrame, {t = 0.2}, {Size = UDim2.new(1, 0, 0, 60)}):Play()
                        tw(ddList, {t = 0.2}, {Size = UDim2.new(1, -20, 0, 0)}):Play()
                        tw(ddArrow, {t = 0.2}, {Rotation = 0}):Play()
                    end
                end)
                
                function dd:Set(val)
                    dd.val = val
                    ddBtn.Text = val
                end
                
                function dd:Refresh(opts)
                    for _, c in pairs(ddScroll:GetChildren()) do
                        if c:IsA("TextButton") then
                            c:Destroy()
                        end
                    end
                    
                    for _, opt in pairs(opts) do
                        local optBtn = mkEl("TextButton", {
                            Name = opt,
                            Parent = ddScroll,
                            BackgroundColor3 = clr.bg2,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 25),
                            Font = Enum.Font.Gotham,
                            Text = opt,
                            TextColor3 = clr.text,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false
                        })
                        mkCorner(optBtn, 3)
                        mkPad(optBtn, 8)
                        
                        optBtn.MouseEnter:Connect(function()
                            tw(optBtn, {t = 0.1}, {BackgroundColor3 = clr.accent2}):Play()
                        end)
                        
                        optBtn.MouseLeave:Connect(function()
                            tw(optBtn, {t = 0.1}, {BackgroundColor3 = clr.bg2}):Play()
                        end)
                        
                        optBtn.MouseButton1Click:Connect(function()
                            dd.val = opt
                            ddBtn.Text = opt
                            dd.open = false
                            
                            tw(ddFrame, {t = 0.2}, {Size = UDim2.new(1, 0, 0, 60)}):Play()
                            tw(ddList, {t = 0.2}, {Size = UDim2.new(1, -20, 0, 0)}):Play()
                            tw(ddArrow, {t = 0.2}, {Rotation = 0}):Play()
                            
                            if cfg.callback then
                                cfg.callback(dd.val)
                            end
                        end)
                    end
                end
                
                return dd
            end
            
            function sect:ColorPicker(cfg)
                local cp = {val = cfg.def or Color3.fromRGB(255, 255, 255), open = false}
                
                local cpFrame = mkEl("Frame", {
                    Name = cfg.name,
                    Parent = sectContainer,
                    BackgroundColor3 = clr.bg3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35),
                    ClipsDescendants = true
                })
                mkCorner(cpFrame, 4)
                
                local cpLbl = mkEl("TextLabel", {
                    Name = "Label",
                    Parent = cpFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = cfg.name,
                    TextColor3 = clr.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local cpBtn = mkEl("TextButton", {
                    Name = "Button",
                    Parent = cpFrame,
                    BackgroundColor3 = cp.val,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -30, 0.5, -10),
                    Size = UDim2.new(0, 25, 0, 20),
                    Text = "",
                    AutoButtonColor = false
                })
                mkCorner(cpBtn, 4)
                mkStroke(cpBtn, clr.border)
                
                local cpPicker = mkEl("Frame", {
                    Name = "Picker",
                    Parent = cpFrame,
                    BackgroundColor3 = clr.bg1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 5, 0, 40),
                    Size = UDim2.new(1, -10, 0, 0),
                    ClipsDescendants = true
                })
                mkCorner(cpPicker, 4)
                mkStroke(cpPicker, clr.border)
                
                local hue = 0
                local sat = 1
                local val = 1
                
                local hsv = mkEl("Frame", {
                    Name = "HSV",
                    Parent = cpPicker,
                    BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -50, 0, 120)
                })
                mkCorner(hsv, 4)
                
                local satGrad = mkEl("UIGradient", {
                    Parent = hsv,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                    },
                    Rotation = 0,
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }
                })
                
                local valGrad = mkEl("UIGradient", {
                    Parent = hsv,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                    },
                    Rotation = 90,
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }
                })
                
                local hsvInd = mkEl("Frame", {
                    Name = "Indicator",
                    Parent = hsv,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(sat, -3, 1 - val, -3),
                    Size = UDim2.new(0, 6, 0, 6)
                })
                mkCorner(hsvInd, 3)
                mkStroke(hsvInd, Color3.fromRGB(0, 0, 0), 2)
                
                local hueBar = mkEl("Frame", {
                    Name = "Hue",
                    Parent = cpPicker,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -30, 0, 10),
                    Size = UDim2.new(0, 20, 0, 120)
                })
                mkCorner(hueBar, 4)
                
                local hueGrad = mkEl("UIGradient", {
                    Parent = hueBar,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    },
                    Rotation = 90
                })
                
                local hueInd = mkEl("Frame", {
                    Name = "Indicator",
                    Parent = hueBar,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, -2, hue, -2),
                    Size = UDim2.new(1, 4, 0, 4)
                })
                mkCorner(hueInd, 2)
                mkStroke(hueInd, Color3.fromRGB(0, 0, 0), 2)
                
                local rgbFrame = mkEl("Frame", {
                    Name = "RGB",
                    Parent = cpPicker,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 140),
                    Size = UDim2.new(1, -20, 0, 70)
                })
                
                local rgbList = mkList(rgbFrame, 5)
                
                local function mkRGB(name, def)
                    local f = mkEl("Frame", {
                        Name = name,
                        Parent = rgbFrame,
                        BackgroundColor3 = clr.bg2,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 20)
                    })
                    mkCorner(f, 3)
                    
                    local l = mkEl("TextLabel", {
                        Parent = f,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(0, 15, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = name,
                        TextColor3 = clr.text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    local t = mkEl("TextBox", {
                        Parent = f,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -50, 0, 0),
                        Size = UDim2.new(0, 45, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = tostring(def),
                        TextColor3 = clr.text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        ClearTextOnFocus = false
                    })
                    mkPad(t, 5)
                    
                    return t
                end
                
                local rBox = mkRGB("R", math.floor(cp.val.R * 255))
                local gBox = mkRGB("G", math.floor(cp.val.G * 255))
                local bBox = mkRGB("B", math.floor(cp.val.B * 255))
                
                local function updateColor()
                    local c = Color3.fromHSV(hue, sat, val)
                    cp.val = c
                    cpBtn.BackgroundColor3 = c
                    
                    rBox.Text = tostring(math.floor(c.R * 255))
                    gBox.Text = tostring(math.floor(c.G * 255))
                    bBox.Text = tostring(math.floor(c.B * 255))
                    
                    if cfg.callback then
                        cfg.callback(c)
                    end
                end
                
                local hsvDrag = false
                local hueDrag = false
                
                hsv.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        hsvDrag = true
                        
                        local pos = inp.Position - hsv.AbsolutePosition
                        sat = math.clamp(pos.X / hsv.AbsoluteSize.X, 0, 1)
                        val = 1 - math.clamp(pos.Y / hsv.AbsoluteSize.Y, 0, 1)
                        
                        hsvInd.Position = UDim2.new(sat, -3, 1 - val, -3)
                        updateColor()
                    end
                end)
                
                hsv.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        hsvDrag = false
                    end
                end)
                
                UIS.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement and hsvDrag then
                        local pos = inp.Position - hsv.AbsolutePosition
                        sat = math.clamp(pos.X / hsv.AbsoluteSize.X, 0, 1)
                        val = 1 - math.clamp(pos.Y / hsv.AbsoluteSize.Y, 0, 1)
                        
                        hsvInd.Position = UDim2.new(sat, -3, 1 - val, -3)
                        updateColor()
                    end
                end)
                
                hueBar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDrag = true
                        
                        local pos = inp.Position - hueBar.AbsolutePosition
                        hue = math.clamp(pos.Y / hueBar.AbsoluteSize.Y, 0, 1)
                        
                        hueInd.Position = UDim2.new(0, -2, hue, -2)
                        hsv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        updateColor()
                    end
                end)
                
                hueBar.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDrag = false
                    end
                end)
                
                UIS.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement and hueDrag then
                        local pos = inp.Position - hueBar.AbsolutePosition
                        hue = math.clamp(pos.Y / hueBar.AbsoluteSize.Y, 0, 1)
                        
                        hueInd.Position = UDim2.new(0, -2, hue, -2)
                        hsv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        updateColor()
                    end
                end)
                
                local function setFromRGB()
                    local r = tonumber(rBox.Text) or 255
                    local g = tonumber(gBox.Text) or 255
                    local b = tonumber(bBox.Text) or 255
                    
                    r = math.clamp(r, 0, 255)
                    g = math.clamp(g, 0, 255)
                    b = math.clamp(b, 0, 255)
                    
                    local c = Color3.fromRGB(r, g, b)
                    hue, sat, val = c:ToHSV()
                    
                    hsvInd.Position = UDim2.new(sat, -3, 1 - val, -3)
                    hueInd.Position = UDim2.new(0, -2, hue, -2)
                    hsv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    
                    cp.val = c
                    cpBtn.BackgroundColor3 = c
                    
                    if cfg.callback then
                        cfg.callback(c)
                    end
                end
                
                rBox.FocusLost:Connect(setFromRGB)
                gBox.FocusLost:Connect(setFromRGB)
                bBox.FocusLost:Connect(setFromRGB)
                
                cpBtn.MouseButton1Click:Connect(function()
                    cp.open = not cp.open
                    
                    if cp.open then
                        tw(cpFrame, {t = 0.2}, {Size = UDim2.new(1, 0, 0, 255)}):Play()
                        tw(cpPicker, {t = 0.2}, {Size = UDim2.new(1, -10, 0, 215)}):Play()
                    else
                        tw(cpFrame, {t = 0.2}, {Size = UDim2.new(1, 0, 0, 35)}):Play()
                        tw(cpPicker, {t = 0.2}, {Size = UDim2.new(1, -10, 0, 0)}):Play()
                    end
                end)
                
                function cp:Set(c)
                    cp.val = c
                    cpBtn.BackgroundColor3 = c
                    hue, sat, val = c:ToHSV()
                    
                    hsvInd.Position = UDim2.new(sat, -3, 1 - val, -3)
                    hueInd.Position = UDim2.new(0, -2, hue, -2)
                    hsv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    
                    rBox.Text = tostring(math.floor(c.R * 255))
                    gBox.Text = tostring(math.floor(c.G * 255))
                    bBox.Text = tostring(math.floor(c.B * 255))
                end
                
                return cp
            end
            
            function sect:List(cfg)
                local lst = {items = {}}
                
                local lstFrame = mkEl("Frame", {
                    Name = cfg.name,
                    Parent = sectContainer,
                    BackgroundColor3 = clr.bg3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 200),
                    ClipsDescendants = true
                })
                mkCorner(lstFrame, 4)
                
                local lstLbl = mkEl("TextLabel", {
                    Name = "Label",
                    Parent = lstFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = cfg.name,
                    TextColor3 = clr.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local lstScroll = mkEl("ScrollingFrame", {
                    Name = "Scroll",
                    Parent = lstFrame,
                    Active = true,
                    BackgroundColor3 = clr.bg1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 1, -65),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = clr.accent
                })
                mkCorner(lstScroll, 4)
                
                local lstLayout = mkList(lstScroll, 3)
                mkPad(lstScroll, 5)
                
                lstLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    lstScroll.CanvasSize = UDim2.new(0, 0, 0, lstLayout.AbsoluteContentSize.Y + 10)
                end)
                
                local addBox = mkEl("TextBox", {
                    Name = "Add",
                    Parent = lstFrame,
                    BackgroundColor3 = clr.bg1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 1, -30),
                    Size = UDim2.new(1, -65, 0, 25),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = "Add item...",
                    PlaceholderColor3 = clr.textDim,
                    Text = "",
                    TextColor3 = clr.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })
                mkCorner(addBox, 4)
                mkPad(addBox, 8)
                
                local addBtn = mkEl("TextButton", {
                    Name = "AddButton",
                    Parent = lstFrame,
                    BackgroundColor3 = clr.accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 1, -30),
                    Size = UDim2.new(0, 40, 0, 25),
                    Font = Enum.Font.GothamBold,
                    Text = "+",
                    TextColor3 = clr.text,
                    TextSize = 16,
                    AutoButtonColor = false
                })
                mkCorner(addBtn, 4)
                
                function lst:Add(txt)
                    if txt == "" then return end
                    
                    local item = mkEl("Frame", {
                        Name = txt,
                        Parent = lstScroll,
                        BackgroundColor3 = clr.bg2,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 28)
                    })
                    mkCorner(item, 3)
                    
                    local itemLbl = mkEl("TextLabel", {
                        Name = "Text",
                        Parent = item,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(1, -36, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = txt,
                        TextColor3 = clr.text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    })
                    
                    local rmvBtn = mkEl("TextButton", {
                        Name = "Remove",
                        Parent = item,
                        BackgroundColor3 = clr.error,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -26, 0.5, -10),
                        Size = UDim2.new(0, 20, 0, 20),
                        Font = Enum.Font.GothamBold,
                        Text = "×",
                        TextColor3 = clr.text,
                        TextSize = 14,
                        AutoButtonColor = false
                    })
                    mkCorner(rmvBtn, 3)
                    
                    rmvBtn.MouseButton1Click:Connect(function()
                        lst:Remove(txt)
                    end)
                    
                    table.insert(lst.items, txt)
                    
                    if cfg.callback then
                        cfg.callback("add", txt)
                    end
                end
                
                function lst:Remove(txt)
                    for i, v in pairs(lst.items) do
                        if v == txt then
                            table.remove(lst.items, i)
                            break
                        end
                    end
                    
                    for _, c in pairs(lstScroll:GetChildren()) do
                        if c:IsA("Frame") and c.Name == txt then
                            c:Destroy()
                        end
                    end
                    
                    if cfg.callback then
                        cfg.callback("remove", txt)
                    end
                end
                
                function lst:Clear()
                    for _, c in pairs(lstScroll:GetChildren()) do
                        if c:IsA("Frame") then
                            c:Destroy()
                        end
                    end
                    lst.items = {}
                    
                    if cfg.callback then
                        cfg.callback("clear", nil)
                    end
                end
                
                addBtn.MouseButton1Click:Connect(function()
                    if addBox.Text ~= "" then
                        lst:Add(addBox.Text)
                        addBox.Text = ""
                    end
                end)
                
                addBox.FocusLost:Connect(function(enter)
                    if enter and addBox.Text ~= "" then
                        lst:Add(addBox.Text)
                        addBox.Text = ""
                    end
                end)
                
                return lst
            end
            
            function sect:Slider(cfg)
                local sld = {val = cfg.def or cfg.min}
                
                local sldFrame = mkEl("Frame", {
                    Name = cfg.name,
                    Parent = sectContainer,
                    BackgroundColor3 = clr.bg3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 60)
                })
                mkCorner(sldFrame, 4)
                
                local sldLbl = mkEl("TextLabel", {
                    Name = "Label",
                    Parent = sldFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -60, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = cfg.name,
                    TextColor3 = clr.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local sldVal = mkEl("TextLabel", {
                    Name = "Value",
                    Parent = sldFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 5),
                    Size = UDim2.new(0, 45, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(sld.val),
                    TextColor3 = clr.accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local sldBar = mkEl("Frame", {
                    Name = "Bar",
                    Parent = sldFrame,
                    BackgroundColor3 = clr.bg1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 35),
                    Size = UDim2.new(1, -20, 0, 6)
                })
                mkCorner(sldBar, 3)
                
                local sldFill = mkEl("Frame", {
                    Name = "Fill",
                    Parent = sldBar,
                    BackgroundColor3 = clr.accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((sld.val - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
                })
                mkCorner(sldFill, 3)
                
                local sldBtn = mkEl("Frame", {
                    Name = "Button",
                    Parent = sldBar,
                    BackgroundColor3 = clr.text,
                    BorderSizePixel = 0,
                    Position = UDim2.new((sld.val - cfg.min) / (cfg.max - cfg.min), -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                mkCorner(sldBtn, 6)
                mkStroke(sldBtn, clr.accent, 2)
                
                local drag = false
                
                sldBar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        drag = true
                        
                        local pos = math.clamp((inp.Position.X - sldBar.AbsolutePosition.X) / sldBar.AbsoluteSize.X, 0, 1)
                        sld.val = math.floor(cfg.min + (cfg.max - cfg.min) * pos)
                        
                        if cfg.increment then
                            sld.val = math.floor(sld.val / cfg.increment) * cfg.increment
                        end
                        
                        sldVal.Text = tostring(sld.val)
                        sldFill.Size = UDim2.new((sld.val - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
                        sldBtn.Position = UDim2.new((sld.val - cfg.min) / (cfg.max - cfg.min), -6, 0.5, -6)
                        
                        if cfg.callback then
                            cfg.callback(sld.val)
                        end
                    end
                end)
                
                sldBar.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        drag = false
                    end
                end)
                
                UIS.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement and drag then
                        local pos = math.clamp((inp.Position.X - sldBar.AbsolutePosition.X) / sldBar.AbsoluteSize.X, 0, 1)
                        sld.val = math.floor(cfg.min + (cfg.max - cfg.min) * pos)
                        
                        if cfg.increment then
                            sld.val = math.floor(sld.val / cfg.increment) * cfg.increment
                        end
                        
                        sldVal.Text = tostring(sld.val)
                        sldFill.Size = UDim2.new((sld.val - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
                        sldBtn.Position = UDim2.new((sld.val - cfg.min) / (cfg.max - cfg.min), -6, 0.5, -6)
                        
                        if cfg.callback then
                            cfg.callback(sld.val)
                        end
                    end
                end)
                
                function sld:Set(val)
                    sld.val = math.clamp(val, cfg.min, cfg.max)
                    sldVal.Text = tostring(sld.val)
                    sldFill.Size = UDim2.new((sld.val - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
                    sldBtn.Position = UDim2.new((sld.val - cfg.min) / (cfg.max - cfg.min), -6, 0.5, -6)
                end
                
                return sld
            end
            
            function sect:Label(cfg)
                local lbl = {}
                
                local lblFrame = mkEl("TextLabel", {
                    Name = cfg.name,
                    Parent = sectContainer,
                    BackgroundColor3 = clr.bg3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = cfg.text or cfg.name,
                    TextColor3 = clr.textDim,
                    TextSize = 11,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                mkCorner(lblFrame, 4)
                mkPad(lblFrame, 10)
                
                function lbl:Set(txt)
                    lblFrame.Text = txt
                end
                
                return lbl
            end
            
            function sect:Keybind(cfg)
                local kb = {val = cfg.def or Enum.KeyCode.Unknown, binding = false}
                
                local kbFrame = mkEl("Frame", {
                    Name = cfg.name,
                    Parent = sectContainer,
                    BackgroundColor3 = clr.bg3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                mkCorner(kbFrame, 4)
                
                local kbLbl = mkEl("TextLabel", {
                    Name = "Label",
                    Parent = kbFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = cfg.name,
                    TextColor3 = clr.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local kbBtn = mkEl("TextButton", {
                    Name = "Button",
                    Parent = kbFrame,
                    BackgroundColor3 = clr.bg1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -70, 0.5, -12.5),
                    Size = UDim2.new(0, 65, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = kb.val.Name,
                    TextColor3 = clr.text,
                    TextSize = 10,
                    AutoButtonColor = false
                })
                mkCorner(kbBtn, 4)
                
                kbBtn.MouseButton1Click:Connect(function()
                    kb.binding = true
                    kbBtn.Text = "..."
                    kbBtn.BackgroundColor3 = clr.accent
                end)
                
                UIS.InputBegan:Connect(function(inp, gpe)
                    if kb.binding and inp.UserInputType == Enum.UserInputType.Keyboard then
                        kb.val = inp.KeyCode
                        kb.binding = false
                        kbBtn.Text = inp.KeyCode.Name
                        kbBtn.BackgroundColor3 = clr.bg1
                        
                        if cfg.callback then
                            cfg.callback(kb.val)
                        end
                    end
                    
                    if not gpe and inp.KeyCode == kb.val and cfg.mode == "toggle" then
                        if cfg.callback then
                            cfg.callback(kb.val)
                        end
                    end
                end)
                
                function kb:Set(key)
                    kb.val = key
                    kbBtn.Text = key.Name
                end
                
                return kb
            end
            
            return sect
        end
        
        return tab
    end
    
    function win:Notify(cfg)
        local nt = mkEl("Frame", {
            Name = "Notification",
            Parent = sg,
            BackgroundColor3 = clr.bg2,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -320, 1, 100),
            Size = UDim2.new(0, 300, 0, 80)
        })
        mkCorner(nt, 6)
        mkStroke(nt, cfg.type == "error" and clr.error or cfg.type == "success" and clr.success or clr.accent, 2)
        
        local ntIcon = mkEl("ImageLabel", {
            Name = "Icon",
            Parent = nt,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0.5, -15),
            Size = UDim2.new(0, 30, 0, 30),
            Image = cfg.icon or "rbxassetid://7734053426",
            ImageColor3 = cfg.type == "error" and clr.error or cfg.type == "success" and clr.success or clr.accent
        })
        
        local ntTitle = mkEl("TextLabel", {
            Name = "Title",
            Parent = nt,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 55, 0, 10),
            Size = UDim2.new(1, -70, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = cfg.title or "Notification",
            TextColor3 = clr.text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local ntDesc = mkEl("TextLabel", {
            Name = "Description",
            Parent = nt,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 55, 0, 32),
            Size = UDim2.new(1, -70, 0, 38),
            Font = Enum.Font.Gotham,
            Text = cfg.desc or "",
            TextColor3 = clr.textDim,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        
        tw(nt, {t = 0.4, s = Enum.EasingStyle.Back}, {Position = UDim2.new(1, -320, 1, -100)}):Play()
        
        task.delay(cfg.duration or 3, function()
            tw(nt, {t = 0.3}, {Position = UDim2.new(1, -320, 1, 100)}):Play()
            task.wait(0.3)
            nt:Destroy()
        end)
    end
    
    function win:Dialog(cfg)
        local dlg = {}
        
        local overlay = mkEl("Frame", {
            Name = "Overlay",
            Parent = sg,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 10
        })
        
        local dlgFrame = mkEl("Frame", {
            Name = "Dialog",
            Parent = overlay,
            BackgroundColor3 = clr.bg2,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 400, 0, 200),
            ZIndex = 11
        })
        mkCorner(dlgFrame, 6)
        mkStroke(dlgFrame, clr.accent, 2)
        
        local dlgTitle = mkEl("TextLabel", {
            Name = "Title",
            Parent = dlgFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 15),
            Size = UDim2.new(1, -40, 0, 25),
            Font = Enum.Font.GothamBold,
            Text = cfg.title or "Dialog",
            TextColor3 = clr.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11
        })
        
        local dlgDesc = mkEl("TextLabel", {
            Name = "Description",
            Parent = dlgFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 50),
            Size = UDim2.new(1, -40, 0, 100),
            Font = Enum.Font.Gotham,
            Text = cfg.desc or "",
            TextColor3 = clr.textDim,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 11
        })
        
        local btnContainer = mkEl("Frame", {
            Name = "Buttons",
            Parent = dlgFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 1, -50),
            Size = UDim2.new(1, -40, 0, 35),
            ZIndex = 11
        })
        
        local btnList = mkEl("UIListLayout", {
            Parent = btnContainer,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local function addBtn(text, callback, primary)
            local btn = mkEl("TextButton", {
                Name = text,
                Parent = btnContainer,
                BackgroundColor3 = primary and clr.accent or clr.bg3,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 100, 0, 35),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = clr.text,
                TextSize = 12,
                AutoButtonColor = false,
                ZIndex = 11
            })
            mkCorner(btn, 4)
            
            btn.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
                overlay:Destroy()
            end)
            
            return btn
        end
        
        if cfg.buttons then
            for _, btnCfg in pairs(cfg.buttons) do
                addBtn(btnCfg.text, btnCfg.callback, btnCfg.primary)
            end
        else
            addBtn("OK", cfg.callback, true)
        end
        
        return dlg
    end
    
    UIS.InputBegan:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end
    end)
    
    return win
end

local fsPath = "RoSense/"

function RS:SaveCfg(name)
    local data = HttpService:JSONEncode(RS.Cfg)
    writefile(fsPath .. name .. ".json", data)
end

function RS:LoadCfg(name)
    if isfile(fsPath .. name .. ".json") then
        local data = readfile(fsPath .. name .. ".json")
        RS.Cfg = HttpService:JSONDecode(data)
        return true
    end
    return false
end

function RS:GetCfgs()
    if not isfolder(fsPath) then
        makefolder(fsPath)
    end
    
    local cfgs = {}
    for _, file in pairs(listfiles(fsPath)) do
        if file:sub(-5) == ".json" then
            local name = file:gsub(fsPath, ""):gsub(".json", "")
            table.insert(cfgs, name)
        end
    end
    return cfgs
end

function RS:DelCfg(name)
    if isfile(fsPath .. name .. ".json") then
        delfile(fsPath .. name .. ".json")
        return true
    end
    return false
end

function RS:SaveAsset(name, url)
    if not isfolder(fsPath .. "assets/") then
        makefolder(fsPath .. "assets/")
    end
    
    local data = game:HttpGet(url)
    writefile(fsPath .. "assets/" .. name, data)
end

function RS:GetAsset(name)
    if isfile(fsPath .. "assets/" .. name) then
        return getcustomasset(fsPath .. "assets/" .. name)
    end
    return nil
end

function RS:SetTheme(theme)
    if theme.bg1 then clr.bg1 = theme.bg1 end
    if theme.bg2 then clr.bg2 = theme.bg2 end
    if theme.bg3 then clr.bg3 = theme.bg3 end
    if theme.accent then clr.accent = theme.accent end
    if theme.accent2 then clr.accent2 = theme.accent2 end
    if theme.text then clr.text = theme.text end
    if theme.textDim then clr.textDim = theme.textDim end
    if theme.border then clr.border = theme.border end
end

function RS:GetTheme()
    return {
        bg1 = clr.bg1,
        bg2 = clr.bg2,
        bg3 = clr.bg3,
        accent = clr.accent,
        accent2 = clr.accent2,
        text = clr.text,
        textDim = clr.textDim,
        border = clr.border
    }
end

return RS
