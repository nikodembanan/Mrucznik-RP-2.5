//-----------------------------------------------<< Source >>------------------------------------------------//
//                                                  lidercar                                                 //
//----------------------------------------------------*------------------------------------------------------//
//----[                                                                                                 ]----//
//----[         |||||             |||||                       ||||||||||       ||||||||||               ]----//
//----[        ||| |||           ||| |||                      |||     ||||     |||     ||||             ]----//
//----[       |||   |||         |||   |||                     |||       |||    |||       |||            ]----//
//----[       ||     ||         ||     ||                     |||       |||    |||       |||            ]----//
//----[      |||     |||       |||     |||                    |||     ||||     |||     ||||             ]----//
//----[      ||       ||       ||       ||     __________     ||||||||||       ||||||||||               ]----//
//----[     |||       |||     |||       |||                   |||    |||       |||                      ]----//
//----[     ||         ||     ||         ||                   |||     ||       |||                      ]----//
//----[    |||         |||   |||         |||                  |||     |||      |||                      ]----//
//----[    ||           ||   ||           ||                  |||      ||      |||                      ]----//
//----[   |||           ||| |||           |||                 |||      |||     |||                      ]----//
//----[  |||             |||||             |||                |||       |||    |||                      ]----//
//----[                                                                                                 ]----//
//----------------------------------------------------*------------------------------------------------------//
// Autor: mrucznik
// Data utworzenia: 10.02.2024


//

//------------------<[ Implementacja: ]>-------------------
command_lidercar_Impl(playerid, akcja[16], opcje[256])
{
    if(!orgIsLeader(playerid) && PlayerInfo[playerid][pLider] == 0)
    {
        sendErrorMessage(playerid, "Nie jeste� liderem!");
        return 1;
    }

	if(!IsPlayerInAnyVehicle(playerid))
	{
        sendErrorMessage(playerid, "Musisz by� w poje�dzie, kt�ry chcesz edytowa�!");
        return 1;
    }

    new vehicleID = GetPlayerVehicleID(playerid);
    new vehicleUID = VehicleUID[vehicleID][vUID];
    new lider = PlayerInfo[playerid][pLider];
    new org = GetPlayerOrg(playerid);
    new string[512];
    new liderOwner = CarData[vehicleUID][c_OwnerType] == CAR_OWNER_FRACTION && \
        lider == CarData[vehicleUID][c_Owner] && 
        lider > 0;
    new orgOwner = CarData[vehicleUID][c_OwnerType] == CAR_OWNER_FAMILY && \
        org == CarData[vehicleUID][c_Owner];

    format(string, sizeof(string), "OWNER_FAMILY %d ORGLEADER %d c_Owner veh %d orgOwner %d", CAR_OWNER_FAMILY, orgIsLeader(playerid), CarData[vehicleUID][c_Owner], orgOwner);
    sendTipMessage(playerid, string);
    format(string, sizeof(string), "Player Org %d, Player Org %d", gPlayerOrg[playerid], GetPlayerOrg(playerid));
    sendTipMessage(playerid, string);
	if(!liderOwner && !orgOwner)
	{
        sendErrorMessage(playerid, "Ten pojazd nie nale�y do Twojej organizacji!");
        return 1;
    }

    // choose command action
	if(strcmp(akcja, "parkuj", true) == 0) {
        command_lidercar_parkuj(playerid);
    } else if(strcmp(akcja, "przemaluj", true) == 0) {
        command_lidercar_przemaluj(playerid, vehicleID, opcje);
    } else if(strcmp(akcja, "ranga", true) == 0) {
        command_lidercar_ranga(playerid, vehicleUID, opcje);
    } else if(strcmp(akcja, "opis", true) == 0) {
        command_lidercar_opis(playerid, vehicleID, vehicleUID, opcje);
    } else {
        sendErrorMessage(playerid, "Niepoprawna opcja!");
        StaryCzas[playerid] -= 200;
        Command_ReProcess(playerid, "lidercar", true);
    }

    return 1;
}

command_lidercar_parkuj(playerid)
{
    StaryCzas[playerid] -= 200;
    Command_ReProcess(playerid, "zaparkuj", false);
    return 1;
}

command_lidercar_przemaluj(playerid, vehicleID, opcje[256])
{
    new color1, color2;
    if(sscanf(opcje, "dd", color1, color2))
    {
        sendTipMessage(playerid, "U�yj /lidercar przemaluj [kolor 1] [kolor 2]");
        sendTipMessage(playerid, "Uwaga! Koszt przemalowania: 1500$");
        return 1;
    }

    // change color
    ChangeVehicleColor(vehicleID, color1, color2);
    MRP_ChangeVehicleColor(vehicleID, color1, color2);

    // send message, take money
    SendClientMessage(playerid, COLOR_PINK, "Pojazd przemalowany! -1500$");
    ZabierzKase(playerid, 1500);
    return 1;
}

command_lidercar_ranga(playerid, vehicleUID, opcje[256])
{
    new rank;
    if(sscanf(opcje, "d", rank))
    {
        sendTipMessage(playerid, "U�yj /lidercar ranga [ranga od kt�rej mo�na u�ywa� pojazdu]");
        return 1;
    }

    if(rank < 0 || rank > 9) 
    {
        sendErrorMessage(playerid, "Ranga od 0 do 9!");
        return 1;
    }

    // save rank
    CarData[vehicleUID][c_Rang] = rank;
    Car_Save(vehicleUID, CAR_SAVE_OWNER);

    // send message
    new string[128];
    format(string, sizeof(string), "Od teraz tylko osoby z %d rang� b�d� mog�y u�ywa� tego pojazdu.", rank);
    SendClientMessage(playerid, COLOR_PINK, string);
    return 1;
}

command_lidercar_opis(playerid, vehicleID, vehicleUID, opcje[256])
{
    sendTipMessage(playerid, "Opcja b�dzie dost�pna w nast�pnej aktualizacji (v2.7.12)");
    return 1;

    new description[256];
    if(sscanf(opcje, "s[256]", description))
    {
        sendTipMessage(playerid, "U�yj /lidercar opis [opis pojazdu]");
        return 1;
    }

    // change description

    // send message
    new string[256];
    format(string, sizeof(string), "Nowy opis pojazdu: %s", description);
    SendClientMessage(playerid, COLOR_PINK, string);
}

//end