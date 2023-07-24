set maxVal to 100000.
set spAlt to 33000.

set VAB_GEO to latlng(-0.097, -74.62).
set LAUNCH_PAD_GEO to latlng(-0.0972, -74.5577).
set LANDING_ZONE_GEO to latlng(-0.0972, -74.5312).

set tempGeo to LANDING_ZONE_GEO.      //Target Geographic Position

set LANDING_PAD_GEO to latlng(tempGeo:lat, tempGeo:lng - 0.0035).        //0.007

set landHeight to LANDING_PAD_GEO:TerrainHeight.

set tr to addons:tr.

clearScreen.

print "WAITING FOR THE TARGET ALTITUDE...".

wait until Ship:altitude >= spAlt.

clearScreen.
print "MECO".
// kuniverse:forcesetactivevessel(vessel("F9-firststage")).

wait 1.

tr:setTarget(LANDING_PAD_GEO).
lock throttle to 0.

clearScreen.
print "BOOSTER BACK START".

lock latErr to LANDING_PAD_GEO:lat - tr:ImpactPos:lat.
lock lngErr to LANDING_PAD_GEO:lng - tr:ImpactPos:lng.


rcs on.

toggle AG3.

wait 2.
boosterTurnBack().

lock tarVec to heading(90 - arcTan2(latErr, lngErr), 0).
lock steering to tarVec.

set tarDist to sqrt(latErr ^ 2 + lngErr ^ 2).
wait until vAng(SHIP:facing:Vector, tarVec:Vector) < 40.
wait 0.5.

rcs off.
print "Started Burning".

until sqrt(latErr ^ 2 + lngErr ^ 2) > tarDist and tarDist < 1.5 {
    set tarDist to sqrt(latErr ^ 2 + lngErr ^ 2).

    set throttleVal to min(1, tarDist).
    lock throttle to throttleVal.

    if tarDist > 0.001 {
        set tempVec to tarVec.
    }

    lock steering to tempVec.

    clearScreen.
    print "------------------BOOSTER-BACK-BURN--------------------".
    print "".
    print "CONTROL PART:" + "FALCON9 STAGE 1".
    print "TAR DIST:" + tarDist.
    print "VANG:" + vAng(SHIP:facing:Vector, tarVec:Vector).
    print "TARGET POS:" + LANDING_PAD_GEO.
    if tr:HasImpact() = true {
        print "IMPACT POS:" + tr:impactPos().
    }
    print "LAT ERR:" + latErr.
    print "LNG ERR:" + lngErr.
    // print "TOUCH DOWN TIME:" + addons:tr:TimeTillImpact().
    print "STEERING:" + steering.
    print "".
    print "THROTTLE:" + throttleVal.
    print "AVAILABLE THRUST:" + availableThrust.
    print "CURRENT GEOPOSITION:" + SHIP:geoposition.
    print "".
    print "-------------------------------------------------------".

    wait 0.001.
}

lock throttle to 0.
print "Burning ended".
wait 1.
// rcs on.

// lock steering to tr:CorrectedVec.
// wait until vAng(SHIP:facing:vector, tr:CorrectedVec) < 15.

rcs off.

wait until SHIP:verticalspeed < -20.

// rcs on.

// wait until SHIP:verticalSpeed <= 0.

set Kp to 0.008.
set Ki to 0.00.
set Kd to 0.00144.

set e to 0.
set le to 0.
set se to 0.

set d to 0.

set tar to 20.
set output to 0.
lock cur to alt:radar.
lock throttle to max(output, 0).

set dt to 0.001.

when ALT:RADAR <= 60000 then {
    Toggle AG1.
    // rcs on.
}

when SHIP:altitude <= 20000 then {
    toggle AG4.
}

when ALT:RADAR <= 200 then {
    Toggle AG2.
}

// when SHIP:verticalspeed >= -20 and ALT:RADAR <= 600 then {
//     lock steering to UP.
// }

SET PITCHS TO PIDLOOP(-7000, -1000, -7000, -8, 8).
SET PITCHS:SETPOINT TO 0.

SET YAWS TO PIDLOOP(-7000, -1000, -7000, -8, 8).
SET YAWS:SETPOINT TO 0.

until SHIP:verticalspeed >= -4 and ALT:radar <= 20{
    set le to e.
    set e to tar - cur.
    set d to (e - le) / dt.
    set se to se + e * dt.
    set output to Kp * e + Ki * se + Kd * d.

    

    clearScreen.
    print "----------------BOOSTER-BACK-LANDING------------------".
    print "".
    print "CONTROL PART:" + "FALCON9 STAGE 1".
    print "TAR DIST:" + tarDist.
    print "VANG:" + vAng(SHIP:facing:Vector, tarVec:Vector).
    print "TARGET GEO:" + LANDING_PAD_GEO.
    if tr:hasimpact() = true {
        print "IMPACT POS:" + tr:impactPos().
    }
    print "LAT ERR:" + latErr.
    print "LNG ERR:" + lngErr.
    print "STEERING:" + steering.
    print "".
    print "THROTTLE:" + throttleVal.
    print "AVAILABLE THRUST:" + availableThrust.
    print "CURRENT GEO:" + SHIP:geoposition.
    print "".
    print "-------------------------------------------------------".

    if SHIP:verticalspeed <= -400 {
        lock steering to srfRetrograde + R(PITCHS:update(time:seconds, latErr), YAWS:update(time:seconds, lngErr), 0).
    } else if ALT:radar >= 200 {
        lock steering to tr:CorrectedVec.
    } else if ALT:radar < 200 {
        lock latErr to 0.
        lock lngErr to 0.
        lock steering to heading(90, 90).
    }

    wait 0.001.
    clearScreen.
}

lock throttle to 0.
set ship:control:pilotmainthrottle to 0.