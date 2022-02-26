local addonName, globalTable = ...
local L = LibStub("AceLocale-3.0"):GetLocale("LegendaryStockTracker")

function LST:SetRestockFromChat(input)
	local values = { };
    for value in string.gmatch(input, "(%d+)") do
		table.insert(values, value);
    end
	if(#values == 1) then
		LST:SetRestockAmountByRank(values[1], nil, nil, nil, nil, nil);
	elseif(#values == 7) then
		LST:SetRestockAmountByRank(values[1], values[2], values[3], values[4], values[5], values[6], values[7]);
	else
		print(L["LST: Error, incorrect input"]);
	end
end

function LST:SetRestockAmountByRank(r1, r2, r3, r4, r5, r6, r7)
	if(r2 == nil or r3 == nil or r4 == nil or r5 == nil or r6 == nil or r7 == nil) then
		LST.db.profile.settings.restockAmountByRank[1] = r1;
		LST.db.profile.settings.restockAmountByRank[2] = r1;
		LST.db.profile.settings.restockAmountByRank[3] = r1;
		LST.db.profile.settings.restockAmountByRank[4] = r1;
		LST.db.profile.settings.restockAmountByRank[5] = r1;
		LST.db.profile.settings.restockAmountByRank[6] = r1;
		LST.db.profile.settings.restockAmountByRank[7] = r1;
	else
		LST.db.profile.settings.restockAmountByRank[1] = r1;
		LST.db.profile.settings.restockAmountByRank[2] = r2;
		LST.db.profile.settings.restockAmountByRank[3] = r3;
		LST.db.profile.settings.restockAmountByRank[4] = r4;
		LST.db.profile.settings.restockAmountByRank[5] = r5;
		LST.db.profile.settings.restockAmountByRank[6] = r6;
		LST.db.profile.settings.restockAmountByRank[7] = r7;
	end
	LST:PrintRestockAmountByRank();
end

function LST:PrintRestockAmountByRank()
	print(L["LST restock amounts"] .. LST.db.profile.settings.restockAmountByRank[1] .. " " .. LST.db.profile.settings.restockAmountByRank[2] .. " " .. LST.db.profile.settings.restockAmountByRank[3] .. " " .. LST.db.profile.settings.restockAmountByRank[4] .. " " .. LST.db.profile.settings.restockAmountByRank[5] .. " " .. LST.db.profile.settings.restockAmountByRank[6] .. " " .. LST.db.profile.settings.restockAmountByRank[7]);
end