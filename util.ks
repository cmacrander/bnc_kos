// Utility functions

@lazyglobal off.

function logtxt {
    parameter txt.
    log txt to "log.txt".
}

function clear_log {
    log "" to "log.txt".  // to make sure it exists
    delete "log.txt".  // to clear it
    log "" to "log.txt".  // to re-create it so it's there when you look for it
}

function sum {
    parameter li.

    local s to 0.
    for e in li {
        set s to s + e.
    }

    return s.
}

function mean {
    parameter li.

    return sum(li) / li:LENGTH.
}

// Get all the engines that are part of the current stage.

function util_get_staged_engines {
    local current_engines to LIST().
    // You can't just say `for eng in ENGINES`, you have to store
    // it in a "real" variable first... because... kOS is kinda
    // dumb that way? I dunno.
    local engs to list().
    list ENGINES in engs.
    for eng in engs {
        if eng:STAGE = STAGE:NUMBER {
            current_engines:ADD(eng).
        }
    }
    return current_engines.
}

// Todo:
// function util_can_gimbal {
//     
// }

// Changes state of all solar panels on craft.
// WARNING: some types of solar panels don't retract!
// @param {string} action - Must be 'toggle', 'extend', or 'retract'.

function util_move_all_solar_panels {
    parameter action.

    local allowed to LIST("toggle", "extend", "retract").
    if (not allowed:CONTAINS(action)) {
        print "ERROR (util_move_all_solar_panels): Invalid " +
              "action: '" + action + "'.".
        return.
    }

    for module in SHIP:MODULESNAMED("ModuleDeployableSolarPanel") {
        if (action = "toggle") {
            // A panel can have a variety of states when open, e.g.
            // "Direct Sunlight", but when retracted is "Retracted".
            // We need to know this so we can pass true (extend) or 
            // false (retract) into the toggle action.
            local target_state to (
                module:GETFIELD("status") = "Retracted").
            module:DOACTION("toggle panels", target_state).
        } else if (action = "extend") {
            module:DOACTION("extend panel", true).
        } else if (action = "retract") {
            module:DOACTION("retract panel", true).
        }
    }
}

// Native `warpto()` goes to an absolute time and doesn't block execution.
// This warps forward some seconds, and waits until the warp is done.
function util_relative_warp {
    parameter sec.

    if (sec < 0) {
        print "ERROR (util_relative_warp): Can't warp negative seconds.".
        return.
    }

    local warp_target to TIME:SECONDS + sec.
    warpto(warp_target).
    wait until TIME:SECONDS >= warp_target.
}

// Turns on SAS and waits until rotation on all three axes is under 0.01 deg/s.
// Restores SAS state to what it was before the function ran.
function util_stabilize {
    print "Stabilizing the ship...".

    lock THROTTLE to 0.
    unlock STEERING.
    local original_sas_state to SAS.
    local original_sasmode to SASMODE.
    SAS on.
    set SASMODE to "stabilityassist".

    local wait_duration to 0.1.
    local fudge to 0.01.  // degree change per wait duration allowable
    local start to TIME:SECONDS.

    local prev_facing to SHIP:FACING.
    wait wait_duration.
    local d_pitch to SHIP:FACING:PITCH - prev_facing:PITCH.
    local d_yaw to SHIP:FACING:YAW - prev_facing:YAW.
    local d_roll to SHIP:FACING:ROLL - prev_facing:ROLL.
    until abs(d_pitch) < fudge and abs(d_yaw) < fudge and abs(d_roll) < fudge {
        set prev_facing to SHIP:FACING.
        wait wait_duration.
        set d_pitch to SHIP:FACING:PITCH - prev_facing:PITCH.
        set d_yaw to SHIP:FACING:YAW - prev_facing:YAW.
        set d_roll to SHIP:FACING:ROLL - prev_facing:ROLL.
    }
    print "...took " + (round(TIME:SECONDS - start, 2)) +
          "s to stabilize to < " + (round(fudge / wait_duration, 3)) +
          " deg/s.".

    set SAS to original_sas_state.
    set SASMODE to original_sasmode.
    unlock THROTTLE.
}

