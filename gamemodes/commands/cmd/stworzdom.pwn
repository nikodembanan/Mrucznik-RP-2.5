//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-----------------------------------------------[ stworzdom ]-----------------------------------------------//
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

YCMD:stworzdom(playerid, params[], help)
{
    if(gPlayerLogged[playerid] == 1)
    {
	    if(PlayerInfo[playerid][pAdmin] >= 5000 || IsAScripter(playerid))
		{
   			new interior, kesz;
			if( sscanf(params, "dd", interior, kesz))
			{
				sendTipMessage(playerid, "U�yj /zrobdom [interior] [dodatkowa op�ata]");
				return 1;
			}

			if(interior >= 1 && interior <= MAX_NrDOM)
			{
			    if(kesz >= 0 && kesz <= 1000000000)
			    {
					new string[128];
                    new domid = StworzDom(playerid, interior, kesz);
					format(string, sizeof(string), "%s stworzyl nowy dom o (id %d)", GetNick(playerid), domid);
					Log(statsLog, INFO, string);
			    }
			    else
			    {
			        sendTipMessage(playerid, "Dodatkowa op�ata 0 do 1mld (1 000 000 000)");
			    }
			}
			else
			{
			    sendTipMessage(playerid, "Interior od 1 do 46");
			}
		}
	}
	return 1;
}
