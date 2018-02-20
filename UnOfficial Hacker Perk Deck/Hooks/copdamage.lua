if CopDamage then
	Hooks:PreHook(CopDamage, "damage_explosion", "HackPerkDeck_ecm_feedback_dmg_pre", function(self, attack_data)
		if attack_data and attack_data.variant == "stun" and attack_data.weapon_unit and alive(attack_data.weapon_unit) and attack_data.weapon_unit:name():key() == Idstring("units/payday2/equipment/gen_equipment_jammer/gen_equipment_jammer"):key() then
			self._ecm_feedback_hit = TimerManager:game():time() + 2
		end
	end)
	
	Hooks:PreHook(CopDamage, "die", "HackPerkDeck_Botnet", function(self, attack_data)
		if attack_data and attack_data.attacker_unit and alive(attack_data.attacker_unit) and managers.player:has_category_upgrade("player", "passive_hacker_crew_kill_health") then
			local damage_ext = alive(managers.player:player_unit()) and managers.player:player_unit():character_damage()
			if damage_ext and not damage_ext:need_revive() and not damage_ext:dead() then
				if attack_data.attacker_unit ~= managers.player:player_unit() then
					local _ecm_jammers = managers.groupai:state()._ecm_jammers
					if type(_ecm_jammers) == "table" then
						for u_key, data in pairs(_ecm_jammers) do
							if data.unit and alive(data.unit) and data.unit:base() and (data.unit:base()._jammer_active or data.unit:base()._feedback_active) and data.unit:base()._battery_life and data.unit:base()._battery_life > 0 then
								damage_ext:restore_health(1, true)
								break
							end
						end
					end
				end
			end
		end
	end)
end