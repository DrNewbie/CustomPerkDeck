function PlayerManager:MagicPerkDeckUseMagic(magic, data)
	if not self:local_player() or not self:local_player():movement() then
		return
	end
	local MP_stamina = self:local_player():movement()._stamina
	local t = TimerManager:game():time()
	self._mpd_flamer_cd = self._mpd_flamer_cd or 0
	if magic == "mpd_meteorite" then
		self._mpd_flamer_cd = 0
		return
	end
	if self._mpd_flamer_cd > t then
		return
	end
	if magic == "mpd_ffball" then
		local upgrade_value = self:upgrade_value("player", "passive_magic_fireball_1", nil)
		if upgrade_value then
			local Magic_CD = upgrade_value[1]
			local MP_Cost = upgrade_value[2]
			if MP_Cost > MP_stamina then
				return
			end
			self._mpd_flamer_cd = t + Magic_CD
			self:local_player():movement():subtract_stamina(MP_Cost)
			self._flamethrower_effect_collection = self._flamethrower_effect_collection or {}
			for id, effect_entry in pairs(self._flamethrower_effect_collection) do
				World:effect_manager():kill(effect_entry.id)
				self._flamethrower_effect_collection[id] = nil
			end
			self._mpd_flamer_bool = 1
			self._mpd_flamer_data = data
		end
	elseif magic == "mpd_flamer" then
		local upgrade_value = self:upgrade_value("player", "passive_magic_flamethrower_1", nil)
		if upgrade_value then
			local MP_Cost = upgrade_value[2]
			if MP_Cost > MP_stamina then
				return
			end
			if data then
				self:local_player():movement():subtract_stamina(MP_Cost)
			end
			return true
		end
	elseif magic == "mpd_firebomb" then
		local upgrade_value = self:upgrade_value("player", "passive_magic_firebomb_1", nil)
		if upgrade_value then
			local Magic_CD = upgrade_value[3]
			if data then
				self._mpd_flamer_cd = t + Magic_CD
			end
			return true
		end
	end
	return
end

local mvec1 = Vector3()

Hooks:PostHook(PlayerManager, "update", "Ply_"..Idstring("mpd_ffball:Fire!!!!"):key(), function(self, t, dt)
	if self:local_player() and self:local_player():movement() then
		if self._mpd_flamer_bool then
			self._mpd_flamer_bool = self._mpd_flamer_bool - dt
			if self._mpd_flamer_bool < 0 then
				self._mpd_flamer_bool = nil
			end
			self._flamethrower_effect_collection = self._flamethrower_effect_collection or {}
			local _flame_effect_id = World:effect_manager():spawn({
				effect = Idstring("effects/payday2/particles/explosions/flamethrower"),
				position = self._mpd_flamer_data[1],
				normal = math.UP
			})
			table.insert(self._flamethrower_effect_collection, {
				been_alive = false,
				id = _flame_effect_id,
				position = self._mpd_flamer_data[1],
				direction = self._mpd_flamer_data[2]
			})
		end
		if type(self._flamethrower_effect_collection) == "table" and self._flamethrower_effect_collection[1] then
			local flame_effect_dt = 5 / dt
			local flame_effect_distance = 10000 / flame_effect_dt
			for id, effect_entry in pairs(self._flamethrower_effect_collection) do
				local do_continue = true
				if World:effect_manager():alive(effect_entry.id) == false then
					if effect_entry.been_alive == true then
						World:effect_manager():kill(effect_entry.id)
						table.remove(self._flamethrower_effect_collection, id)
						do_continue = false
					end
				elseif effect_entry.been_alive == false then
					effect_entry.been_alive = true
				end
				if do_continue == true then
					mvector3.set(mvec1, effect_entry.position)
					mvector3.add(effect_entry.position, effect_entry.direction * flame_effect_distance)
					local raycast = World:raycast(mvec1, effect_entry.position)
					if raycast ~= nil then
						table.remove(self._flamethrower_effect_collection, id)
					else
						World:effect_manager():move(effect_entry.id, effect_entry.position)
					end
					local effect_distance = mvector3.distance(effect_entry.position, self:local_player():movement()._m_head_pos)
					if 10000 < effect_distance then
						World:effect_manager():kill(effect_entry.id)
					end
				end
				if self:local_player():inventory() and self:local_player():inventory():equipped_unit() then
					local wpn_unit = self:local_player():inventory():equipped_unit()
					local hits = World:find_units("sphere", effect_entry.position, 200, managers.slot:get_mask("enemies"))
					for _, hit_unit in pairs(hits) do
						if managers.enemy:is_enemy(hit_unit) and not self._mpd_flamer_data[hit_unit:key()] then
							self._mpd_flamer_data[hit_unit:key()] = true
							hit_unit:character_damage():damage_fire({
								variant = "fire",
								damage = 10,
								weapon_unit = wpn_unit,
								attacker_unit = self:local_player(),
								col_ray = {ray = Vector3(1, 0, 0), hit_position = effect_entry.position, position = effect_entry.position},
								armor_piercing = true,
								fire_dot_data = {
									dot_trigger_chance = 100,
									dot_damage = 10,
									dot_length = 3.1,
									dot_trigger_max_distance = 20000,
									dot_tick_period = 0.5
								}
							})
						end
					end
				end
			end
		end
	end
end)