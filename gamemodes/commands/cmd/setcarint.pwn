//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-----------------------------------------------[ setcarint ]-----------------------------------------------//
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

// Opis:
/*
	
*/


// Notatki skryptera:
/*
	
*/

YCMD:setcarint(playerid, params[], help)
{
    if(IsPlayerConnected(playerid))
    {
        new plo;
        if( sscanf(params, "d", plo))
        {
            sendTipMessage(playerid, "U�yj /setcarint [carid]");
            return 1;
        }
        if (PlayerInfo[playerid][pAdmin] >= 1 || Uprawnienia(playerid, ACCESS_PANEL) || IsAKO(playerid) || IsAScripter(playerid))
        {
            LinkVehicleToInterior(plo, GetPlayerInterior(playerid));

            _MruAdmin(playerid, sprintf("Ustawi�e� interior auta %d na %d", plo, GetPlayerInterior(playerid)));

        }
        else
        {
            noAccessMessage(playerid);
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_GREY, "B��d!");
    }
    return 1;
}