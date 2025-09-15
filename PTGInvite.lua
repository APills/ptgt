local addonName, PTGT = ...
local PTGinvite = {}
_G[addonName] = PTGT

-------------------------------------------------
-- Whisper Invite Queue
-- Supports ingame Character to Character Whispers
-- Supports ingame RealID to RealID Whispers
-- Basic Battle.net Whispers can not be supported
-------------------------------------------------
PTGinvite.whisperQueue = {}
PTGinvite.BNDebug = false

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_WHISPER")
f:RegisterEvent("CHAT_MSG_BN_WHISPER")

f:SetScript("OnEvent", function(self, event, msg, sender, ...)
    if msg:lower() ~= "ptv" then return end

    local target

    if event == "CHAT_MSG_WHISPER" then
        target = Ambiguate(sender, "none")

    elseif event == "CHAT_MSG_BN_WHISPER" then
        local bnSenderID = select(13, ...)
        if PTGinvite.BNDebug then
            print("|cff00ff00[BN Debug]|r msg:", msg, "sender:", sender, "bnSenderID:", bnSenderID)
        end
        if bnSenderID then
            local accountInfo = C_BattleNet.GetAccountInfoByID(bnSenderID)
            if accountInfo and accountInfo.client == "WoW" and accountInfo.characterName then
                target = accountInfo.characterName .. "-" .. GetRealmName()
            end
        end
    end

    if target and not PTGinvite.whisperQueue[target] then
        PTGinvite.whisperQueue[target] = true
        print("|cff00ff00[PTGT Invite]|r Added to invite queue:", target)
    end
end)

local inviteFrame = CreateFrame("Frame", "PTGinviteInviteFrame", UIParent, "BasicFrameTemplateWithInset")
inviteFrame:SetSize(220, 80)
inviteFrame:SetPoint("CENTER")
inviteFrame:SetFrameStrata("DIALOG")
inviteFrame:SetToplevel(true)
inviteFrame:SetMovable(true)
inviteFrame:EnableMouse(true)
inviteFrame:RegisterForDrag("LeftButton")
inviteFrame:Hide()

inviteFrame:SetScript("OnMouseDown", function(self, button)
	self:StartMoving()
end)
inviteFrame:SetScript("OnMouseUp", function(self)
	self:StopMovingOrSizing()
end)

inviteFrame.title = inviteFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
inviteFrame.title:SetPoint("TOP", 0, -10)
inviteFrame.title:SetText("Click to Invite Members")

local inviteButton = CreateFrame("Button", nil, inviteFrame, "GameMenuButtonTemplate")
inviteButton:SetSize(180, 30)
inviteButton:SetPoint("CENTER", 0, -10)
inviteButton:SetText("Invite Next")
inviteButton:SetNormalFontObject("GameFontNormalLarge")
inviteButton:SetHighlightFontObject("GameFontHighlightLarge")

inviteButton:SetScript("OnClick", function()
    for name,_ in pairs(PTGinvite.whisperQueue) do
        GuildInvite(name)
        print("|cff00ff00[PTGT Invite]|r Invited:", name)
        PTGinvite.whisperQueue[name] = nil
        break
    end

    local remaining = 0
    for _ in pairs(PTGinvite.whisperQueue) do remaining = remaining + 1 end
    print("|cff00ff00[PTGT Invite]|r", remaining, "players remaining in queue.")
end)

function HandleHelpCommand(cmd)
    print("|cff00ffff[PTGT Help]|r")
    print("|cffffd700Usage:|r /ptgt <module> <command>")
    print("To see a list of commands, do /ptgt <module> help")
    print("Modules: Invite (i), Promoter (p)")
end

function HandleICommand(cmd)
        if cmd == "bi" then
            local count = 0
            for _ in pairs(PTGinvite.whisperQueue) do count = count + 1 end
            if count == 0 then
                print("|cff00ff00[PTGT Invite]|r No players in queue.")
                return
            end
            inviteFrame:Show()
            print("|cff00ff00[PTGT Invite]|r Click the button to invite", count, "players (one per click).")
        elseif cmd == "cq" then
            PTGinvite.whisperQueue = {}
            inviteFrame:Hide()
            print("|cff00ff00[PTGT Invite]|r Invite queue cleared.")
        elseif cmd == "db" then
            inviteFrame:Show()
            print("|cff00ffff[PTGT DEBUG]|r Invite Frame Forced Open.")
        else
            print("|cffffd700Usage:|r /ptgt i <command>")
            print("|cff00ff00Current Module:|r Invite (i)")
            print("|cff00ff00Invite Commands:|r Batch Invite (bi), Clear Queue (cq), DeBug (db)")
        end
    end

function HandlePCommand(cmd)
    PTGT_PTGPromote.HandlePCommand(msg)
end

SLASH_PTGT1 = "/ptgt"

SlashCmdList["PTGT"] = function(msg)
msg = msg:lower():trim()
local module, command = msg:match("^(%S+)%s*(.*)$")
module = module:lower()
command = command:lower()

    if not module or module == "" then
            print("Usage: /ptgt <module> <command>")
            return
    end

    if module == "help" then
        HandleHelpCommand(command)
    elseif module == "i" then
        HandleICommand(command)
    elseif module == "p" then
        HandlePCommand(command)

    else
        print("Unknown module: " .. module)
    end
end
