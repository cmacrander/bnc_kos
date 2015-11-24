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

// Assumes no change in thrust during the burn, for example from staging,
// atmospheric pressure, or fuel consumption.
function orbit_simple_burn_time {
    parameter dv.

    local acc to SHIP:MAXTHRUST / SHIP:MASS.
    return abs(dv / acc).
}

// Change either one's apoapsis or periapsis.
//
// Takes an align time because it seems really unlikely the computer could
// predict how nimble (or cement-trucky, or wet-noodly) your craft is.
//
// Assumes your craft is ready for time warp, engines off, etc.
function orbit_alter_apsis {
    parameter apsis.  // "periapsis" or "apoapsis"
    parameter target_altitude.  // meters
    parameter align_time.  // seconds

    // Initialize //

    // Function will deem current orbit acceptable and skip the requested
    // maneuver if within this many meters of the target.
    local already_good_enough to target_altitude * 0.01.  // 1% of target

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
        print "ERROR (orbit_alter_apsis): No engines found.".
        return.
    }

    if (abs(target_altitude - original_altitude) < already_good_enough) {
        print "Altitude already satisfactory. No burn planned.".
        return.
    }

    // Maneuver //

    local dv to orbit_dv_for_apsis_change(burn_altitude, original_altitude,
                                          target_altitude).
    local maneuv to node(TIME:SECONDS + apsis_eta, 0, 0, dv).
    add maneuv.
    local burn_time to orbit_simple_burn_time(dv).

    // Warp to burn //

    local warp_sec to (maneuv:ETA - (burn_time / 2)) - align_time.
    if (maneuv:ETA < warp_sec) {
        print "ERROR (orbit_alter_apsis): Not enough time to burn.".
        return.
    }
    util_relative_warp(warp_sec).

    // Align //

    SAS off.  // SAS on + lock STEERING = CRAZY TIME.
    lock STEERING to maneuv:BURNVECTOR.

    wait until maneuv:ETA <= (burn_time / 2).

    // Burn //

    print "Burning to " + apsis + " of " + (target_altitude / 1000) + "km...".
    lock THROTTLE to 1.

    //   During the burn, the remaining delta v in the maneuver is the
    // magnitude of the burn vector. It would be most accurate to reduce this
    // to zero.
    //   Another strategy is using orbit_simple_burn_time(), but that's based
    // on the mass of the ship at the beginning of the burn, and burning fuel
    // reduces mass, so the time will always be too long, with bigger errors
    // for long burns.
    //   Just using dv is fiddly though, because if your alignment isn't
    // perfect you might never reach zero, i.e. shoot past the target vector
    // but never _through_ it.
    //   So this tries the dv method, but uses the overly-long burn time as
    // a fail-safe.

    // The goal for this parameter is to get precise maneuvers on really long
    // burns, so for a 1000 m/s burn, try to get down to 1 m/s. Trying to hit
    // 0.01 m/s on a 10 m/s burn is obviously unrealistic, but that's what
    // the failsafe is for.
    local maneuver_precision to 0.001.

    wait until (maneuv:BURNVECTOR:MAG < dv * maneuver_precision  // precise
                or maneuv:ETA <= (-burn_time / 2)).  // failsafe

    print "...Desired orbit reached.".
    lock THROTTLE to 0.

    // Cleanup //

    set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
    unlock THROTTLE.
    unlock STEERING.
    remove maneuv.
    util_stabilize().
}

// Example of using alter apsis. Uncomment to use orbit.ks as a function.
//parameter aps.
//parameter tar.
//clearscreen.
//clear_log().
//orbit_alter_apsis(aps, tar * 1000, 20).
