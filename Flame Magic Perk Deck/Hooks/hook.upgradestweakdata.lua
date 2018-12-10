Hooks:PostHook(UpgradesTweakData, "_player_definitions", "MagicPerkDeckTierInit", function(self)
	self.values.player.passive_magic_flamethrower_1 = {
		{
			0,--CD
			1--MP Cost
		}
	}
	self.definitions.player_magic_flamethrower_1 = {
		name_id = "player_magic_flamethrower_1",
		category = "feature",		
		upgrade = {
			value = 1,
			upgrade = "passive_magic_flamethrower_1",
			category = "player"
		}
	}
	self.values.player.passive_magic_fireball_1 = {
		{
			8,--CD
			8--MP Cost
		}
	}
	self.definitions.player_magic_fireball_1 = {
		name_id = "player_magic_fireball_1",
		category = "feature",		
		upgrade = {
			value = 1,
			upgrade = "passive_magic_fireball_1",
			category = "player"
		}
	}
	self.values.player.passive_magic_firebomb_1 = {
		{
			100,--Damage
			1000,--Area
			5--CD
		}
	}
	self.definitions.player_magic_firebomb_1 = {
		name_id = "player_magic_firebomb_1",
		category = "feature",		
		upgrade = {
			value = 1,
			upgrade = "passive_magic_firebomb_1",
			category = "player"
		}
	}
	self.values.player.passive_magic_meteorite_1 = {
		true
	}
	self.definitions.player_magic_meteorite_1 = {
		name_id = "player_magic_meteorite_1",
		category = "feature",		
		upgrade = {
			value = 1,
			upgrade = "passive_magic_meteorite_1",
			category = "player"
		}
	}
	self.values.player.passive_magic_regeneration_1 = {
		true
	}
	self.definitions.player_magic_regeneration_1 = {
		name_id = "player_magic_regeneration_1",
		category = "feature",		
		upgrade = {
			value = 1,
			upgrade = "passive_magic_regeneration_1",
			category = "player"
		}
	}
end)