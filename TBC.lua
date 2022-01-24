local addonName, addonTable = ...
local Addon = addonTable[1]

if not Addon.isTbc then
    return
end

local TBC = Addon:NewModule(addonName .. "TBC", "AceEvent-3.0")
Addon.TBC = TBC

local fastLootDelay = 0

function TBC:Initialize()
    TBC:RegisterEvent("UI_ERROR_MESSAGE")
    TBC:RegisterEvent("LOOT_READY")
end

function TBC:UI_ERROR_MESSAGE(event, errorType, msg)
    if E.db[addonName].enabled and E.db[addonName].standDismount then
        if msg == SPELL_FAILED_NOT_STANDING or msg == ERR_CANTATTACK_NOTSTANDING or msg == ERR_LOOT_NOTSTANDING or msg ==
            ERR_TAXINOTSTANDING then
            DoEmote("stand")
            UIErrorsFrame:Clear()
        elseif msg == ERR_ATTACK_MOUNTED or msg == ERR_MOUNT_ALREADYMOUNTED or msg == ERR_NOT_WHILE_MOUNTED or msg ==
            ERR_TAXIPLAYERALREADYMOUNTED or msg == SPELL_FAILED_NOT_MOUNTED then
            if IsMounted() then
                Dismount()
                UIErrorsFrame:Clear()
            end
        end
    end
end

function TBC:LOOT_READY(event)
    if E.db[addonName].enabled and E.db[addonName].fastLoot then
        if GetTime() - fastLootDelay >= 0.3 then
            fastLootDelay = GetTime()
            if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
                for i = GetNumLootItems(), 1, -1 do
                    LootSlot(i)
                end
                fastLootDelay = GetTime()
            end
        end
    end
end