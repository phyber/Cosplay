Cosplay = LibStub("AceAddon-3.0"):NewAddon("Cosplay", "AceEvent-3.0", "AceHook-3.0")
local Cosplay = Cosplay
local L = LibStub("AceLocale-3.0"):GetLocale("Cosplay")

local AHButtonsCreated = false
local MainButtonsCreated = false

local string_lower = string.lower
local DressUpFrame = DressUpFrame
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
_G.IsClassic = IsClassic

local DressUpModel
do
    if IsClassic() then
        DressUpModel = DressUpFrame.DressUpModel
    else
        DressUpModel = _G.DressUpModel
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
            DressUpModel:Undress()
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
        local AuctionDUFUndressButton = CreateFrame("Button", "ADUFUndressButton", SideDressUpModel, "UIPanelButtonTemplate")
        AuctionDUFUndressButton:SetWidth(70)
        AuctionDUFUndressButton:SetHeight(22)
        AuctionDUFUndressButton:SetText(L["Undress"])
        AuctionDUFUndressButton:SetPoint("BOTTOM", "SideDressUpModelResetButton", "TOP", 0, 2)
        AuctionDUFUndressButton:SetScript("OnClick", function()
            SideDressUpModel:Undress()
            PlaySound(GS_TITLE_OPTION_OK)
        end)

        AHButtonsCreated = true
    end

    self:UnregisterEvent("AUCTION_HOUSE_SHOW")
end

function Cosplay:Reset()
    local race, fileName = UnitRace("player")

    SetPortraitTexture(DressUpFramePortrait, "player")
    SetDressUpBackground(DressUpFrame, fileName)
    DressUpModel:SetUnit("player")
end

local function DressUpTargetTexturePath()
    local fileName = select(2, UnitRace("target"))
    if fileName then
        if string_lower(fileName) == "gnome" then
            fileName = "Dwarf"
        elseif string_lower(fileName) == "troll" then
            fileName = "Orc"
        end
    else
        fileName = "Orc"
    end

    return "Interface\\DressUpFrame\\DressUpBackground-"..fileName
end

local function SetDressUpTargetBackground()
    local texture = DressUpTargetTexturePath()
    DressUpBackgroundTopLeft:SetTexture(texture..1)
    DressUpBackgroundTopRight:SetTexture(texture..2)
    DressUpBackgroundBotLeft:SetTexture(texture..3)
    DressUpBackgroundBotRight:SetTexture(texture..4)
end

function Cosplay:DressUpTarget()
    if not DressUpFrame:IsVisible() then
        ShowUIPanel(DressUpFrame)
    else
        PlaySound(GS_TITLE_OPTION_OK)
    end

    if UnitIsVisible("target") then
        SetPortraitTexture(DressUpFramePortrait, "target")
        SetDressUpTargetBackground()
        DressUpModel:SetUnit("target")
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
end
