//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//--------------------------------------------------[ idz ]--------------------------------------------------//
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

YCMD:idz(playerid, params[], help)
{
    if(IsPlayerConnected(playerid))
    {
        if(PlayerInfo[playerid][pInjury] > 0 || PlayerInfo[playerid][pBW] > 0)
        {
            ShowPlayerInfoDialog(playerid, "Mrucznik Role Play", "{FF542E}Jeste� ranny!\n{FFFFFF}Nie mo�esz zatrzyma� animacji.");
            return 1;
        }
        ShowPlayerDialogEx(playerid, 1213, DIALOG_STYLE_LIST,"Automatyczna animacja","Pijak\nNormalny\nBabcia\nGangsta\nGangsta 2\nGarbaty\nZ broni�\nNormalny 2\nStaruszka\nDziwka\nPaker\nKobieta\nTuptu�\nNormalny 3","Akceptuj","Anuluj");    
    }
    return 1;
}
