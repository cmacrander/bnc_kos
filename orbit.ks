// Orbit.ks
//
// Utilities for orbital maneuvers.

@lazyglobal off.

run util.

parameter ap.

// A very primitive set of actions to raise one's apoapsis.
// Needed improvements:
// * Non-insane steering
// * Some way of calculating lead-up time, probably by:
//   - calculating delta v of the transition
//   - comparing that to ship's TWR
// * Smooth throttle up and down
// * Generality so we can raise/lower both Ap and Pe
function orbit_alter_ap {
    parameter target_ap.

    // Function will seem orbit acceptable if within  this many meters of the
    // target.
    local fudge_factor to target_ap * 0.01.  // 1% of target

    // Operate on the difference between the target
    // ap and the current ap.
    lock ap_diff to target_ap - SHIP:APOAPSIS.

    // Keep track of which sign ap_diff has initially, to protect from
    // overshooting.
    // N.B. Important to declare locally outside of the if/else, because in
    // kOS, if/else blocks have their own scope, in which the variable would
    // otherwise be trapped.
    local diff_sign to "".
    if (ap_diff >= 0) {
        set diff_sign to "positive".
    } else {
        set diff_sign to "negative".
    }

    local current_engines to util_get_staged_engines().

    if (current_engines:LENGTH = 0) {
        print "ERROR (orbit_raise_ap): No engines found.".
        return.
    }

    warpto(TIME:SECONDS + ETA:PERIAPSIS - 15).
    //wait until ETA:PERIAPSIS < 15.

    if (abs(ap_diff) < fudge_factor) {
        print "Ap already satisfactory. No burn planned.".
    } else if (ap_diff > 0) {
        print "RAISING Ap, steering to prograde.".
        lock STEERING to SHIP:PROGRADE.
    } else if (ap_diff < 0) {
        print "LOWERING Ap, steering to retrograde.".
        lock STEERING to SHIP:RETROGRADE.
    }

    wait until ETA:PERIAPSIS < 1.

    print "Burning to " + (target_ap / 1000) + "km...".
    lock THROTTLE to 1.
    until abs(ap_diff) < fudge_factor {
        // Add a failsafe, so if we overshoot the fudge factor within 1
        // physics tick, we don't keep burning past the target.
        if (diff_sign = "positive" and ap_diff < 0) {
            break.
        } else if (diff_sign = "negative" and ap_diff > 0) {
            break.
        }
    }

    print "Desired orbit reached.".
    lock THROTTLE to 0.
}
