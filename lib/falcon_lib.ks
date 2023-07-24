SET BOOSTER_TAG to "BOOSTER".

SET VAB_GEO to latlng(-0.097, -74.62).

SET LAUNCH_PAD_GEO to latlng(-0.0972, -74.5577).
// set LAUNCH_PAD_GEO_L to latlng(-0.0972, -74.558).

SET LANDING_ZONE_GEO to latlng(-0.0972, -74.5312).

SET tarGeo to VAB_GEO.

SET TR to addons:TR.

function gravityTurn {
    PARAMETER mH, H0.

    SET KR to 6 * 10 ^ 5.    // 坎星半径
    SET M to 5.2915793 * 10 ^ 22.   // 坎星质量
    SET mV to sqrt((constant:G * M) / (KR + mH)).    // 万有引力公式推导式
    SET k to (H0 - mH) / mV ^ 2.    // 重力转向轨道 f(x)=k(x-mV)^2 + mH 中的系数 k

    SET cV to SHIP:airspeed.

    SET pitchDegree to min(2 * k * (cV - mV), 90).  // 俯仰角


    SET vK TO .01.
    SET vecDiff TO vAng(SHIP:VELOCITY:ORBIT, heading(90, pitchDegree, 90):topvector).


    clearScreen.
    PRINT "FALCON STATUS".
    PRINT "-----------------------------------------------------------".
    PRINT "        ALTITUDE: " + SHIP:altitude.
    PRINT "       AIR SPEED: " + SHIP:airspeed.
    PRINT "  VERTICAL SPEED: " + SHIP:verticalspeed.
    PRINT "       DIRECTION: " + SHIP:direction.
    PRINT "            MASS: " + SHIP:mass.
    PRINT "      MAX THRUST: " + SHIP:maxthrust.
    PRINT "AVAILABLE THRUST: " + availableThrust.
    PRINT "         GEO POS: " + SHIP:geoposition.
    PRINT "        THROTTLE: " + throttle.
    PRINT "-----------------------------------------------------------".

    wait 0.001.

    return heading(90, pitchDegree + vecDiff * vK, 90).
}

function boosterTurnBack {
    set SHIP:control:pitch to 1.
    wait 6.
    set SHIP:control:pitch to 0.
    wait 4.
}

function boosterBackBurn {
    lock latErr to tarGeo:lat - TR:impactPos:lat.
    lock lngErr to tarGeo:lng - TR:impactPos:lng.

    lock disErr to sqrt(latErr ^ 2 + lngErr ^ 2).

    lock backVec to heading(arcTan2(lngErr, latErr), 0).

    lock bfAngleErr to vAng(SHIP:facing:vector, backVec:vector).

    lock steering to backVec.

    TOGGLE AG1.

    lock throttle to abs(80 - bfAngleErr) / 80.

    WAIT UNTIL bfAngleErr <= 40.     // 等待旋转到位

    // set tarErr to disErr.

    RCS off.

    LOCK throttle to min(disErr, 1).

    UNTIL disErr < 0.004 {
        clearScreen.
        print "------------------BOOSTER-BACK-BURN--------------------".
        print "".
        print "CONTROL PART:" + "FALCON9 STAGE 1".
        print "DIS ERR:" + disErr.
        print "VANG:" + vAng(SHIP:facing:Vector, backVec:vector).
        print "TARGET POS:" + tarGeo.
        print "LAT ERR:" + latErr.
        print "LNG ERR:" + lngErr.
        // print "TOUCH DOWN TIME:" + addons:tr:TimeTillImpact().
        print "STEERING:" + steering.
        print "".
        print "THROTTLE:" + throttle.
        print "AVAILABLE THRUST:" + availableThrust.
        print "".
        print "-------------------------------------------------------".

        wait 0.001.
    }

    lock throttle to 0.
    print "Burning ended".
    wait 1.
}

function boosterBackAdject {
    set maxAngle to 8.

    WAIT UNTIL SHIP:verticalspeed < -10.
    lock steering to TR:CorrectedVec.

    RCS ON.
    WAIT UNTIL vAng(SHIP:facing:vector, TR:CorrectedVec) < 10.
    // RCS OFF.

    set kP to -8000.
    set kI to -1000.
    set kD to -4000.

    lock latErr to tarGeo:lat - TR:impactPos:lat.
    lock lngErr to tarGeo:lng - TR:impactPos:lng.

    set PID_LAT to pidLoop(kP, kI, kD, -maxAngle, maxAngle).
    set PID_LAT:setpoint to 0.

    set PID_LNG to pidLoop(kP, kI, kD, -maxAngle, maxAngle).
    set PID_LNG:setpoint to 0.

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

    when ALT:radar <= 200 then {
        Legs ON.
    }

    when SHIP:altitude <= 60000 then {
        BRAKES ON.
        // RCS OFF.
    }

    when SHIP:altitude <= 20000 then {
        TOGGLE AG2.
        RCS ON.
        // set tarGeo to LAUNCH_PAD_GEO_L.
    }

    until SHIP:verticalSpeed >= -4 and ALT:radar <= 20 {
        set latAdjustOut to PID_LAT:update(time:seconds, latErr).
        set lngAdjustOut to PID_LNG:update(time:seconds, lngErr).

        if SHIP:verticalspeed >= -500 {
            lock steering to srfRetrograde + R(-latAdjustOut, -lngAdjustOut, 0).
        } else {
            lock steering to srfRetrograde + R(latAdjustOut, lngAdjustOut, 0).
        }

        set le to e.
        set e to tar - cur.
        set d to (e - le) / dt.
        set se to se + e * dt.
        set output to Kp * e + Ki * se + Kd * d.

        clearScreen.
        print "|-----------------BOOSTER-BACK-LANDING------------------".
        print "| ".
        print "| CONTROL PART:" + "FALCON9 STAGE 1".
        print "| TARGET GEO:" + tarGeo.
        print "| LAT ERR:" + latErr.
        print "| LNG ERR:" + lngErr.
        print "| STEERING:" + steering.
        print "| ".
        print "| THROTTLE:" + throttle.
        print "| AVAILABLE THRUST:" + availableThrust.
        print "| ".
        print "|--------------------------------------------------------".

        WAIT 0.001.
    }

    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
}