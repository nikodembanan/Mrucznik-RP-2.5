//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-----------------------------------------------[ poddajsie ]-----------------------------------------------//
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

YCMD:poddajsie(playerid, params[], help)
{
	new string[128];
	new sendername[MAX_PLAYER_NAME];
	new giveplayer[MAX_PLAYER_NAME];

    if(IsPlayerConnected(playerid))
    {
		if(PlayerInfo[playerid][pJob] == 1)
	 	{
	 	    new playa;
			if( sscanf(params, "k<fix>", playa))
			{
				sendTipMessage(playerid, "U�yj /poddajsie [Nick/ID]");
				SendClientMessage(playerid, COLOR_GRAD3, "INFORMACJA: ta komenda proponuje poddanie si� przest�pcy");
				return 1;
			}


			if(IsPlayerConnected(playa))
		    {
   				if(playa != INVALID_PLAYER_ID)
			    {
				    if(GetDistanceBetweenPlayers(playerid,playa) < 10)
					{
					    if(PoziomPoszukiwania[playa] >= 2)
					    {
					        if(playa != playerid)
					        {
					            if(lowcaz[playerid] == playa)
					            {
									new reward = PoziomPoszukiwania[playa] * 10000;
									new punishment = PoziomPoszukiwania[playa] * 1000;
									new bail = PoziomPoszukiwania[playa] * 16000;

							        GetPlayerName(playerid, sendername, sizeof(sendername));
				        			GetPlayerName(playa, giveplayer, sizeof(giveplayer));
							        format(string, sizeof(string), "* �owca Nagr�d %s proponuje ci poddanie si� i trafienie do wi�zienia z kar� %d$ i kaucj� %d$, aby si� zgodzi� wpisz /poddajesie", sendername, punishment, bail);
							        SendClientMessage(playa, COLOR_LIGHTBLUE, string);
							        format(string, sizeof(string), "* Zaproponowa�e� %s poddanie si�, je�li zostanie ono akceptowane zarobisz %d$",giveplayer, reward);
							        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							        poddaje[playa] = 1;
									lowcap[playa] = playerid;
									
									format(string, sizeof(string), "%s [%d] zaoferowa� poddanie si� dla %s [%d]", GetNick(playerid), playerid, GetNick(playa), playa);
									SendMessageToAdmin(string, COLOR_P@);
								}
								else
								{
								    sendErrorMessage(playerid, "Nie masz zlecenia na tego gracza");
								}
							}
							else
							{
								sendErrorMessage(playerid, "Nie mo�esz si� podda� samemu sobie");
                			}
					    }
					    else
					    {
					    	sendErrorMessage(playerid, "Ten gracz nie ma WL");
                		}
					}
					else
				    {
				    	sendErrorMessage(playerid, "Ten gracz jest za daleko");
               		}
				}
				else
				{
                    sendErrorMessage(playerid, "Taki gracz nie istnieje");
                }
			}
		}
		else
	   	{
	   		sendErrorMessage(playerid, "Nie jeste� �owc� nagr�d");
		}
	}
	return 1;
}
