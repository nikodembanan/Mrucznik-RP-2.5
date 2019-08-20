//-----------------------------------------------<< MySQL >>-------------------------------------------------//
//                                             player_attachments                                            //
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
// Autor: Mrucznik
// Data utworzenia: 10.08.2019
//Opis:
/*
	Modu� odpowiedzialny za zarz�dzanie obiektami przyczepialnymi do gracza.
*/

//

//------------------<[ MySQL: ]>--------------------
PlayerAttachments_Create(playerid, itemid)
{
    new str[512];
    format(str, sizeof(str), "INSERT INTO `mru_playeritems` (`model`, `UID`, `bone`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `sz`, `sy`, `sz`)"\
					 " VALUES ('%d', '%d', '%d', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f')", 
		PrzedmiotyPremium[itemid][Model], 
		PlayerInfo[playerid][pUID], 
		/*TODO: PrzedmiotyPremium[itemid][bone]*/ 2,
		0.0, 0.0, 0.0,
		0.0, 0.0, 0.0,
		1.0, 1.0, 1.0
	);
    mysql_query(str);
    new id = mysql_insert_id();

	map_add(MAttachedItems[playerid], PrzedmiotyPremium[itemid][Model], true);
    return id;
}

PlayerAttachments_Remove(playerid, model)
{
    new str[256];
    format(str, sizeof(str), "DELETE FROM mru_playeritems WHERE `uid`=%d AND `model`='%d'", PlayerInfo[playerid][pUID], model);
    mysql_query(str);
	map_remove(MAttachedItems[playerid], model);
}

PlayerAttachments_LoadItems(playerid)
{
	new str[256], model, bone, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:sx, Float:sy, Float:sz, bool:active;
    format(str, sizeof(str), "SELECT `model`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `sx`, `sy`, `sz`, `active`,`bone` FROM `mru_playeritems` WHERE `UID`='%d'", PlayerInfo[playerid][pUID]);
    mysql_query(str);
    mysql_store_result();
    while(mysql_fetch_row_format(str, "|"))
    {
        sscanf(str, "p<|>dfffffffffdd", model, x, y, z, rx, ry, rz, sx, sy, sz, active, bone);
        map_add(MAttachedItems[playerid], model, active);
		if(active)
		{
			AttachPlayerItem(playerid, model, bone, x, y, z, rx, ry, rz, sx, sy, sz);
		}
    }
    mysql_free_result();
}

PlayerAttachments_LoadItem(playerid, model)
{
	new str[256], bone, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:sx, Float:sy, Float:sz, bool:active, index = -1;
	format(str, sizeof(str), "SELECT `x`, `y`, `z`, `rx`, `ry`, `rz`, `sx`, `sy`, `sz`, `active`,`bone` FROM `mru_playeritems` WHERE `UID`='%d' AND `model`='%d'", 
		PlayerInfo[playerid][pUID],
		model
	);
    mysql_query(str);
    mysql_store_result();
    if(mysql_fetch_row_format(str, "|"))
    {
        sscanf(str, "p<|>fffffffffdd", x, y, z, rx, ry, rz, sx, sy, sz, active, bone);
        map_add(MAttachedItems[playerid], model, active);
		if(active)
		{
			index = AttachPlayerItem(playerid, model, bone, x, y, z, rx, ry, rz, sx, sy, sz);
		}
    }
    mysql_free_result();
    return index;
}

PlayerAttachments_UpdateItem(playerid, model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, bone, active) {
    new str[256];
    format(str, sizeof(str), "UPDATE mru_playeritems SET `bone`='%d', `x`='%f',`y`='%f',`z`='%f', `rx`='%f',`ry`='%f',`rz`='%f', `active`='%d' WHERE `uid`='%d' AND model='%d'", 
		bone, x,y,z,rx,ry,rz, active, PlayerInfo[playerid][pUID], model);
    mysql_query(str);
    return 1;
}

PlayerAttachments_SetActive(playerid, model, active) {
    new str[256];
    format(str, sizeof(str), "UPDATE mru_playeritems SET `active`='%d' WHERE `uid`='%d' AND model='%d'", 
		active, PlayerInfo[playerid][pUID], model);
    mysql_query(str);
    return 1;
}

//end