//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//------------------------------------------------[ kajdanki ]-----------------------------------------------//
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

YCMD:kajdanki(playerid, params[], help)
{
    if(IsPlayerConnected(playerid))
    {
        if(IsACop(playerid) || (IsABOR(playerid) && PlayerInfo[playerid][pRank] >= 2))
        {
            new giveplayerid;
            if(sscanf(params, "k<fix>", giveplayerid))
            {
                sendTipMessage(playerid, "U�yj /kajdanki [ID_GRACZA]");
                return 1;
            }

            if(!IsPlayerConnected(giveplayerid))
            {
                sendTipMessage(playerid, "Nie ma takiego gracza");
                return 1;
            }

            if(Kajdanki_Uzyte[playerid] != 1)
            {
                if(IsACop(playerid))
                {
                    if(OnDuty[playerid] == 0)
                    {
                        sendErrorMessage(playerid, "Nie jeste� na s�u�bie!");
                        return 1;
                    }
                }

                if(Spectate[giveplayerid] != INVALID_PLAYER_ID)
                {
                    sendTipMessage(playerid, "Jeste� zbyt daleko od gracza");
                    return 1;
                }

                if(GetDistanceBetweenPlayers(playerid,giveplayerid) < 5)
                {
                    if(GetPlayerState(playerid) == 1 && GetPlayerState(giveplayerid) == 1)
                    {
                        if(Kajdanki_JestemZakuty[giveplayerid] == 0)
                        {
                            new string[128];
                            if(PlayerInfo[giveplayerid][pBW] >= 1 || PlayerInfo[giveplayerid][pInjury] >= 1)
                            {
                                //Wiadomo�ci
                                format(string, sizeof(string), "* %s docisn�� do ziemi nieprzytomnego %s i sku� go.", GetNick(playerid, true), GetNick(giveplayerid, true));
                                ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                                format(string, sizeof(string), "Dzi�ki szybkiej interwencji uda�o Ci si� sku� %s.", GetNick(giveplayerid, true));
                                SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
                                sendTipMessageEx(giveplayerid, COLOR_BLUE, "Jeste� nieprzytomny - policjant sku� ci� bez wi�kszego wysi�ku.");

                                //czynno�ci
                                CuffedAction(playerid, giveplayerid);
                            }
                            else if(GetPlayerSpecialAction(giveplayerid) == SPECIAL_ACTION_DUCK)
                            {
                                //Wiadomo�ci
                                format(string, sizeof(string), "* %s dociska do ziemi %s, a nast�pnie zakuwa go w kajdanki.", GetNick(playerid, true), GetNick(giveplayerid, true));
                                ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                                format(string, sizeof(string), "Sku�e� %s.", GetNick(giveplayerid, true));
                                SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
                                sendTipMessageEx(giveplayerid, COLOR_BLUE, "Le�a�e� na ziemi - policjant sku� ci� bez wi�kszego wysi�ku.");

                                //czynno�ci
                                CuffedAction(playerid, giveplayerid);
                            }
                            else
                            {
                                format(string, sizeof(string), "* %s wyci�ga kajdanki i pr�buje je za�o�y� %s.", GetNick(playerid, true),GetNick(giveplayerid, true));
                                ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                                ShowPlayerDialogEx(giveplayerid, 98, DIALOG_STYLE_MSGBOX, "Aresztowanie", "Policjant chce za�o�y� ci kajdanki, je�li osacza ci� niedu�a liczba policjant�w mo�esz spr�bowa� si� wyrwa�\nJednak pami�taj je�li si� wyrwiesz i jeste� uzbrojony policjant ma prawo ci� zabi�. \nMo�esz tak�e dobrowolnie podda� si� policjantom.", "Poddaj si�", "Wyrwij si�");
                                Kajdanki_KtoSkuwa[giveplayerid] = playerid;
                                //Kajdanki_Uzyte[giveplayerid] = 1;
                                SetTimerEx("UzyteKajdany",30000,0,"d",giveplayerid);
                            }
                        }
                        else
                        {
                            new string[128];
                            format(string, sizeof(string), "* Zosta�e� rozkuty przez %s.", GetNick(playerid));
                            SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
                            format(string, sizeof(string), "* Rozku�e� %s.", GetNick(giveplayerid));

                            UnCuffedAction(playerid, giveplayerid);
                        }
                    } else
                    {
                        sendErrorMessage(playerid, "�aden z was nie mo�e by� w wozie!");
                    }
                } else
                {
                    sendTipMessage(playerid, "Jeste� zbyt daleko od gracza");
                }
            } else
            {
                if(GetDistanceBetweenPlayers(playerid,giveplayerid) < 5)
                {
                    UnCuffedAction(playerid, giveplayerid);
                }
                else
                {
                    sendTipMessage(playerid, "Jeste� zbyt daleko od gracza kt�rego sku�e�.");
                }
                return 1;
            }
        } else
        {
            sendTipMessage(playerid, "Nie posiadasz kajdanek");
        }
    }
    return 1;
}
