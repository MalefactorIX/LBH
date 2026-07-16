# The Rate of Fire throttle
aka, the infamous "rez queue". There is a server-side limit to how many objects or 'rez calls' an avatar's scripted attachments can spawn before the region enacts a restriction. 
This restriction freezes all scripts for attachments or objects attempting to spawn additional objects. It should be noted that ESTATE MANAGERS (confirmed) and potentially land moderation (needs more testing) are NOT affected by this restriction within the regions they manage.

This restriction is separate from global rezqueue but is part of the same system. The global rezqueue is triggered during the same time window that this restriction is imposed against avatars, however is it generally shorter than the targetted restrictions in duration.
The throttle sits around 1800 to 2000 RPM (30 to 33 calls per second) under ideal conditions, but it is affected by latency and region load. It is possible to easily hit the limit at 1000RPM during high region load or activity, and considerably easier the higher the RPM of the weapon beyond this.
The restriction is applied to all attachments so long as the avatar continues to exceed the limit. Keep weapons around 600 to 750 RPM will make it so it is rare it hit these conditions consistently, as well as shorten the duration of any such incident due to the low overall rate of rezzing. That said, duration is largely dependent on how high the average rez-calls are and function is restored once the avatar drops below the acceptable limit. It is likely calculated in the same way script-time is.

Since 2016, most of my weapons have been hitscan and thus rarely hit this limit. Even as I transitioned back to physical rounds, my guns rarely exceed 600RPM due to this reason among others.

# Enduring effects
Post-Combat 2.0, the need to have individual spawn parcels has become obsolete. The same applies to changing ideology in regards to vehicle respawning.
In the case of avatars, functions like llGetHealth allow us to more actively monitor a target's health state and prevent blackscreening. The same *should* be true for vehicles but in practice has been inconsistent. 
More effort and coordination will need to be made to prevent objects from improperly damaging vehicles or avatars past the kill-point.
