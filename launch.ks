///////////////////
// BASIC LAUNCH  //
///////////////////

// EXPECTED PRE-LAUNCH VARIABLES SET BY USER
// desired_orbit: the desired orbit height in km
// turn_start: the height at which to start the turn in km
set desired_orbit to 80.
set turn_start to 3.

// PRELIMINARIES AND COUNTDOWN
set desired_orbit_m to desired_orbit*1000.
set turn_start_m to turn_start*1000.
set apoapsis_reached to false.

clearscreen.

print "Launching in:".
from {local countdown is 3.} until countdown = 0 step {set countdown to countdown - 1.} do {
  print "..." + countdown.
  wait 1.
}

// CALCULATE PITCH FUNCTION
lock pitch_angle to 90 - 90*(APOAPSIS / desired_orbit_m).

// LAUNCH AND STAGING
lock THROTTLE to 1.0.
lock STEERING to heading(90,90).
SAS on.
set SASMODE to "stabilityassist".
stage.

when MAXTHRUST = 0 then {
    print "Activating next stage".
    stage.
    preserve.
}.

// GUIDANCE
when ALTITUDE > turn_start_m then {
  lock STEERING to heading(90,pitch_angle).
  print "Reached " + turn_start + "km, starting turn".
}

when APOAPSIS > desired_orbit_m then {
  lock STEERING to heading(90,0).
  lock THROTTLE to 0.
  print desired_orbit + "km apoapsis achieved, steering to horizon, cutting engines".
  set apoapsis_reached to true.
}

when apoapsis_reached and ETA:APOAPSIS < 60 then {
  lock THROTTLE to 1.
  print "60s to apoapsis, circularizing orbit".
}

when PERIAPSIS > desired_orbit_m then {
  print desired_orbit + "km orbit achieved, cutting throttle".
  lock THROTTLE to 0.
  set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
}

until PERIAPSIS > desired_orbit_m {
  print "Pitch Angle: " + round(pitch_angle,0) at (0,16).
  log TIME + "," + APOAPSIS + "," + pitch_angle to log.txt.
  wait 1.
}
