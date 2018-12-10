Hooks:PostHook(PlayerDamage, "init", "Ply_"..Idstring("MDP:InitData"):key(), function(self)
	if managers.player:has_category_upgrade("player", "passive_magic_firebomb_1") or 
		managers.player:has_category_upgrade("player", "passive_magic_meteorite_1") then
		self._mpd_firebomb_fire_units = {}
		self._mpd_meteorite_dt = 0
	end
end)

Hooks:PreHook(PlayerDamage, "_on_damage_event", "Ply_"..Idstring("mpd_firebomb:Active!!!!"):key(), function(self)
	local armor_broken = self:_max_armor() > 0 and self:get_real_armor() <= 0
	if armor_broken and managers.player:has_category_upgrade("player", "passive_magic_firebomb_1") then
		if managers.player:MagicPerkDeckUseMagic("mpd_firebomb", false) then
			self._mpd_firebomb_bool = true
			self._mpd_firebomb_dt = 0.25
		end
	end
end)

Hooks:PreHook(PlayerDamage, "update", "Ply_"..Idstring("mpd_firebomb:KaBoom!!!!"):key(), function(self, unit, t, dt)
	if self._mpd_firebomb_bool then
		if self._mpd_firebomb_dt then
			self._mpd_firebomb_dt = self._mpd_firebomb_dt - dt
			if self._mpd_firebomb_dt < 0 then
				self._mpd_firebomb_dt = nil
				self._mpd_firebomb_bool = nil
			end
		end
		if not self._mpd_firebomb_dt then
			local upgrade_value = managers.player:upgrade_value("player", "passive_magic_firebomb_1", nil)
			if upgrade_value then
				local FFdmg = upgrade_value[1]
				local Area = upgrade_value[2]
				local position = self._unit:position()
				local rotation = self._unit:rotation()
				local data = tweak_data.env_effect:incendiary_fire()
				data.burn_duration = 10
				data.sound_event_impact_duration = 1
				local fire_unit = EnvironmentFire.spawn(position, rotation, data, Vector3(0, 0, 1), self._unit, 0, 1)
				if fire_unit then
					table.insert(self._mpd_firebomb_fire_units, fire_unit)
					managers.player:MagicPerkDeckUseMagic("mpd_firebomb", true)
					local wpn_unit = self._unit:inventory():equipped_unit()
					if wpn_unit then
						local hits = World:find_units("sphere", position, Area, managers.slot:get_mask("enemies"))
						for _, hit_unit in pairs(hits) do
							if managers.enemy:is_enemy(hit_unit) then
								hit_unit:character_damage():damage_fire({
									variant = "fire",
									damage = FFdmg,
									weapon_unit = wpn_unit,
									attacker_unit = self._unit,
									col_ray = {ray = Vector3(1, 0, 0), hit_position = position, position = position},
									armor_piercing = true,
									fire_dot_data = {
										dot_trigger_chance = 100,
										dot_damage = 2,
										dot_length = 5,
										dot_trigger_max_distance = Area*2,
										dot_tick_period = 0.5
									}
								})
							end
						end
					end
				end
			end
		end
	end
	if managers.player:has_category_upgrade("player", "passive_magic_meteorite_1") then
		for i, ff_unit in pairs(self._mpd_firebomb_fire_units) do
			if ff_unit and alive(ff_unit) then
				if mvector3.distance(ff_unit:position(), self._unit:position()) < 500 then
					self._mpd_meteorite_dt = 1
				end
			else
				table.remove(self._mpd_firebomb_fire_units, i)
			end
		end
	end
	if self._mpd_meteorite_dt then
		self._mpd_meteorite_dt = self._mpd_meteorite_dt - dt
		if self._mpd_meteorite_dt < 0 then
			self._mpd_meteorite_dt = nil
		else
			managers.player:MagicPerkDeckUseMagic("mpd_meteorite")
			self._unit:movement():add_stamina(1)
		end
	end
end)

local MPDFireProof = PlayerDamage.damage_fire

function PlayerDamage:damage_fire(attack_data, ...)
	if managers.player:has_category_upgrade("player", "passive_magic_meteorite_1") then
		self._mpd_meteorite_dt = 1
		return
	end
	return MPDFireProof(self, attack_data, ...)
end