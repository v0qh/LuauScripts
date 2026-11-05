local cloneref = cloneref or function(Object)
    return Object
end

local Environment = getgenv and getgenv() or _G

local Services = setmetatable({}, {
    __index = function(Self, Name)
        local Service = cloneref(game:GetService(Name))
        rawset(Self, Name, Service)
        return Service
    end,
})

if Environment.Library and type(Environment.Library.Unload) == "function" then
    pcall(Environment.Library.Unload, Environment.Library)
end

local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local RunService = Services.RunService
local HttpService = Services.HttpService
local GuiService = Services.GuiService
local LocalPlayer = Services.Players.LocalPlayer

local UD2, UD, Vec2, Rgb = UDim2.new, UDim.new, Vector2.new, Color3.fromRGB
local R4, R5, R6, R8, Full = UD(0, 3), UD(0, 3), UD(0, 4), UD(0, 4), UD(1, 0)
local AutoX, AutoY, AutoXY = Enum.AutomaticSize.X, Enum.AutomaticSize.Y, Enum.AutomaticSize.XY
local Left, Center, Right = Enum.TextXAlignment.Left, Enum.TextXAlignment.Center, Enum.TextXAlignment.Right
local White, Black = Rgb(255, 255, 255), Rgb(0, 0, 0)

local Library = {
    Name = "liminal.cc",
    Version = "5.0.0",
    Directory = "liminal",
    Subfolders = {"Configs", "Themes"},
    IconSource = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",
    Flags = {},
    Options = {},
    Connections = {},
    Keybinds = {},
    ThemeObjects = {},
    ThemeCallbacks = {},
    HotkeyEntries = {},
    UnloadCallbacks = {},
    NotificationCount = 0,
    Open = false,
    Unloaded = false,
    ShowHotkeys = true,
    ShowWatermark = true,
    WatermarkTitle = "liminal.cc",
    PresetNames = {"Lilac", "Purple", "Violet", "Orchid", "Indigo", "Crimson"},
    Presets = {
        Purple = Rgb(139, 92, 246),
        Violet = Rgb(168, 85, 247),
        Orchid = Rgb(217, 70, 239),
        Indigo = Rgb(99, 102, 241),
        Lilac = Rgb(196, 148, 255),
        Crimson = Rgb(240, 85, 105),
    },
    Theme = {
        Background = Rgb(15, 15, 18),
        Sidebar = Rgb(11, 11, 14),
        Panel = Rgb(21, 21, 25),
        Element = Rgb(30, 30, 36),
        ElementHover = Rgb(40, 40, 48),
        Outline = Rgb(42, 42, 51),
        Off = Rgb(55, 55, 67),
        Text = Rgb(240, 240, 246),
        SubText = Rgb(132, 132, 148),
        Accent = Rgb(196, 148, 255),
        Success = Rgb(88, 208, 140),
        Warning = Rgb(245, 190, 80),
        Danger = Rgb(240, 85, 105),
    },
}

Environment.Library = Library

local Theme = Library.Theme

local function MakeFont(Weight)
    return Font.new("rbxassetid://12187365364", Weight, Enum.FontStyle.Normal)
end

local Fonts = {
    Regular = MakeFont(Enum.FontWeight.Regular),
    Medium = MakeFont(Enum.FontWeight.Medium),
    SemiBold = MakeFont(Enum.FontWeight.SemiBold),
    Bold = MakeFont(Enum.FontWeight.Bold),
}

local Defaults = {
    Frame = {BorderSizePixel = 0},
    CanvasGroup = {BorderSizePixel = 0},
    ScrollingFrame = {
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Outline,
        CanvasSize = UD2(),
        AutomaticCanvasSize = AutoY,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
    },
    TextLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        FontFace = Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Left,
        Text = "",
    },
    TextButton = {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        FontFace = Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Left,
        Text = "",
    },
    TextBox = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        FontFace = Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.SubText,
        TextXAlignment = Left,
        ClearTextOnFocus = false,
        Text = "",
    },
    ImageLabel = {BackgroundTransparency = 1, BorderSizePixel = 0},
    UIStroke = {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Outline, Thickness = 1},
    UIListLayout = {SortOrder = Enum.SortOrder.LayoutOrder},
}

local function Create(ClassName, Properties, Children)
    local Object = Instance.new(ClassName)
    local Base = Defaults[ClassName]

    if Base then
        for Property, Value in Base do
            Object[Property] = Value
        end
    end

    local ThemeMap, Parent

    for Property, Value in Properties do
        if Property == "Theme" then
            ThemeMap = Value
        elseif Property == "Parent" then
            Parent = Value
        else
            Object[Property] = Value
        end
    end

    if ThemeMap then
        for Property, Key in ThemeMap do
            Object[Property] = Theme[Key]
            table.insert(Library.ThemeObjects, {Object, Property, Key})
        end
    end

    if Children then
        for _, Child in Children do
            Child.Parent = Object
        end
    end

    Object.Parent = Parent

    return Object
end

local function Corner(Radius)
    return Create("UICorner", {CornerRadius = Radius or R6})
end

local function Stroke(Color, Transparency)
    return Create("UIStroke", {Color = Color or Theme.Outline, Transparency = Transparency or 0})
end

local function Pad(Top, RightPad, Bottom, LeftPad)
    return Create("UIPadding", {
        PaddingTop = UD(0, Top),
        PaddingRight = UD(0, RightPad),
        PaddingBottom = UD(0, Bottom),
        PaddingLeft = UD(0, LeftPad),
    })
end

local function List(Padding, Extra)
    local Properties = {Padding = UD(0, Padding or 0)}

    if Extra then
        for Key, Value in Extra do
            Properties[Key] = Value
        end
    end

    return Create("UIListLayout", Properties)
end

local TweenDefault = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function Tween(Object, Goal, Duration, Style, Direction)
    local Info = TweenDefault

    if Duration then
        Info = TweenInfo.new(Duration, Style or Enum.EasingStyle.Quad, Direction or Enum.EasingDirection.Out)
    end

    local Animation = TweenService:Create(Object, Info, Goal)
    Animation:Play()

    return Animation
end

local function Apply(Object, Goal, Instant, Duration)
    if Instant then
        for Property, Value in Goal do
            Object[Property] = Value
        end
    else
        Tween(Object, Goal, Duration)
    end
end

local IconCache = {}
local IconProvider

local function LoadIconProvider()
    local Success, Provider = pcall(function()
        return loadstring(game:HttpGet(Library.IconSource))()
    end)

    if Success and type(Provider) == "table" then
        IconProvider = Provider
    end
end

local function ResolveIcon(Name)
    if type(Name) ~= "string" or Name == "" then
        return nil
    end

    local Cached = IconCache[Name]

    if Cached ~= nil then
        return Cached or nil
    end

    local Result = false

    if Name:sub(1, 13) == "rbxassetid://" then
        Result = {Image = Name, RectSize = Vector2.zero, RectOffset = Vector2.zero}
    elseif IconProvider then
        local Success, Asset = pcall(IconProvider.GetAsset, Name)

        if Success and Asset and Asset.Url then
            Result = {Image = Asset.Url, RectSize = Asset.ImageRectSize, RectOffset = Asset.ImageRectOffset}
        end
    end

    IconCache[Name] = Result

    return Result or nil
end

local function SetIcon(Image, Name)
    local Data = ResolveIcon(Name)

    if Data then
        Image.Image = Data.Image
        Image.ImageRectSize = Data.RectSize
        Image.ImageRectOffset = Data.RectOffset
    else
        Image.Image = ""
    end
end

local function Icon(Name, Size, Color, Properties)
    Properties = Properties or {}
    Properties.Size = UD2(0, Size, 0, Size)
    Properties.ImageColor3 = Color or Theme.SubText

    local Image = Create("ImageLabel", Properties)
    SetIcon(Image, Name)

    return Image
end

local function PointerPosition(Input)
    if Input.UserInputType == Enum.UserInputType.Touch then
        return Vec2(Input.Position.X, Input.Position.Y + GuiService:GetGuiInset().Y)
    end

    return UserInputService:GetMouseLocation()
end

local function BeginDrag(Input, OnUpdate)
    OnUpdate(PointerPosition(Input))

    local Moved, Ended

    Moved = UserInputService.InputChanged:Connect(function(Changed)
        local Type = Changed.UserInputType

        if Type == Enum.UserInputType.MouseMovement or Type == Enum.UserInputType.Touch then
            OnUpdate(PointerPosition(Changed))
        end
    end)

    Ended = UserInputService.InputEnded:Connect(function(Finished)
        if Finished.UserInputType == Input.UserInputType then
            Moved:Disconnect()
            Ended:Disconnect()
        end
    end)
end

local function IsPress(Input)
    local Type = Input.UserInputType

    return Type == Enum.UserInputType.MouseButton1 or Type == Enum.UserInputType.Touch
end

local KeyAliases = {
    LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl",
    LeftAlt = "LAlt", RightAlt = "RAlt", Return = "Enter", Backspace = "Bksp", CapsLock = "Caps",
    Escape = "Esc", Insert = "Ins", Delete = "Del", PageUp = "PgUp", PageDown = "PgDn",
    One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8",
    Nine = "9", Zero = "0", MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
    Backquote = "`", Minus = "-", Equals = "=", LeftBracket = "[", RightBracket = "]",
    BackSlash = "\\", Semicolon = ";", Quote = "'", Comma = ",", Period = ".", Slash = "/",
}

local MouseBinds = {
    [Enum.UserInputType.MouseButton1] = true,
    [Enum.UserInputType.MouseButton2] = true,
    [Enum.UserInputType.MouseButton3] = true,
}

local function KeyName(Key)
    if not Key then
        return "None"
    end

    return KeyAliases[Key.Name] or Key.Name
