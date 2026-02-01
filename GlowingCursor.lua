local addonName, addon = ...

_G.GlowingCursor = addon

local defaults = {
    size = 95,
    offsetX = 14,
    offsetY = -13,
    texture = "Blue",
}

local textureAtlases = {
    ["Blue"] = "talents-search-notonactionbar",
    ["Yellow"] = "talents-search-notonactionbarhidden",
}

local db
local cursorFrame
local cursorTexture

function addon:OnInitialize()
    db = GlowingCursorDB or {}
    
    for k, v in pairs(defaults) do
        if db[k] == nil then
            db[k] = v
        end
    end
    
    GlowingCursorDB = db
end

function addon:CreateCursorFrame()
    cursorFrame = CreateFrame("Frame", "GlowingCursorFrame", UIParent)
    cursorFrame:SetSize(db.size, db.size)
    cursorFrame:SetFrameStrata("HIGH")
    cursorFrame:SetFrameLevel(100)
    
    cursorTexture = cursorFrame:CreateTexture(nil, "OVERLAY")
    cursorTexture:SetAllPoints(cursorFrame)
    local atlas = textureAtlases[db.texture] or textureAtlases["Blue"]
    cursorTexture:SetAtlas(atlas)
    cursorTexture:SetBlendMode("ADD")
    
    cursorFrame:Hide()
end

function addon:UpdateCursorPosition()
    if not cursorFrame then return end
    
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    
    x = x / scale
    y = y / scale
    
    cursorFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x + db.offsetX, y + db.offsetY)
end

function addon:EnableCursor()
    if not cursorFrame then
        self:CreateCursorFrame()
    end
    
    cursorFrame:Show()
    cursorFrame:SetScript("OnUpdate", function() addon:UpdateCursorPosition() end)
end

function addon:DisableCursor()
    if cursorFrame then
        cursorFrame:Hide()
        cursorFrame:SetScript("OnUpdate", nil)
    end
end

function addon:UpdateSettings()
    if cursorFrame then
        cursorFrame:SetSize(db.size, db.size)
        if cursorTexture then
            local atlas = textureAtlases[db.texture] or textureAtlases["Blue"]
            cursorTexture:SetAtlas(atlas)
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        addon:OnInitialize()
    elseif event == "PLAYER_LOGIN" then
        addon:EnableCursor()
    end
end)

addon.db = db
addon.defaults = defaults
