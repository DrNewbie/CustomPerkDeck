Hooks:PreHook(CopDamage, "damage_fire", "MagicPerkDeckRegenerationEvent", function(self, attack_data)
	if self._dead or self._invulnerable then
		return
	end
	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:local_player() then
		if managers.player:has_category_upgrade("player", "passive_magic_regeneration_1") then
			local ply_dmg = attack_data.attacker_unit:character_damage()
			if ply_dmg then
				ply_dmg:change_health(ply_dmg:_max_health() * 0.005)
				attack_data.attacker_unit:movement():add_stamina(1)
			end			
		end
	end
end)