if PlayerManager then
	Hooks:PostHook(PlayerManager, "add_grenade_amount", "HackPerkDeck_use_ecm_jammer", function(self, amount)
		if self:player_unit() and alive(self:player_unit()) and amount == -1 then
			local peer_id = managers.network:session():local_peer():id()
			local grenade = self._global.synced_grenades[peer_id].grenade or ""
			if grenade == "small_ecm" then
				ECMJammerBase.spawn(self:player_unit():position(), self:player_unit():rotation(), 1, self:player_unit(), peer_id, true)
			end
		end
	end)
	
	Hooks:PreHook(PlayerManager, "on_killshot", "HackPerkDeck_ecm_on_killshot", function(self, killed_unit)
		local player_unit = self:player_unit()
		if not player_unit then
			return
		end
		local damage_ext = player_unit:character_damage()
		if not damage_ext:need_revive() and not damage_ext:dead() then
			if self:has_category_upgrade("player", "passive_hacker_kill_health") then
				local _ecm_jammers = managers.groupai:state()._ecm_jammers
				if type(_ecm_jammers) == "table" then
					for u_key, data in pairs(_ecm_jammers) do
						if data.unit and alive(data.unit) and data.unit:base() and (data.unit:base()._jammer_active or data.unit:base()._feedback_active) and data.unit:base()._battery_life and data.unit:base()._battery_life > 0 then
							damage_ext:restore_health(2, true)
							break
						end
					end
				end
			end
			if self:has_category_upgrade("player", "passive_hacker_kill_dodge") and killed_unit:character_damage() and killed_unit:character_damage()._ecm_feedback_hit then
				self._hacker_kill_dodge = TimerManager:game():time() + 30
			end
		end
	end)
	
	function PlayerManager:_dodge_shot_gain(gain_value)
		if gain_value then
			self._dodge_shot_gain_value = gain_value
		else
			local Ans = self._dodge_shot_gain_value or 0
			if self:has_category_upgrade("player", "passive_hacker_kill_dodge") and self._hacker_kill_dodge and self._hacker_kill_dodge > TimerManager:game():time() then
				return Ans + 0.2
			end
			return Ans
		end
	end
end