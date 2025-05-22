function OnPostSpawn() {
    LowerSection <- Entities.FindByNameNearest("miniboss_level1_rot", self.GetOrigin(), 2000);
    MiddleSection <- Entities.FindByNameNearest("miniboss_level2_rot", self.GetOrigin(), 2000);
    UpperSection <- Entities.FindByNameNearest("miniboss_level3_rot", self.GetOrigin(), 2000);
    ActiveWeapon <- 1; // Lasers default, followed by bombs, then guns.
    Controller <- null;
    GunHurt <- Entities.FindByNameNearest("miniboss_chainhurt", self.GetOrigin(), 2000);
    LaserA <- Entities.FindByNameNearest("miniboss_level1_beamA", self.GetOrigin(), 2000);
    LaserB <- Entities.FindByNameNearest("miniboss_level1_beamB", self.GetOrigin(), 2000);
    LaserC <- Entities.FindByNameNearest("miniboss_level1_beamC", self.GetOrigin(), 2000);
    LaserD <- Entities.FindByNameNearest("miniboss_level1_beamD", self.GetOrigin(), 2000);
    FireBombDropper <- Entities.FindByNameNearest("miniboss_firebombMaker", self.GetOrigin(), 2000);
    LasersAltCD <- 0.0;
    LasersReverseCD <- 0.0;
    BombsFireCD <- 0.0;
    BombsReverseCD <- 0.0;
    GunsFireCD <- 0.0;
    GunsReverseCD <- 0.0;
    InputLock <- false;
    ExtraLasersOn <- true;
    BossIsRunning <- false;
    BlockLaserControl <- true;
}

function SetController() {
    // ClientPrint(GetListenServerHost(), 3, "Controller set.")
    Controller = activator;
    BossIsRunning = true;
    Controller.SetScriptOverlayMaterial("cybertower/overhaul/screenoverlays/minibosshudlaser.vmt");
}

function DebugWeapons() {
    ClientPrint(GetListenServerHost(), 3, ActiveWeapon.tostring());
    switch (ActiveWeapon) {
        case 1: {
            ClientPrint(GetListenServerHost(), 3, "Lasers selected.");
            break;
        }
        case 2: {
            ClientPrint(GetListenServerHost(), 3, "Bombs selected.");
            break;
        }
        case 3: {
            ClientPrint(GetListenServerHost(), 3, "Guns selected.");
            break;
        }
    }
}

function PressedMoveLeft() {
    if (ActiveWeapon == 1) {ActiveWeapon = 3}
    else {ActiveWeapon += -1}
    switch (ActiveWeapon)
    {
        case 1: {
            Controller.SetScriptOverlayMaterial("cybertower/overhaul/screenoverlays/minibosshudlaser.vmt");
            break;
        }
        case 2: {
            Controller.SetScriptOverlayMaterial("cybertower/overhaul/screenoverlays/minibosshudbomb.vmt");
            break;
        }
        case 3: {
            Controller.SetScriptOverlayMaterial("cybertower/overhaul/screenoverlays/minibosshudgun.vmt");
            break;
        }
    }
    // DebugWeapons();
}

function PressedMoveRight() {
    if (ActiveWeapon == 3) {ActiveWeapon = 1}
    else {ActiveWeapon += 1}
    switch (ActiveWeapon)
    {
        case 1: {
            Controller.SetScriptOverlayMaterial("cybertower/overhaul/screenoverlays/minibosshudlaser.vmt");
            break;
        }
        case 2: {
            Controller.SetScriptOverlayMaterial("cybertower/overhaul/screenoverlays/minibosshudbomb.vmt");
            break;
        }
        case 3: {
            Controller.SetScriptOverlayMaterial("cybertower/overhaul/screenoverlays/minibosshudgun.vmt");
            break;
        }
    }
    // DebugWeapons();
}

