//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//------------------------------------------------[ togtxda ]------------------------------------------------//
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

YCMD:togtxda(playerid, params[], help)
{
	if(togADMTXD[playerid] == 0)
	{
		togADMTXD[playerid] =1;
		sendTipMessage(playerid, "TOG: Wy��czy�e� Text'Drawy z karami"); 
	}
	else if(togADMTXD[playerid] == 1)
	{
		togADMTXD[playerid] = 0; 
		sendTipMessage(playerid, "TOG: W��czy�e� Text'Drawy z karami"); 
	}
	return 1;
}
