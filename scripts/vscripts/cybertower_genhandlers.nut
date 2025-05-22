function OnPostSpawn() {
    __CollectGameEventCallbacks(this);
    // Debug Vars
    DebugRedCount <- 0;

    SpinRate <- 0.5;
    MaxPlayers <- MaxClients().tointeger();
    RedCount <- 0;
    ScaleAmount <- 5000; // the base HP to scale off of
    ScaleFactor <- 0.8; // the lower this number, the slower the reds ascend the curve. 1 = default
    ScaleOffset <- 1 // the higher this number, the farther into the curve HP starts. Cannot be negative.
    ScaleSubtraction <- 9000 // Take away this much HP from the result. Make sure we dont go too low.
    RedGenScaleFactor <- 1.5;
    OriginalHealth <- 0;
    RotParent <- null;
    switch (self.GetName()) {
        case "mini_versus_blueGenBR": {
            RotParent = Entities.FindByName(null, "mini_versus_blueGenR");
            // ClientPrint(GetListenServerHost(), 3, "i am blue");
            break;
        }
        case "mini_versus_yellowGenBR": {
            RotParent = Entities.FindByName(null, "mini_versus_yellowGenR");
            // ClientPrint(GetListenServerHost(), 3, "i am piss")
            break;
        }
        case "mini_versus_greenGenBR": {
            RotParent = Entities.FindByName(null, "mini_versus_greenGenR");
            // ClientPrint(GetListenServerHost(), 3, "i am puke")
            break;
        }
        case "mini_versus_redGenBR": {
            RotParent = Entities.FindByName(null, "mini_versus_redGenR");
            // ClientPrint(GetListenServerHost(), 3, "i am apple")
            break;
        }
    }
    // DoVersusSetup();
}

function DoVersusSetup() {
    CalculateReds();
    ScaleOwnHealth();
    CalcNewRotation();
}

function CalculateReds() {
    local numReds = 0;
    local team_red = Constants.ETFTeam.TF_TEAM_RED;
    for (local i = 1; i <= MaxPlayers ; i++) {
        local plyr = PlayerInstanceFromIndex(i);
        if (plyr == null) continue;
        if (plyr.GetTeam() == team_red) { numReds++ }
    }
    RedCount = numReds;
}

function GetOwnHealth() {
    return NetProps.GetPropInt(self, "m_iHealth");
}

function ScaleOwnHealth() {
    local newHealth = ScaleAmount;
    if (DebugRedCount > 0) {RedCount = DebugRedCount}
    newHealth += (ScaleAmount * (log((RedCount * ScaleFactor) + 1 + ScaleOffset))) - ScaleSubtraction;
    
    if (self.GetName() == "mini_versus_redGenBR") { newHealth *= RedGenScaleFactor }
    NetProps.SetPropInt(self, "m_iHealth", newHealth.tointeger());
    OriginalHealth = newHealth;
    // ClientPrint(GetListenServerHost(), 3, newHealth.tostring());    
}

function OnScriptHook_OnTakeDamage(params) {
    if (params.const_entity != self) { return }
    CalcNewRotation();
    // ClientPrint(GetListenServerHost(), 3, GetOwnHealth().tostring());
    // ClientPrint(GetListenServerHost(), 3, SpinRate.tostring());  
}

function CalcNewRotation() {
    SpinRate = (1.0 - ((GetOwnHealth().tofloat() / OriginalHealth.tofloat()) / 1.5));
    EntFireByHandle(RotParent, "SetSpeed", SpinRate.tostring(), -1, self, self);
}