local addonName, addonTable = ...
local Addon = addonTable[1]
local E, L, V, P, G = unpack(ElvUI)

P[addonName] = {
    enabled = true,
    fastLoot = true,
    standDismount = true,
    acceptSummon = false,
    acceptResurrection = true,
    disableLootRollConfirmation = true,
    disableLootBindConfirmation = true,
    disableVendorRefundWarning = true,
    disableMailRefundWarning = true,
    autoInvite = true,
    autoInvitePassword = "inv"
}

if E.db[addonName] == nil then
    E.db[addonName] = P[addonName]
end

local function GetOptionValue(setting)
    return E.db[addonName][setting]
end

local function GetDefaultOptionValue(setting)
    return P[addonName][setting]
end

local function SetOptionValue(setting, val)
    E.db[addonName][setting] = val
end

local function CreateToggleOption(caption, desc, order, width, setting, tristate, disabled, hidden)
    return {
        type = "toggle",
        name = caption,
        desc = desc,
        order = order,
        width = width,
        tristate = tristate,
        disabled = disabled,
        hidden = hidden,
        get = function(info)
            return GetOptionValue(setting)
        end,
        set = function(info, value)
            SetOptionValue(setting, value)
        end
    }
end

function Addon:InsertOptions()
    local options = {
        order = 100,
        type = "group",
        name = Addon.title,
        childGroups = "tab",
        args = {
            name = {order = 1, type = "header", name = Addon.title},
            enabled = CreateToggleOption(L["Enabled"], nil, 4, nil, "enabled"),
            lineBreak = {type = "header", name = "", order = 5},
            fastLoot = CreateToggleOption(L["Faster Auto-Loot"], nil, 10, "full", "fastLoot"),
            standDismount = CreateToggleOption(L["Auto Stand/Dismount"], nil, 11, "full", "standDismount"),
            acceptSummon = CreateToggleOption(L["Accept Summons"], nil, 12, "full", "acceptSummon"),
            acceptResurrection = CreateToggleOption(L["Accept Resurrection"], nil, 13, "full", "acceptResurrection"),
            disableLootBindConfirmation = CreateToggleOption(L["Disable Bind on Pickup Confirmation"], nil, 14, "full", "disableLootBindConfirmation"),
            disableLootRollConfirmation = CreateToggleOption(L["Disable Loot Roll Confirmation"], nil, 15, "full", "disableLootRollConfirmation"),
            disableVendorRefundWarning = CreateToggleOption(L["Disable Vendor Refund Warning"], nil, 16, "full", "disableVendorRefundWarning"),
            disableMailRefundWarning = CreateToggleOption(L["Disable Mail Refund Warning"], nil, 17, "full", "disableMailRefundWarning"),
            autoInvite = CreateToggleOption(L["Auto Invite"], nil, 18, "full", "autoInvite"),
            autoInvitePassword = {
                type = "input",
                name = L["Auto Invite Password"],
                order = 22,
                width = "full",
                disabled = function()
                    return not E.db[addonName].autoInvite
                end,
                get = function()
                    return E.db[addonName].autoInvitePassword
                end,
                set = function(_, val)
                    E.db[addonName].autoInvitePassword = val
                end
            }
        }
    }

    E.Options.args[addonName] = options
end
