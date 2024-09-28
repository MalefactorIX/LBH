string last;
key o;
integer mode=2;//0 = Off, 1 = As hit, 2 = On death
default
{
    state_entry()
    {
        o=llGetOwner();
    }
    on_rez(integer p)
    {
        o=llGetOwner();
    }
    link_message(integer s, integer n, string m, key id)
    {
        if(n)return;
        if(m=="off")
        {
            mode=0;
            state off;//We move to a different state so we're not generating on_damage or on_death events while disabled.
        }
        else if(m=="Clamped")
        {
             llOwnerSay("Damage Detector set to report On Death");
            mode=2;
        }
        else if(m=="Normal")
        {
            llOwnerSay("Damage Detector set to report On Hit");
        }
    }
    on_damage(integer d)
    {
        string text;
        while(d--)
        {
            if(llList2Integer(llDetectedDamage(d),1)>-1)
            {
                vector vel=llDetectedVel(d);
                integer ivel;
                string rezzer=llKey2Name(llDetectedRezzer(d));
                key owner=llDetectedOwner(d);
                if(vel!=ZERO_VECTOR)ivel=llRound(llVecMag(vel));
                if(ivel)text+="["+llDetectedName(d)+"] at "+(string)ivel+"m/s";
                else text+="["+llDetectedName(d)+"]";
                if(owner==o)text+=" by yourself";
                else text+=" by "+(string)"secondlife:///app/agent/"+(string)owner+ "/about";
                if(rezzer)text+=" using ["+rezzer+"]\n";
                else text+="\n";
            }
        }
        if(text)last=text;
        if(mode==1)llOwnerSay(" \n[Damage Report]\n"+last);
    }
    on_death()
    {
        if(mode==2)llOwnerSay(" \n[Last registered hits]\n"+last);
    }
}
state off
{
    state_entry()
    {
        llOwnerSay("Damage detector disabled");
    }
    link_message(integer s, integer n, string m, key id)
    {
        if(n)return;
        if(m=="Clamped")
        {
             llOwnerSay("Damage Detector set to report On Death");
            mode=2;
            state default;
        }
        else if(m=="Normal")
        {
            llOwnerSay("Damage Detector set to report On Hit");
            state default;
        }
    }
}
