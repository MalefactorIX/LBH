//PROOF OF CONCEPT. DO NOT USE AS IT WILL LIKELY NOT WORK
integer random;//Pick a random spawn?
teleport(vector pos)
{
    llTeleportAgent(o,"",pos,pos+<5.0,0.0,0.0>*llGetRot());
}
key o;//owner key
key qid;//Tracks dataserver requests
default
{
    state_entry()
    {
        o=llGetOwner();
        random=(integer)llLinksetDataRead("Rando");
        qid=llReadKeyValue(llGetRegionName()+"_RESPAWNLIST");
    }
    on_rez(integer c)
    {
        llResetScript();
    }
    changed(integer c)
    {
        if(c&CHANGED_REGION)
        {
            llLinksetDataDelete("RespawnList");//List we have no longer applies if we switch regions
            llLinksetDataDelete("RespawnChoice");//No longer applies if we switch regions
            qid=llReadKeyValue(llGetRegionName()+"_RESPAWNLIST");//Check if new region has a respawnlist
        }
    }
    dataserver(key id, string data)
    {
        //Store data in this format: name;vector, name;vector, name;vector,...
        //First entry should be the default spawn for all newcomers.
        if(id!=qid)return;
        else if((integer)llGetSubString(data,0,0))
        {
            data=llGetSubString(data,2,-1);
            llLinksetDataWrite("RespawnList",data);
            llOwnerSay("Respawn list updated: "+(string)llGetListLength(llCSV2List(data))+" entries available");
            if(!llAgentInExperience(o))llOwnerSay("[WARNING]\nYou must join the experience in order to use this item!");
        }
        else 
        {
            llOwnerSay("[ERROR] Could not load due to an experience error: "+llToUpper(llGetExperienceErrorMessage((integer)llGetSubString(data,2,-1))));
            state off;
        }
    }
    on_death()
    {
        if(llAgentInExperience(o))llRequestExperiencePermissions(o,"");
        //Don't run the code if the agent has not granted experience permissions
    }
    experience_permissions(key id)
    {
        list spawns=llCSV2List(llLinksetDataRead("RespawnList"));
        if(random)
        {
            integer l=llGetListLength(spawns);
            if(l<1)return;//Do not attempt to respawn via script if there are no stored spawn locations
            l=llFloor(llFrand(l));
            string spawn=llList2String(spawns,l);
            spawns=llParseString2List(spawn,[";"],[""]);//Breaks up the name and vector
            llOwnerSay("Respawning at "+llList2String(spawns,0));
            teleport((vector)llList2String(spawns,1));
        }
        else
        {
            //Write a dialog for this or make another script do it idk
            list newspawns=llCSV2List(llLinksetDataRead("RespawnChoice"));//RespawnChoice already has the parsing done.
            if(llGetListLength(newspawns)<1&&llGetListLength(spawns)>0)//No/Invalid spawn choice but we have a list
            {
                string spawn=llList2String(spawns,0);//Pick the first on in the list as the default spawn
                newspawns=llParseString2List(spawn,[";"],[""]);//Breaks up the name and vector
                llOwnerSay("No spawn location set. Respawning at "+llList2String(newspawns,0));
            }
            teleport((vector)llList2String(newspawns,1));
        }
    }
}
state off
{
    changed(integer c)
    {
        if(c&CHANGED_REGION)llResetScript();//Check and see if the new region has the experience.
    }
    on_rez(integer p)
    {
        llResetScript();
    }
}
