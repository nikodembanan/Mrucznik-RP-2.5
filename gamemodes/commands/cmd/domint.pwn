//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-------------------------------------------------[ domint ]------------------------------------------------//
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

YCMD:domint(playerid, params[], help)
{
    if(PlayerInfo[playerid][pAdmin] == 5000)
	{
		new dld, interior;
		if( sscanf(params, "dd", dld, interior))
		{
			sendTipMessage(playerid, "U�yj /domint [dom ID] [interior] ");
			return 1;
		}
		if(interior >= 1 && interior <= MAX_NrDOM)
		{
            Dom_ChangeInt(playerid, dld, interior);
		}
		else
		{
		    sendTipMessage(playerid, "Interior od 1 do 46");
		}
	}
	return 1;
}
