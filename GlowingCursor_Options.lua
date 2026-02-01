local addonName, addon = ...

local db
local category

local textureOptions = {
    "Blue",
    "Yellow",
}

local function CreateSlider(parent, name, label, minVal, maxVal, step, value, callback)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(200)
    slider:SetHeight(20)
    
    _G[name .. "Low"]:SetText(tostring(minVal))
    _G[name .. "High"]:SetText(tostring(maxVal))
    _G[name .. "Text"]:SetText(label)
    
    local valueText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    valueText:SetPoint("TOP", slider, "BOTTOM", 0, 3)
    slider.valueText = valueText
    
    slider:SetScript("OnValueChanged", function(self, value)
        local displayValue = math.floor(value * 10) / 10
        self.valueText:SetText(tostring(displayValue))
        callback(value)
    end)
    
    slider:SetValue(value)
    
    return slider
end

local function CreateDropdown(parent, name, label, options, getCurrentValue, callback)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetSize(200, 30)
    
    local labelText = dropdown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
    labelText:SetText(label)
    
    local function OnClick(self)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
        callback(options[self:GetID()])
    end
    
    local function Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        local currentValue = getCurrentValue()
        for i, option in ipairs(options) do
            info.text = option
            info.func = OnClick
            info.checked = (option == currentValue)
            UIDropDownMenu_AddButton(info, level)
        end
    end
    
    UIDropDownMenu_Initialize(dropdown, Initialize)
    
    local initialValue = getCurrentValue()
    for i, option in ipairs(options) do
        if option == initialValue then
            UIDropDownMenu_SetSelectedID(dropdown, i)
            break
        end
    end
    
    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetButtonWidth(dropdown, 124)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")
    
    return dropdown
end

local function BuildOptionsPanel()
    local panel = CreateFrame("Frame", "GlowingCursorOptions")
    panel.name = "Glowing Cursor"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Glowing Cursor")
    
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure the appearance and position of your glowing cursor")
    subtitle:SetWidth(600)
    subtitle:SetJustifyH("LEFT")
    
    local textureDropdown = CreateDropdown(
        panel,
        "GlowingCursorTextureDropdown",
        "Texture Style",
        textureOptions,
        function() return db.texture end,
        function(value)
            db.texture = value
            addon:UpdateSettings()
        end
    )
    textureDropdown:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -16, -30)
    panel.textureDropdown = textureDropdown
    
    local sizeSlider = CreateSlider(
        panel,
        "GlowingCursorSizeSlider",
        "Cursor Size",
        16,
        256,
        1,
        db.size,
        function(value)
            db.size = math.floor(value)
            addon:UpdateSettings()
        end
    )
    sizeSlider:SetPoint("TOPLEFT", textureDropdown, "BOTTOMLEFT", 16, -30)
    panel.sizeSlider = sizeSlider
    
    local offsetXSlider = CreateSlider(
        panel,
        "GlowingCursorOffsetXSlider",
        "X Offset",
        -100,
        100,
        1,
        db.offsetX,
        function(value)
            db.offsetX = math.floor(value)
        end
    )
    offsetXSlider:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -30)
    panel.offsetXSlider = offsetXSlider
    
    local offsetYSlider = CreateSlider(
        panel,
        "GlowingCursorOffsetYSlider",
        "Y Offset",
        -100,
        100,
        1,
        db.offsetY,
        function(value)
            db.offsetY = math.floor(value)
        end
    )
    offsetYSlider:SetPoint("TOPLEFT", offsetXSlider, "BOTTOMLEFT", 0, -30)
    panel.offsetYSlider = offsetYSlider
    
    local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetButton:SetSize(120, 22)
    resetButton:SetPoint("TOPLEFT", offsetYSlider, "BOTTOMLEFT", 0, -20)
    resetButton:SetText("Reset to Default")
    resetButton:SetScript("OnClick", function()
        db.size = addon.defaults.size
        db.offsetX = addon.defaults.offsetX
        db.offsetY = addon.defaults.offsetY
        db.texture = addon.defaults.texture
        
        panel.sizeSlider:SetValue(db.size)
        panel.offsetXSlider:SetValue(db.offsetX)
        panel.offsetYSlider:SetValue(db.offsetY)
        
        for i, option in ipairs(textureOptions) do
            if option == db.texture then
                UIDropDownMenu_SetSelectedID(panel.textureDropdown, i)
                break
            end
        end
        
        addon:UpdateSettings()
    end)
    
    if Settings and Settings.RegisterCanvasLayoutCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        db = GlowingCursorDB or addon.defaults
        
        C_Timer.After(0.5, function()
            BuildOptionsPanel()
        end)
    end
end)
