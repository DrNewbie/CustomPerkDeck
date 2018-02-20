if ECMJammerBase then
	function ECMJammerBase.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, small_ecm)
		if not small_ecm then
			battery_life_upgrade_lvl = math.clamp(battery_life_upgrade_lvl, 1, #ECMJammerBase.battery_life_multiplier)
			local unit = World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_jammer/gen_equipment_jammer"), pos, rot)
			managers.network:session():send_to_peers_synched("sync_equipment_setup", unit, battery_life_upgrade_lvl, peer_id or 0)
			unit:base():setup(battery_life_upgrade_lvl, owner)
			return unit
		else
			local unit = World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_jammer/gen_equipment_jammer"), pos, rot)
			unit:base():setup(battery_life_upgrade_lvl, owner, small_ecm)
			return unit
		end
	end
	
	Hooks:PostHook(ECMJammerBase, "setup", "HackPerkDeck_small_ecm_setup", function(self, battery_life_upgrade_lvl, owner, small_ecm)
		if small_ecm then
			self._battery_life = 8
			self._max_battery_life = 8
			self._low_battery_life = 1
			self._small_ecm = true
			self:set_active(true)
		end
	end)
	
	Hooks:PostHook(ECMJammerBase, "update", "HackPerkDeck_small_ecm_update", function(self, unit, t, dt)
		if self._small_ecm then
			if not self._feedback_active and not managers.groupai:state():whisper_mode() then
				self:_set_feedback_active(true)
			end
			if self._battery_life > 0 then
				self._battery_life = self._battery_life - dt
				self._unit:set_position(self._owner:position())
			else
				self._feedback_expire_t = 0
				self._feedback_duration = 0
				self:destroy()
				self._unit:set_slot(0)
			end
		end
	end)
end