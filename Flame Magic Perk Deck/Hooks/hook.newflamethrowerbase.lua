MPDFlamerBase = MPDFlamerBase or class(NewFlamethrowerBase)

MPDFFBallBase = MPDFFBallBase or class(NewFlamethrowerBase)

Hooks:PostHook(MPDFlamerBase, "setup_default", "MPDFlamerBaseInit", function(self)
	managers.player:add_to_temporary_property("bullet_storm", 999, 1)
end)

Hooks:PostHook(MPDFFBallBase, "setup_default", "MPDFFBallBaseInit", function(self)
	managers.player:add_to_temporary_property("bullet_storm", 999, 1)
end)

function MPDFFBallBase:_spawn_muzzle_effect()
end

MPDFlamerBase.backup_fire_raycast = MPDFlamerBase.backup_fire_raycast or MPDFlamerBase.super._fire_raycast
MPDFlamerBase.backup_spawn_muzzle_effect = MPDFlamerBase.backup_spawn_muzzle_effect or MPDFlamerBase._spawn_muzzle_effect

MPDFlamerBase.super._fire_raycast = function(self, ...)
	if not managers.player:MagicPerkDeckUseMagic("mpd_flamer", true) then
		return {}
	end
	return MPDFlamerBase.backup_fire_raycast(self, ...)
end

MPDFlamerBase._spawn_muzzle_effect = function(self, ...)
	if not managers.player:MagicPerkDeckUseMagic("mpd_flamer", false) then
		return
	end
	return MPDFlamerBase.backup_spawn_muzzle_effect(self, ...)
end

function MPDFFBallBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	if user_unit and user_unit == managers.player:local_player() then
		if not managers.player:has_active_temporary_property("bullet_storm") then
			managers.player:add_to_temporary_property("bullet_storm", 999, 1)		
		end
		managers.player:MagicPerkDeckUseMagic("mpd_ffball", {from_pos, direction})
	end
	return {}
end