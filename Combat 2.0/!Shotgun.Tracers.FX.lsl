//You will need to apply ribbons either via another script or in a state_entry() event. This script merely moves all the prims into position and plays impact particles and sound.
proc(list data)
{
    vector init=(vector)llList2String(data,0);
    llSetRegionPos(init);
    integer l=llGetListLength(data);
    integer i;
    list params;
    //llOwnerSay(llDumpList2String(data,";"));
    while(++i<l)
    {
        params+=[PRIM_LINK_TARGET,i+1,PRIM_POS_LOCAL,(vector)llList2String(data,i)-init];
    }
    llSetLinkPrimitiveParamsFast(1,params);
    //llOwnerSay("Movement cleared");
    while(l--)llLinkParticleSystem(l,[
        PSYS_PART_FLAGS,            PSYS_PART_EMISSIVE_MASK|PSYS_PART_FOLLOW_VELOCITY_MASK|PSYS_PART_INTERP_COLOR_MASK|PSYS_PART_INTERP_SCALE_MASK,
        PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_EXPLODE,
        PSYS_PART_START_COLOR,      ZERO_VECTOR,
        PSYS_PART_END_COLOR,      <0.2,0.2,0.2>,
        PSYS_PART_START_ALPHA,      0.5,
        PSYS_PART_END_ALPHA,        0.05,
        PSYS_PART_START_SCALE,      <0.2,0.2,0.0>,
        PSYS_PART_END_SCALE,        <1.0,1.0,0.0>,
        PSYS_PART_MAX_AGE,          0.5,
        PSYS_SRC_MAX_AGE,          0.5,
        PSYS_SRC_ACCEL,             <0.0,0.0,1.0>,
        PSYS_SRC_TEXTURE,           "e75df406-a153-7695-0f08-bbcb844987be",
        PSYS_SRC_BURST_RATE,        .1,
        PSYS_SRC_ANGLE_BEGIN,       0.0,
        PSYS_SRC_ANGLE_END,        PI,
        PSYS_SRC_BURST_PART_COUNT,  3,
        PSYS_SRC_BURST_RADIUS,      .1,
        PSYS_SRC_BURST_SPEED_MIN,   .0,
        PSYS_SRC_BURST_SPEED_MAX,   1.0]);
    //llOwnerSay("Particles Cleared");
    llSleep(0.1);
    llLinkPlaySound(-2,llGetInventoryName(INVENTORY_SOUND,llRound(llFrand(7.0))),1.0,0);
    llSleep(5.0);
    llDie();
}
default
{
    on_rez(integer p)
    {
        if(p)
        {
            llSleep(0.1);
            proc(llParseString2List(llGetStartString(),[";"],[""]));//Gun did most of the work for us.
        }
    }
}
