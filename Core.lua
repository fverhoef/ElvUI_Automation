local addonName, addonTable = ...
local Addon = addonTable[1]
local EP = LibStub("LibElvUIPlugin-1.0")
local E, L, V, P, G = unpack(ElvUI)

local fastLootDelay = 0

function Addon:Initialize()
    EP:RegisterPlugin(addonName, Addon.InsertOptions)
    Addon:RegisterEvent("RESURRECT_REQUEST")
    Addon:RegisterEvent("CONFIRM_SUMMON")
    Addon:RegisterEvent("CONFIRM_LOOT_ROLL")
    Addon:RegisterEvent("LOOT_BIND_CONFIRM")
    Addon:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")
    Addon:RegisterEvent("MAIL_LOCK_SEND_ITEMS")
    Addon:RegisterEvent("CHAT_MSG_WHISPER")
    Addon:RegisterEvent("CHAT_MSG_BN_WHISPER")

    if Addon.TBC then
        Addon.TBC:Initialize()
    end
end

function Addon:RESURRECT_REQUEST(event, inviter)
    if E.db[addonName].automation.enabled and E.db[addonName].automation.acceptResurrection then
        Addon:AcceptResurrection(inviter)
    end
end

function Addon:CONFIRM_SUMMON(event)
    if E.db[addonName].automation.enabled and E.db[addonName].automation.acceptSummon then
        Addon:AcceptSummon()
    end
end

function Addon:CONFIRM_LOOT_ROLL(event, rollID, rollType, confirmReason)
    if E.db[addonName].automation.enabled and E.db[addonName].automation.disableLootRollConfirmation then
        ConfirmLootRoll(rollID, rollType)
        StaticPopup_Hide("CONFIRM_LOOT_ROLL")
    end
end

function Addon:LOOT_BIND_CONFIRM(event, lootSlot)
    if E.db[addonName].automation.enabled and E.db[addonName].automation.disableLootBindConfirmation then
        ConfirmLootSlot(lootSlot)
        StaticPopup_Hide("LOOT_BIND")
    end
end

function Addon:MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL(event)
    if E.db[addonName].automation.enabled and E.db[addonName].automation.disableVendorRefundWarning then
        SellCursorItem()
    end
end

function Addon:MAIL_LOCK_SEND_ITEMS(event, attachSlot, itemLink)
    if E.db[addonName].automation.enabled and E.db[addonName].automation.disableMailRefundWarning then
        RespondMailLockSendItem(attachSlot, true)
    end
end

function Addon:CHAT_MSG_WHISPER(event, text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID,
                                     channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle,
                                     hideSenderInLetterbox, supressRaidIcons)
    if not E.db[addonName].automation.enabled or not E.db[addonName].automation.autoInvite then
        return
    end

    if Addon:PlayerCanInvite() and Addon:TextMatchesAutoInvitePassword(text) then
        InviteUnit(playerName)
    end
end

function Addon:CHAT_MSG_BN_WHISPER(event, text, playerName, languageName, channelName, playerName2, specialFlags,
                                        zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile,
                                        isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    if not E.db[addonName].automation.enabled or not E.db[addonName].automation.autoInvite then
        return
    end

    if Addon:PlayerCanInvite() and Addon:TextMatchesAutoInvitePassword(text) then
        if bnSenderID and BNIsFriend(bnSenderID) then
            local index = BNGetFriendIndex(bnSenderID)
            if index then
                local toonID = select(6, BNGetFriendInfo(index))
                if toonID then
                    BNInviteFriend(toonID)
                end
            end
        end
    end
end

function Addon:PlayerCanInvite()
    return not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
end

function Addon:TextMatchesAutoInvitePassword(text)
    return string.lower(string.trim(text)) == string.lower(E.db[addonName].automation.autoInvitePassword)
end

function Addon:AcceptSummon()
    if not UnitAffectingCombat("player") then
        local summoner = GetSummonConfirmSummoner()
        local summonArea = GetSummonConfirmAreaName()
        Addon:Print("Accepting summons from " .. summoner .. " to " .. summonArea .. " in 10 seconds.")
        C_Timer.After(10, function()
            local newSummoner = GetSummonConfirmSummoner()
            local newSummonArea = GetSummonConfirmAreaName()
            if summoner == newSummoner and summonArea == newSummonArea then
                -- Automatically accept summon after 10 seconds if summoner name and location have not changed
                C_SummonInfo.ConfirmSummon()
                StaticPopup_Hide("CONFIRM_SUMMON")
            end
        end)
    end
end

function Addon:AcceptResurrection(unit)
    -- TODO: Exclude Chained Spirit (Zul'Gurub)
    if unit == L["Chained Spirit"] then
        return
    end

    local delay = GetCorpseRecoveryDelay()
    if delay and delay > 0 then
        C_Timer.After(delay + 1, function()
            if not UnitAffectingCombat(unit) then
                AcceptResurrect()
            end
        end)
    else
        if not UnitAffectingCombat(unit) then
            AcceptResurrect()
        end
    end
end
