//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//--------------------------------------------------[ kill ]-------------------------------------------------//
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

YCMD:kill(playerid, params[], help)
{
	new giveplayer[MAX_PLAYER_NAME];
	new sendername[MAX_PLAYER_NAME];
	

    if(IsPlayerConnected(playerid))
    {
		new playa;
		if( sscanf(params, "k<fix>", playa))
		{
			sendTipMessage(playerid, "U�yj /kill [ID/Imie_Nazwisko]");
			return 1;
		}

		if (PlayerInfo[playerid][pAdmin] >= 1)
		{
		    if(IsPlayerConnected(playa))
		    {
		        if(playa != INVALID_PLAYER_ID)
		        {		
					SetPVarInt(playerid, 'skip_bw', 1);
					GetPlayerName(playa, giveplayer, sizeof(giveplayer));
					GetPlayerName(playerid, sendername, sizeof(sendername));
					SetPlayerHealth(playa, 0);
					Log(adminLog, INFO, "Admin %s zabi� %s komend� /kill", GetPlayerLogName(playerid), GetPlayerLogName(playa));

					_MruAdmin(playerid, sprintf("Zabi�e� gracza %s [%d] za pomoc� komendy", GetNick(playa, true), playa));
					if(playerid != playa) _MruAdmin(playa, sprintf("Zosta�e� zabity przez admina %s [%d]", GetNick(playerid, true), playerid));

					SendCommandLogMessage(sprintf("Admin %s [%d] da� /kill graczowi %s [%d]", GetNick(playerid, true), playerid, GetNick(playa, true), playa));
					
				}
			}
		}
		else
		{
			noAccessMessage(playerid);
		}
	}
	return 1;
}
