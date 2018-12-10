local function SpawnFireOnMyHandWOW(them)
	if managers.player:has_category_upgrade("player", "passive_magic_flamethrower_1") then
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		local aligns = tweak_data.blackmarket.melee_weapons[melee_entry].align_objects or {"a_weapon_left", "a_weapon_right"}
		them._hand_effects = them._hand_effects or {}
		if them._hand_effects then
			for k, v in pairs(them._hand_effects) do
				World:effect_manager():fade_kill(v)
				them._hand_effects[k] = nil
			end
			them._hand_effects = {}
		end
		for k , v in ipairs(aligns) do
			table.insert(them._hand_effects, World:effect_manager():spawn({
				effect = Idstring("effects/particles/fire/small_light_fire"),
				parent = them._parent_unit:camera()._camera_unit:get_object(Idstring(v))
			}))
		end
	end
end

Hooks:PostHook(FPCameraPlayerBase, "update", "SpawnFireOnMyHandWOWNow", function(self, unit, t, dt)
	if managers.player:has_category_upgrade("player", "passive_magic_flamethrower_1") then
		if self._my_hand_is_on_fire then
			self._my_hand_is_on_fire = self._my_hand_is_on_fire - dt
			if self._my_hand_is_on_fire < 0 then
				self._my_hand_is_on_fire = nil
			end
		else
			self._my_hand_is_on_fire = math.random()*20
			SpawnFireOnMyHandWOW(self)
		end
	end	
end)