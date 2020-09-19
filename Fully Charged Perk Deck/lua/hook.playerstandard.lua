Hooks:PostHook(PlayerStandard, "init", "F_"..Idstring("FullyChargedSteelsightInit"):key(), function(self)
	self._in_steelsight_last = false
end)

Hooks:PostHook(PlayerStandard, "_check_action_steelsight", "F_"..Idstring("FullyChargedSteelsightUpdate"):key(), function(self)
	if self._in_steelsight_last ~= self:in_steelsight() then
		self._in_steelsight_last = self:in_steelsight()
		if not self._in_steelsight_last then
			self._fully_charged_time2damage_t = 0
		else
			self._fully_charged_time2damage_t = TimerManager:game():time()
		end
	end
end)