local ThisModPath = ModPath
local ThisModIds = Idstring(ThisModPath):key()
local __Name = function(__id)
	return "C4BOMB_"..Idstring(tostring(__id).."::"..ThisModIds):key()
end
local __LoadOnce = __Name("BaseLoadOnce")
local __SpawnC4 = __Name("__SpawnC4")

local __spawn_gas_bomb = function(_s_pos, dt)
	DelayedCalls:Add(__Name(__Name(_s_pos)..__Name(dt)), dt, function()
		local projectile_type = "launcher_poison"
		local projectile_type_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_type)
		if Network and Network:is_client() then
			managers.network:session():send_to_host("request_throw_projectile", projectile_type_index, _s_pos, Vector3(0, 0, -1))
		else
			unit = ProjectileBase.throw_projectile(projectile_type, _s_pos, Vector3(0, 0, -1), managers.network:session():local_peer():id())
		end
	end)
	return
end

local __spawn_bomb = function(_s_pos, __s_rot)
	local __range = tweak_data.projectiles["concussion"].range
	managers.explosion:play_sound_and_effects(_s_pos, math.UP, __range, {
		camera_shake_max_mul = 4,
		effect = "effects/particles/explosions/explosion_flash_grenade",
		sound_event = "concussion_explosion",
		feedback_range = __range
	})
	managers.explosion:detect_and_stun({
		player_damage = 0,
		hit_pos = _s_pos,
		range = __range,
		collision_slotmask = managers.slot:get_mask("explosion_targets"),
		curve_pow = 3,
		damage = 0,
		ignore_unit = managers.player:local_player(),
		alert_radius = __range,
		user = managers.player:local_player(),
		verify_callback = callback(ConcussionGrenade, ConcussionGrenade, "_can_stun_unit")
	})
	local __bomb = TripMineBase[__SpawnC4](_s_pos, __s_rot, Vector3(0, 0, -1), false)
	if __bomb then
		call_on_next_update(function()
			__bomb:base():explode()
		end)
	end
	return
end

