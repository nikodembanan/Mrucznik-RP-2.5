//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//------------------------------------------------[ unblock ]------------------------------------------------//
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

YCMD:unblock(playerid, params[], help)
{
	new string[128];

    if(PlayerInfo[playerid][pAdmin] >= 1)
	{
		if(isnull(params))
		{
			sendTipMessage(playerid, "U�yj /unblock [nick]");
			return 1;
		}
		if(MruMySQL_Unblock(params, playerid))
		{
    		format(string, sizeof(string), "Administrator %s nada� unblocka na posta� %s", GetNickEx(playerid), params);
            //SendPunishMessage(string);
            ABroadCast(COLOR_YELLOW,string,1);
            Log(punishmentLog, INFO, "Admin %s odblokowa� %s", GetPlayerLogName(playerid), params);
        }
	}
	return 1;
}
