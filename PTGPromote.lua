local addonName, PTGT = ...
local PTGPromote = {}
_G[addonName] = PTGT

PTGPromote.promoteQueue = {}
local guildClubID = C_Club.GetGuildClubId()
local members = C_Club.GetClubMembers(guildClubID)

for _, memberId in ipairs(members) do
    local info = C_Club.GetMemberInfo(guildClubID, memberId)
    if info then
        print("PTGT INFO ", info.name, info.guildRank, info.guildRankOrder, info.memberNote or "")
    end
end

function BuildPromotionList()
    local guildClubID = C_Club.GetGuildClubId()
    if not guildClubID then return {} end

    local members = C_Club.GetClubMembers(guildClubID)
    if not members then return {} end

    local promotionList = {}

    for _, memberId in ipairs(members) do
        local info = C_Club.GetMemberInfo(guildClubID, memberId)
        if info and info.name then
            local note = info.memberNote or ""
            local rankOrder = info.guildRankOrder
            local rankName = info.guildRank or ("Rank " .. tostring(rankOrder))

            local targetRank, targetRankName = nil, nil

            if note:match("%[Immo%]") or note:match("%[Eter%]") or note:match("%[Infi%]") then
                targetRank = 4
                targetRankName = "Raider Alts"
            elseif note ~= "" then
                targetRank = 5
                targetRankName = "Member Alts"
            end

            if targetRank and rankOrder > targetRank then
                table.insert(promotionList, {
                    name = info.name,
                    currentRank = rankOrder,
                    currentRankName = rankName,
                    targetRank = targetRank,
                    targetRankName = targetRankName,
                })
            end
        end
    end

    return promotionList
end


function HandlePCommand(cmd)
    if cmd == "pl" then
        local list = BuildPromotionList()
        if #list == 0 then
            print("|cff00ff00[PTGT Promoter]|r No members need promotion.")
        else
            print("|cff00ff00[PTGT Promoter]|r To Promote:")
            for _, entry in ipairs(list) do
                print(string.format(
                    "%s (%s → %s)",
                    entry.name,
                    entry.currentRankName,
                    entry.targetRankName or ("Rank " .. tostring(entry.targetRank))
                ))
            end
        end
    elseif cmd == "db" then
        -- promoteFrame:Show()
        -- print("|cff00ffff[PTGT DEBUG]|r Promote Frame Forced Open.")
    else
        print("|cffffd700Usage:|r /ptgt p <command>")
        print("|cff00ff00Current Module:|r Promoter (p)")
        print("|cff00ff00Promote Commands:|r Promotion List (pl)")
    end
end
