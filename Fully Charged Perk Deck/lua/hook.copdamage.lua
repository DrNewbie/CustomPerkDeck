local FullyChargedPerkShotEvent = CopDamage.damage_bullet
local ExplosionHeadshotForceDelay = 0
function CopDamage:damage_bullet(attack_data, ...)
	local explosion_headshot = {}
	if attack_data and attack_data.damage and attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit == managers.player:player_unit() then
		local player = attack_data.attacker_unit
		if player and player == managers.player:local_player() and player:inventory() and player:inventory():equipped_unit():base():is_category("snp") then
			if managers.player:has_category_upgrade("player", "passive_fully_charged_headshot_ony") and managers.player:upgrade_value("player", "passive_fully_charged_headshot_ony", false) then
				if attack_data.col_ray and attack_data.col_ray.body and attack_data.col_ray.body:name() then 
					local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
					if not head then
						return
					end
				else
					return
				end
			end
			local damage_ex = player:character_damage()
			if damage_ex and not damage_ex:arrested() and not damage_ex:need_revive() then
				if damage_ex:get_real_armor() and managers.player:has_category_upgrade("player", "passive_fully_charged_armor2damage") and managers.player:upgrade_value("player", "passive_fully_charged_armor2damage", false) then
					local armor = damage_ex:get_real_armor()
					damage_ex:set_armor(0)
					damage_ex:_send_set_armor()
					damage_ex:_update_armor_hud(0, 0.1)
					damage_ex:damage_simple({
						damage = 0.01,
						variant = "bullet"
					})
					attack_data.damage = attack_data.damage * (1+(armor/100))
				end
				if managers.player:has_category_upgrade("player", "passive_fully_charged_far2damage") and managers.player:upgrade_value("player", "passive_fully_charged_far2damage", false) then
					local distance = mvector3.distance(self._unit:position(), player:position())
					local dis_buff = (distance/100) * 0.03 + 1
					attack_data.damage = attack_data.damage * dis_buff
				end
				if managers.player:has_category_upgrade("player", "passive_fully_charged_time2damage") and managers.player:upgrade_value("player", "passive_fully_charged_time2damage", false) then
					local in_steelsight = player:movement() and player:movement():current_state() and player:movement():current_state():in_steelsight() or false
					if in_steelsight then
						local fct = player:movement() and player:movement():current_state() and player:movement():current_state()._fully_charged_time2damage_t or 0
						if fct > 0 then
							fct = TimerManager:game():time() - fct
							if fct > 0 then
								attack_data.damage = attack_data.damage * (1+(fct/40))
								player:movement():current_state()._fully_charged_time2damage_t = TimerManager:game():time()
							end
						end
					end
				end
				local explosive_headshot = managers.player:upgrade_value("player", "passive_fully_charged_explosive_headshot_1", 0)
				explosive_headshot = explosive_headshot + managers.player:upgrade_value("player", "passive_fully_charged_explosive_headshot_2", 0)
				if explosive_headshot > 1 then
					local pos = self._unit and self._unit:position()
					explosion_headshot = {
						hit_pos = pos,
						range = explosive_headshot,
						damage = attack_data.damage*10.25,
					}
				end
			end
			if explosion_headshot and explosion_headshot.hit_pos and TimerManager:game():time() > ExplosionHeadshotForceDelay then
				ExplosionHeadshotForceDelay = TimerManager:game():time() + 0.25
				managers.explosion:play_sound_and_effects(
					explosion_headshot.hit_pos,
					math.UP,
					explosion_headshot.range,
					{
						sound_event = "grenade_explode",
						effect = "effects/payday2/particles/explosions/grenade_explosion",
						camera_shake_max_mul = 4,
						sound_muffle_effect = true,
						feedback_range = explosion_headshot.range * 2
					}
				)
				local characters_hit = {}
				local bodies = World:find_bodies("intersect", "sphere", explosion_headshot.hit_pos, explosion_headshot.range, managers.slot:get_mask("explosion_targets"))
				local old_col_ray_unit = attack_data.col_ray.unit or self._unit
				for _, hit_body in pairs(bodies) do
					local character = hit_body:unit():character_damage() and hit_body:unit():character_damage().damage_explosion and not hit_body:unit():character_damage():dead()
					if character and not characters_hit[hit_body:unit():key()] then
						characters_hit[hit_body:unit():key()] = true
						attack_data.col_ray.unit = hit_body:unit()
						InstantExplosiveBulletBase:on_collision(attack_data.col_ray, player:inventory():equipped_unit(), player, attack_data.damage*1.25 or 1, false)
					end
				end
				attack_data.col_ray.unit = old_col_ray_unit
			end
			if not damage_ex:arrested() and not damage_ex:need_revive() then
				damage_ex:set_fully_charged_invulnerable(true)
			end
			if not damage_ex:full_health() then
				damage_ex:restore_health(damage_ex:_max_health()*0.01, true)
			end
		end
	end	
	return FullyChargedPerkShotEvent(self, attack_data, ...)
end