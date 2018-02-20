local HackPerkDeck_ModPath = ModPath

if ModCore then
	ModCore:new(HackPerkDeck_ModPath .. "Config.xml", true, true)
else
	Hooks:Add("LocalizationManagerPostInit", "HackPD_loc", function(loc)
		loc:load_localization_file(HackPerkDeck_ModPath.."Loc/EN.txt")
	end)
end