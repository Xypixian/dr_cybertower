function OnPostSpawn() {
    MaxPlayers <- MaxClients().tointeger();
    MaxWeapons <- 8;
    SlotMelee <- 3;
    teamBlu <- Constants.ETFTeam.TF_TEAM_BLUE;
    teamRed <- Constants.ETFTeam.TF_TEAM_RED;
    condTaunt <- Constants.ETFCond.TF_COND_TAUNTING;
    TFGamerules <- Entities.FindByClassname(null, "tf_gamerules");
    BossSpecDest <- Entities.FindByName(null, "finalboss_preservetpdest");
    EscapeSpecDest <- Entities.FindByName(null, "a1_intro_escapeFailTP");
    PreservedRed <- null;
    BluIsPreserved <- false;
    AllowHealing <- true;
    BossMode <- false;
    EscapeMode <- false;
    __CollectGameEventCallbacks(this);
}

function ApplyNonScriptOverlayAll(nsOverlay) {
    for (local i = 1; i <= MaxPlayers ; i++) {
        local nsOverlayPlayer = PlayerInstanceFromIndex(i);
        if (nsOverlayPlayer == null) continue;

        EntFire("clientcommand", "Command", "r_screenoverlay " + nsOverlay, -1, nsOverlayPlayer);
    }
}

function ApplyTruceModeAll() {
    for (local i = 1; i <= MaxPlayers ; i++) {
        local trucePlayer = PlayerInstanceFromIndex(i);
        if (trucePlayer == null) continue;

        trucePlayer.SetCollisionGroup(27);
        NetProps.SetPropBool(TFGamerules, "m_bTruceActive", true);
    }
}

function DisableTruceModeAll() {
    for (local i = 1; i <= MaxPlayers ; i++) {
        local trucePlayer = PlayerInstanceFromIndex(i);
        if (trucePlayer == null) continue;

        trucePlayer.SetCollisionGroup(5);
        NetProps.SetPropBool(TFGamerules, "m_bTruceActive", false);
    }
}

// fuck you medics
function OnGameEvent_player_healed(params)
{
    if (AllowHealing) { return }
    if (params.patient == params.healer) {
        local player = GetPlayerFromUserID(params.patient);
        if (player 
            && player.GetPlayerClass() == Constants.ETFClass.TF_CLASS_MEDIC
            && params.amount < 10)
        {
            player.SetHealth(player.GetHealth() - params.amount);
        }
    }
}

function PrintTeams(redmsg, blumsg) {
    for (local i = 1; i <= MaxPlayers ; i++) {
        local msgPlayer = PlayerInstanceFromIndex(i);
        if (msgPlayer == null) continue;

        if (msgPlayer.GetTeam() == teamBlu) { ClientPrint(msgPlayer, 3, blumsg)}
        else { ClientPrint(msgPlayer, 3, redmsg)}
    }
}

function OnScriptHook_OnTakeDamage(params) {
    if (!BossMode) { return }
    local dmgPlyr = params.const_entity;
    if (!dmgPlyr.IsPlayer()) { return }
    if (params.attacker.IsPlayer()) {
        params.damage = 0;
        return;
    }
    local dmgAmt = params.damage;
    local plyHlth = dmgPlyr.GetHealth()

    if ((plyHlth - 1) < dmgAmt.tointeger()) {
        if (dmgPlyr.GetTeam() == teamBlu) {
            TPToSafeSpot(dmgPlyr);
            BluIsPreserved = true;
            params.damage = 0;
            ClientPrint(dmgPlyr, 3, "You died! You're being preserved to keep the round going.");
            return;
        }
        if (CheckPreservedRed()) { return }
        else {
            TPToSafeSpot(dmgPlyr);
            PreservedRed = dmgPlyr;
            params.damage = 0;
            ClientPrint(dmgPlyr, 3, "You died! You're being preserved to keep the round going.");
        }
    }
}

function CheckPreservedRed() {
    if (PreservedRed == null) { return false}
    if (!PreservedRed.IsValid()) { return false }
    if (NetProps.GetPropInt(PreservedRed, "m_LifeState") != 0) { return false }
    return true;
}

function TPToSafeSpot(hPlayer) {
    if (EscapeMode) { hPlayer.SetAbsOrigin(EscapeSpecDest.GetOrigin()) }
    else { hPlayer.SetAbsOrigin(BossSpecDest.GetOrigin()) }
}

function CheckForAllDead() {
    if (BluIsPreserved
        && CheckPreservedRed()
    ) {
        local redCount = 0;
        for (local i = 1; i <= MaxPlayers ; i++) {
            local chkPlayer = PlayerInstanceFromIndex(i);
            if (chkPlayer == null) continue;
            if (chkPlayer.GetTeam() == teamRed
            && NetProps.GetPropInt(chkPlayer, "m_lifeState") == 0
            ) {
                redCount++
            }
        }
        if (redCount < 2) {
            EntFire("red_win", "SetTeam", "1", -1, self);
            EntFire("red_win", "RoundWin", "", 0.02, self);
            EntFire("specialEndRelay_bossLose", "Trigger", "", -1, self);
        }
    }
}

function ForceAllToThirdPerson() {
    for (local i = 1; i <= MaxPlayers ; i++) {
        local tpPlayer = PlayerInstanceFromIndex(i);
        if (tpPlayer == null) continue;

        if (NetProps.GetPropInt(tpPlayer, "m_lifeState") != 0) { continue }
        tpPlayer.SetForcedTauntCam(1);
    }
}

function ForcePlayersToMelee() {
    for (local i = 1; i <= MaxPlayers ; i++) {
        local meleePlayer = PlayerInstanceFromIndex(i);
        if (meleePlayer == null) continue;

        for (local ii = 0; ii < MaxWeapons; ii++) {
            local targetWeapon = NetProps.GetPropEntityArray(meleePlayer, "m_hMyWeapons", ii);
            if (targetWeapon != null) {
                local weaponClass = targetWeapon.GetClassname();
                if (weaponClass == "tf_weapon_minigun") { NetProps.SetPropEntity(meleePlayer, "m_hActiveWeapon", null) }
                else if (startswith(weaponClass, "tf_weapon_sniperrifle")) { NetProps.SetPropFloat(targetWeapon, "m_flNextPrimaryAttack", 0.0)}
                
                if (meleePlayer.InCond(condTaunt)) { meleePlayer.RemoveCond(condTaunt) }
                if (targetWeapon.IsMeleeWeapon()) { meleePlayer.Weapon_Switch(targetWeapon)}
                else {targetWeapon.Destroy()}
            }
        }
    }
}