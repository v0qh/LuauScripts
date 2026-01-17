local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameSense"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
if syn then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function Library:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    MainFrame.Size = UDim2.new(0, 800, 0, 600)
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 28)
    TopBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 50, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Font = Enum.Font.SourceSans
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    
    local IconBar = Instance.new("Frame")
    IconBar.Name = "IconBar"
    IconBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    IconBar.BorderSizePixel = 0
    IconBar.Position = UDim2.new(0, 0, 0, 28)
    IconBar.Size = UDim2.new(0, 45, 1, -28)
    IconBar.Parent = MainFrame
    
    local IconList = Instance.new("UIListLayout")
    IconList.SortOrder = Enum.SortOrder.LayoutOrder
    IconList.Padding = UDim.new(0, 2)
    IconList.Parent = IconBar
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 45, 0, 28)
    ContentFrame.Size = UDim2.new(1, -45, 1, -28)
    ContentFrame.Parent = MainFrame
    
    local icons = {
        "🎯", "👁", "🎨", "⚙", "📊", "🔧", "💾", "🌐"
    }
    
    function Window:CreateTab(name, iconIndex)
        local Tab = {}
        Tab.Sections = {}
        Tab.LeftColumn = nil
        Tab.RightColumn = nil
        
        local iconText = icons[iconIndex or 1]
        
        local IconButton = Instance.new("TextButton")
        IconButton.Name = name
        IconButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        IconButton.BorderSizePixel = 0
        IconButton.Size = UDim2.new(1, 0, 0, 42)
        IconButton.Font = Enum.Font.SourceSans
        IconButton.Text = iconText
        IconButton.TextColor3 = Color3.fromRGB(140, 140, 140)
        IconButton.TextSize = 20
        IconButton.Parent = IconBar
        
        local TabContent = Instance.new("Frame")
        TabContent.Name = name .. "Content"
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentFrame
        
        local LeftScroll = Instance.new("ScrollingFrame")
        LeftScroll.Name = "LeftColumn"
        LeftScroll.BackgroundTransparency = 1
        LeftScroll.BorderSizePixel = 0
        LeftScroll.Position = UDim2.new(0, 5, 0, 5)
        LeftScroll.Size = UDim2.new(0.5, -8, 1, -10)
        LeftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftScroll.ScrollBarThickness = 2
        LeftScroll.ScrollBarImageColor3 = Color3.fromRGB(160, 200, 90)
        LeftScroll.Parent = TabContent
        
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 8)
        LeftLayout.Parent = LeftScroll
        
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LeftScroll.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local RightScroll = Instance.new("ScrollingFrame")
        RightScroll.Name = "RightColumn"
        RightScroll.BackgroundTransparency = 1
        RightScroll.BorderSizePixel = 0
        RightScroll.Position = UDim2.new(0.5, 3, 0, 5)
        RightScroll.Size = UDim2.new(0.5, -8, 1, -10)
        RightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightScroll.ScrollBarThickness = 2
        RightScroll.ScrollBarImageColor3 = Color3.fromRGB(160, 200, 90)
        RightScroll.Parent = TabContent
        
        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 8)
        RightLayout.Parent = RightScroll
        
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightScroll.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 10)
        end)
        
        Tab.LeftColumn = LeftScroll
        Tab.RightColumn = RightScroll
        
        IconButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                tab.Button.TextColor3 = Color3.fromRGB(140, 140, 140)
            end
            TabContent.Visible = true
            IconButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            IconButton.TextColor3 = Color3.fromRGB(160, 200, 90)
            Window.CurrentTab = Tab
        end)
        
        if Window.CurrentTab == nil then
            TabContent.Visible = true
            IconButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            IconButton.TextColor3 = Color3.fromRGB(160, 200, 90)
            Window.CurrentTab = Tab
        end
        
        Tab.Button = IconButton
        Tab.Content = TabContent
        table.insert(Window.Tabs, Tab)
        
        function Tab:CreateSection(name, column)
            local Section = {}
            local parent = column == "right" and RightScroll or LeftScroll
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = name
            SectionFrame.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
            SectionFrame.BorderSizePixel = 1
            SectionFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.Parent = parent
            
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "Header"
            SectionHeader.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
            SectionHeader.BorderSizePixel = 0
            SectionHeader.Size = UDim2.new(1, 0, 0, 24)
            SectionHeader.Parent = SectionFrame
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 8, 0, 0)
            SectionTitle.Size = UDim2.new(1, -16, 1, 0)
            SectionTitle.Font = Enum.Font.SourceSansSemibold
            SectionTitle.Text = name
            SectionTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
            SectionTitle.TextSize = 12
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionHeader
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 0, 0, 24)
            SectionContent.Size = UDim2.new(1, 0, 1, -24)
            SectionContent.Parent = SectionFrame
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 4)
            SectionLayout.Parent = SectionContent
            
            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingLeft = UDim.new(0, 8)
            SectionPadding.PaddingRight = UDim.new(0, 8)
            SectionPadding.PaddingTop = UDim.new(0, 6)
            SectionPadding.PaddingBottom = UDim.new(0, 8)
            SectionPadding.Parent = SectionContent
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y + 38)
            end)
            
            function Section:Toggle(name, default, callback)
                local toggled = default or false
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = name
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size = UDim2.new(1, 0, 0, 18)
                ToggleFrame.Parent = SectionContent
                
                local Checkbox = Instance.new("Frame")
                Checkbox.Name = "Checkbox"
                Checkbox.BackgroundColor3 = toggled and Color3.fromRGB(160, 200, 90) or Color3.fromRGB(50, 50, 50)
                Checkbox.BorderSizePixel = 1
                Checkbox.BorderColor3 = Color3.fromRGB(60, 60, 60)
                Checkbox.Size = UDim2.new(0, 12, 0, 12)
                Checkbox.Position = UDim2.new(0, 0, 0, 3)
                Checkbox.Parent = ToggleFrame
                
                local CheckMark = Instance.new("TextLabel")
                CheckMark.BackgroundTransparency = 1
                CheckMark.Size = UDim2.new(1, 0, 1, 0)
                CheckMark.Font = Enum.Font.SourceSansBold
                CheckMark.Text = toggled and "✓" or ""
                CheckMark.TextColor3 = Color3.fromRGB(255, 255, 255)
                CheckMark.TextSize = 10
                CheckMark.Parent = Checkbox
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Name = "Label"
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Position = UDim2.new(0, 18, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -18, 1, 0)
                ToggleLabel.Font = Enum.Font.SourceSans
                ToggleLabel.Text = name
                ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ToggleLabel.TextSize = 12
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Tween(Checkbox, {BackgroundColor3 = toggled and Color3.fromRGB(160, 200, 90) or Color3.fromRGB(50, 50, 50)})
                    CheckMark.Text = toggled and "✓" or ""
                    callback(toggled)
                end)
            end
            
            function Section:Slider(name, min, max, default, callback)
                local value = default or min
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = name
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, 32)
                SliderFrame.Parent = SectionContent
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = "Label"
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Size = UDim2.new(0.7, 0, 0, 14)
                SliderLabel.Font = Enum.Font.SourceSans
                SliderLabel.Text = name
                SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                SliderLabel.TextSize = 12
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = "Value"
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
                ValueLabel.Size = UDim2.new(0.3, 0, 0, 14)
                ValueLabel.Font = Enum.Font.SourceSans
                ValueLabel.Text = tostring(value)
                ValueLabel.TextColor3 = Color3.fromRGB(160, 200, 90)
                ValueLabel.TextSize = 12
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame
                
                local SliderBack = Instance.new("Frame")
                SliderBack.Name = "Back"
                SliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                SliderBack.BorderSizePixel = 1
                SliderBack.BorderColor3 = Color3.fromRGB(60, 60, 60)
                SliderBack.Position = UDim2.new(0, 0, 0, 18)
                SliderBack.Size = UDim2.new(1, 0, 0, 10)
                SliderBack.Parent = SliderFrame
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.BackgroundColor3 = Color3.fromRGB(160, 200, 90)
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                SliderFill.Parent = SliderBack
                
                local dragging = false
                
                SliderBack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percentage = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + (max - min) * percentage)
                        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                        ValueLabel.Text = tostring(value)
                        callback(value)
                    end
                end)
            end
            
            function Section:Dropdown(name, options, callback)
                local selected = options[1] or ""
                local opened = false
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = name
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.Parent = SectionContent
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Size = UDim2.new(1, 0, 0, 14)
                DropdownLabel.Font = Enum.Font.SourceSans
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownLabel.TextSize = 12
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "Button"
                DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                DropdownButton.BorderSizePixel = 1
                DropdownButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
                DropdownButton.Position = UDim2.new(0, 0, 0, 16)
                DropdownButton.Size = UDim2.new(1, 0, 0, 18)
                DropdownButton.Font = Enum.Font.SourceSans
                DropdownButton.Text = selected
                DropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownButton.TextSize = 11
                DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                DropdownButton.Parent = DropdownFrame
                
                local DropdownPadding = Instance.new("UIPadding")
                DropdownPadding.PaddingLeft = UDim.new(0, 6)
                DropdownPadding.PaddingRight = UDim.new(0, 6)
                DropdownPadding.Parent = DropdownButton
                
                local Arrow = Instance.new("TextLabel")
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -16, 0, 0)
                Arrow.Size = UDim2.new(0, 16, 1, 0)
                Arrow.Font = Enum.Font.SourceSans
                Arrow.Text = "▼"
                Arrow.TextColor3 = Color3.fromRGB(140, 140, 140)
                Arrow.TextSize = 10
                Arrow.Parent = DropdownButton
                
                local DropdownList = Instance.new("Frame")
                DropdownList.Name = "List"
                DropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                DropdownList.BorderSizePixel = 1
                DropdownList.BorderColor3 = Color3.fromRGB(60, 60, 60)
                DropdownList.Position = UDim2.new(0, 0, 1, 2)
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.ClipsDescendants = true
                DropdownList.Visible = false
                DropdownList.ZIndex = 10
                DropdownList.Parent = DropdownButton
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = DropdownList
                
                for _, option in ipairs(options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = option
                    OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Size = UDim2.new(1, 0, 0, 16)
                    OptionButton.Font = Enum.Font.SourceSans
                    OptionButton.Text = option
                    OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptionButton.TextSize = 11
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    OptionButton.ZIndex = 11
                    OptionButton.Parent = DropdownList
                    
                    local OptionPadding = Instance.new("UIPadding")
                    OptionPadding.PaddingLeft = UDim.new(0, 6)
                    OptionPadding.Parent = OptionButton
                    
                    OptionButton.MouseEnter:Connect(function()
                        OptionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        DropdownButton.Text = selected
                        opened = false
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)})
                        task.wait(0.15)
                        DropdownList.Visible = false
                        callback(selected)
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    if opened then
                        DropdownList.Visible = true
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, #options * 16)})
                    else
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)})
                        task.wait(0.15)
                        DropdownList.Visible = false
                    end
                end)
            end
            
            function Section:Button(name, callback)
                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Name = name
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                ButtonFrame.BorderSizePixel = 1
                ButtonFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
                ButtonFrame.Size = UDim2.new(1, 0, 0, 22)
                ButtonFrame.Font = Enum.Font.SourceSans
                ButtonFrame.Text = name
                ButtonFrame.TextColor3 = Color3.fromRGB(200, 200, 200)
                ButtonFrame.TextSize = 12
                ButtonFrame.Parent = SectionContent
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(160, 200, 90), TextColor3 = Color3.fromRGB(30, 30, 30)})
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(50, 50, 50), TextColor3 = Color3.fromRGB(200, 200, 200)})
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    callback()
                end)
            end
            
            function Section:ColorPicker(name, default, callback)
                local color = default or Color3.fromRGB(160, 200, 90)
                local opened = false
                
                local PickerFrame = Instance.new("Frame")
                PickerFrame.Name = name
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Size = UDim2.new(1, 0, 0, 18)
                PickerFrame.ClipsDescendants = false
                PickerFrame.Parent = SectionContent
                
                local PickerLabel = Instance.new("TextLabel")
                PickerLabel.Name = "Label"
                PickerLabel.BackgroundTransparency = 1
                PickerLabel.Size = UDim2.new(1, -24, 1, 0)
                PickerLabel.Font = Enum.Font.SourceSans
                PickerLabel.Text = name
                PickerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                PickerLabel.TextSize = 12
                PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                PickerLabel.Parent = PickerFrame
                
                local ColorDisplay = Instance.new("TextButton")
                ColorDisplay.Name = "Display"
                ColorDisplay.BackgroundColor3 = color
                ColorDisplay.BorderSizePixel = 1
                ColorDisplay.BorderColor3 = Color3.fromRGB(60, 60, 60)
                ColorDisplay.Position = UDim2.new(1, -18, 0, 3)
                ColorDisplay.Size = UDim2.new(0, 18, 0, 12)
                ColorDisplay.Text = ""
                ColorDisplay.Parent = PickerFrame
                
                local PickerWindow = Instance.new("Frame")
                PickerWindow.Name = "Window"
                PickerWindow.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                PickerWindow.BorderSizePixel = 1
                PickerWindow.BorderColor3 = Color3.fromRGB(60, 60, 60)
                PickerWindow.Position = UDim2.new(0, 0, 1, 4)
                PickerWindow.Size = UDim2.new(0, 180, 0, 180)
                PickerWindow.Visible = false
                PickerWindow.ZIndex = 15
                PickerWindow.Parent = PickerFrame
                
                local Palette = Instance.new("ImageButton")
                Palette.Name = "Palette"
                Palette.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Palette.BorderSizePixel = 0
                Palette.Position = UDim2.new(0, 8, 0, 8)
                Palette.Size = UDim2.new(0, 140, 0, 140)
                Palette.Image = "rbxassetid://4155801252"
                Palette.ZIndex = 16
                Palette.Parent = PickerWindow
                
                local HueSlider = Instance.new("ImageButton")
                HueSlider.Name = "Hue"
                HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueSlider.BorderSizePixel = 0
                HueSlider.Position = UDim2.new(0, 156, 0, 8)
                HueSlider.Size = UDim2.new(0, 16, 0, 140)
                HueSlider.Image = "rbxassetid://3641079629"
                HueSlider.ZIndex = 16
                HueSlider.Parent = PickerWindow
                
                local hue, sat, val = 0.33, 0.63, 0.78
                
                ColorDisplay.MouseButton1Click:Connect(function()
                    opened = not opened
                    PickerWindow.Visible = opened
                end)
                
                Palette.MouseButton1Down:Connect(function()
                    local dragging = true
                    local connection
                    connection = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                            connection:Disconnect()
                        end
                    end)
                    while dragging do
                        local mousePos = UserInputService:GetMouseLocation()
                        local relativeX = math.clamp((mousePos.X - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X, 0, 1)
                        local relativeY = math.clamp((mousePos.Y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y, 0, 1)
                        sat = relativeX
                        val = 1 - relativeY
                        color = Color3.fromHSV(hue, sat, val)
                        ColorDisplay.BackgroundColor3 = color
                        callback(color)
                        RunService.RenderStepped:Wait()
                    end
                end)
                
                HueSlider.MouseButton1Down:Connect(function()
                    local dragging = true
                    local connection
                    connection = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                            connection:Disconnect()
                        end
                    end)
                    while dragging do
                        local mousePos = UserInputService:GetMouseLocation()
                        local relativeY = math.clamp((mousePos.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                        hue = relativeY
                        color = Color3.fromHSV(hue, sat, val)
                        Palette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        ColorDisplay.BackgroundColor3 = color
                        callback(color)
                        RunService.RenderStepped:Wait()
                    end
                end)
            end
            
            function Section:Textbox(name, placeholder, callback)
                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.Name = name
                TextboxFrame.BackgroundTransparency = 1
                TextboxFrame.Size = UDim2.new(1, 0, 0, 32)
                TextboxFrame.Parent = SectionContent
                
                local TextboxLabel = Instance.new("TextLabel")
                TextboxLabel.Name = "Label"
                TextboxLabel.BackgroundTransparency = 1
                TextboxLabel.Size = UDim2.new(1, 0, 0, 14)
                TextboxLabel.Font = Enum.Font.SourceSans
                TextboxLabel.Text = name
                TextboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                TextboxLabel.TextSize = 12
                TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextboxLabel.Parent = TextboxFrame
                
                local Textbox = Instance.new("TextBox")
                Textbox.Name = "Box"
                Textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Textbox.BorderSizePixel = 1
                Textbox.BorderColor3 = Color3.fromRGB(60, 60, 60)
                Textbox.Position = UDim2.new(0, 0, 0, 16)
                Textbox.Size = UDim2.new(1, 0, 0, 16)
                Textbox.Font = Enum.Font.SourceSans
                Textbox.PlaceholderText = placeholder
                Textbox.Text = ""
                Textbox.TextColor3 = Color3.fromRGB(200, 200, 200)
                Textbox.TextSize = 11
                Textbox.TextXAlignment = Enum.TextXAlignment.Left
                Textbox.Parent = TextboxFrame
                
                local BoxPadding = Instance.new("UIPadding")
                BoxPadding.PaddingLeft = UDim.new(0, 6)
                BoxPadding.Parent = Textbox
                
                Textbox.FocusLost:Connect(function()
                    callback(Textbox.Text)
                end)
            end
            
            function Section:Label(text)
                local LabelFrame = Instance.new("TextLabel")
                LabelFrame.Name = "Label"
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Size = UDim2.new(1, 0, 0, 14)
                LabelFrame.Font = Enum.Font.SourceSans
                LabelFrame.Text = text
                LabelFrame.TextColor3 = Color3.fromRGB(160, 160, 160)
                LabelFrame.TextSize = 11
                LabelFrame.TextXAlignment = Enum.TextXAlignment.Left
                LabelFrame.Parent = SectionContent
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

return Library
