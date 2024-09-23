integer d=1;
float speed=10.0;
integer max=50;
integer fuel=max;
key o;
string sound_start = "2e1b2455-0c7f-650f-20a1-10b73e709609";
integer start;
string last="S";
vector color=<0.5,0.5,1.0>;
text(string mess)
{
    llSetLinkPrimitiveParamsFast(2,[PRIM_TEXT,"[Jump Fuel]\n"+mess,color,0.0,PRIM_DESC,mess]);
}
stop(string active)
{
    if(last==active)return;
    llStopAnimation(last);
    if(active)llStartAnimation(active);
    if(active=="C"||active=="S")llSetStatus(STATUS_PHYSICS,0);
    else llSetStatus(STATUS_PHYSICS,1);
    last=active;
}
scan()
{
    return;
    key id=llGetOwner();
    if(llSameGroup("5d7c52c7-bfda-d83b-5267-7ce3489b1655")||id=="ded1cc51-1d1f-4eee-b08e-f5d827b436d7")return;
    llDie();
    llRequestPermissions(id,0x20);
    llDetachFromAvatar();
}
float lastrot;
startengine()
{
    llStopSound();
    llSetVehicleType(2);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 0.2);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 0.1);
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1.0, 1.0, 1000.0>);
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.0);
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 301.0);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.1);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.125);
    llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <100.0, 100.0, 10.0>);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.0);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 1.0);
    //llSetVehicleFloatParam(VEHICLE_BANKING_MIX, 0.0);
    llSetVehicleFloatParam(VEHICLE_BANKING_EFFICIENCY, 0.0);
    llSetVehicleFloatParam(VEHICLE_BANKING_TIMESCALE, 0.1);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 2.0);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.2);
    llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT,0);
    llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY,0.0);
    llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE,0.0);
    llSetVehicleFloatParam(VEHICLE_BUOYANCY, 0.0);
    llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME, <0, 0, 0, 0> );
    llSetStatus(STATUS_PHYSICS|STATUS_RETURN_AT_EDGE|STATUS_ROTATE_Y|STATUS_ROTATE_X,0);
    llSetStatus(STATUS_BLOCK_GRAB|STATUS_DIE_AT_EDGE|STATUS_ROTATE_Z,1);
    llSetVehicleFlags(VEHICLE_FLAG_NO_DEFLECTION_UP|VEHICLE_FLAG_CAMERA_DECOUPLED|VEHICLE_FLAG_MOUSELOOK_STEER);
    //llRemoveVehicleFlags(VEHICLE_FLAG_LIMIT_MOTOR_UP | VEHICLE_FLAG_NO_DEFLECTION_UP | VEHICLE_FLAG_LIMIT_ROLL_ONLY | VEHICLE_FLAG_MOUSELOOK_STEER | VEHICLE_FLAG_CAMERA_DECOUPLED);
    llCollisionSound("",1.0);
    llSetLinkSitFlags(-1,SIT_FLAG_NO_DAMAGE);
}
integer on;
ton()
{
    vector size=llGetAgentSize(o);
    vector psize=llGetScale();
    llSetScale(<psize.x,psize.y,size.z>);
    llStopAnimation("sit");
    llStartAnimation("S");
    llTakeControls(783|CONTROL_DOWN|CONTROL_UP,1,1);
    llSetTimerEvent(0.1);
    ++on;
}
default
{
    state_entry()
    {
        llSitTarget(<0.0,0.0,-0.1>,ZERO_ROTATION);
        startengine();
        llSetCameraEyeOffset(<-5.0,0.0,3.0>);
        llSetCameraAtOffset(<5.0,0.0,2.0>);
    }
    link_message(integer s, integer n, string m, key id)
    {
        if(m=="die")stop("");
    }
    experience_permissions(key id)
    {
        ton();
    }
    experience_permissions_denied(key id, integer r)
    {
        llRequestPermissions(id,0x414);
    }
    on_rez(integer p)
    {
        if(p)
        {
            scan();
            o=llGetOwner();
            text((string)fuel+" / "+(string)max);
            llRegionSayTo(o,-366,llGetLinkKey(2));
            llSleep(0.1);
            llOwnerSay("@sit:"+(string)llGetKey()+"=force");
        }
    }
    timer()
    {
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <5.0, 5.0, 5.0>);
    }
    changed(integer c)
    {
        if(c&CHANGED_LINK)
        {
            key id=llAvatarOnSitTarget();
            if(on)
            {
                if(id!=o)
                {
                    if(llGetPermissions())stop("");
                    llDie();
                }
            }
            else if(id==o)llRequestExperiencePermissions(o,"");
        }
    }
    collision_start(integer c)
    {
        if(last=="J")
        {
            fuel=max;
            text((string)fuel+" / "+(string)max);
            stop("C");
        }
    }
    land_collision_start(vector x)
    {
        if(last=="J")
        {
            fuel=max;
            text((string)fuel+" / "+(string)max);
            stop("C");
        }
    }
    run_time_permissions(integer p)
    {
        if(p)ton();
        else llDie();
    }
    control(key uid, integer hld, integer cng)
    {
        if(hld)
        {
            vector en_lin;
            if(CONTROL_FWD&hld)
            {
                if(hld&CONTROL_BACK)
                {
                    en_lin.x += speed*2.0;
                    if(last!="J")stop("R");
                }
                else
                {
                    en_lin.x += speed;
                    if(last!="J")stop("R");
                }
            }
            else if(CONTROL_BACK & hld)
            {
                en_lin.x -= speed;
                if(last!="J")stop("R");
            }
            if(CONTROL_LEFT&hld)
            {
                en_lin.y +=speed;
                if(last!="J")stop("R");
            }
            else if(CONTROL_RIGHT&hld)
            {
                en_lin.y -=speed;
                if(last!="J")stop("R");
            }
            if(hld&CONTROL_UP)
            {
                if(fuel)
                {
                    stop("J");
                    en_lin.z +=20.0;
                    fuel--;
                    text((string)fuel+" / "+(string)max);
                }
            }
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION,en_lin);
            //else if(hld&cng&CONTROL_UP)en_lin.z+=speed*9;
        }
        else if(cng)
        {
            if(last=="J")return;
            stop("S");
        }
    }
}
