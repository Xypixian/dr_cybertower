function OnPostSpawn() {
    CurrentTime <- 241;
    MaxPlayers <- MaxClients().tointeger();
    OverlayToUse <- "null";
    EscapeMode <- false;
}

function ApplyNewTimer() {
    if (CurrentTime < 1) { return }
    CurrentTime--;
    OverlayToUse = "cybertower/overhaul/screenoverlays/timers/" + CurrentTime.tointeger().tostring() + ".vmt";

    for (local i = 1; i <= MaxPlayers ; i++) {
        local overlayPlayer = PlayerInstanceFromIndex(i);
        if (overlayPlayer == null) continue

        overlayPlayer.SetScriptOverlayMaterial(OverlayToUse);
    }
    if (EscapeMode) { return }
    if (CurrentTime == 180) {EntFireByHandle(self, "FireUser1", "", -1, self, self)}
    if (CurrentTime == 120) {EntFireByHandle(self, "FireUser2", "", -1, self, self)}
    if (CurrentTime == 60) {EntFireByHandle(self, "FireUser3", "", -1, self, self)}
    if (CurrentTime == 30) {EntFireByHandle(self, "FireUser4", "", -1, self, self)}
}