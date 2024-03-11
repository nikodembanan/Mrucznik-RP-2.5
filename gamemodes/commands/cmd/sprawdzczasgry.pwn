//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//------------------------------------------------[ sprawdzczasgry ]------------------------------------------------//
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

YCMD:sprawdzczasgry(playerid, params[], help)
{
    if(PlayerInfo[playerid][pAdmin] == 0)
	{
        return 1;
    }

    new giveplayerid;
    if( sscanf(params, "k<fix>", giveplayerid))
    {
        sendTipMessage(playerid, "U�yj /sprawdzczasgry [id gracza]");
        return 1;
    }

    if(!IsPlayerConnected(giveplayerid) || giveplayerid == INVALID_PLAYER_ID)
    {
        sendTipMessage(playerid, "Tego gracza nie ma na serwerze!");
        return 1;         
    }

    new sessionLength = GetTickCount() - pSessionStart[giveplayerid];
    printf("pSessionStart: %d", pSessionStart[giveplayerid]);
    printf("Now: %d", GetTickCount());
    printf("Session Length RAW: %d", sessionLength);
    sessionLength -= sessionLength % 1000; // zaokr�glenie do pe�nych sekund

    new sLenUnderMinuteTicks = sessionLength % 60000;
    new sLenUnderHourTicks = sessionLength % 3600000;

    new sessionSeconds = sLenUnderMinuteTicks / 1000;
    new sessionMinutes = (sLenUnderHourTicks - sLenUnderMinuteTicks) / 60000;
    new sessionHours = (sessionLength - sLenUnderHourTicks) / 3600000;

    printf("sessionLength: %d | sLenUnderMinuteTicks: %d | sLenUnderHourTicks: %d", sessionLength, sLenUnderMinuteTicks, sLenUnderHourTicks);
    printf("sessionSeconds: %d | minutes: %d | hours: %d", sessionSeconds, sessionMinutes, sessionHours);

	new string[128];
    format(string, sizeof(string), "Czas gry gracza %s [ID %d]: Godzin - %d | Minut - %d | Sekund - %d", 
        GetNick(giveplayerid), giveplayerid, sessionHours, sessionMinutes, sessionSeconds);
    SendClientMessage(playerid, COLOR_WHITE, string);

	return 1;
}