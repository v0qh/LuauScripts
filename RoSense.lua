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
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Ripple(parent, x, y)
    local circle = Instance.new("ImageLabel")
    circle.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    circle.BackgroundTransparency = 0.5
    circle.Size = UDim2.new(0, 0, 0, 0)
    circle.Position = UDim2.new(0, x, 0, y)
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.ZIndex = 10
    circle.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = circle
    
    Tween(circle, {Size = UDim2.new(0, 100, 0, 100), BackgroundTransparency = 1}, 0.5)
    task.delay(0.5, function()
        circle:Destroy()
    end)
end

function Library:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -300)
    MainFrame.Size = UDim2.new(0, 700, 0, 600)
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(150, 200, 100)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.Size = UDim2.new(0, 120, 1, -30)
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 2)
    TabList.Parent = TabContainer
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 120, 0, 30)
    ContentFrame.Size = UDim2.new(1, -120, 1, -30)
    ContentFrame.Parent = MainFrame
    
    function Window:CreateTab(name)
        local Tab = {}
        Tab.Sections = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.Font = Enum.Font.Code
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabButton.TextSize = 13
        TabButton.Parent = TabContainer
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(150, 200, 100)
        TabContent.Visible = false
        TabContent.Parent = ContentFrame
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 10)
        TabLayout.Parent = TabContent
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 10)
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.PaddingRight = UDim.new(0, 10)
        Padding.Parent = TabContent
        
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
                tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            TabButton.TextColor3 = Color3.fromRGB(150, 200, 100)
            Window.CurrentTab = Tab
        end)
        
        if Window.CurrentTab == nil then
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            TabButton.TextColor3 = Color3.fromRGB(150, 200, 100)
            Window.CurrentTab = Tab
        end
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        table.insert(Window.Tabs, Tab)
        
        function Tab:CreateSection(name)
            local Section = {}
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = name
            SectionFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, -10, 0, 0)
            SectionFrame.Parent = TabContent
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 10, 0, 5)
            SectionTitle.Size = UDim2.new(1, -20, 0, 20)
            SectionTitle.Font = Enum.Font.Code
            SectionTitle.Text = name
            SectionTitle.TextColor3 = Color3.fromRGB(150, 200, 100)
            SectionTitle.TextSize = 13
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 0, 0, 30)
            SectionContent.Size = UDim2.new(1, 0, 1, -30)
            SectionContent.Parent = SectionFrame
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 5)
            SectionLayout.Parent = SectionContent
            
            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingLeft = UDim.new(0, 10)
            SectionPadding.PaddingRight = UDim.new(0, 10)
            SectionPadding.PaddingBottom = UDim.new(0, 10)
            SectionPadding.Parent = SectionContent
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, -10, 0, SectionLayout.AbsoluteContentSize.Y + 40)
            end)
            
            function Section:Toggle(name, default, callback)
                local toggled = default or false
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = name
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
                ToggleFrame.Parent = SectionContent
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "Button"
                ToggleButton.BackgroundColor3 = toggled and Color3.fromRGB(150, 200, 100) or Color3.fromRGB(30, 30, 30)
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Size = UDim2.new(0, 35, 0, 15)
                ToggleButton.Font = Enum.Font.Code
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame
                
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.Name = "Indicator"
                ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleIndicator.BorderSizePixel = 0
                ToggleIndicator.Position = toggled and UDim2.new(1, -13, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                ToggleIndicator.Size = UDim2.new(0, 11, 0, 11)
                ToggleIndicator.Parent = ToggleButton
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Name = "Label"
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Position = UDim2.new(0, 40, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
                ToggleLabel.Font = Enum.Font.Code
                ToggleLabel.Text = name
                ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ToggleLabel.TextSize = 12
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Tween(ToggleButton, {BackgroundColor3 = toggled and Color3.fromRGB(150, 200, 100) or Color3.fromRGB(30, 30, 30)})
                    Tween(ToggleIndicator, {Position = toggled and UDim2.new(1, -13, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)})
                    callback(toggled)
                end)
            end
            
            function Section:Slider(name, min, max, default, callback)
                local value = default or min
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = name
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, 35)
                SliderFrame.Parent = SectionContent
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = "Label"
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Size = UDim2.new(1, 0, 0, 15)
                SliderLabel.Font = Enum.Font.Code
                SliderLabel.Text = name .. ": " .. value
                SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                SliderLabel.TextSize = 12
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                local SliderBack = Instance.new("Frame")
                SliderBack.Name = "Back"
                SliderBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                SliderBack.BorderSizePixel = 0
                SliderBack.Position = UDim2.new(0, 0, 0, 20)
                SliderBack.Size = UDim2.new(1, 0, 0, 8)
                SliderBack.Parent = SliderFrame
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.BackgroundColor3 = Color3.fromRGB(150, 200, 100)
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
                        SliderLabel.Text = name .. ": " .. value
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
                DropdownFrame.Size = UDim2.new(1, 0, 0, 25)
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.Parent = SectionContent
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "Button"
                DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Size = UDim2.new(1, 0, 0, 25)
                DropdownButton.Font = Enum.Font.Code
                DropdownButton.Text = name .. ": " .. selected
                DropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownButton.TextSize = 12
                DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                DropdownButton.Parent = DropdownFrame
                
                local DropdownPadding = Instance.new("UIPadding")
                DropdownPadding.PaddingLeft = UDim.new(0, 5)
                DropdownPadding.Parent = DropdownButton
                
                local DropdownList = Instance.new("Frame")
                DropdownList.Name = "List"
                DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                DropdownList.BorderSizePixel = 0
                DropdownList.Position = UDim2.new(0, 0, 1, 2)
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.ClipsDescendants = true
                DropdownList.Visible = false
                DropdownList.ZIndex = 5
                DropdownList.Parent = DropdownFrame
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = DropdownList
                
                for _, option in ipairs(options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = option
                    OptionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Size = UDim2.new(1, 0, 0, 20)
                    OptionButton.Font = Enum.Font.Code
                    OptionButton.Text = option
                    OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptionButton.TextSize = 11
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    OptionButton.ZIndex = 6
                    OptionButton.Parent = DropdownList
                    
                    local OptionPadding = Instance.new("UIPadding")
                    OptionPadding.PaddingLeft = UDim.new(0, 5)
                    OptionPadding.Parent = OptionButton
                    
                    OptionButton.MouseEnter:Connect(function()
                        OptionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        OptionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        DropdownButton.Text = name .. ": " .. selected
                        opened = false
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)})
                        task.wait(0.2)
                        DropdownList.Visible = false
                        callback(selected)
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    if opened then
                        DropdownList.Visible = true
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, #options * 20)})
                    else
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)})
                        task.wait(0.2)
                        DropdownList.Visible = false
                    end
                end)
            end
            
            function Section:Button(name, callback)
                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Name = name
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Size = UDim2.new(1, 0, 0, 25)
                ButtonFrame.Font = Enum.Font.Code
                ButtonFrame.Text = name
                ButtonFrame.TextColor3 = Color3.fromRGB(200, 200, 200)
                ButtonFrame.TextSize = 12
                ButtonFrame.Parent = SectionContent
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(150, 200, 100)})
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    callback()
                end)
            end
            
            function Section:ColorPicker(name, default, callback)
                local color = default or Color3.fromRGB(255, 255, 255)
                local opened = false
                
                local PickerFrame = Instance.new("Frame")
                PickerFrame.Name = name
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Size = UDim2.new(1, 0, 0, 25)
                PickerFrame.ClipsDescendants = false
                PickerFrame.Parent = SectionContent
                
                local PickerLabel = Instance.new("TextLabel")
                PickerLabel.Name = "Label"
                PickerLabel.BackgroundTransparency = 1
                PickerLabel.Size = UDim2.new(1, -30, 1, 0)
                PickerLabel.Font = Enum.Font.Code
                PickerLabel.Text = name
                PickerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                PickerLabel.TextSize = 12
                PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                PickerLabel.Parent = PickerFrame
                
                local ColorDisplay = Instance.new("TextButton")
                ColorDisplay.Name = "Display"
                ColorDisplay.BackgroundColor3 = color
                ColorDisplay.BorderSizePixel = 0
                ColorDisplay.Position = UDim2.new(1, -25, 0.5, -10)
                ColorDisplay.Size = UDim2.new(0, 25, 0, 20)
                ColorDisplay.Text = ""
                ColorDisplay.Parent = PickerFrame
                
                local PickerWindow = Instance.new("Frame")
                PickerWindow.Name = "Window"
                PickerWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                PickerWindow.BorderSizePixel = 0
                PickerWindow.Position = UDim2.new(0, 0, 1, 5)
                PickerWindow.Size = UDim2.new(0, 200, 0, 200)
                PickerWindow.Visible = false
                PickerWindow.ZIndex = 10
                PickerWindow.Parent = PickerFrame
                
                local Palette = Instance.new("ImageButton")
                Palette.Name = "Palette"
                Palette.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Palette.BorderSizePixel = 0
                Palette.Position = UDim2.new(0, 10, 0, 10)
                Palette.Size = UDim2.new(0, 150, 0, 150)
                Palette.Image = "rbxassetid://4155801252"
                Palette.ZIndex = 11
                Palette.Parent = PickerWindow
                
                local HueSlider = Instance.new("ImageButton")
                HueSlider.Name = "Hue"
                HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueSlider.BorderSizePixel = 0
                HueSlider.Position = UDim2.new(0, 170, 0, 10)
                HueSlider.Size = UDim2.new(0, 20, 0, 150)
                HueSlider.Image = "rbxassetid://3641079629"
                HueSlider.ImageColor3 = Color3.fromRGB(255, 255, 255)
                HueSlider.ZIndex = 11
                HueSlider.Parent = PickerWindow
                
                ColorDisplay.MouseButton1Click:Connect(function()
                    opened = not opened
                    PickerWindow.Visible = opened
                end)
                
                local hue, sat, val = 0, 1, 1
                
                Palette.MouseButton1Down:Connect(function()
                    local dragging = true
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
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    end
                end)
            end
            
            function Section:Textbox(name, placeholder, callback)
                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.Name = name
                TextboxFrame.BackgroundTransparency = 1
                TextboxFrame.Size = UDim2.new(1, 0, 0, 40)
                TextboxFrame.Parent = SectionContent
                
                local TextboxLabel = Instance.new("TextLabel")
                TextboxLabel.Name = "Label"
                TextboxLabel.BackgroundTransparency = 1
                TextboxLabel.Size = UDim2.new(1, 0, 0, 15)
                TextboxLabel.Font = Enum.Font.Code
                TextboxLabel.Text = name
                TextboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                TextboxLabel.TextSize = 12
                TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextboxLabel.Parent = TextboxFrame
                
                local Textbox = Instance.new("TextBox")
                Textbox.Name = "Box"
                Textbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Textbox.BorderSizePixel = 0
                Textbox.Position = UDim2.new(0, 0, 0, 20)
                Textbox.Size = UDim2.new(1, 0, 0, 20)
                Textbox.Font = Enum.Font.Code
                Textbox.PlaceholderText = placeholder
                Textbox.Text = ""
                Textbox.TextColor3 = Color3.fromRGB(200, 200, 200)
                Textbox.TextSize = 11
                Textbox.TextXAlignment = Enum.TextXAlignment.Left
                Textbox.Parent = TextboxFrame
                
                local BoxPadding = Instance.new("UIPadding")
                BoxPadding.PaddingLeft = UDim.new(0, 5)
                BoxPadding.Parent = Textbox
                
                Textbox.FocusLost:Connect(function()
                    callback(Textbox.Text)
                end)
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

return Library
