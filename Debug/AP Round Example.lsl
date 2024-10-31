//Code used for testing. Not optimized.
integer lba_damage = 5;
default
{
    state_entry()
    {
        llSetDamage(100.0);
    }
    collision_start(integer num_detected)
    {
        llSetStatus(0x010,1);
        llSetStatus(0x001,0);
        key hit = llDetectedKey(0);
        string desc = (string)llGetObjectDetails(llDetectedKey(0),[OBJECT_DESC]);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR,ALL_SIDES,<0,0,0>,0.,PRIM_GLOW,ALL_SIDES,0.]);
        if(llSubStringIndex(desc,"LBA") != -1
        && llDetectedName(0) != llGetObjectName()) {
            integer version = (integer)llGetSubString(desc,6,6);
            integer hex=(integer)("0x" + llGetSubString(llMD5String((string)hit,0), 0, 3));
            llSay(0,(string)hex);
            llRegionSayTo(hit,hex,(string)hit+","+(string)lba_damage);
            llSetTimerEvent(.15);
        } else {
            llSay(0,"Did not meet LBA criteria");
            llDie();
        }
    }
    timer() {
        llDie();
    }
    land_collision_start(vector pos)
    {
        llSetStatus(0x010,1);
        llSetStatus(0x001,0);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR,ALL_SIDES,<0,0,0>,0.,PRIM_GLOW,ALL_SIDES,0.]);
        llDie();
    }
}
