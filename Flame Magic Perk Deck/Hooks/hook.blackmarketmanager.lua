local MagicPerkDeck_BM_forced_primary = BlackMarketManager.forced_primary

function BlackMarketManager:forced_primary(...)
	if managers.job:current_level_id() then
		if managers.player:has_category_upgrade("player", "passive_magic_flamethrower_1") then
			return {
				equipped = true,
				factory_id = "wpn_fps_mpd_flamer",
				blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id("wpn_fps_mpd_flamer"),
				weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id("wpn_fps_mpd_flamer"),
				global_values = {}
			}
		end
	end
	return MagicPerkDeck_BM_forced_primary(self, ...)
end

local MagicPerkDeck_BM_forced_secondary = BlackMarketManager.forced_secondary

function BlackMarketManager:forced_secondary(...)
	if managers.job:current_level_id() then
		if managers.player:has_category_upgrade("player", "passive_magic_fireball_1") then
			return {
				equipped = true,
				factory_id = "wpn_fps_mpd_ffball",
				blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id("wpn_fps_mpd_ffball"),
				weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id("wpn_fps_mpd_ffball"),
				global_values = {}
			}
		end
	end
	return MagicPerkDeck_BM_forced_secondary(self, ...)
end