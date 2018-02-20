if CopDamage then
	Hooks:PreHook(CopDamage, "damage_explosion", "HackPerkDeck_ecm_feedback_dmg_pre", function(self, attack_data)
		if attack_data and attack_data.variant == "stun" and attack_data.weapon_unit and alive(attack_data.weapon_unit) and attack_data.weapon_unit:name():key() == Idstring("units/payday2/equipment/gen_equipment_jammer/gen_equipment_jammer"):key() then
			self._ecm_feedback_hit = TimerManager:game():time() + 2
		end
	end)
end