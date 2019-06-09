//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-----------------------------------------------[ adajrange ]-----------------------------------------------//
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
Komenda pozwalaj�ca nada� rang� dla innego ID - stworzona dla admin�w z wysokim LVL lub adm. technicznych. 	
*/

YCMD:adajrange(playerid, params[], help)
{
    if(IsAHeadAdmin(playerid) || IsAScripter(playerid))
    {
        new giveplayerid, rankValue, string[256]; 
        if(sscanf(params, "k<fix>d", giveplayerid, rankValue))
        {
            sendTipMessage(playerid, "U�yj /adajrange [ID/CZʌ�_NICKU] [RANGA]"); 
            return 1;
        }
        if(IsPlayerConnected(playerid))
        {
            if(IsPlayerConnected(giveplayerid))
            {
                if(GetPlayerFraction(giveplayerid) != 0 || GetPlayerOrg(giveplayerid) != 0)
                {

                    if(strlen(FracRang[GetPlayerFraction(giveplayerid)][rankValue]) < 1)
                    {
                        sendErrorMessage(playerid, "Ta ranga nie jest stworzona!"); 
                        return 1;
                    } 
                    format(string, sizeof(string), "AdmCmd: %s [%d] da� %s [%d] rang� %d z poprzedniej rangi %d [w %d]", 
                    GetNick(playerid), 
                    playerid,
                    GetNick(giveplayerid),
                    giveplayerid,
                    rankValue, 
                    PlayerInfo[giveplayerid][pRank], 
                    GetPlayerFraction(giveplayerid)); 
                    SendMessageToAdmin(string, COLOR_RED);
                    format(string, sizeof(string), "Admin %s zmieni� tw�j stopie� z %d na %d", GetNick(playerid), PlayerInfo[giveplayerid][pRank], rankValue); 
                    sendTipMessage(giveplayerid, string); 
                    PlayerInfo[giveplayerid][pRank] = rankValue;
                    return 1;
                }
                else
                {
                    return sendErrorMessage(playerid, "Ten gracz nie ma �adnej frakcji i organizacji!"); 
                }
            }
            else
            {
                return sendErrorMessage(playerid, "Nie ma takiego gracza"); 
            }
        }
    }
    else
    {
        return noAccessMessage(playerid); 
    }
    
    return 1;
}