function PressedAttack() {
    switch (ActiveWeapon) {
        case 1: {
            if (LasersAltCD > 0) {
                ClientPrint(Controller, 3, "Laser alternation recharging.");
                return;
            }
            if (BlockLaserControl) {
                ClientPrint(Controller, 3, "Lasers setting up. Try again in a few seconds.");
                return;
            }
            EntFireByHandle(LaserA, "Toggle", "", -1, self, self);
            EntFireByHandle(LaserC, "Toggle", "", -1, self, self);
            if (ExtraLasersOn) {
                EntFireByHandle(LaserB, "Toggle", "", -1, self, self);
                EntFireByHandle(LaserD, "Toggle", "", -1, self, self);
            }
            LasersAltCD = 10.0;
            break;
        }
        case 2: {
            if (BombsFireCD > 0) {
                ClientPrint(Controller, 3, "Bomb dropping recharging.");
                return;
            }
            EntFireByHandle(FireBombDropper, "ForceSpawnAtEntityOrigin", "!self", -1, self, self);
            FireBombDropper.EmitSound("Cybertower.FirebombDrop")
            BombsFireCD = 10.0;
            break;
        }
        case 3: {
            if (GunsFireCD > 0) {
                ClientPrint(Controller, 3, "Chainguns recharging.");
                return;
            }
            EntFireByHandle(GunHurt, "Enable", "", -1, self, self);
            EntFireByHandle(GunHurt, "Disable", "", 2.5, self, self);
            EntFire("miniboss_chainparticles", "Start", "", -1, self);
            EntFire("miniboss_chainparticles", "Stop", "", 2.5, self);
            MiddleSection.EmitSound("Cybertower.Chaingun");
            MiddleSection.EmitSound("Cybertower.Chaingun");
            GunsFireCD = 10.0;
            break;
        }
    }
}

function PressedAttack2() {
    switch (ActiveWeapon) {
        case 1: {
            if (LasersReverseCD > 0) {
                ClientPrint(Controller, 3, "Laser reversal recharging.");
                return;
            }
            if (BlockLaserControl) {
                ClientPrint(Controller, 3, "Lasers setting up. Try again in a few seconds.");
                return;
            }
            EntFireByHandle(LowerSection, "Stop", "", -1, self, self);
            LowerSection.EmitSound("Cybertower.MechStop");
            EntFireByHandle(LowerSection, "Reverse", "", 0.1, self, self);
            EntFireByHandle(LowerSection, "Start", "", 1.5, self, self);
            EntFireByHandle(LowerSection, "RunScriptCode", "self.EmitSound(`Cybertower.MechStart`)", 1.5, self, self);
            LasersReverseCD = 10.0;
            break;
        }
        case 2: {
            if (BombsReverseCD > 0) {
                ClientPrint(Controller, 3, "Dropper reversal recharging.");
                return;
            }
            EntFireByHandle(UpperSection, "Stop", "", -1, self, self);
            UpperSection.EmitSound("Cybertower.MechStop");
            EntFireByHandle(UpperSection, "Reverse", "", 0.1, self, self);
            EntFireByHandle(UpperSection, "Start", "", 1.5, self, self);
            EntFireByHandle(UpperSection, "RunScriptCode", "self.EmitSound(`Cybertower.MechStart`)", 1.5, self, self);
            BombsReverseCD = 10.0;
            break;
        }
        case 3: {
            if (GunsReverseCD > 0) {
                ClientPrint(Controller, 3, "Gun reversal recharging.");
                return;
            }
            EntFireByHandle(MiddleSection, "Stop", "", -1, self, self);
            MiddleSection.EmitSound("Cybertower.MechStop");
            EntFireByHandle(MiddleSection, "Reverse", "", 0.1, self, self);
            EntFireByHandle(MiddleSection, "Start", "", 1.5, self, self);
            EntFireByHandle(MiddleSection, "RunScriptCode", "self.EmitSound(`Cybertower.MechStart`)", 1.5, self, self);
            GunsReverseCD = 10.0;
            break;
        }
    }
}

function MinibossThink() {
    // ClientPrint(GetListenServerHost(), 3, "i am think, yeah yeah yeah i am lorde")
    if (!BossIsRunning) { return }
    // ClientPrint(GetListenServerHost(), 3, "FUCK YOU")
    if (GunsReverseCD > 0) {GunsReverseCD -= 0.1}
    if (LasersReverseCD > 0) {LasersReverseCD -= 0.1}
    if (BombsReverseCD > 0) {BombsReverseCD -= 0.1}
    if (GunsFireCD > 0) {GunsFireCD -= 0.1}
    if (LasersAltCD > 0) {LasersAltCD -= 0.1}
    if (BombsFireCD > 0) {BombsFireCD -= 0.1}
}
