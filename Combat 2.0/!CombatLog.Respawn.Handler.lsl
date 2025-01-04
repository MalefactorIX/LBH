integer upper;
integer lower;
string BuildEventText(string _json)//Credit to the GrandFed gang for the original function
{
    key target = (key)llJsonGetValue(_json, ["target"]);
    vector tpos=(vector)((string)llGetObjectDetails(target,[OBJECT_POS]));
    if(tpos.z<lower||tpos.z>upper)//Denies kills outside of combat arena
    {
        //llOwnerSay((string)tpos);
        return "null";
    }
    key owner = (key)llJsonGetValue(_json, ["owner"]);
    if(llVecDist(tpos,opfor)<10.0||llVecDist(tpos,defor)<10.0)//Denies kills and warns killer if they are killing too close to spawns.
    {
        if(llKey2Name(owner))llRegionSayTo(owner,0,"You are killing people too closely to a spawn location!");
        return "null";
    }
    string owner_name = llKey2Name(owner);
    //llSay(0,(string)owner);
    integer type=(integer)llJsonGetValue(_json, ["type"]);
    key rezzer = (key)llJsonGetValue(_json, ["rezzer"]);
    //Update for rez-less guns
    key source = (key)llJsonGetValue(_json, ["source"]);

    string target_name = llKey2Name(target);
    string rezzer_name = llList2String(llGetObjectDetails(rezzer, [OBJECT_NAME]), 0);
    //Update for rez-less guns
    string source_name = llKey2Name(source);
    string dmg=llJsonGetValue(_json, ["damage"]);
    string init=llJsonGetValue(_json, ["initial"]);
    if(dmg!=init)dmg=(string)llFloor((float)dmg)+" ("+(string)llFloor((float)init)+")";//Appends the attempted damage if it does not match the final damage (armor)
    else dmg=(string)llFloor((float)dmg);
    if(type==-1)
    {
        owner_name="Physics";
        rezzer_name="Newton's First Law";
    }
    else if (rezzer_name == "") rezzer_name = "UNK/EPH";
    //Update for rez-less guns
    if (rezzer_name == owner_name) rezzer_name = source_name;
    else if(owner_name=="")owner_name="Unknown";
    string text=(string)target+","+(string)owner;
    llSetText("[Last Reported Death]\n"+owner_name+" ["+rezzer_name+"] "+target_name,<1.0,1.0,1.0>,1.0);
    return text;
}
list groups=["37c791a2-07e5-e6f0-da0a-c3df8715d2cc"];//Group list for defending forces
integer auth(key id)
{
    string gid=(string)llList2Key(llGetObjectDetails(llList2Key(llGetAttachedList(id), 0), [OBJECT_GROUP]), 0);
    integer n=llListFindList(groups,[gid]);
    if(n>-1&&gid!="")return 1;//Good
    else return 0;//Bad
}
vector opfor=<229.0,30.0,1981.0>;//Opposing Forces Respawn
vector defor=<18.0,24.0,1977.0>;//Defending Forces Respawn
teleport(key id)
{
    vector pos=opfor;
    if(auth(id))pos=defor;
    llTeleportAgent(id,"",pos,<128,128,pos.z>);
}
default
{
    state_entry()
    {
        list desc=llCSV2List(llGetObjectDesc());//Ie: 0,500 sets the limit between 0 and 500m in the air
        upper=(integer)llList2String(desc,1);
        lower=(integer)llList2String(desc,0);
        llSay(0,"Upper Boundry: "+(string)upper+"\nLower Boundry: "+(string)lower);
        llListen(COMBAT_CHANNEL, "", COMBAT_LOG_ID, "");
    }
    experience_permissions(key id)
    {
        teleport(id);
    }
    experience_permissions_denied(key id, integer r)
    {
        llRegionSayTo(id,0,"An unexpected error has occurred ["+(string)r+"]");
    }
    listen(integer chan, string name, key id, string message)
    {
        list new_events = llJson2List(message);
        integer count = llGetListLength(new_events);
        integer l=llGetListLength(new_events);
        integer i;
        list event_texts;
        //llSay(0,"yay");
        while(i<l)
        {
            string json = llList2String(new_events, i);
            string event_type = llJsonGetValue(json, ["event"]);
            if (event_type == "DEATH") {
                string text = BuildEventText(json);//Generates the text string
                if(text!="null")
                {
                    list data=llCSV2List(text);
                    key target=llList2String(data,0);
                    key source=llList2String(data,1);
                    //llOwnerSay("Attempting to respawn "+llKey2Name(target));
                    if(llAgentInExperience(target)&&llAgentInExperience(source))llRequestExperiencePermissions(target,"");
                    else
                    {
                        llOwnerSay("Failed due to missing experience");
                        if(!llAgentInExperience(target))llRegionSayTo(target,0,"You need to accept the region experience to do combat here. Until then, kills and deaths will not be proceeded if they are caused to or by you.");
                        if(!llAgentInExperience(source))llRegionSayTo(source,0,"You need to accept the region experience to do combat here. Until then, kills and deaths will not be proceeded if they are caused to or by you.");
                    }
                }
                //else llOwnerSay("null");
            }
            //else llSay(0,event_type);
            ++i;
        }
    }
}
