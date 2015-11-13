// Orbit.ks
//
// Utilities for orbital maneuvers.

@lazyglobal off.

run util.

// A very primitive set of actions to raise one's apoapsis.
// Needed improvements:
// * Non-insane steering
// * Some way of calculating lead-up time, probably by:
//   - calculating delta v of the transition
//   - comparing that to ship's TWR
// * Smooth throttle up and down
// * Generality so we can raise/lower both Ap and Pe
function orbit_raise_ap {
    parameter target_ap.

    local current_engines to util_get_current_engines().

    if (current_engines:LENGTH = 0) {
        print "ERROR (orbit_raise_ap): No engines found.".
        return.
    }

    set target_ap to target_ap * 1000.

    until ETA:PERIAPSIS < 15 {
        wait 1.
    }

    print "10 sec until Pe, steering to prograde.".
    lock STEERING to SHIP:PROGRADE.

    until ETA:PERIAPSIS < 1 {
        // When both values were 1, the probe sometimes missed
        // the window, presumably because ETA went from 1.0 to
        // a big number in one wait time and was never strictly
        // less than 1.
        wait 0.1.  
    }

    print "Burning to " + (target_ap / 1000) + "km...".
    until SHIP:APOAPSIS >= target_ap {
      lock THROTTLE to 1.
    }

    print "Desired orbit reached.".
    lock THROTTLE to 0.
}
