string cver="LABSv1.0";//Current script version
//LABS=Light Armor Body System
string keyvalue="STRATUMWEAPONAUTH";//Name of experience key that stores version list
key qid;//Current dataserver query
//The actual code
integer mhp=100;//How much damage the armor can take before no longer providing support
integer hp=mhp;
float reduct=0.5;//Value 0 to 1 that indicates how much damage should be reduced by
updatetext()
{
    llSetLinkPrimitiveParamsFast(-4,[PRIM_TEXT,
        "[Light CS2 Armor]\n "+(string)hp+" / "+(string)mhp+
        "\nReduction: "+(string)llFloor(100.0*reduct)+"%",
        <1.0,1.0,1.0>,0.5]);
}
default
{
    state_entry()
    {
        qid=llReadKeyValue(keyvalue);
    }
    attach(key id)
    {
        if(id)llResetScript();
    }
    on_damage(integer d)//https://youtu.be/Rqw4z1nJ5W4?si=L4Lfc8SRSRyv_N3x
    {
        if(hp<1)return;//Do not do stuff if the armor is broken
        while(d--&&hp>0)//Note: This runs the list backwards
        {
            list damage=llDetectedDamage(d);
            integer type=llList2Integer(damage, 1);
            //curamt,type,orgamt
            if(type==DAMAGE_TYPE_IMPACT)llAdjustDamage(d,0);
            else if(type)return;//If type is not 0, don't change stuff
            else
            {
                integer newamt=llFloor(llList2Integer(damage,0)*reduct);
                if(newamt>0)
                {
                    llAdjustDamage(d,newamt);
                    hp-=newamt;
                }
            }
        }
        if(hp<0)hp=0;//Prevents HP from reporting negative values
    }
    final_damage(integer d)
    {
        updatetext();//Once all damage is processed, update text
    }
    on_death()
    {
        hp=mhp;
        updatetext();
    }
    dataserver(key id, string data)
    {
        if(id!=qid)return;
        else if((integer)llGetSubString(data,0,0))
        {
            if(llSubStringIndex(data,cver)>-1)
            {
                llOwnerSay("Version is up to date!");
                hp=mhp;
                updatetext();
            }
            else
            {
                llOwnerSay("[ERROR] Item is not up to date or is no longer supported. Please grab the latest copy where available");
                state off;
            }
        }
        else
        {
            llOwnerSay("Startup Failed due to an experience error ["+llGetSubString(data,2,-1)+"]");
            state off;
        }
    }
}
state off
{
    on_rez(integer p)
    {
        llResetScript();
    }
}
