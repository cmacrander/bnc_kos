// Orbit.ks
//
// Utilities for orbital maneuvers.

@lazyglobal off.

run util.

// Takes altitude-based apses in meters, returns delta v.
// Based entirely on the last section of:
// http://wiki.kerbalspaceprogram.com/wiki/Tutorial:_Basic_Orbiting_(Math)
function orbit_dv_for_apsis_change {
    parameter hc1.  // altitude of apsis where burn will take place
    parameter ho1.  // altitude of apsis which will change
    parameter ho2.  // target altitude of changed apsis

    // Change from altitudes to radii.
    local rc1 to hc1 + SHIP:ORBIT:BODY:RADIUS.
    local ro1 to ho1 + SHIP:ORBIT:BODY:RADIUS.
    local ro2 to ho2 + SHIP:ORBIT:BODY:RADIUS.

    local termA to sqrt((2 * SHIP:ORBIT:BODY:MU) / rc1).
    local termB to sqrt(ro2 / (rc1 + ro2)).
    local termC to sqrt(ro1 / (rc1 + ro1)).

    return termA * (termB - termC).
}

// Assumes no change in thrust during the burn, for example from staging
// or atmospheric pressure.
function orbit_burn_time {
    parameter dv.

    local acc to SHIP:MAXTHRUST / SHIP:MASS.
    return abs(dv / acc).
}

// Change either one's apoapsis or periapsis.
function orbit_alter_apsis {
    parameter apsis.  // "periapsis" or "apoapsis"
    parameter target_altitude.  // meters

    // Initialize //

    // Function will deem orbit acceptable if within this many meters of the
    // target.
    local fudge_factor to target_altitude * 0.01.  // 1% of target

    local align_time to 15.

    // Calculations that vary based on selection of one apsis or the other.
    local apsis_eta to 0.
    local burn_altitude to 0.
    local original_altitude to 0.
    if (apsis = "apoapsis") {
        lock apsis_eta to ETA:PERIAPSIS.  // Don't use `eta`, it's reserved!
        set burn_altitude to SHIP:ORBIT:PERIAPSIS.
        set original_altitude to SHIP:ORBIT:APOAPSIS.
    } else if (apsis = "periapsis") {
        lock apsis_eta to ETA:APOAPSIS.
        set burn_altitude to SHIP:ORBIT:APOAPSIS.
        set original_altitude to SHIP:ORBIT:PERIAPSIS.
    }

    // Sanity //

    local current_engines to util_get_staged_engines().
    if (current_engines:LENGTH = 0) {
        print "ERROR (orbit_maneuver_apsis): No engines found.".
        return.
    }

    if (abs(target_altitude - original_altitude) < fudge_factor) {
        print "Altitude already satisfactory. No burn planned.".
        return.
    }

    // Maneuver //

    local dv to orbit_dv_for_apsis_change(burn_altitude, original_altitude,
                                          target_altitude).
    local maneuv to node(TIME:SECONDS + apsis_eta, 0, 0, dv).
    add maneuv.
    local burn_time to orbit_burn_time(dv).

    // Warp to burn //

    local warp_sec to (maneuv:ETA - (burn_time / 2)) - align_time.
    if (maneuv:ETA < warp_sec) {
        print "ERROR (orbit_maneuver_apsis): Not enough time to burn.".
        return.
    }
    util_relative_warp(warp_sec).

    // Align //

    SAS off.  // SAS on + lock STEERING = CRAZY TIME.
    lock STEERING to maneuv:BURNVECTOR.

    wait until maneuv:ETA <= (burn_time / 2).

    // Burn //

    print "Burning to " + (target_altitude / 1000) + "km...".
    lock THROTTLE to 1.

    wait until maneuv:ETA <= (-burn_time / 2).

    print "Desired orbit reached.".
    lock THROTTLE to 0.

    // Cleanup //

    set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
    unlock THROTTLE.
    unlock STEERING.
    remove maneuv.
    util_stabilize().
}


parameter aps.
parameter tar.
clearscreen.
clear_log().
orbit_alter_apsis(aps, tar * 1000).
