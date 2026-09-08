dofile(ModPath .. "lua/settings.lua")
local ICC = InstantCorpseCleanup

if RequiredScript == "lib/managers/gameplaycentralmanager" then

Hooks:PostHook(GamePlayCentralManager, "init", "ICC_NoDecals_Init", function(self)
    self._icc_defaults = { bullet = self._block_bullet_decals, blood = self._block_blood_decals }
    ICC:ApplyDecalSettings(self)
end)


local blood_impact = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a")
local blood_screen = Idstring("effects/particles/character/player/blood_screen")

local original_flesh = Hooks:GetFunction(GamePlayCentralManager, "sync_play_impact_flesh")
Hooks:OverrideFunction(GamePlayCentralManager, "sync_play_impact_flesh", function(self, from, dir)
    if not ICC.settings.remove_decals then
        return original_flesh(self, from, dir)
    end
    self._effect_manager:spawn({
        effect = blood_impact,
        position = from,
        normal = dir
    })

    local player = managers.player:player_unit()
    if player and mvector3.distance_sq(from, player:movement():m_head_pos()) < 40000 then
        self._effect_manager:spawn({
            effect = blood_screen,
            position = Vector3(),
            rotation = Rotation()
        })
    end

    local sound_source = self:_get_impact_source()
    sound_source:stop()
    sound_source:set_position(from)
    sound_source:set_switch("materials", "flesh")
    sound_source:post_event("bullet_hit")
end)



elseif RequiredScript == "lib/managers/explosionmanager" then
local original_spawn = Hooks:GetFunction(ExplosionManager, "spawn_sound_and_effects")

Hooks:OverrideFunction(ExplosionManager, "spawn_sound_and_effects", function(self,
    position, normal, range, effect_name, sound_event, on_unit, idstr_decal,
    idstr_effect, molotov_damage_effect_table, ...)
    if ICC.settings.remove_decals then idstr_decal = false end
    return original_spawn(self, position, normal, range, effect_name, sound_event,
        on_unit, idstr_decal, idstr_effect, molotov_damage_effect_table, ...)
end)

end
