if UpgradesTweakData then
	Hooks:PostHook(UpgradesTweakData, "_grenades_definitions", "HackPerkDeck_grenades_definitions", function(self)
		self.definitions.small_ecm = {category = "grenade"}
	end)
	
	Hooks:PostHook(UpgradesTweakData, "_player_definitions", "HackPerkDeck_player_definitions", function(self)
		self.values.player.passive_hacker_kill_faster_small_ecm = {6}
		self.definitions.player_hacker_kill_faster_small_ecm = {
			name_id = "player_hacker_kill_faster_small_ecm",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "passive_hacker_kill_faster_small_ecm",
				category = "player"
			}
		}
		self.values.player.passive_hacker_kill_health = {2}
		self.definitions.player_hacker_kill_health = {
			name_id = "player_hacker_kill_health",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "passive_hacker_kill_health",
				category = "player"
			}
		}
		self.values.player.passive_hacker_kill_dodge = {{0.2, 30}}
		self.definitions.player_hacker_kill_dodge = {
			name_id = "player_hacker_kill_dodge",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "passive_hacker_kill_dodge",
				category = "player"
			}
		}
		self.values.player.passive_hacker_crew_kill_health = {1}
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