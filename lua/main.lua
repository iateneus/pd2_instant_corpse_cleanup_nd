-- Instant Corpse Cleanup 1.3

if RequiredScript == "lib/managers/enemymanager" then

local CORPSE_CHECK_INTERVAL = 0.10
local SHIELD_CHECK_INTERVAL = 0.10
local KEEP_BODIES_IN_STEALTH = true

local function should_keep_bodies()
    if not KEEP_BODIES_IN_STEALTH or not managers.groupai then
        return false
    end

    local state = managers.groupai:state()
    return state and state:whisper_mode()
end

Hooks:PostHook(EnemyManager, "init", "ICC_NativeDisposalSetup", function(self)
    self._MAX_NR_CORPSES = 0
    self._MAX_NR_SHIELDS = 0
    self._shield_disposal_lifetime = 0
    self._corpse_disposal_upd_interval = CORPSE_CHECK_INTERVAL
    self._shield_disposal_upd_interval = SHIELD_CHECK_INTERVAL
end)

Hooks:PostHook(EnemyManager, "corpse_limit", "ICC_ForceZeroCorpseLimit", function()
    if should_keep_bodies() then
        return 9999
    end

    return 0
end)

Hooks:PostHook(EnemyManager, "shield_limit", "ICC_ForceZeroShieldLimit", function()
    if should_keep_bodies() then
        return 9999
    end

    return 0
end)

Hooks:PostHook(EnemyManager, "on_enemy_died", "ICC_DisposeCorpseImmediately", function(self)
    if should_keep_bodies() or not self:is_corpse_disposal_enabled() then
        return
    end

    self:_upd_corpse_disposal()
end)

-- CivilianDamage registers bodies through on_civilian_died rather than
-- on_enemy_died. In loud, use the same immediate native disposal pass.
Hooks:PostHook(EnemyManager, "on_civilian_died", "ICC_DisposeCivilianImmediately", function(self)
    if should_keep_bodies() or not self:is_corpse_disposal_enabled() then
        return
    end

    self:_upd_corpse_disposal()
end)

-- Shields are registered before all their internal data is ready in the
-- 64-bit version. The native pass removes them with the zero limit.

elseif RequiredScript == "lib/units/enemies/cop/copdamage" then

    Hooks:PreHook(CopDamage, "_spawn_head_gadget", "ICC_BlockHeadGearDebris", function(self)
        self._head_gear = false
    end)

end
