if UpgradesTweakData then
	Hooks:PostHook(UpgradesTweakData, "_grenades_definitions", "HackPerkDeck_grenades_definitions", function(self)
		self.definitions.small_ecm = {category = "grenade"}
	end)
	
	Hooks:PostHook(UpgradesTweakData, "_player_definitions", "HackPerkDeck_player_definitions", function(self)
		self.values.player.passive_hacker_kill_health = {true}
		self.definitions.player_hacker_kill_health = {
			name_id = "player_hacker_kill_health",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "passive_hacker_kill_health",
				category = "player"
			}
		}
		self.values.player.passive_hacker_kill_dodge = {true}
		self.definitions.player_hacker_kill_dodge = {
			name_id = "player_hacker_kill_dodge",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "passive_hacker_kill_dodge",
				category = "player"
			}
		}
		self.values.player.passive_hacker_crew_kill_health = {true}
		self.definitions.player_hacker_crew_kill_health = {
			name_id = "player_hacker_crew_kill_health",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "passive_hacker_crew_kill_health",
				category = "player"
			}
		}
	end)
end