if PlayerManager and not PlayerManager[__LoadOnce] then
	PlayerManager[__LoadOnce] = true
	
	local __DelayLoop = __Name("__DelayLoop")
	
	function PlayerManager:IsUsingC4Bomb()
		if not Utils or not Utils:IsInHeist() then
			return false
		end
		if not self:local_player() or not self:local_player():character_damage() then
			return false
		end
		if managers.blackmarket:equipped_grenade() ~= "weapon_c4" then
			return false
		end
		return true
	end
	
	function PlayerManager:IsC4BombEnough()
		if self:IsUsingC4Bomb() and self:can_throw_grenade() then
			return true
		end
		return false 
	end
	
	function PlayerManager:IsC4BombNotFull()
		return self:get_timer_remaining("replenish_grenades")
	end
	
	function PlayerManager:C4BombRechargeFunc()
		if not self:IsC4BombNotFull() then
			return false
		end
		local __success = false
		local weapon_list = {}
		local ammo_reduction = 0.02
		local leftover = 0
		for id, weapon in pairs(self:local_player():inventory():available_selections()) do
			local ammo_ratio = weapon.unit:base():get_ammo_ratio()
			if ammo_reduction > ammo_ratio then
				leftover = leftover + ammo_reduction - ammo_ratio
				weapon_list[id] = {
					unit = weapon.unit,
					amount = ammo_ratio,
					total = ammo_ratio
				}
			else
				weapon_list[id] = {
					unit = weapon.unit,
					amount = ammo_reduction,
					total = ammo_ratio
				}
			end
		end
		for id, data in pairs(weapon_list) do
			local ammo_left = data.total - data.amount
			if leftover > 0 and ammo_left > 0 then
				local extra_ammo = leftover > ammo_left and ammo_left or leftover
				leftover = leftover - extra_ammo
				data.amount = data.amount + extra_ammo
			end
			if 0 < data.amount then
				data.unit:base():reduce_ammo_by_procentage_of_total(data.amount)
				managers.hud:set_ammo_amount(id, data.unit:base():ammo_info())
				__success = true
			end
		end
		return __success
	end

	Hooks:PostHook(PlayerManager, "update", __Name("update"), function(self, t, dt)
		if not self:IsUsingC4Bomb() then
		
		else
			--[[Recharge]]
			if self[__DelayLoop] then
				if self[__DelayLoop] <= 0 then
					self[__DelayLoop] = 0.75
					if self:C4BombRechargeFunc() then
						local __timer_remaining = self:get_timer_remaining("replenish_grenades") or 1
						local __speed_up_timer = __timer_remaining * (0.18 * (1.01 + math.random())) + math.random() * 5
						--self:local_player():sound():play("pickup_ammo", nil, true)
						managers.player:speed_up_grenade_cooldown(__speed_up_timer)
					end
				else
					self[__DelayLoop] = self[__DelayLoop] - dt
				end
			end
		end
	end)

	Hooks:PreHook(PlayerManager, "attempt_ability", __Name("attempt_ability"), function(self, ability)
		if self:IsC4BombEnough() and tostring(ability) == "weapon_c4" then
			local __plyS = self:local_player():movement() and self:local_player():movement()._states.standard
			if __plyS then
				local action_forbidden = not PlayerBase.USE_GRENADES or not __plyS:_projectile_repeat_allowed() or __plyS:chk_action_forbidden("interact") or __plyS:_interacting() or __plyS:is_deploying() or __plyS:_changing_weapon() or __plyS:_is_meleeing() or __plyS:_is_using_bipod()
				if not action_forbidden then
					__plyS:_do_action_intimidate(TimerManager:game():time(), "cmd_gogo", "g18", true)
					local __ray = self:local_player():equipment():valid_look_at_placement(tweak_data.equipments["trip_mine"])
					local __dir = __plyS:get_fire_weapon_direction()
					local __pos = nil
					local __rot = nil
					local __moving = false
					if __ray and __ray.normal and __ray.position then
						__pos = __ray.position
						__rot = Rotation(__ray.normal, math.UP)
						__moving = true					
					else
						__pos = self:local_player():movement():m_head_pos() + __dir * 10
						__rot = Rotation(math.random()*90, 90, 0)
					end
					TripMineBase[__SpawnC4](__pos, __rot, __dir, __moving)
				end
			end
		end
	end)
	
	Hooks:PostHook(PlayerManager, "activate_temporary_upgrade", __Name("activate_temporary_upgrade"), function(self, v1, v2)
		if v1 == "temporary" and v2 == "armor_break_invulnerable" and self:has_category_upgrade("player", "c4_bomb_self_destruct") and self:local_player():character_damage() and self:local_player():character_damage():get_real_armor() <= 0 and self:IsC4BombEnough() then
			local __pos = self:local_player():position() + Vector3(0, 0, 10)
			local __rot = Rotation(90, 90, 0)
			self:add_grenade_amount(-1)
			self:local_player():character_damage():_regenerate_armor()
			call_on_next_update(function()
				local __damage_size = tweak_data.weapon.trip_mines.damage_size * 0.75
				__spawn_bomb(__pos + Vector3(0, __damage_size, 0),		__rot, Vector3(0, 0, -1), false)
				__spawn_bomb(__pos + Vector3(0, -__damage_size, 0),		__rot, Vector3(0, 0, -1), false)
				__spawn_bomb(__pos + Vector3(0, 0, 0),					__rot, Vector3(0, 0, -1), false)
				__spawn_bomb(__pos + Vector3(__damage_size, 0, 0),		__rot, Vector3(0, 0, -1), false)
				__spawn_bomb(__pos + Vector3(-__damage_size, 0, 0),		__rot, Vector3(0, 0, -1), false)
				__spawn_gas_bomb(__pos + Vector3(0, 0, 					-8)	, 0)
				__spawn_gas_bomb(__pos + Vector3(0, __damage_size, 		-8)	, 0.15)
				__spawn_gas_bomb(__pos + Vector3(0, -__damage_size, 	-8)	, 0.30)
				__spawn_gas_bomb(__pos + Vector3(__damage_size, 0,		-8)	, 0.45)
				__spawn_gas_bomb(__pos + Vector3(-__damage_size, 0,		-8)	, 0.60)
			end)
		end
	end)
	
	local old_upgrade_value = __Name("upgrade_value")
	PlayerManager[old_upgrade_value] = PlayerManager[old_upgrade_value] or PlayerManager.upgrade_value
	function PlayerManager:upgrade_value(__category, __upgrade, ...)
		local __ans = self[old_upgrade_value](self, __category, __upgrade, ...)
		if __category == "player" and __upgrade == "extra_ammo_multiplier" and self:has_category_upgrade("player", "weapon_c4_loss_ammo") then
			__ans = __ans * self:upgrade_value("player", "weapon_c4_loss_ammo", 1)
		elseif __category == "player" and __upgrade == "pick_up_ammo_multiplier" and self:has_category_upgrade("player", "addition_ammo_pickup_weapon_c4") then
			__ans = __ans + self:upgrade_value("player", "addition_ammo_pickup_weapon_c4", 0)
		end
		return __ans
	end
	
	Hooks:PostHook(PlayerManager, "_internal_load", __Name("_internal_load"), function(self)
		if self:has_category_upgrade("player", "c4_bomb_recharge_by_ammo") then
			self[__DelayLoop] = 0
		end
	end)	
