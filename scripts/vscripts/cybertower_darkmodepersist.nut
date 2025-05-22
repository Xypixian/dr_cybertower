function OnPostSpawn() {
    DarkPlayers <- []
    DarkFade <- Entities.FindByName(null, "darkmodeFade");
}

function AddPlayerToDarkList() {
    foreach (drkPlyr in DarkPlayers) {
        if (drkPlyr == activator) { return }
    }
    DarkPlayers.push(activator);
}

function RestoreDarkMode() {
    foreach (drkPlyr in DarkPlayers) {
        if (drkPlyr.IsValid() == false) continue

        EntFireByHandle(DarkFade, "Fade", "", -1, drkPlyr, drkPlyr);
    }
}