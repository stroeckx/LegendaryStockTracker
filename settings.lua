local addonName, globalTable = ...

function LST:SetRestockFromChat(input)
	local values = { };
    for value in string.gmatch(input, "(%d+)") do
		table.insert(values, value);
    end
	if(#values == 1) then
		LST:SetRestockAmountByRank(values[1], nil, nil, nil);
	elseif(#values == 4) then
		LST:SetRestockAmountByRank(values[1], values[2], values[3], values[4]);
	else
		print(L["LST: Error, incorrect input"]);
	end
end

function LST:SetRestockAmountByRank(r1, r2, r3, r4)
	if(r2 == nil or r3 == nil or r4 == nil) then
		LST.db.profile.settings.restockAmountByRank[1] = r1;
		LST.db.profile.settings.restockAmountByRank[2] = r1;
		LST.db.profile.settings.restockAmountByRank[3] = r1;
		LST.db.profile.settings.restockAmountByRank[4] = r1;
	else
		LST.db.profile.settings.restockAmountByRank[1] = r1;
		LST.db.profile.settings.restockAmountByRank[2] = r2;
		LST.db.profile.settings.restockAmountByRank[3] = r3;
		LST.db.profile.settings.restockAmountByRank[4] = r4;
	end
end

function LST:PrintRestockAmountByRank()
	print(LST.db.profile.settings.restockAmountByRank[1] .. " " .. LST.db.profile.settings.restockAmountByRank[2] .. " " .. LST.db.profile.settings.restockAmountByRank[3] .. " " .. LST.db.profile.settings.restockAmountByRank[4]);
end