//-----------------------------------------------<< Source >>------------------------------------------------//
//                                                  discord                                                  //
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
// Autor: skTom
// Data utworzenia: 04.05.2019
//Opis:
/*
	Modu� ��cz�cy gamemod z Mrucznikowym Discordem.
*/

//

//-----------------<[ Callbacki: ]>-----------------
//-----------------<[ Funkcje: ]>-------------------
LoadDiscordChannels()
{
    new type, org_id, channel_id[64];
	new Cache:result = mysql_query(mruMySQL_Connection, "SELECT `type`, `org_id`, `channel_id` FROM `mru_discord` ORDER BY `id` ASC");
    if(cache_is_valid(result))
	{
		for(new i; i < cache_num_rows(); i++)
		{
			cache_get_value_index_int(i, 0, type);
			cache_get_value_index_int(i, 1, org_id);
			cache_get_value_index(i, 2, channel_id);
			if(type == 1) //frakcja
			{
				g_FracChannel[org_id] = DCC_FindChannelById(channel_id);
			}
			else //rodzina
			{
				g_OrgChannel[org_id] = DCC_FindChannelById(channel_id);
			}
		}
		cache_delete(result);
	}
    print("Wczytano kana�y discord");
}
DiscordConnectInit()
{
	g_GSLSLOGChannelId=DCC_FindChannelById("723216208165601321"); // GS Los Santos log
	g_GSCMLOGChannelId=DCC_FindChannelById("723216292081041408"); // GS Commerce log
	g_GSWFLOGChannelId=DCC_FindChannelById("723216357835145376"); // GS Willowfield log
	g_SanNewsChannelId=DCC_FindChannelById("696491963582513272"); //ig-san-news
	g_AdminChannelId=DCC_FindChannelById("696501357208797214"); //ig-admin
	g_ReportChannelId=DCC_FindChannelById("697009695495422012"); //ig-report

	LoadDiscordChannels();
	return 1;
}
SendDiscordMessage(channel, message[])
{
	new dest[512];
	utf8encode(dest, message);
	switch(channel)
	{
		case 0:
		{
			DCC_SendChannelMessage(g_SanNewsChannelId, dest); // #ig-san-newsxd
		}
		case 1:
		{
			DCC_SendChannelMessage(g_AdminChannelId, dest); // #ig-admin-chat
		}
		case 2:
		{
			DCC_SendChannelMessage(g_ReportChannelId, dest); // #ig-report
		}
		case 3:
		{
			DCC_SendChannelMessage(g_GSLSLOGChannelId, dest); // #gunshop-los-santos
		}
		case 4:
		{
			DCC_SendChannelMessage(g_GSCMLOGChannelId, dest); // #gunshop-commerce
		}
		case 5:
		{
			DCC_SendChannelMessage(g_GSWFLOGChannelId, dest); // #gunshop-willowfield
		}
	}
	return 1;
}

SendDiscordFracMessage(fractionid, message[])
{
	new dest[512];
	utf8encode(dest, message);
	DCC_SendChannelMessage(g_FracChannel[fractionid], dest);

	return 1;
}
SendDiscordOrgMessage(orgid, message[])
{
	if(_:g_OrgChannel[orgid] == 0) return 1;

	new dest[512];
	utf8encode(dest, message);
	DCC_SendChannelMessage(g_OrgChannel[orgid], dest);

	return 1;
}
public DCC_OnMessageCreate(DCC_Message:message)
{
	new DCC_Channel:channel, DCC_User:author, messageText[MAX_MESSAGE_LENGTH];
	DCC_GetMessageChannel(message, channel);
	DCC_GetMessageAuthor(message, author);
	DCC_GetMessageContent(message, messageText);

	new bool:IsBot;
	DCC_IsUserBot(author, IsBot);
	if(channel == g_AdminChannelId && IsBot == false)
	{
		new user_name[32 + 1],str[MAX_MESSAGE_LENGTH], dest[MAX_MESSAGE_LENGTH];
		DCC_GetUserName(author, user_name);
		format(str,sizeof(str), "[DISCORD] %s: %s",user_name, messageText);
		utf8decode(dest, str);
		strreplace(dest,"%","#");
		SendAdminMessage(0xFFC0CB, dest);
		return 1;
	}
	for(new i=0;i<MAX_ORG;i++)
    {
		if(channel == g_OrgChannel[i] && IsBot == false) 
		{
			new user_name[32 + 1],str[128],dest[128];
			DCC_GetUserName(author, user_name);
			format(str,sizeof(str), "[DISCORD] %s: %s", user_name, messageText);
			utf8decode(dest, str);
			strreplace(dest,"%","#");
			SendNewFamilyMessage(i, TEAM_AZTECAS_COLOR, dest);
			return 1;
		}
    }
	for(new i=0;i<MAX_FRAC;i++)
	{
		if(channel == g_FracChannel[i] && IsBot == false) 
		{
			new user_name[32 + 1],str[MAX_MESSAGE_LENGTH],dest[MAX_MESSAGE_LENGTH];
			DCC_GetUserName(author, user_name);
			format(str,sizeof(str), "[DISCORD] %s: %s",user_name, messageText);
			utf8decode(dest, str);
			strreplace(dest,"%","#");
			if(0 < i <= 4 || i == 11 || i == 7 || i == 17)
			{
				SendRadioMessage(i, TEAM_BLUE_COLOR, dest);
			}
			else 
			{
				SendFamilyMessage(i, TEAM_AZTECAS_COLOR, dest);
			}
			return 1;
		}
	}
	return 0;
}


//-----------------<[ Timery: ]>-------------------
//------------------<[ MySQL: ]>--------------------

//end