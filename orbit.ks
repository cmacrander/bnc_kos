// Orbit.ks
//
// Utilities for orbital maneuvers.

@lazyglobal off.

run util.

// Change either one's apoapsis or periapsis.
// Needed improvements:
// * Non-insane steering
// * Some way of calculating lead-up time, probably by:
//   - calculating delta v of the transition
//   - comparing that to ship's TWR
// * Smooth throttle up and down
function orbit_alter_apsis {
    parameter apsis.  // "periapsis" or "apoapsis"
    parameter target.  // meters

    // Initialize //

    // Function will deem orbit acceptable if within  this many meters of the
    // target.
    local fudge_factor to target * 0.01.  // 1% of target

    // Calculations that vary based on selection of one apsis or the other.
    local diff to 0.
    local my_eta to 0.
    if (apsis = "apoapsis") {
        set diff to target - SHIP:APOAPSIS.
        lock my_eta to ETA:PERIAPSIS.  // Don't use 'eta', it's reserved!
    } else if (apsis = "periapsis") {
        set diff to target - SHIP:PERIAPSIS.
        lock my_eta to ETA:APOAPSIS.
    }

    // Sanity check ship's readiness for burn before starting anything.
    local current_engines to util_get_staged_engines().
    if (current_engines:LENGTH = 0) {
        print "ERROR (orbit_raise_ap): No engines found.".
        return.
    }

    // Warp to burn //

    util_relative_warp(my_eta - 15).

    // Align //

    SAS off.  // SAS on + lock STEERING = CRAZY TIME
    if (abs(diff) < fudge_factor) {
        print "Altitude already satisfactory. No burn planned.".
        return.
    } else if (diff > 0) {
        print "RAISING apsis, steering to prograde.".
        lock STEERING to SHIP:PROGRADE.
    } else if (diff < 0) {
        print "LOWERING apsis, steering to retrograde.".
        lock STEERING to SHIP:RETROGRADE.
    }

    wait until my_eta < 1.

    // Burn //

    print "Burning to " + (target / 1000) + "km...".
    lock THROTTLE to 1.

    // Define the end of the burn based on the major axis, not apoapsis or
    // periapsis height, because the location of those can flip as you raise
    // or lower their height "through" the height of the other.
    local lock major_axis to (SHIP:ORBIT:SEMIMAJORAXIS * 2).
    local target_ma to major_axis + diff.
    local current_diff to 0.

    // Standarize the sign of the difference.
    if (diff >= 0) {
        lock current_diff to target_ma - major_axis.
    } else {
        lock current_diff to major_axis - target_ma.
    }

    // Burn until the difference to the target major axis is gone.
    wait until current_diff <= 0.

    print "Desired orbit reached.".
    lock THROTTLE to 0.
    set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
}


parameter aps.
parameter tar.

clearscreen.
clear_log().
orbit_alter_apsis(aps, tar * 1000).