end

local function InputMatches(Input, Key)
    if tostring(Key.EnumType) == "KeyCode" then
        return Input.KeyCode == Key
    end

    return Input.UserInputType == Key
end

local function GetPing()
    local Success, Value = pcall(function()
        return Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)

    return Success and math.floor(Value + 0.5) or 0
end

function Library:Connect(Signal, Callback)
    local Connection = Signal:Connect(Callback)
    table.insert(self.Connections, Connection)

    return Connection
end

function Library:Fire(Callback, ...)
    if type(Callback) ~= "function" then
        return
    end

    local Success, Result = pcall(Callback, ...)

    if not Success then
        warn(string.format("[%s] callback error: %s", self.Name, tostring(Result)))
    end
end

function Library:OnTheme(Callback)
    table.insert(self.ThemeCallbacks, Callback)

    return Callback
end

function Library:SetAccent(Color)
    Theme.Accent = Color

    for Index = #self.ThemeObjects, 1, -1 do
        local Entry = self.ThemeObjects[Index]

        if Entry[1].Parent then
            Entry[1][Entry[2]] = Theme[Entry[3]]
        else
            table.remove(self.ThemeObjects, Index)
        end
    end

    for _, Callback in self.ThemeCallbacks do
        Callback()
    end
end

function Library:Register(Element)
    if Element.Flag then
        self.Options[Element.Flag] = Element
        self.Flags[Element.Flag] = Element.Value
    end
end

function Library:SetHotkey(Id, Text)
    if not self.HotkeyFrame then
        return
    end

    local Entry = self.HotkeyEntries[Id]

    if Text then
        if not Entry then
            Entry = Create("TextLabel", {
                Size = UD2(0, 0, 0, 18),
                AutomaticSize = AutoX,
                TextColor3 = Theme.Text,
                TextSize = 12,
                LayoutOrder = 1,
                Parent = self.HotkeyFrame,
            })
            self.HotkeyEntries[Id] = Entry
        end

        Entry.Text = Text
    elseif Entry then
        Entry:Destroy()
        self.HotkeyEntries[Id] = nil
    end

    self.HotkeyFrame.Visible = self.ShowHotkeys and next(self.HotkeyEntries) ~= nil
end

function Library:SetHotkeysVisible(State)
    self.ShowHotkeys = State
    self.HotkeyFrame.Visible = State and next(self.HotkeyEntries) ~= nil
end

function Library:SetWatermarkVisible(State)
    self.ShowWatermark = State
    self.Watermark.Visible = State
end

function Library:NewBind(Options)
    local Bind = {
        Name = Options.Name or "Bind",
        Key = Options.Default,
        Mode = Options.Mode or "Toggle",
        Active = false,
        Callback = Options.Callback,
        HideHotkey = Options.HideHotkey == true,
        Flag = Options.Flag,
        Listeners = {},
    }

    function Bind:Notify()
        for _, Listener in self.Listeners do
            Listener()
        end
    end

    function Bind:Refresh()
        local Text

        if self.Active and self.Key and not self.HideHotkey then
            Text = self.Name .. " - " .. KeyName(self.Key)
        end

        Library:SetHotkey(self, Text)
    end

    function Bind:SetKey(Key)
        self.Key = Key
        self:Notify()
        self:Refresh()
    end

    function Bind:SetMode(Mode)
        self.Mode = Mode
        self:Notify()
    end

    function Bind:SetActive(State, Silent)
        self.Active = State

        if self.Flag then
            Library.Flags[self.Flag] = State
        end

        self:Refresh()

        if not Silent then
            Library:Fire(self.Callback, State)
        end
    end

    function Bind:Press(Pressed)
        if self.Mode == "Hold" then
            self:SetActive(Pressed)
        elseif Pressed then
            self:SetActive(not self.Active)
        end
    end

    function Bind:Serialize()
        local Key

        if self.Key then
            Key = {Type = tostring(self.Key.EnumType), Name = self.Key.Name}
        end

        return {Key = Key, Mode = self.Mode}
    end

    function Bind:Deserialize(Data)
        if type(Data) ~= "table" then
            return
        end

        local Key

        if Data.Key then
            local Success, Result = pcall(function()
                return Enum[Data.Key.Type][Data.Key.Name]
            end)

            Key = Success and Result or nil
        end

        self.Mode = Data.Mode or self.Mode
        self:SetKey(Key)
    end

    table.insert(self.Keybinds, Bind)

    return Bind
end

function Library:BindChip(Parent, Bind, Order)
    local Chip = Create("TextButton", {
        Size = UD2(0, 0, 0, 18),
        AutomaticSize = AutoX,
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0,
        LayoutOrder = Order or 2,
        FontFace = Fonts.SemiBold,
        TextSize = 11,
        TextColor3 = Theme.SubText,
        TextXAlignment = Center,
        Text = KeyName(Bind.Key),
        Parent = Parent,
    }, {Corner(R4), Stroke(), Pad(0, 6, 0, 6)})

    table.insert(Bind.Listeners, function()
        Chip.Text = self.Binding == Bind and "..." or KeyName(Bind.Key)
    end)

    Chip.MouseButton1Click:Connect(function()
        local Previous = self.Binding
        self.Binding = Bind
        Chip.Text = "..."

        if Previous and Previous ~= Bind then
            Previous:Notify()
        end
    end)

    Chip.MouseButton2Click:Connect(function()
        self:OpenModeMenu(Chip, Bind)
    end)

    return Chip
end

function Library:OpenModeMenu(Anchor, Bind)
    self.ModeTarget = Bind

    for Mode, Button in self.ModeButtons do
        local On = Bind.Mode == Mode
        Button.BackgroundColor3 = On and Theme.Accent or Theme.Element
        Button.TextColor3 = On and White or Theme.SubText
    end

    self:OpenPopup(self.ModeFrame, Anchor, nil, true)
end

function Library:OpenPopup(Popup, Anchor, OnClose, AlignRight, AtMouse)
    self:ClosePopup()

    local Overlay = self.Overlay
    local Origin = Anchor.AbsolutePosition - Overlay.AbsolutePosition
    local Width, Height = Popup.Size.X.Offset, Popup.Size.Y.Offset
    local X = AlignRight and (Origin.X + Anchor.AbsoluteSize.X - Width) or Origin.X
    local Y = Origin.Y + Anchor.AbsoluteSize.Y + 4

    if AtMouse then
        local Mouse = UserInputService:GetMouseLocation() - Overlay.AbsolutePosition

        X, Y = Mouse.X + 10, Mouse.Y + 10
        Origin = Vec2(Mouse.X, Mouse.Y - 10)
    end

    if Y + Height > Overlay.AbsoluteSize.Y - 8 then
        Y = Origin.Y - Height - 4
    end

    X = math.clamp(X, 8, math.max(8, Overlay.AbsoluteSize.X - Width - 8))
    Popup.Position = UD2(0, X, 0, Y)
    Popup.Visible = true
    self.Blocker.Visible = true
    self.ActivePopup = {Popup = Popup, OnClose = OnClose}
end

function Library:ClosePopup()
    local Active = self.ActivePopup

    if not Active then
        return
    end

    self.ActivePopup = nil
    Active.Popup.Visible = false
    self.Blocker.Visible = false

    if Active.OnClose then
        Active.OnClose()
    end
end

function Library:SetOpen(State)
    local Window = self.Window

    if not Window then
        return
    end

    self.Open = State
    self:ClosePopup()
    self.Modal.Modal = State
    Window:UpdatePanels()

    if State then
        Window.Root.Visible = true
        Tween(Window.Root, {GroupTransparency = 0}, 0.24, Enum.EasingStyle.Quint)
        Tween(Window.Scale, {Scale = 1}, 0.24, Enum.EasingStyle.Quint)
    else
        Tween(Window.Scale, {Scale = 0.96}, 0.18)
        Tween(Window.Root, {GroupTransparency = 1}, 0.18).Completed:Once(function()
            if not self.Open then
                Window.Root.Visible = false
            end
        end)
    end
end

function Library:Toggle()
    self:SetOpen(not self.Open)
end