end

if PlayerDamage and not PlayerDamage[__LoadOnce] then
	PlayerDamage[__LoadOnce] = true
	
	local __auto_revive_timer = __Name("__c4_bomb_cheat_death_auto_revive_timer")
	local __chk_cheat_death = __Name("_chk_cheat_death")
	local __chk_cheat_death_loop = __Name("__chk_cheat_death_loop")
	
	PlayerDamage[__chk_cheat_death] = PlayerDamage[__chk_cheat_death] or function(self)
		if managers.player:has_category_upgrade("player", "c4_bomb_cheat_death") then
			if managers.player:IsC4BombEnough() then
				managers.player:add_grenade_amount(-1)
				self._revives = Application:digest_value(Application:digest_value(self._revives, false) + 1, true)
				self[__auto_revive_timer] = 2
				local __pos = managers.player:local_player():position() + Vector3(0, 0, 10)
				call_on_next_update(function()
					local __damage_size = tweak_data.weapon.trip_mines.damage_size * 0.75
					local __rot = Rotation(90, 90, 0)
					__spawn_bomb(__pos + Vector3(0, 0, 0),								__rot)
					__spawn_bomb(__pos + Vector3(__damage_size*1.5, 0, 0),				__rot)
					__spawn_bomb(__pos + Vector3(__damage_size, __damage_size, 0),		__rot)
					__spawn_bomb(__pos + Vector3(0, __damage_size*1.5, 0),				__rot)
					__spawn_bomb(__pos + Vector3(-__damage_size, __damage_size, 0),		__rot)
					__spawn_bomb(__pos + Vector3(-__damage_size*1.5, 0, 0),				__rot)
					__spawn_bomb(__pos + Vector3(-__damage_size, -__damage_size, 0),	__rot)
					__spawn_bomb(__pos + Vector3(0, -__damage_size*1.5, 0),				__rot)
					__spawn_bomb(__pos + Vector3(__damage_size, -__damage_size, 0),		__rot)
					__spawn_gas_bomb(__pos + Vector3(0, 0,								-8),	0)
					__spawn_gas_bomb(__pos + Vector3(__damage_size*1.5, 0,				-8),	0.15)
					__spawn_gas_bomb(__pos + Vector3(__damage_size, __damage_size,		-8),	0.30)
					__spawn_gas_bomb(__pos + Vector3(0, __damage_size*1.5,				-8),	0.45)
					__spawn_gas_bomb(__pos + Vector3(-__damage_size, __damage_size,		-8),	0.60)
					__spawn_gas_bomb(__pos + Vector3(-__damage_size*1.5, 0,				-8),	0.75)
					__spawn_gas_bomb(__pos + Vector3(-__damage_size, -__damage_size,	-8),	0.90)
					__spawn_gas_bomb(__pos + Vector3(0, -__damage_size*1.5,				-8),	1.05)
					__spawn_gas_bomb(__pos + Vector3(__damage_size, -__damage_size,		-8),	1.20)
				end)
			end
		end
	end
	
	Hooks:PreHook(PlayerDamage, "_chk_cheat_death", __Name("_chk_cheat_death"), function(self)
		self[__chk_cheat_death](self)
	end)	
	
	Hooks:PostHook(PlayerDamage, "update", __Name("update"), function(self, unit, t, dt)
		if self[__auto_revive_timer] then
			self[__auto_revive_timer] = self[__auto_revive_timer] - dt
			if self[__auto_revive_timer] <= 0 then
				self[__auto_revive_timer] = nil
				self:revive(true)
				self._unit:sound_source():post_event("nine_lives_skill")
			end
		elseif self:need_revive() and managers.player:has_category_upgrade("player", "c4_bomb_cheat_death") then
			if not self[__chk_cheat_death_loop] then
				self[__chk_cheat_death_loop] = 1.5
			else
				self[__chk_cheat_death_loop] = self[__chk_cheat_death_loop] - dt
				if self[__chk_cheat_death_loop] <= 0 then
					self[__chk_cheat_death_loop] = nil
					self[__chk_cheat_death](self)
				end
			end
		end
	end)
