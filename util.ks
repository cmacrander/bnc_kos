// Utility functions

@lazyglobal off.

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
