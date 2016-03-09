--Donni Anthania, The Crazy Cat Lady. Thought it would be fun to add her back.
--Plan is to let her drop a quest item, that'll upgrade to a butchers knife :)
--Export sound files from https://www.youtube.com/watch?v=BcmM4PJiT-w   ?

local function CatLady(event, pUnit)
	if event == 1 then --OnCombat
		pUnit:SendUnitSay("YAHAHAH - YAHA, NAHA!")
	end
end

RegisterCreatureEvent(90106, 1, CatLady) --OnCombat
RegisterCreatureEvent(90106, 2, CatLady) --OnLeaveCombat
RegisterCreatureEvent(90106, 4, CatLady) --OnDeath