Cosplay = LibStub("AceAddon-3.0"):NewAddon("Cosplay", "AceEvent-3.0", "AceHook-3.0")
local Cosplay = Cosplay
local L = LibStub("AceLocale-3.0"):GetLocale("Cosplay")

local AHButtonsCreated = false
local MainButtonsCreated = false

local DressUpFrame = DressUpFrame
local UnitIsPlayer = UnitIsPlayer
local UnitIsVisible = UnitIsVisible
local UnitRace = UnitRace

local GS_TITLE_OPTION_OK = SOUNDKIT.GS_TITLE_OPTION_OK

-- Bindings
BINDING_NAME_CosplayButtonName = L["Open the DressUpFrame"]
BINDING_NAME_CosplayButtonHeader = L["Undress Button"]

local IsClassic
do
    local classic_versions = {
        [11302] = true,
    }

    local version = select(4, GetBuildInfo())
    local isClassic = classic_versions[version]

    IsClassic = function()
        return isClassic
    end
end

-- Create a function that returns an appropriate DressUpModel
local DressUpModel
do
    if IsClassic() then
        DressUpModel = function()
            return DressUpFrame.DressUpModel
        end
    else
        DressUpModel = function()
            return DressUpFrame.ModelScene:GetPlayerActor()
        end
    end
end

-- Create a function that will dress up the current target
local DressUpTarget
do
    if IsClassic() then
        DressUpTarget = function(unitID)
            DressUpModel():SetUnit(unitID)
        end
    else
        DressUpTarget = function(unitID)
            DressUpModel():SetModelByUnit(unitID)
        end
    end
end

function Cosplay:CreateMainButtons()
    if not MainButtonsCreated then
        -- Undress button.  Lets get nekkid!
        local DUFUndressButton = CreateFrame("Button", "DUFUndressButton", DressUpFrame, "UIPanelButtonTemplate")
        DUFUndressButton:SetWidth(80)
        DUFUndressButton:SetHeight(22)
        DUFUndressButton:SetText(L["Undress"])
        DUFUndressButton:SetPoint("RIGHT", "DressUpFrameResetButton", "LEFT", 0, 0)
        DUFUndressButton:SetFrameStrata("HIGH")
        DUFUndressButton:SetScript("OnClick", function()
            DressUpModel():Undress()
            PlaySound(GS_TITLE_OPTION_OK)
        end)

        -- Target button.
        local DUFDressTargetButton = CreateFrame("Button", "DUFDressTargetButton", DressUpFrame, "UIPanelButtonTemplate")
        DUFDressTargetButton:SetWidth(80)
        DUFDressTargetButton:SetHeight(22)
        DUFDressTargetButton:SetText(L["Target"])
        DUFDressTargetButton:SetPoint("RIGHT", "DUFUndressButton", "LEFT", 0, 0)
        DUFDressTargetButton:SetFrameStrata("HIGH")
        DUFDressTargetButton:SetScript("OnClick", function()
            self:DressUpTarget()
        end)
        DUFDressTargetButton:SetScript("OnShow", function()
            self:Reset()
        end)

        -- All done
        MainButtonsCreated = true

        -- Unhook the script now.
        self:Unhook(DressUpFrame, "OnShow")
    end
end

function Cosplay:CreateAHButtons()
    if not AHButtonsCreated then
        local ADUFUndressButton = CreateFrame("Button", "ADUFUndressButton", SideDressUpModel, "UIPanelButtonTemplate")
        ADUFUndressButton:SetWidth(70)
        ADUFUndressButton:SetHeight(22)
        ADUFUndressButton:SetText(L["Undress"])
        ADUFUndressButton:SetPoint("BOTTOM", "SideDressUpModelResetButton", "TOP", 0, 2)
        ADUFUndressButton:SetScript("OnClick", function()
            SideDressUpModel:Undress()
            PlaySound(GS_TITLE_OPTION_OK)
        end)

        AHButtonsCreated = true
    end

    self:UnregisterEvent("AUCTION_HOUSE_SHOW")
end


local ResetPlayerModel
do
    if IsClassic() then
        ResetPlayerModel = function()
            DressUpTarget("player")
        end
    else
        ResetPlayerModel = function()
            DressUpTarget("player")
            DressUpModel():SetSheathed(false)
            DressUpModel():Dress()
        end
    end
end

function Cosplay:Reset()
    local race, fileName = UnitRace("player")

    SetPortraitTexture(DressUpFramePortrait, "player")
    SetDressUpBackground(DressUpFrame, fileName)

    ResetPlayerModel()
end

function Cosplay:DressUpTarget()
    if not DressUpFrame:IsVisible() then
        ShowUIPanel(DressUpFrame)
    else
        PlaySound(GS_TITLE_OPTION_OK)
    end

    if UnitIsVisible("target") and UnitIsPlayer("target") then
        local race, fileName = UnitRace("target")
        SetPortraitTexture(DressUpFramePortrait, "target")
        SetDressUpBackground(DressUpFrame, fileName)

        DressUpTarget("target")
    else
        self:Reset()
    end
end

function Cosplay:OnEnable()
    if not AHButtonsCreated then
        self:RegisterEvent("AUCTION_HOUSE_SHOW", "CreateAHButtons")
    end

    if not MainButtonsCreated then
        self:HookScript(DressUpFrame, "OnShow", "CreateMainButtons")
    end

    -- We need to secure hook the Reset button in retail, otherwise the
    -- DressUpFrame won't reset properly if we've previously dressed up another
    -- player.
    if not IsClassic() then
        self:SecureHookScript(DressUpFrame.ResetButton, "OnClick", "Reset")
    end
end
