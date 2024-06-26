//------------------------------------------<< Generated source >>-------------------------------------------//
//                                                ip5                                                //
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
// Kod wygenerowany automatycznie narz�dziem Mrucznik CTL

// ================= UWAGA! =================
//
// WSZELKIE ZMIANY WPROWADZONE DO TEGO PLIKU
// ZOSTAN� NADPISANE PO WYWO�ANIU KOMENDY
// > mrucznikctl build
//
// ================= UWAGA! =================


//-------<[ include ]>-------
#include "ip5_impl.pwn"

//-------<[ initialize ]>-------
command_ip5()
{
    

    //aliases
    

    //permissions
    

    //prefix
    
}

//-------<[ command ]>-------
YCMD:ip5(playerid, params[], help)
{
    if (help)
    {
        sendTipMessage(playerid, "Wy�wietlanie 5 ostatnich adres�w IP, na kt�rych gra� gracz pod danym nickiem.");
        return 1;
    }
    //fetching params

    if(isnull(params))
    {
        sendTipMessage(playerid, "U�yj /ip5 [Nick/ID] ");
        return 1;
    }

    new offline = false;
    new giveplayer[MAX_PLAYER_NAME];
    if(sscanf(params, "r", giveplayer) || !IsPlayerConnected(giveplayer[0]))
    {
        new formatString[8];
        format(formatString, sizeof(formatString), "s[%d]", MAX_PLAYER_NAME);
        sscanf(params, formatString, giveplayer);
        offline = true;
    }
    //command body
    return command_ip5_Impl(playerid, giveplayer, offline);
}

/*
*/