//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-----------------------------------------------[ usunpozar ]-----------------------------------------------//
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

YCMD:usunpozar(playerid, params[], help)
{
	if (PlayerInfo[playerid][pAdmin] >= 15 || PlayerInfo[playerid][pAdmin] == 7 || IsAScripter(playerid))
	{
	    DeleteAllFire();
	    sendTipMessage(playerid, "Usun��e� aktywne po�ary!");
	    sendTipMessage(playerid, "Aby wywo�a� losowy po�ar wpisz /losowypozar !");
	    
	    new string[128];
        format(string, 128, "CMD_Info: /usunpozar u�yte przez %s [%d]", GetNick(playerid), playerid);
        SendCommandLogMessage(string);
        CMDLog(string);
	}
	else
	{
		noAccessMessage(playerid);
	}
	return 1;
}