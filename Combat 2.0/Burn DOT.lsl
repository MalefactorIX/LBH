fire()
{
    llLoopSound("99f14289-b9c6-def0-9827-bbcfa74369ab",1.0);
    llParticleSystem([
PSYS_PART_FLAGS,(0
| PSYS_PART_EMISSIVE_MASK
| PSYS_PART_BOUNCE_MASK
| PSYS_PART_INTERP_COLOR_MASK
| PSYS_PART_INTERP_SCALE_MASK
),
PSYS_PART_START_COLOR,<1.00000, 0.1500000, 0.00000>,
PSYS_PART_END_COLOR,<1.00000, 0.700000, 0.25000000>,
PSYS_PART_START_GLOW,0.2,
PSYS_PART_START_ALPHA,0.50000,
PSYS_PART_END_ALPHA,0.000000,
PSYS_PART_START_SCALE,<3.00000, 3.00000, 0.00000>,
PSYS_PART_END_SCALE,<0.00000, 0.00000, 0.00000>,
PSYS_PART_MAX_AGE,2.500000,
PSYS_SRC_ACCEL,<0.00000, 0.00000, 0.80000>,
PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_ANGLE_CONE,
PSYS_SRC_TEXTURE,"8738201d-ec3d-288a-7d65-031211f9fee7",
PSYS_SRC_BURST_RATE,0.20000,
PSYS_SRC_BURST_PART_COUNT,1,
PSYS_SRC_BURST_RADIUS,0.000000,
PSYS_SRC_BURST_SPEED_MIN,0.5000000,
PSYS_SRC_BURST_SPEED_MAX,1.50000,
PSYS_SRC_MAX_AGE,0.000000,
PSYS_SRC_OMEGA,<0.00000, 0.00000, 0.00000>,
PSYS_SRC_ANGLE_BEGIN,0.20000,
PSYS_SRC_ANGLE_END,0.050000]);
}
vector tar(key id)
{
    vector pos=llList2Vector(llGetObjectDetails(id,[OBJECT_POS]),0);
    if(llGetParcelFlags(pos)&PARCEL_FLAG_ALLOW_DAMAGE)return pos;
    else
    {
        llDie();
        return ZERO_VECTOR;
    }
}
string dmgprim;
integer param;
string id;
integer flip;
integer lasthp;
default
{
    state_entry()
    {
        llParticleSystem([]);
        llStopSound();
    }
    on_rez(integer p)
    {
        if(p)
        {
            param=p;
            dmgprim=llGetInventoryName(INVENTORY_OBJECT,0);
            id=llGetStartString();
            if(llGetAgentSize(id))
            {
                llSetRegionPos(tar(id));
                fire();
                llResetTime();
                lasthp=llFloor(llGetHealth(id));
                llDamage(id,param,102);
                llSleep(0.1);
                if(llFloor(llGetHealth(id))>=lasthp)llDie();
                else llSetTimerEvent(0.2);
            }
            else llDie();
        }
    }
    timer()
    {
        if(llGetTime()>3.0)llDie();
        else
        {
            llSetRegionPos(tar(id));
            flip=!flip;
            if(flip)
            {
                integer newhp=llFloor(llGetHealth(id));
                if(newhp<lasthp)
                {
                    llDamage(id,param,5);
                    lasthp=newhp;

                }
                else llDie();
            }
        }
    }
}