end

if TripMineBase and not TripMineBase[__LoadOnce] then
	local mvec1 = Vector3()
	TripMineBase[__LoadOnce] = true
	TripMineBase[__SpawnC4] = TripMineBase[__SpawnC4] or function(pos, rot, dir, moving)
		if not DB:has(Idstring("unit"), Idstring("units/payday2/equipment/gen_equipment_tripmine/gen_c4_bomb_husk")) then
			return
		end
		local __tripmine = World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_tripmine/gen_c4_bomb_husk"), pos, rot)
		if __tripmine then
			--Init
			__tripmine:base():setup(false)
			--Active
			__tripmine:base()._collided = moving
			__tripmine:base()._active = true
			__tripmine:base()._activate_timer = 3
			__tripmine:set_extension_update_enabled(Idstring("base"), true)
			--Add
			local from_pos = __tripmine:position() + __tripmine:rotation():y() * 10
			local to_pos = from_pos + __tripmine:rotation():y() * __tripmine:base()._init_length
			local ray = __tripmine:raycast("ray", from_pos, to_pos, "slot_mask", managers.slot:get_mask("world_geometry"))
			__tripmine:base()._length = math.clamp(ray and ray.distance + 10 or __tripmine:base()._init_length, 0, __tripmine:base()._init_length)
			__tripmine:anim_set_time(__tripmine:base()._ids_laser, __tripmine:base()._length / __tripmine:base()._init_length)
			__tripmine:base()._activate_timer = 3
			mvector3.set(__tripmine:base()._ray_from_pos, __tripmine:base()._position)
			mvector3.set(__tripmine:base()._ray_to_pos, __tripmine:base()._forward)
			mvector3.multiply(__tripmine:base()._ray_to_pos, __tripmine:base()._length)
			mvector3.add(__tripmine:base()._ray_to_pos, __tripmine:base()._ray_from_pos)
			--Flyable
			local function __on_collision(self)
			
			end
			__tripmine:base()._on_collision = __on_collision
			local velocity = dir
			velocity = velocity * tweak_data.projectiles["launcher_frag"].launch_speed  
			velocity = Vector3(velocity.x, velocity.y, velocity.z + 50)
			__tripmine:base()._velocity = velocity
			__tripmine:base()._sweep_data = {
				slot_mask = managers.slot:get_mask("world_geometry")
			}
			__tripmine:base()._sweep_data.current_pos = __tripmine:position()
			__tripmine:base()._sweep_data.last_pos = mvector3.copy(__tripmine:base()._sweep_data.current_pos)
			local function __update(self, unit, t, dt)
				if type(self._sweep_data) == "table" then
					if not self._collided then
						self._sweep_data.old_last_pos = true
						self._unit:m_position(self._sweep_data.current_pos)
						self._unit:set_position(self._sweep_data.current_pos)
						self._position = self._sweep_data.current_pos
						mvector3.set(self._ray_from_pos, self._position)
						mvector3.set(self._ray_to_pos, self._forward)
						mvector3.multiply(self._ray_to_pos, self._length)
						mvector3.add(self._ray_to_pos, self._ray_from_pos)
						ProjectileBase.update(self, unit, t, dt)
					else
						if self._sweep_data.old_last_pos then
							self._sweep_data.old_last_pos = false
							self._unit:set_enabled(false)
							self._unit:set_enabled(true)
						end
					end
				end
				if self._activate_timer then
					self._activate_timer = self._activate_timer - dt
					if self._activate_timer <= 0 then
						self._activate_timer = nil
						self:set_armed(self._startup_armed)
						self._startup_armed = nil
					end
				else
					if self._explode_timer then
						self._explode_timer = self._explode_timer - dt
						if self._explode_timer <= 0 then
							self:_explode(self._explode_ray)
						end
					else
						local ray = self._unit:raycast("ray", self._ray_from_pos, self._ray_to_pos, "sphere_cast_radius", 20, "slot_mask", self._slotmask, "ray_type", "trip_mine body")
						if ray and ray.unit and not tweak_data.character[ray.unit:base()._tweak_table].is_escort then
							self._explode_timer = tweak_data.weapon.trip_mines.delay + managers.player:upgrade_value("trip_mine", "explode_timer_delay", 0)
							self._explode_ray = ray
							self._unit:sound_source():post_event("trip_mine_beep_explode")
						end
					end
				end
			end
			__tripmine:base().update = __update
			__tripmine:push_at(1, velocity, __tripmine:position())
			--Boom
			local function __explode(self, col_ray)
				local damage_size = tweak_data.weapon.trip_mines.damage_size * managers.player:upgrade_value("trip_mine", "explosion_size_multiplier_1", 1) * managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)
				local damage = tweak_data.weapon.trip_mines.damage * 2 * managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)
				local player = managers.player:player_unit()
				local weapon_unit = player:inventory():equipped_unit()
				local slotmask = managers.slot:get_mask("explosion_targets")
				managers.explosion:give_local_player_dmg(self._position, damage_size, tweak_data.weapon.trip_mines.player_damage)
				self._unit:set_extension_update_enabled(Idstring("base"), false)
				self._deactive_timer = 5
				self:_play_sound_and_effects()
				local bodies = World:find_bodies("intersect", "cylinder", self._ray_from_pos, self._ray_to_pos, damage_size, slotmask)
				for _, hit_body in ipairs(bodies) do
					if alive(hit_body) then
						local dir = nil
						dir = hit_body:center_of_mass()
						mvector3.direction(dir, self._ray_from_pos, dir)
						local normal = dir
						local prop_damage = math.min(damage, 200)
						local network_damage = math.ceil(prop_damage * 163.84)
						prop_damage = network_damage / 163.84
						if hit_body:extension() and hit_body:extension().damage then
							hit_body:extension().damage:damage_explosion(player, normal, hit_body:position(), dir, prop_damage)
							hit_body:extension().damage:damage_damage(player, normal, hit_body:position(), dir, prop_damage)
							if hit_body:unit():id() ~= -1 then
								if player then
									managers.network:session():send_to_peers_synched("sync_body_damage_explosion", hit_body, player, normal, hit_body:position(), dir, math.min(32768, network_damage))
								else
									managers.network:session():send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, hit_body:position(), dir, math.min(32768, network_damage))
								end
							end
						end
						local e_character_hit = {}
						local e_character = hit_body:unit():character_damage() and not hit_body:unit():character_damage():dead()
						if e_character and not e_character_hit[hit_body:unit():key()] then
							local give_dmg = hit_body:unit():character_damage()
							e_character_hit[hit_body:unit():key()] = true
							self:_give_explosion_damage(col_ray, hit_body:unit(), damage)
							if type(give_dmg.damage_fire) == "function" then
								give_dmg:damage_fire({
									variant = "fire",
									damage = 1,
									weapon_unit = weapon_unit,
									attacker_unit = player,
									col_ray = col_ray,
									armor_piercing = true,
									fire_dot_data = {
										dot_trigger_chance = 100,
										dot_damage = 10,
										dot_length = 3,
										dot_trigger_max_distance = 3000,
										dot_tick_period = 0.5
									}
								})
							end
						end
					end
				end
				if managers.player:has_category_upgrade("trip_mine", "fire_trap") then
					local fire_trap_data = managers.player:upgrade_value("trip_mine", "fire_trap", nil)
					if fire_trap_data then
						managers.network:session():send_to_peers_synched("sync_trip_mine_explode_spawn_fire", self._unit, player, self._ray_from_pos, self._ray_to_pos, damage_size, damage, fire_trap_data[1], fire_trap_data[2])
						self:_spawn_environment_fire(player, fire_trap_data[1], fire_trap_data[2])
					end
				end
				--[[C4 Boom the thing]]
				local __boomeds = World:find_units("sphere", self._ray_from_pos, 300, managers.slot:get_mask("bullet_impact_targets"))
				if type(__boomeds) == "table" then
					for id, hit_unit in pairs(__boomeds) do
						if hit_unit:base() and type(hit_unit:base()._devices) == "table" and type(hit_unit:base()._devices.c4) == "table" and type(hit_unit:base()._devices.c4.amount) == "number" then
							if not hit_unit:base()._devices.c4.max_amount then
								hit_unit:base()._devices.c4.max_amount = hit_unit:base()._devices.c4.amount + 1
							end
							if hit_unit:base()._devices.c4.max_amount then
								hit_unit:base()._devices.c4.max_amount = hit_unit:base()._devices.c4.max_amount - math.random() - 0.3
								if hit_unit:base()._devices.c4.max_amount <= 0 then
										hit_unit:base():device_completed("c4")
								end
							end
							break
						end
					end
				end
				local alert_event = {
					"aggression",
					self._position,
					tweak_data.weapon.trip_mines.alert_radius,
					self._alert_filter,
					player
				}
				managers.groupai:state():propagate_alert(alert_event)
				self._unit:set_slot(0)
			end		
			__tripmine:base()._explode = __explode
			local function old_explode(self)
				self:_explode({
					ray = self._forward,
					position = self._position
				})
			end
			__tripmine:base().explode = old_explode
			local function __bullet_hit(self)
				self:explode()
			end
			__tripmine:base().bullet_hit = __bullet_hit
			return __tripmine
		end
		return
	end
end

if NetworkMatchMakingSTEAM and not NetworkMatchMakingSTEAM[__LoadOnce] then
	NetworkMatchMakingSTEAM[__LoadOnce] = true
	local old_set_attributes = NetworkMatchMakingSTEAM.set_attributes
	function NetworkMatchMakingSTEAM:set_attributes(settings, ...)
		settings.numbers[3] = 3
		return old_set_attributes(self, settings, ...)
	end

	local old_is_server_ok = NetworkMatchMakingSTEAM.is_server_ok
	function NetworkMatchMakingSTEAM:is_server_ok(friends_only, room, attributes_list, is_invite, ...)
		if attributes_list.numbers and attributes_list.numbers[3] < 3 then
			return false
		end
		return old_is_server_ok(self, friends_only, room, attributes_list, is_invite, ...)
	end
end