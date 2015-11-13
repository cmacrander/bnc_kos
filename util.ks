// Utility functions

@lazyglobal off.

// Changes state of all solar panels on craft.
// WARNING: some types of solar panels don't retract!
// @param {string} action - Must be 'toggle', 'extend', or 'retract'.

function util_move_all_solar_panels {
    parameter action.

    local allowed to list("toggle", "extend", "retract").
    if (not allowed:contains(action)) {
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
