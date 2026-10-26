-- Egg Farm Hub - GUI prototype
-- Target: Roblox Studio / game you own or are authorized to modify.
-- This file provides the GUI and settings only.
-- It does NOT implement third-party-game exploiting, teleporting, or stealing eggs.
-- For a game you own, connect these controls to server-validated game mechanics.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("EggFarmHub")
if old then old:Destroy() end

local settings = {
    Rarity = "Secret",
    TeleportToEgg = true,
    ReturnToSaveZone = true,
    AutoRepeat = false,
}

local running = false
local selectedEgg = nil

local C = {
    bg = Color3.fromRGB(20, 20, 24),
    panel = Color3.fromRGB(31, 31, 36),
    red = Color3.fromRGB(190, 30, 42),
    darkRed = Color3.fromRGB(105, 20, 27),
    white = Color3.fromRGB(245, 245, 245),
    gray = Color3.fromRGB(165, 165, 175),
    green = Color3.fromRGB(65, 180, 100),
}

local function create(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = obj
end

local gui = create("ScreenGui", {
    Name = "EggFarmHub",
    ResetOnSpawn = false,
}, playerGui)

local main = create("Frame", {
    Size = UDim2.fromOffset(350, 410),
    Position = UDim2.new(0.5, -175, 0.5, -205),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
}, gui)
round(main, 12)

local header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = C.red,
    BorderSizePixel = 0,
}, main)
round(header, 12)

create("TextLabel", {
    Size = UDim2.new(1, -55, 1, 0),
    Position = UDim2.fromOffset(14, 0),
    BackgroundTransparency = 1,
    Text = "EGG FARM HUB",
    Font = Enum.Font.GothamBold,
    TextSize = 19,
    TextColor3 = C.white,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local close = create("TextButton", {
    Size = UDim2.fromOffset(34, 30),
    Position = UDim2.new(1, -42, 0, 9),
    Text = "X",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = C.white,
    BackgroundColor3 = C.darkRed,
}, header)
round(close, 6)
close.Activated:Connect(function()
    running = false
    gui.Enabled = false
end)

local tabs = create("Frame", {
    Size = UDim2.new(1, -20, 0, 38),
    Position = UDim2.fromOffset(10, 58),
    BackgroundTransparency = 1,
}, main)

local farmTab = create("TextButton", {
    Size = UDim2.new(0.5, -4, 1, 0),
    Text = "FARM",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = C.white,
    BackgroundColor3 = C.red,
}, tabs)
round(farmTab, 6)

local settingsTab = create("TextButton", {
    Size = UDim2.new(0.5, -4, 1, 0),
    Position = UDim2.new(0.5, 4, 0, 0),
    Text = "SETTINGS",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = C.white,
    BackgroundColor3 = C.panel,
}, tabs)
round(settingsTab, 6)

local content = create("Frame", {
    Size = UDim2.new(1, -20, 1, -108),
    Position = UDim2.fromOffset(10, 102),
    BackgroundTransparency = 1,
}, main)

local pages = {}

local function makePage(name)
    local page = create("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = C.red,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, content)
    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
    end)
    pages[name] = page
    return page
end

local farmPage = makePage("Farm")
local settingsPage = makePage("Settings")

local function label(parent, text, height)
    return create("TextLabel", {
        Size = UDim2.new(1, -4, 0, height or 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = C.white,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function button(parent, text, callback, color)
    local b = create("TextButton", {
        Size = UDim2.new(1, -4, 0, 38),
        BackgroundColor3 = color or C.panel,
        Text = text,
        TextColor3 = C.white,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
    }, parent)
    round(b, 7)
    b.Activated:Connect(callback)
    return b
end

local status = label(farmPage, "Status: Siap", 32)
status.TextColor3 = C.green

local rarityOptions = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
label(farmPage, "PILIH RARITY", 22)

local rarityButton
rarityButton = button(farmPage, "Rarity: Secret  ▼", function()
    local index = table.find(rarityOptions, settings.Rarity) or 1
    index = index % #rarityOptions + 1
    settings.Rarity = rarityOptions[index]
    rarityButton.Text = "Rarity: " .. settings.Rarity .. "  ▼"
    selectedEgg = nil
    status.Text = "Status: Rarity diubah"
end, C.darkRed)

label(farmPage, "EGG TERSEDIA", 22)
local eggList = create("Frame", {
    Size = UDim2.new(1, -4, 0, 70),
    BackgroundColor3 = C.panel,
}, farmPage)
round(eggList, 8)

local function refreshEggList()
    for _, child in ipairs(eggList:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end

    -- For your own game, place egg models in Workspace.Eggs and add
    -- a string Attribute named "Rarity" to each model.
    local folder = workspace:FindFirstChild("Eggs")
    local count = 0

    if folder then
        for _, egg in ipairs(folder:GetChildren()) do
            if egg:GetAttribute("Rarity") == settings.Rarity then
                count += 1
                local item = create("TextButton", {
                    Size = UDim2.new(1, -8, 0, 30),
                    BackgroundColor3 = selectedEgg == egg and C.red or C.panel,
                    Text = egg.Name,
                    TextColor3 = C.white,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                }, eggList)
                round(item, 5)
                item.Activated:Connect(function()
                    selectedEgg = egg
                    status.Text = "Dipilih: " .. egg.Name
                    refreshEggList()
                end)
            end
        end
    end

    if count == 0 then
        label(eggList, folder and "Tidak ada egg dengan rarity ini."
            or "Workspace.Eggs belum tersedia.", 42)
    end
    eggList.Size = UDim2.new(1, -4, 0, math.max(45, count * 34))
end

button(farmPage, "REFRESH DAFTAR EGG", function()
    refreshEggList()
    status.Text = "Status: Daftar diperbarui"
end, C.darkRed)

button(farmPage, "START FARM", function()
    if not selectedEgg or not selectedEgg.Parent then
        status.Text = "Status: Pilih egg terlebih dahulu"
        refreshEggList()
        return
    end
    running = true
    status.Text = "Status: GUI siap; sambungkan mekanik game sendiri"
    -- No teleport or collection action is performed by this prototype.
end, C.red)

button(farmPage, "STOP FARM", function()
    running = false
    status.Text = "Status: Dihentikan"
end)

label(settingsPage, "PENGATURAN FARM", 26)

local function settingToggle(text, key)
    local b
    local function update()
        b.Text = text .. ": " .. (settings[key] and "ON" or "OFF")
        b.BackgroundColor3 = settings[key] and C.red or C.panel
    end
    b = button(settingsPage, "", function()
        settings[key] = not settings[key]
        update()
    end)
    update()
end

settingToggle("Teleport ke egg", "TeleportToEgg")
settingToggle("Kembali ke Save Zone", "ReturnToSaveZone")
settingToggle("Auto Repeat", "AutoRepeat")

label(settingsPage,
    "Default: Secret | Teleport ON | Save Zone ON | Auto Repeat OFF", 46)

local function showPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end
    farmTab.BackgroundColor3 = name == "Farm" and C.red or C.panel
    settingsTab.BackgroundColor3 = name == "Settings" and C.red or C.panel
end

farmTab.Activated:Connect(function()
    showPage("Farm")
    refreshEggList()
end)
settingsTab.Activated:Connect(function()
    showPage("Settings")
end)

-- Drag window with mouse or touch
local dragging, dragStart, startPosition
header.Active = true
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

showPage("Farm")
refreshEggList()