function Library:Notify(Options)
    self:Init()

    Options = Options or {}

    local Duration = Options.Duration or 4
    local Kind = Options.Type or "Info"
    local Colors = {Info = Theme.Accent, Success = Theme.Success, Warning = Theme.Warning, Error = Theme.Danger}
    local Icons = {Info = "info", Success = "circle-check", Warning = "triangle-alert", Error = "circle-x"}
    local Color = Colors[Kind] or Theme.Accent

    self.NotificationCount += 1

    local Holder = Create("Frame", {
        Size = UD2(1, 0, 0, 0),
        AutomaticSize = AutoY,
        BackgroundTransparency = 1,
        LayoutOrder = self.NotificationCount,
        Parent = self.NotificationHolder,
    })

    local Card = Create("Frame", {
        Position = UD2(0, 330, 0, 0),
        Size = UD2(1, 0, 0, 0),
        AutomaticSize = AutoY,
        BackgroundColor3 = Theme.Panel,
        Parent = Holder,
    }, {Corner(R6), Stroke()})

    Icon(Options.Icon or Icons[Kind] or "info", 18, Color, {Position = UD2(0, 14, 0, 12), Parent = Card})

    local Body = Create("Frame", {
        Size = UD2(1, 0, 0, 0),
        AutomaticSize = AutoY,
        BackgroundTransparency = 1,
        Parent = Card,
    }, {Pad(11, 14, 12, 44), List(3)})

    Create("TextLabel", {
        Size = UD2(1, 0, 0, 16),
        Text = Options.Title or self.Name,
        FontFace = Fonts.SemiBold,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = 1,
        Parent = Body,
    })

    if Options.Content then
        Create("TextLabel", {
            Size = UD2(1, 0, 0, 0),
            AutomaticSize = AutoY,
            Text = Options.Content,
            TextColor3 = Theme.SubText,
            TextSize = 12,
            TextWrapped = true,
            LayoutOrder = 2,
            Parent = Body,
        })
    end

    local Track = Create("Frame", {
        Size = UD2(1, 0, 0, 2),
        BackgroundColor3 = Theme.Off,
        LayoutOrder = 3,
        Parent = Body,
    }, {Corner(Full)})

    local Fill = Create("Frame", {
        Size = UD2(1, 0, 1, 0),
        BackgroundColor3 = Color,
        Parent = Track,
    }, {Corner(Full)})

    Tween(Card, {Position = UD2(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint)
    Tween(Fill, {Size = UD2(0, 0, 1, 0)}, Duration, Enum.EasingStyle.Linear)

    task.delay(Duration, function()
        if self.Unloaded then
            return
        end

        Tween(Card, {Position = UD2(0, 330, 0, 0)}, 0.25, Enum.EasingStyle.Quint).Completed:Once(function()
            Holder:Destroy()
        end)
    end)
end

function Library:Init()
    if self.Gui then
        return
    end

    self.FileSystem = (writefile and readfile and isfile and isfolder and makefolder and listfiles and delfile) and true or false

    if self.FileSystem then
        pcall(function()
            if not isfolder(self.Directory) then
                makefolder(self.Directory)
            end

            for _, Folder in self.Subfolders do
                local Path = self.Directory .. "/" .. Folder

                if not isfolder(Path) then
                    makefolder(Path)
                end
            end
        end)
    end

    LoadIconProvider()

    local Gui = Create("ScreenGui", {
        Name = HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    self.Gui = Gui

    self.Modal = Create("TextButton", {Name = "Modal", Size = UD2(), Modal = false, Parent = Gui})

    self.Overlay = Create("Frame", {
        Name = "Overlay",
        Size = UD2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 20,
        Parent = Gui,
    })

    self.Blocker = Create("TextButton", {Name = "Blocker", Size = UD2(1, 0, 1, 0), Visible = false, ZIndex = 1, Parent = self.Overlay})

    self.Blocker.MouseButton1Click:Connect(function()
        self:ClosePopup()
    end)

    self.Blocker.MouseButton2Click:Connect(function()
        self:ClosePopup()
    end)

    self.NotificationHolder = Create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vec2(1, 1),
        Position = UD2(1, -18, 1, -18),
        Size = UD2(0, 300, 1, -36),
        BackgroundTransparency = 1,
        ZIndex = 10,
        Parent = Gui,
    }, {List(8, {VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right})})

    self.Watermark = Create("Frame", {
        Name = "Watermark",
        Position = UD2(0, 16, 0, 52),
        Size = UD2(0, 0, 0, 28),
        AutomaticSize = AutoX,
        BackgroundColor3 = Theme.Panel,
        ZIndex = 5,
        Parent = Gui,
    }, {
        Corner(R6),
        Stroke(),
        Pad(0, 10, 0, 10),
        List(8, {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center}),
    })

    self.WatermarkIcon = Icon("flame", 14, Theme.Accent, {Theme = {ImageColor3 = "Accent"}, LayoutOrder = 1, Parent = self.Watermark})

    self.WatermarkLabel = Create("TextLabel", {
        Size = UD2(0, 0, 1, 0),
        AutomaticSize = AutoX,
        TextSize = 12,
        Text = self.WatermarkTitle,
        LayoutOrder = 2,
        Parent = self.Watermark,
    })

    self.HotkeyFrame = Create("Frame", {
        Name = "Hotkeys",
        Position = UD2(0, 16, 0, 92),
        Size = UD2(0, 0, 0, 0),
        AutomaticSize = AutoXY,
        BackgroundColor3 = Theme.Panel,
        Visible = false,
        ZIndex = 5,
        Parent = Gui,
    }, {Corner(R6), Stroke(), Pad(8, 10, 8, 10), List(4)})

    Create("TextLabel", {
        Size = UD2(0, 0, 0, 16),
        AutomaticSize = AutoX,
        Text = "Hotkeys",
        FontFace = Fonts.SemiBold,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        LayoutOrder = 0,
        Parent = self.HotkeyFrame,
    })

    local ModeFrame = Create("Frame", {
        Name = "ModeMenu",
        Visible = false,
        Size = UD2(0, 132, 0, 98),
        BackgroundColor3 = Theme.Panel,
        ZIndex = 2,
        Parent = self.Overlay,
    }, {Corner(R6), Stroke(), Pad(6, 6, 6, 6), List(4)})

    self.ModeFrame = ModeFrame
    self.ModeButtons = {}

    for Index, Entry in {{"Toggle", "On Toggle"}, {"Hold", "On Hold"}} do
        local Button = Create("TextButton", {
            Size = UD2(1, 0, 0, 26),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0,
            Text = Entry[2],
            TextXAlignment = Center,
            LayoutOrder = Index,
            Parent = ModeFrame,
        }, {Corner(R4)})

        Button.MouseButton1Click:Connect(function()
            if self.ModeTarget then
                self.ModeTarget:SetMode(Entry[1])
            end

            self:ClosePopup()
        end)

        self.ModeButtons[Entry[1]] = Button
    end

    local Reset = Create("TextButton", {
        Size = UD2(1, 0, 0, 26),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0,
        Text = "Reset",
        TextColor3 = Theme.SubText,
        TextXAlignment = Center,
        LayoutOrder = 3,
        Parent = ModeFrame,
    }, {Corner(R4), Stroke()})

    Reset.MouseButton1Click:Connect(function()
        if self.ModeTarget then
            self.ModeTarget:SetKey(nil)
        end

        self:ClosePopup()
    end)

    self:Connect(UserInputService.InputBegan, function(Input, Processed)
        if self.Binding then
            local Candidate

            if Input.UserInputType == Enum.UserInputType.Keyboard then
                Candidate = Input.KeyCode
            elseif MouseBinds[Input.UserInputType] then
                Candidate = Input.UserInputType
            end

            if Candidate then
                local Bind = self.Binding
                self.Binding = nil

                if Candidate == Enum.KeyCode.Escape then
                    Candidate = nil
                end

                Bind:SetKey(Candidate)
            end

            return
        end

        if Processed then
            return
        end

        for _, Bind in self.Keybinds do
            if Bind.Key and InputMatches(Input, Bind.Key) then
                Bind:Press(true)
            end
        end
    end)

    self:Connect(UserInputService.InputEnded, function(Input)
        for _, Bind in self.Keybinds do
            if Bind.Mode == "Hold" and Bind.Key and InputMatches(Input, Bind.Key) then
                Bind:Press(false)
            end
        end
    end)

    local Frames, Elapsed = 0, 0

    self:Connect(RunService.Heartbeat, function(Delta)
        Frames += 1
        Elapsed += Delta

        if Elapsed < 0.5 then
            return
        end

        local Rate = math.floor(Frames / Elapsed + 0.5)
        Frames, Elapsed = 0, 0

        if self.ShowWatermark then
            self.WatermarkLabel.Text = string.format(
                "%s  |  %s  |  %d fps  |  %d ms",
                self.WatermarkTitle,
                LocalPlayer.DisplayName,
                Rate,
                GetPing()
            )
        end
    end)

    if syn and syn.protect_gui then
        pcall(syn.protect_gui, Gui)
    end

    local Success = pcall(function()
        Gui.Parent = gethui and gethui() or Services.CoreGui
    end)

    if not Success or not Gui.Parent then
        Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local ElementBase = {}
ElementBase.__index = ElementBase

function ElementBase:Get()
    return self.Value
end

function ElementBase:Fire(...)
    Library:Fire(self.Callback, ...)
end

function ElementBase:Commit()
    if self.Flag then
        Library.Flags[self.Flag] = self.Value
    end
end

function ElementBase:SetVisible(State)
    self.Hidden = not State
    self.Row.Visible = State and self.Matched
end

local function FitLabel(Label, Side, Gap)
    local function Update()
        Label.Size = UD2(1, -(Side.AbsoluteSize.X + (Gap or 8)), Label.Size.Y.Scale, Label.Size.Y.Offset)
    end

    Side:GetPropertyChangedSignal("AbsoluteSize"):Connect(Update)
    Update()
end

local function NewElement(Type, Options)
    return setmetatable({
        Type = Type,
        Flag = Options.Flag,
        Callback = Options.Callback,
        Matched = true,
        Hidden = false,
    }, ElementBase)
end

local function CreateRight(Row)
    return Create("Frame", {
        AnchorPoint = Vec2(1, 0.5),
        Position = UD2(1, 0, 0.5, 0),
        Size = UD2(0, 0, 1, 0),
        AutomaticSize = AutoX,
        BackgroundTransparency = 1,
        Parent = Row,
    }, {
        List(6, {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })
end

function Library:CreateColorPicker(Parent, Options, Order)
    local Picker = NewElement("Colorpicker", Options)
    local Start = Options.Default or Theme.Accent
    local H, S, V = Start:ToHSV()
    local Popup, SV, SVKnob, HueKnob, Hex

    Picker.Value = Start

    local Swatch = Create("TextButton", {
        Size = UD2(0, 24, 0, 14),
        BackgroundColor3 = Start,
        BackgroundTransparency = 0,
        LayoutOrder = Order or 1,
        Parent = Parent,
    }, {Corner(R4), Stroke()})

    local function Sync()
        Picker.Value = Color3.fromHSV(H, S, V)
        Swatch.BackgroundColor3 = Picker.Value

        if Popup then
            SV.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
            SVKnob.Position = UD2(S, 0, 1 - V, 0)
            HueKnob.Position = UD2(H, 0, 0.5, 0)
            Hex.Text = "#" .. Picker.Value:ToHex():upper()
        end
    end

    local function Emit()
        Sync()
        Picker:Commit()
        Picker:Fire(Picker.Value)
    end

    local function Build()
        local Rainbow = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Rgb(255, 0, 0)),
            ColorSequenceKeypoint.new(1 / 6, Rgb(255, 255, 0)),
            ColorSequenceKeypoint.new(2 / 6, Rgb(0, 255, 0)),
            ColorSequenceKeypoint.new(3 / 6, Rgb(0, 255, 255)),
            ColorSequenceKeypoint.new(4 / 6, Rgb(0, 0, 255)),
            ColorSequenceKeypoint.new(5 / 6, Rgb(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Rgb(255, 0, 0)),
        })

        Popup = Create("Frame", {
            Visible = false,
            Size = UD2(0, 204, 0, 188),
            BackgroundColor3 = Theme.Panel,
            ZIndex = 2,
            Parent = self.Overlay,
        }, {Corner(R6), Stroke(), Pad(8, 8, 8, 8)})

        SV = Create("Frame", {Size = UD2(1, 0, 0, 116), BackgroundColor3 = Color3.fromHSV(H, 1, 1), Parent = Popup}, {Corner(R4)})

        Create("Frame", {Size = UD2(1, 0, 1, 0), BackgroundColor3 = White, Parent = SV}, {
            Corner(R4),
            Create("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}),
        })

        Create("Frame", {Size = UD2(1, 0, 1, 0), BackgroundColor3 = Black, Parent = SV}, {
            Corner(R4),
            Create("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})}),
        })

        SVKnob = Create("Frame", {
            AnchorPoint = Vec2(0.5, 0.5),
            Size = UD2(0, 10, 0, 10),
            BackgroundColor3 = White,
            Parent = SV,
        }, {Corner(Full), Create("UIStroke", {Color = Black, Thickness = 1.5})})

        local SVHit = Create("TextButton", {Size = UD2(1, 0, 1, 0), Parent = SV})

        SVHit.InputBegan:Connect(function(Input)
            if IsPress(Input) then
                BeginDrag(Input, function(Pointer)
                    local Position, Size = SV.AbsolutePosition, SV.AbsoluteSize
                    S = math.clamp((Pointer.X - Position.X) / Size.X, 0, 1)
                    V = 1 - math.clamp((Pointer.Y - Position.Y) / Size.Y, 0, 1)
                    Emit()
                end)
            end
        end)

        local Hue = Create("Frame", {
            Position = UD2(0, 0, 0, 124),
            Size = UD2(1, 0, 0, 12),
            BackgroundColor3 = White,
            Parent = Popup,
        }, {Corner(Full), Create("UIGradient", {Color = Rainbow})})

        HueKnob = Create("Frame", {
            AnchorPoint = Vec2(0.5, 0.5),
            Size = UD2(0, 6, 0, 16),
            BackgroundColor3 = White,
            Parent = Hue,
        }, {Corner(Full), Create("UIStroke", {Color = Black, Thickness = 1.5})})

        local HueHit = Create("TextButton", {Size = UD2(1, 0, 1, 0), Parent = Hue})

        HueHit.InputBegan:Connect(function(Input)
            if IsPress(Input) then
                BeginDrag(Input, function(Pointer)
                    local Position, Size = Hue.AbsolutePosition, Hue.AbsoluteSize
                    H = math.clamp((Pointer.X - Position.X) / Size.X, 0, 1)
                    Emit()
                end)
            end
        end)

        local HexBox = Create("Frame", {
            Position = UD2(0, 0, 0, 144),
            Size = UD2(1, 0, 0, 28),
            BackgroundColor3 = Theme.Element,
            Parent = Popup,
        }, {Corner(R5), Stroke()})

        Hex = Create("TextBox", {
            Size = UD2(1, 0, 1, 0),
            TextXAlignment = Center,
            TextColor3 = Theme.SubText,
            Parent = HexBox,
        })

        Hex.FocusLost:Connect(function()
            local Value = Hex.Text:gsub("#", "")

            if #Value == 6 and Value:match("^%x+$") then
                Picker:Set(Color3.fromHex(Value))
            else
                Sync()
            end
        end)

        Sync()
    end

    function Picker:Set(Color, Silent)
        H, S, V = Color:ToHSV()
        Sync()
        self:Commit()

        if not Silent then
            self:Fire(self.Value)
        end
    end

    function Picker:Serialize()
        return self.Value:ToHex()
    end

    function Picker:Deserialize(Data)
        if type(Data) == "string" and #Data == 6 then
            self:Set(Color3.fromHex(Data))
        end
    end

    Swatch.MouseButton1Click:Connect(function()
        if not Popup then
            Build()
        end

        self:OpenPopup(Popup, Swatch, nil, true, true)
    end)

    return Picker
end

local GroupMethods = {}
GroupMethods.__index = GroupMethods

function GroupMethods:Next()
    self.Count += 1

    return self.Count
end

function GroupMethods:Track(Element, Row, Name, Static)
    Element.Row = Row
    Element.Key = (Name or ""):lower()
    Element.Static = Static == true
    table.insert(self.Elements, Element)
end

function GroupMethods:AddToggle(Options)
    local Toggle = NewElement("Toggle", Options)
    Toggle.Value = Options.Default == true

    local Row = Create("TextButton", {
        Size = UD2(1, 0, 0, 22),
        LayoutOrder = self:Next(),
        Parent = self.Body,
    })

    local BoxStroke = Stroke()

    local Box = Create("Frame", {
        AnchorPoint = Vec2(0, 0.5),
        Position = UD2(0, 0, 0.5, 0),
        Size = UD2(0, 16, 0, 16),
        BackgroundColor3 = Theme.Element,
        Parent = Row,
    }, {Corner(R4), BoxStroke})

    local Check = Icon("check", 12, White, {
        AnchorPoint = Vec2(0.5, 0.5),
        Position = UD2(0.5, 0, 0.5, 0),
        ImageTransparency = 1,
        Parent = Box,
    })

    local Label = Create("TextLabel", {
        Position = UD2(0, 26, 0, 0),
        Size = UD2(1, -26, 1, 0),
        Text = Options.Name or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Row,
    })

    local Side = CreateRight(Row)
    FitLabel(Label, Side, 34)

    -- Off rows are dimmed so what's on stands out at a glance.
    local function Render(Instant)
        local On = Toggle.Value

        Apply(Box, {BackgroundColor3 = On and Theme.Accent or Theme.Element}, Instant)
        Apply(BoxStroke, {Color = On and Theme.Accent or Theme.Outline}, Instant)
        Apply(Check, {ImageTransparency = On and 0 or 1}, Instant)
        Apply(Label, {TextColor3 = On and Theme.Text or Theme.SubText}, Instant)
    end

    Row.MouseEnter:Connect(function()
        if not Toggle.Value then
            Tween(BoxStroke, {Color = Theme.Off})
        end
    end)

    Row.MouseLeave:Connect(function()
        Render(false)
    end)

    function Toggle:Set(Value, Silent)
        self.Value = Value == true

        if self.Bind then
            self.Bind:SetActive(self.Value, true)
        end

        self:Commit()
        Render(Silent)

        if not Silent then
            self:Fire(self.Value)
        end
    end

    function Toggle:AddKeybind(KeyOptions)
        KeyOptions = KeyOptions or {}

        local Bind = Library:NewBind({
            Name = KeyOptions.Name or Options.Name,
            Default = KeyOptions.Default,
            Mode = KeyOptions.Mode,
            Callback = function(State)
                Toggle:Set(State)
            end,
        })

        Bind.Active = Toggle.Value
        Bind:Refresh()
        Library:BindChip(Side, Bind, 5)
        self.Bind = Bind

        return Bind
    end

    function Toggle:AddColorPicker(ColorOptions)
        local Picker = Library:CreateColorPicker(Side, ColorOptions or {}, 1)
        Library:Register(Picker)

        return Picker
    end

    function Toggle:Serialize()
        return {Value = self.Value, Bind = self.Bind and self.Bind:Serialize() or nil}
    end

    function Toggle:Deserialize(Data)
        if type(Data) ~= "table" then
            return
        end

        if self.Bind and Data.Bind then
            self.Bind:Deserialize(Data.Bind)
        end

        self:Set(Data.Value)
    end

    Row.MouseButton1Click:Connect(function()
        Toggle:Set(not Toggle.Value)
    end)

    Library:OnTheme(function()
        Render(true)
    end)

    Render(true)
    self:Track(Toggle, Row, Options.Name)
    Library:Register(Toggle)

    return Toggle
end

function GroupMethods:AddSlider(Options)
    local Slider = NewElement("Slider", Options)
    local Min, Max = Options.Min or 0, Options.Max or 100
    local Increment = Options.Increment or 1
    local Suffix = Options.Suffix or ""
    local Decimals = 0
    local Fraction = tostring(Increment):match("%.(%d+)")

    if Fraction then
        Decimals = #Fraction
    end

    local Format = "%." .. Decimals .. "f"

    local Row = Create("Frame", {
        Size = UD2(1, 0, 0, 34),
        BackgroundTransparency = 1,
        LayoutOrder = self:Next(),
        Parent = self.Body,
    })

    local Label = Create("TextLabel", {
        Size = UD2(1, 0, 0, 16),
        Text = Options.Name or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Row,
    })

    local Chip = Create("TextLabel", {
        AnchorPoint = Vec2(1, 0),
        Position = UD2(1, 0, 0, 0),
        Size = UD2(0, 0, 0, 16),
        AutomaticSize = AutoX,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        TextXAlignment = Right,
        Parent = Row,
    })

    FitLabel(Label, Chip, 10)

    local Track = Create("Frame", {
        Position = UD2(0, 0, 0, 25),
        Size = UD2(1, 0, 0, 4),
        BackgroundColor3 = Theme.Element,
        Parent = Row,
    }, {Corner(Full)})

    local Fill = Create("Frame", {
        Size = UD2(0, 0, 1, 0),
        Theme = {BackgroundColor3 = "Accent"},
        Parent = Track,
    }, {Corner(Full)})

    local Knob = Create("Frame", {
        AnchorPoint = Vec2(0.5, 0.5),
        Position = UD2(0, 0, 0.5, 0),
        Size = UD2(0, 12, 0, 12),
        BackgroundColor3 = White,
        Parent = Track,
    }, {Corner(Full), Create("UIStroke", {Thickness = 2, Theme = {Color = "Accent"}})})

    local Hit = Create("TextButton", {
        Position = UD2(0, 0, 0, 16),
        Size = UD2(1, 0, 0, 18),
        Parent = Row,
    })

    function Slider:Set(Value, Silent)
        Value = math.floor((Value - Min) / Increment + 0.5) * Increment + Min
        Value = math.clamp(tonumber(string.format(Format, Value)) or Min, Min, Max)

        local Percent = (Value - Min) / (Max - Min)

        self.Value = Value
        Fill.Size = UD2(Percent, 0, 1, 0)
        Knob.Position = UD2(Percent, 0, 0.5, 0)
        Chip.Text = string.format(Format, Value) .. Suffix
        self:Commit()

        if not Silent then
            self:Fire(Value)
        end
    end

    function Slider:Serialize()
        return self.Value
    end

    function Slider:Deserialize(Data)
        if type(Data) == "number" then
            self:Set(Data)
        end
    end

    Hit.MouseEnter:Connect(function()
        Tween(Chip, {TextColor3 = Theme.Text})
    end)

    Hit.MouseLeave:Connect(function()
        Tween(Chip, {TextColor3 = Theme.SubText})
    end)

    Hit.InputBegan:Connect(function(Input)
        if IsPress(Input) then
            BeginDrag(Input, function(Pointer)
                local Percent = math.clamp((Pointer.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                Slider:Set(Min + (Max - Min) * Percent)
            end)
        end
    end)

    Slider:Set(Options.Default or Min, true)
    self:Track(Slider, Row, Options.Name)
    Library:Register(Slider)

    return Slider
end

function GroupMethods:AddDropdown(Options)
    local Dropdown = NewElement("Dropdown", Options)
    local Multi = Options.Multi == true
    local Selected = {}
    local Entries = {}

    Dropdown.Multi = Multi
    Dropdown.List = Options.Options or {}
    Dropdown.Value = Multi and {} or nil

    local Row = Create("Frame", {
        Size = UD2(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder = self:Next(),
        Parent = self.Body,
    })

    Create("TextLabel", {Size = UD2(1, 0, 0, 16), Text = Options.Name or "", Parent = Row})

    local Box = Create("TextButton", {
        Position = UD2(0, 0, 0, 22),
        Size = UD2(1, 0, 0, 28),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0,
        Parent = Row,
    }, {Corner(R5), Stroke()})

    local Display = Create("TextLabel", {
        Position = UD2(0, 10, 0, 0),
        Size = UD2(1, -34, 1, 0),
        TextColor3 = Theme.SubText,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Box,
    })

    local Chevron = Icon("chevron-down", 14, Theme.SubText, {
        AnchorPoint = Vec2(1, 0.5),
        Position = UD2(1, -8, 0.5, 0),
        Parent = Box,
    })

    local Popup = Create("Frame", {
        Visible = false,
        Size = UD2(0, 180, 0, 100),
        BackgroundColor3 = Theme.Panel,
        ZIndex = 2,
        Parent = Library.Overlay,
    }, {Corner(R6), Stroke()})

    local Scroll = Create("ScrollingFrame", {Size = UD2(1, 0, 1, 0), ScrollBarThickness = 2, Parent = Popup}, {Pad(4, 4, 4, 4), List(2)})

    local function Collect()
        local Result = {}

        for _, Name in Dropdown.List do
            if Selected[Name] then
                table.insert(Result, Name)
            end
        end

        return Result
    end

    local function Render()
        for _, Entry in Entries do
            local On

            if Multi then
                On = Selected[Entry.Name] == true
            else
                On = Dropdown.Value == Entry.Name
            end

            Entry.Mark.Visible = On
            Entry.Label.TextColor3 = On and Theme.Text or Theme.SubText
            Entry.Label.FontFace = On and Fonts.SemiBold or Fonts.Medium
        end

        if Multi then
            local Chosen = Collect()
            Display.Text = #Chosen > 0 and table.concat(Chosen, ", ") or "None"
        else
            Display.Text = Dropdown.Value or "None"
        end
    end

    local function Commit(Silent)
        if Multi then
            Dropdown.Value = Collect()
        end

        Dropdown:Commit()
        Render()

        if not Silent then
            Dropdown:Fire(Dropdown.Value)
        end
    end

    local function Rebuild()
        for _, Entry in Entries do
            Entry.Button:Destroy()
        end

        table.clear(Entries)

        for Index, Name in Dropdown.List do
            local Button = Create("TextButton", {
                Size = UD2(1, 0, 0, 24),
                BackgroundColor3 = Theme.ElementHover,
                LayoutOrder = Index,
                Parent = Scroll,
            }, {Corner(R4)})

            local Mark = Create("Frame", {
                AnchorPoint = Vec2(0, 0.5),
                Position = UD2(0, 2, 0.5, 0),
                Size = UD2(0, 2, 0, 12),
                Visible = false,
                Theme = {BackgroundColor3 = "Accent"},
                Parent = Button,
            }, {Corner(Full)})

            local Label = Create("TextLabel", {
                Position = UD2(0, 10, 0, 0),
                Size = UD2(1, -16, 1, 0),
                Text = tostring(Name),
                Parent = Button,
            })

            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundTransparency = 0.4})
            end)

            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundTransparency = 1})
            end)

            Button.MouseButton1Click:Connect(function()
                if Multi then
                    Selected[Name] = not Selected[Name] or nil
                else
                    Dropdown.Value = Name
                    Library:ClosePopup()
                end

                Commit()
            end)

            table.insert(Entries, {Name = Name, Button = Button, Mark = Mark, Label = Label})
        end

        Render()
    end

    function Dropdown:Set(Value, Silent)
        if Multi then
            table.clear(Selected)

            if type(Value) == "table" then
                for _, Name in Value do
                    Selected[Name] = true
                end
            end
        else
            self.Value = Value
        end

        Commit(Silent)
    end

    function Dropdown:SetOptions(NewList, Keep)
        self.List = NewList
        Rebuild()

        if not Keep then
            self:Set(Multi and {} or nil, true)
        end
    end

    function Dropdown:Serialize()
        return self.Value
    end

    function Dropdown:Deserialize(Data)
        self:Set(Data)
    end

    Box.MouseButton1Click:Connect(function()
        Popup.Size = UD2(0, Box.AbsoluteSize.X, 0, math.min(#Dropdown.List * 26 + 8, 188))
        Library:OpenPopup(Popup, Box, function()
            Tween(Chevron, {Rotation = 0})
        end)
        Tween(Chevron, {Rotation = 180})
    end)

    Library:OnTheme(Render)
    Rebuild()
    Dropdown:Set(Options.Default, true)
    self:Track(Dropdown, Row, Options.Name)
    Library:Register(Dropdown)

    return Dropdown
end

function GroupMethods:AddKeybind(Options)
    local Keybind = NewElement("Keybind", Options)

    local Bind = Options.Bind or Library:NewBind({
        Name = Options.Name,
        Default = Options.Default,
        Mode = Options.Mode,
        Callback = Options.Callback,
        HideHotkey = Options.HideHotkey,
        Flag = Options.Flag,
    })

    local Row = Create("Frame", {
        Size = UD2(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = self:Next(),
        Parent = self.Body,
    })

    local Label = Create("TextLabel", {
        Size = UD2(1, 0, 1, 0),
        Text = Options.Name or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Row,
    })

    local Side = CreateRight(Row)
    FitLabel(Label, Side)
    Library:BindChip(Side, Bind, 1)

    Keybind.Bind = Bind
    Keybind.Value = Bind.Active

    function Keybind:Serialize()
        return Bind:Serialize()
    end

    function Keybind:Deserialize(Data)
        Bind:Deserialize(Data)
    end

    self:Track(Keybind, Row, Options.Name)
    Library:Register(Keybind)

    return Keybind
end

function GroupMethods:AddColorPicker(Options)
    local Row = Create("Frame", {
        Size = UD2(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = self:Next(),
        Parent = self.Body,
    })

    local Label = Create("TextLabel", {
        Size = UD2(1, 0, 1, 0),
        Text = Options.Name or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Row,
    })

    local Side = CreateRight(Row)
    FitLabel(Label, Side)

    local Picker = Library:CreateColorPicker(Side, Options, 1)

    self:Track(Picker, Row, Options.Name)
    Library:Register(Picker)

    return Picker
end

function GroupMethods:AddTextbox(Options)
    local Textbox = NewElement("Textbox", Options)
    Textbox.Value = Options.Default or ""

    local Row = Create("Frame", {
        Size = UD2(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder = self:Next(),
        Parent = self.Body,
    })

    Create("TextLabel", {Size = UD2(1, 0, 0, 16), Text = Options.Name or "", Parent = Row})

    local Box = Create("Frame", {
        Position = UD2(0, 0, 0, 22),
        Size = UD2(1, 0, 0, 28),
        BackgroundColor3 = Theme.Element,
        Parent = Row,
    }, {Corner(R5), Stroke()})

    local Input = Create("TextBox", {
        Position = UD2(0, 10, 0, 0),
        Size = UD2(1, -20, 1, 0),
        Text = Textbox.Value,
        PlaceholderText = Options.Placeholder or "",
        Parent = Box,
    })

    function Textbox:Set(Value, Silent)
        self.Value = tostring(Value or "")
        Input.Text = self.Value
        self:Commit()

        if not Silent then
            self:Fire(self.Value)
        end
    end

    function Textbox:Serialize()
        return self.Value
    end

    function Textbox:Deserialize(Data)
        self:Set(Data)
    end

    Input.FocusLost:Connect(function()
        Textbox:Set(Input.Text)
    end)

    self:Track(Textbox, Row, Options.Name)
    Library:Register(Textbox)

    return Textbox
end

function GroupMethods:AddButton(Options)
    local Button = NewElement("Button", Options)

    local Row = Create("Frame", {
        Size = UD2(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = self:Next(),
        Parent = self.Body,
    })

    local Click = Create("TextButton", {
        Size = UD2(1, 0, 1, 0),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0,
        Text = Options.Name or "",
        TextXAlignment = Center,
        Parent = Row,
    }, {Corner(R5), Stroke()})

    if Options.Icon then
        Icon(Options.Icon, 14, Theme.SubText, {AnchorPoint = Vec2(0, 0.5), Position = UD2(0, 10, 0.5, 0), Parent = Click})
    end

    Click.MouseEnter:Connect(function()
        Tween(Click, {BackgroundColor3 = Theme.ElementHover})
    end)

    Click.MouseLeave:Connect(function()
        Tween(Click, {BackgroundColor3 = Theme.Element})
    end)

    Click.MouseButton1Click:Connect(function()
        Button:Fire()
    end)

    function Button:SetText(Text)
        Click.Text = Text
    end

    self:Track(Button, Row, Options.Name)

    return Button
end

function GroupMethods:AddLabel(Text)
    local Label = NewElement("Label", {})

    local Row = Create("TextLabel", {
        Size = UD2(1, 0, 0, 0),
        AutomaticSize = AutoY,
        Text = Text or "",
        TextColor3 = Theme.SubText,
        TextSize = 12,
        TextWrapped = true,
        LayoutOrder = self:Next(),
        Parent = self.Body,
    })

    function Label:SetText(Value)
        Row.Text = Value
    end

    self:Track(Label, Row, Text, true)

    return Label
end

function GroupMethods:AddDivider()
    local Divider = NewElement("Divider", {})

    local Row = Create("Frame", {
        Size = UD2(1, 0, 0, 1),
        BackgroundColor3 = Theme.Outline,
        BackgroundTransparency = 0.4,
        LayoutOrder = self:Next(),
        Parent = self.Body,
    })

    self:Track(Divider, Row, "", true)

    return Divider
end

function Library:SaveConfig(Name)
    if not self.FileSystem then
        return false, "File system is not supported by this executor"
    end

    Name = tostring(Name or ""):gsub("[^%w_%- ]", "")

    if Name == "" then
        return false, "Enter a valid config name"
    end

    local Data = {}

    for Flag, Element in self.Options do
        if Element.Serialize then
            Data[Flag] = Element:Serialize()
        end
    end

    local Success, Result = pcall(function()
        writefile(string.format("%s/Configs/%s.json", self.Directory, Name), HttpService:JSONEncode({Date = os.date("%d/%m/%y"), Flags = Data}))
    end)

    return Success, Success and ("Saved " .. Name) or tostring(Result)
end

function Library:LoadConfig(Name)
    if not self.FileSystem then
        return false, "File system is not supported by this executor"
    end

    local Path = string.format("%s/Configs/%s.json", self.Directory, tostring(Name))

    if not Name or Name == "" or not isfile(Path) then
        return false, "Config not found"
    end

    local Success, Result = pcall(function()
        return HttpService:JSONDecode(readfile(Path))
    end)

    if not Success or type(Result) ~= "table" or type(Result.Flags) ~= "table" then
        return false, "Config file is corrupted"
    end

    for Flag, Value in Result.Flags do
        local Element = self.Options[Flag]

        if Element and Element.Deserialize then
            pcall(Element.Deserialize, Element, Value)
        end
    end

    return true, "Loaded " .. Name
end

function Library:DeleteConfig(Name)
    local Path = string.format("%s/Configs/%s.json", self.Directory, tostring(Name))

    if not self.FileSystem or not Name or Name == "" or not isfile(Path) then
        return false, "Config not found"
    end

    delfile(Path)

    return true, "Deleted " .. Name
end

-- The autoload config's name is kept in <Directory>/autoload.txt and loaded once the menu is built.
function Library:SetAutoload(Name)
    if not self.FileSystem then
        return false, "File system is not supported by this executor"
    end

    local Path = self.Directory .. "/autoload.txt"

    if not Name or Name == "" then
        if isfile(Path) then
            delfile(Path)
        end

        return true, "Autoload cleared"
    end

    if not isfile(string.format("%s/Configs/%s.json", self.Directory, tostring(Name))) then
        return false, "Save the config first"
    end

    writefile(Path, tostring(Name))

    return true, Name .. " now loads on start"
end

function Library:GetAutoload()
    local Path = self.Directory .. "/autoload.txt"

    if self.FileSystem and isfile(Path) then
        local Name = readfile(Path)

        return Name ~= "" and Name or nil
    end
end

function Library:LoadAutoload()
    local Name = self:GetAutoload()

    if Name then
        return self:LoadConfig(Name)
    end
end

function Library:ListConfigs()
    local Result = {}

    if not self.FileSystem then
        return Result
    end

    local Success, Files = pcall(listfiles, self.Directory .. "/Configs")

    if Success then
        for _, Path in Files do
            local Name = Path:match("([^/\\]+)%.json$")

            if Name then
                table.insert(Result, Name)
            end
        end
    end

    table.sort(Result)

    return Result
end

function Library:Unload()
    if self.Unloaded then
        return
    end

    self.Unloaded = true

    for _, Callback in self.UnloadCallbacks do
        pcall(Callback)
    end

    for _, Connection in self.Connections do
        pcall(Connection.Disconnect, Connection)
    end

    if self.Modal then
        self.Modal.Modal = false
    end

    if self.Gui then
        self.Gui:Destroy()
    end

    table.clear(self.Flags)
    table.clear(self.Options)
    table.clear(self.Keybinds)
    table.clear(self.ThemeObjects)
    table.clear(self.ThemeCallbacks)

    if Environment.Library == self then
        Environment.Library = nil
    end
end

function Library:CreateWindow(Options)
    self:Init()

    Options = Options or {}

    local Dimensions = Options.Size or Vec2(780, 540)
    local Viewport = Services.Workspace.CurrentCamera

    if Viewport then
        Dimensions = Vec2(math.min(Dimensions.X, Viewport.ViewportSize.X - 32), math.min(Dimensions.Y, Viewport.ViewportSize.Y - 32))
    end
    local Window = {Tabs = {}, Order = 0, Query = "", Panels = {}}
    local Scale = Create("UIScale", {Scale = 0.96})

    local Root = Create("CanvasGroup", {
        Name = "Window",
        AnchorPoint = Vec2(0.5, 0.5),
        Position = UD2(0.5, 0, 0.5, 0),
        Size = UD2(0, Dimensions.X, 0, Dimensions.Y),
        BackgroundColor3 = Theme.Background,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 1,
        Parent = self.Gui,
    }, {
        Corner(R6),
        Stroke(),
        Scale,
    })

    local Header = Create("Frame", {Size = UD2(1, 0, 0, 60), BackgroundColor3 = Theme.Sidebar, Parent = Root})

    -- The accent fades in and out along the top edge.
    Create("Frame", {
        Size = UD2(1, 0, 0, 2),
        Theme = {BackgroundColor3 = "Accent"},
        Parent = Header,
    }, {
        Create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.35, 0.2),
                NumberSequenceKeypoint.new(0.65, 0.2),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }),
    })

    local Badge = Create("Frame", {
        AnchorPoint = Vec2(0, 0.5),
        Position = UD2(0, 16, 0.5, 0),
        Size = UD2(0, 34, 0, 34),
        BackgroundTransparency = 0.82,
        Theme = {BackgroundColor3 = "Accent"},
        Parent = Header,
    }, {Corner(R6), Create("UIStroke", {Transparency = 0.55, Theme = {Color = "Accent"}})})

    -- A logo image stands on its own: no tile or border behind it, a little larger than the icon tile, and it also
    -- replaces the flame in the watermark.
    if Options.Logo then
        Badge.BackgroundTransparency = 1

        local BadgeStroke = Badge:FindFirstChildOfClass("UIStroke")

        if BadgeStroke then
            BadgeStroke:Destroy()
        end

        Create("ImageLabel", {
            AnchorPoint = Vec2(0.5, 0.5),
            Position = UD2(0.5, 0, 0.5, 0),
            Size = UD2(0, 40, 0, 40),
            Image = Options.Logo,
            ScaleType = Enum.ScaleType.Fit,
            Parent = Badge,
        })

        if self.WatermarkIcon then
            self.WatermarkIcon.Visible = false

            Create("ImageLabel", {
                Size = UD2(0, 16, 0, 16),
                Image = Options.Logo,
                ScaleType = Enum.ScaleType.Fit,
                LayoutOrder = 1,
                Parent = self.Watermark,
            })
        end
    else
        Icon(Options.Icon or "flame", 18, Theme.Accent, {
            AnchorPoint = Vec2(0.5, 0.5),
            Position = UD2(0.5, 0, 0.5, 0),
            Theme = {ImageColor3 = "Accent"},
            Parent = Badge,
        })
    end

    local FullName = Options.Name or self.Name
    local Base, Suffix = FullName:match("^(.-)(%..*)$")

    if not Base then
        Base, Suffix = FullName, ""
    end

    local NameRow = Create("Frame", {
        Position = UD2(0, 62, 0, 11),
        Size = UD2(0, 0, 0, 20),
        AutomaticSize = AutoX,
        BackgroundTransparency = 1,
        Parent = Header,
    }, {List(0, {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center})})

    Create("TextLabel", {
        Size = UD2(0, 0, 0, 20),
        AutomaticSize = AutoX,
        Text = Base,
        FontFace = Fonts.Bold,
        TextSize = 17,
        LayoutOrder = 1,
        Parent = NameRow,
    })

    Create("TextLabel", {
        Size = UD2(0, 0, 0, 20),
        AutomaticSize = AutoX,
        Text = Suffix,
        FontFace = Fonts.Bold,
        TextSize = 17,
        Theme = {TextColor3 = "Accent"},
        LayoutOrder = 2,
        Parent = NameRow,
    })

    Create("TextLabel", {
        Position = UD2(0, 62, 0, 32),
        Size = UD2(0, 280, 0, 14),
        Text = Options.Subtitle or ("v" .. self.Version),
        TextColor3 = Theme.SubText,
        TextSize = 11,
        Parent = Header,
    })

    -- Right side of the header: search, then who's playing.
    local Tools = Create("Frame", {
        AnchorPoint = Vec2(1, 0.5),
        Position = UD2(1, -14, 0.5, 0),
        Size = UD2(0, 0, 0, 32),
        AutomaticSize = AutoX,
        BackgroundTransparency = 1,
        Parent = Header,
    }, {
        List(10, {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    local SearchStroke = Stroke()

    local SearchBox = Create("Frame", {
        Size = UD2(0, 176, 0, 30),
        BackgroundColor3 = Theme.Element,
        LayoutOrder = 1,
        Parent = Tools,
    }, {Corner(R6), SearchStroke})

    Icon("search", 14, Theme.SubText, {AnchorPoint = Vec2(0, 0.5), Position = UD2(0, 11, 0.5, 0), Parent = SearchBox})

    local SearchInput = Create("TextBox", {
        Position = UD2(0, 32, 0, 0),
        Size = UD2(1, -42, 1, 0),
        PlaceholderText = "Search...",
        Parent = SearchBox,
    })

    SearchInput.Focused:Connect(function()
        Tween(SearchStroke, {Color = Theme.Accent})
    end)

    SearchInput.FocusLost:Connect(function()
        Tween(SearchStroke, {Color = Theme.Outline})
    end)

    local Account = Create("Frame", {
        Size = UD2(0, 0, 0, 30),
        AutomaticSize = AutoX,
        BackgroundColor3 = Theme.Element,
        LayoutOrder = 2,
        Parent = Tools,
    }, {
        Corner(R6),
        Stroke(),
        Pad(0, 12, 0, 3),
        List(8, {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center}),
    })

    Create("ImageLabel", {
        Size = UD2(0, 24, 0, 24),
        BackgroundTransparency = 0,
        BackgroundColor3 = Theme.Panel,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
        LayoutOrder = 1,
        Parent = Account,
    }, {Corner(R4)})

    Create("TextLabel", {
        Size = UD2(0, 0, 0, 16),
        AutomaticSize = AutoX,
        Text = LocalPlayer.DisplayName,
        FontFace = Fonts.SemiBold,
        TextSize = 12,
        LayoutOrder = 2,
        Parent = Account,
    })

    Create("Frame", {
        AnchorPoint = Vec2(0, 1),
        Position = UD2(0, 0, 1, 0),
        Size = UD2(1, 0, 0, 1),
        BackgroundColor3 = Theme.Outline,
        Parent = Header,
    })

    -- Tabs run along the top as pills; categories become thin dividers between them.
    local Strip = Create("ScrollingFrame", {
        Position = UD2(0, 0, 0, 60),
        Size = UD2(1, 0, 0, 44),
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = AutoX,
        ScrollBarThickness = 0,
        Parent = Root,
    }, {
        Pad(7, 14, 7, 14),
        List(6, {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center}),
    })

    Create("Frame", {
        Position = UD2(0, 0, 0, 104),
        Size = UD2(1, 0, 0, 1),
        BackgroundColor3 = Theme.Outline,
        BackgroundTransparency = 0.5,
        Parent = Root,
    })

    local Pages = Create("Frame", {
        Position = UD2(0, 0, 0, 105),
        Size = UD2(1, 0, 1, -105),
        BackgroundTransparency = 1,
        Parent = Root,
    })

    Header.InputBegan:Connect(function(Input)
        if not IsPress(Input) then
            return
        end

        local Origin = PointerPosition(Input)
        local Start = Root.Position

        BeginDrag(Input, function(Pointer)
            local Delta = Pointer - Origin
            Root.Position = UD2(Start.X.Scale, Start.X.Offset + Delta.X, Start.Y.Scale, Start.Y.Offset + Delta.Y)
        end)
    end)

    Window.Root = Root
    Window.Scale = Scale

    function Window:AddCategory()
        self.Order += 1

        if #self.Tabs == 0 then
            return
        end

        Create("Frame", {
            Size = UD2(0, 1, 0, 18),
            BackgroundColor3 = Theme.Outline,
            LayoutOrder = self.Order,
            Parent = Strip,
        })
    end

    function Window:ApplySearch()
        local Tab = self.Current

        if not Tab then
            return
        end

        local Query = self.Query:lower()

        for _, Group in Tab.Groups do
            local Any = false
            local GroupMatch = Query == "" or Group.Name:find(Query, 1, true) ~= nil

            for _, Element in Group.Elements do
                local Match = GroupMatch

                if not Match and not Element.Static then
                    Match = Element.Key:find(Query, 1, true) ~= nil
                end

                Element.Matched = Match
                Element.Row.Visible = Match and not Element.Hidden
                Any = Any or Match
            end

            Group.Container.Visible = Any or GroupMatch
        end
    end

    function Window:SelectTab(Tab)
        if self.Current == Tab then
            return
        end

        if self.Current then
            self.Current.Active = false
            self.Current.Page.Visible = false
            self.Current:Render(false)
        end

        self.Current = Tab
        Tab.Active = true
        Tab.Page.Visible = true
        Tab:Render(false)
        Library:ClosePopup()
        self:ApplySearch()
        self:UpdatePanels()
    end

    function Window:AddTab(TabOptions)
        self.Order += 1

        local Tab = {
            Name = TabOptions.Name,
            Icon = TabOptions.Icon,
            Groups = {},
            Active = false,
            Sides = {Left = 0, Right = 0},
        }

        local Button = Create("TextButton", {
            Size = UD2(0, 0, 0, 30),
            AutomaticSize = AutoX,
            BackgroundColor3 = Theme.Accent,
            LayoutOrder = self.Order,
            Parent = Strip,
        }, {
            Corner(R6),
            Pad(0, 11, 0, 10),
            List(7, {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center}),
        })

        local ButtonStroke = Create("UIStroke", {Transparency = 1, Theme = {Color = "Accent"}, Parent = Button})
        local TabIcon = Icon(Tab.Icon, 15, Theme.SubText, {LayoutOrder = 1, Parent = Button})

        local TabLabel = Create("TextLabel", {
            Size = UD2(0, 0, 1, 0),
            AutomaticSize = AutoX,
            Text = Tab.Name,
            TextColor3 = Theme.SubText,
            LayoutOrder = 2,
            Parent = Button,
        })

        Tab.Page = Create("ScrollingFrame", {Size = UD2(1, 0, 1, 0), Visible = false, Parent = Pages})

        local Holder = Create("Frame", {
            Size = UD2(1, 0, 0, 0),
            AutomaticSize = AutoY,
            BackgroundTransparency = 1,
            Parent = Tab.Page,
        }, {Pad(16, 16, 16, 16)})

        local Columns = Create("Frame", {
            Size = UD2(1, 0, 0, 0),
            AutomaticSize = AutoY,
            BackgroundTransparency = 1,
            Parent = Holder,
        }, {List(14, {FillDirection = Enum.FillDirection.Horizontal})})

        for Index, Side in {"Left", "Right"} do
            Tab[Side] = Create("Frame", {
                Size = UD2(0.5, -7, 0, 0),
                AutomaticSize = AutoY,
                BackgroundTransparency = 1,
                LayoutOrder = Index,
                Parent = Columns,
            }, {List(14)})
        end

        function Tab:Render(Instant)
            local On = self.Active

            Apply(Button, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = On and 0.84 or 1}, Instant)
            Apply(ButtonStroke, {Transparency = On and 0.5 or 1}, Instant)
            Apply(TabLabel, {TextColor3 = On and Theme.Text or Theme.SubText}, Instant)
            Apply(TabIcon, {ImageColor3 = On and Theme.Accent or Theme.SubText}, Instant)
        end

        function Tab:AddGroup(GroupOptions)
            local Side = GroupOptions.Side

            if Side ~= "Left" and Side ~= "Right" then
                Side = self.Sides.Left <= self.Sides.Right and "Left" or "Right"
            end

            self.Sides[Side] += 1

            local Group = setmetatable({
                Name = (GroupOptions.Name or ""):lower(),
                Elements = {},
                Count = 0,
            }, GroupMethods)

            Group.Container = Create("Frame", {
                Size = UD2(1, 0, 0, 0),
                AutomaticSize = AutoY,
                BackgroundColor3 = Theme.Panel,
                LayoutOrder = self.Sides[Side],
                Parent = self[Side],
            }, {Corner(R8), Stroke(), List(0)})

            local Header = Create("Frame", {
                Size = UD2(1, 0, 0, 34),
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Parent = Group.Container,
            })

            Create("Frame", {
                AnchorPoint = Vec2(0, 0.5),
                Position = UD2(0, 0, 0.5, 0),
                Size = UD2(0, 2, 0, 14),
                Theme = {BackgroundColor3 = "Accent"},
                Parent = Header,
            }, {Corner(Full)})

            local Offset = 12

            if GroupOptions.Icon then
                Icon(GroupOptions.Icon, 14, Theme.Accent, {
                    Theme = {ImageColor3 = "Accent"},
                    AnchorPoint = Vec2(0, 0.5),
                    Position = UD2(0, 12, 0.5, 0),
                    Parent = Header,
                })

                Offset = 33
            end

            Create("TextLabel", {
                Position = UD2(0, Offset, 0, 0),
                Size = UD2(1, -Offset - 12, 1, 0),
                Text = GroupOptions.Name or "",
                FontFace = Fonts.SemiBold,
                Parent = Header,
            })

            Create("Frame", {
                AnchorPoint = Vec2(0, 1),
                Position = UD2(0, 12, 1, 0),
                Size = UD2(1, -24, 0, 1),
                BackgroundColor3 = Theme.Outline,
                BackgroundTransparency = 0.4,
                Parent = Header,
            })

            Group.Body = Create("Frame", {
                Size = UD2(1, 0, 0, 0),
                AutomaticSize = AutoY,
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Parent = Group.Container,
            }, {Pad(10, 12, 12, 12), List(8)})

            table.insert(self.Groups, Group)

            return Group
        end

        Button.MouseEnter:Connect(function()
            if not Tab.Active then
                Tween(Button, {BackgroundTransparency = 0.94})
            end
        end)

        Button.MouseLeave:Connect(function()
            if not Tab.Active then
                Tween(Button, {BackgroundTransparency = 1})
            end
        end)

        Button.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)

        Library:OnTheme(function()
            Tab:Render(true)
        end)

        table.insert(self.Tabs, Tab)

        if #self.Tabs == 1 then
            self:SelectTab(Tab)
        end

        return Tab
    end

    -- Side panels float beside the window (left, or right when there's no room) and show only while the menu is
    -- open on one of their tabs.
    local function PlacePanels()
        local Offset = Root.AbsolutePosition - Library.Gui.AbsolutePosition

        for _, Panel in Window.Panels do
            local Width = Panel.Frame.AbsoluteSize.X
            local X = Offset.X - Width - 12

            if X < 8 then
                X = Offset.X + Root.AbsoluteSize.X + 12
            end

            Panel.Frame.Position = UD2(0, X, 0, Offset.Y)
        end
    end

    Root:GetPropertyChangedSignal("AbsolutePosition"):Connect(PlacePanels)
    Root:GetPropertyChangedSignal("AbsoluteSize"):Connect(PlacePanels)

    function Window:UpdatePanels()
        for _, Panel in self.Panels do
            local Show = Library.Open and self.Current ~= nil and Panel.Tabs[self.Current.Name] == true

            if Show == Panel.Shown then
                continue
            end

            Panel.Shown = Show

            if Show then
                Panel.Frame.Visible = true
                Tween(Panel.Frame, {GroupTransparency = 0}, 0.22, Enum.EasingStyle.Quint)
            else
                Tween(Panel.Frame, {GroupTransparency = 1}, 0.15).Completed:Once(function()
                    if not Panel.Shown then
                        Panel.Frame.Visible = false
                    end
                end)
            end

            if Panel.OnShown then
                Library:Fire(Panel.OnShown, Show)
            end
        end

        PlacePanels()
    end

    function Window:AddSidePanel(PanelOptions)
        local Panel = {Tabs = {}, Shown = false, OnShown = PanelOptions.OnShown}

        for _, Name in PanelOptions.Tabs or {} do
            Panel.Tabs[Name] = true
        end

        Panel.Frame = Create("CanvasGroup", {
            Size = UD2(0, PanelOptions.Width or 220, 0, PanelOptions.Height or 300),
            BackgroundColor3 = Theme.Background,
            GroupTransparency = 1,
            Visible = false,
            Parent = Library.Gui,
        }, {Corner(R6), Stroke()})

        local Top = Create("Frame", {Size = UD2(1, 0, 0, 36), BackgroundColor3 = Theme.Sidebar, Parent = Panel.Frame})

        Create("Frame", {
            Size = UD2(1, 0, 0, 2),
            Theme = {BackgroundColor3 = "Accent"},
            Parent = Top,
        }, {
            Create("UIGradient", {
                Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.2), NumberSequenceKeypoint.new(1, 1)}),
            }),
        })

        Icon(PanelOptions.Icon or "eye", 14, Theme.Accent, {
            Theme = {ImageColor3 = "Accent"},
            AnchorPoint = Vec2(0, 0.5),
            Position = UD2(0, 12, 0.5, 0),
            Parent = Top,
        })

        Create("TextLabel", {
            Position = UD2(0, 33, 0, 0),
            Size = UD2(1, -45, 1, 0),
            Text = PanelOptions.Title or "",
            FontFace = Fonts.SemiBold,
            Parent = Top,
        })

        Create("Frame", {
            AnchorPoint = Vec2(0, 1),
            Position = UD2(0, 0, 1, 0),
            Size = UD2(1, 0, 0, 1),
            BackgroundColor3 = Theme.Outline,
            Parent = Top,
        })

        Panel.Body = Create("Frame", {
            Position = UD2(0, 0, 0, 36),
            Size = UD2(1, 0, 1, -36),
            BackgroundTransparency = 1,
            Parent = Panel.Frame,
        })

        table.insert(self.Panels, Panel)
        self:UpdatePanels()

        return Panel
    end

    function Window:AddSettingsTab()
        local Tab = self:AddTab({Name = "Settings", Icon = "settings"})
        local Interface = Tab:AddGroup({Name = "Interface", Icon = "palette", Side = "Left"})

        local Accent = Interface:AddColorPicker({
            Name = "Accent color",
            Flag = "Liminal.Accent",
            Default = Theme.Accent,
            Callback = function(Color)
                Library:SetAccent(Color)
            end,
        })

        Interface:AddDropdown({
            Name = "Accent preset",
            Options = Library.PresetNames,
            Callback = function(Name)
                local Color = Library.Presets[Name]

                if Color then
                    Accent:Set(Color)
                end
            end,
        })

        Interface:AddKeybind({Name = "Menu keybind", Flag = "Liminal.MenuKey", Bind = Library.MenuBind})

        Interface:AddToggle({
            Name = "Watermark",
            Flag = "Liminal.Watermark",
            Default = Library.ShowWatermark,
            Callback = function(State)
                Library:SetWatermarkVisible(State)
            end,
        })

        Interface:AddToggle({
            Name = "Hotkey list",
            Flag = "Liminal.Hotkeys",
            Default = Library.ShowHotkeys,
            Callback = function(State)
                Library:SetHotkeysVisible(State)
            end,
        })

        local Session = Tab:AddGroup({Name = "Session", Icon = "power", Side = "Left"})

        Session:AddButton({
            Name = "Unload interface",
            Icon = "power",
            Callback = function()
                Library:Unload()
            end,
        })

        local Configuration = Tab:AddGroup({Name = "Configuration", Icon = "folder", Side = "Right"})
        local NameBox = Configuration:AddTextbox({Name = "Config name", Placeholder = "Enter a name"})
        local Saved = Configuration:AddDropdown({Name = "Saved configs", Options = Library:ListConfigs()})

        local function Report(Success, Message)
            Library:Notify({Title = "Configuration", Content = Message, Type = Success and "Success" or "Error", Duration = 3})
        end

        local function Selected()
            return NameBox.Value ~= "" and NameBox.Value or Saved.Value
        end

        local function Refresh()
            Saved:SetOptions(Library:ListConfigs())
        end

        Configuration:AddButton({
            Name = "Save config",
            Icon = "save",
            Callback = function()
                Report(Library:SaveConfig(Selected()))
                Refresh()
            end,
        })

        Configuration:AddButton({
            Name = "Load config",
            Icon = "download",
            Callback = function()
                Report(Library:LoadConfig(Saved.Value or Selected()))
            end,
        })

        Configuration:AddButton({
            Name = "Delete config",
            Icon = "trash",
            Callback = function()
                Report(Library:DeleteConfig(Saved.Value))
                Refresh()
            end,
        })

        Configuration:AddButton({Name = "Refresh list", Icon = "refresh-cw", Callback = Refresh})

        local AutoloadLabel = Configuration:AddLabel("Autoload: " .. (Library:GetAutoload() or "none"))

        Configuration:AddButton({
            Name = "Set as autoload",
            Icon = "star",
            Callback = function()
                Report(Library:SetAutoload(Saved.Value or Selected()))
                AutoloadLabel:SetText("Autoload: " .. (Library:GetAutoload() or "none"))
            end,
        })

        Configuration:AddButton({
            Name = "Clear autoload",
            Icon = "x",
            Callback = function()
                Report(Library:SetAutoload(nil))
                AutoloadLabel:SetText("Autoload: none")
            end,
        })

        return Tab
    end

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        Window.Query = SearchInput.Text
        Window:ApplySearch()
    end)

    self.MenuBind = self.MenuBind or self:NewBind({
        Name = "Menu",
        Default = Options.MenuKey or Enum.KeyCode.Insert,
        Mode = "Toggle",
        HideHotkey = true,
        Callback = function()
            self:Toggle()
        end,
    })

    self.WatermarkTitle = Options.Name or self.Name
    self.Window = Window

    return Window
end

Library.Services = Services
Library.Create = Create
Library.Icon = Icon
Library.Fonts = Fonts

return Library
