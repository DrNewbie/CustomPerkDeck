local ThisModPath = tostring(ModPath)

Hooks:Add("LocalizationManagerPostInit", "CriticalPerk_loc", function(loc)
	if io.file_is_readable(ThisModPath.."Loc/EN.txt") then
		loc:load_localization_file(ThisModPath.."Loc/EN.txt")
	end
end)

pcall(
	function ()
		local this_texture_path = ThisModPath.."Assets/guis/dlcs/critical_perk_deck/textures/pd2/specialization/icons_atlas.texture"
		if io.file_is_readable(this_texture_path) then
			DB:create_entry(
				Idstring("texture"), 
				Idstring("guis/dlcs/critical_perk_deck/textures/pd2/specialization/icons_atlas"), 
				this_texture_path
			)
		end
		return
	end
)