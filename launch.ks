////////////////////////////////////////
//                                    //
// BASIC LAUNCH                       //
// Tested with: kOS Test Rocket.craft //
//                                    //
////////////////////////////////////////

// EXPECTED PRE-LAUNCH VARIABLES SET BY USER
// desired_orbit: the desired orbit height in km
parameter desired_orbit.

// PRELIMINARIES AND COUNTDOWN
set desired_orbit to desired_orbit*1000.
set turn_start to 500.

clearscreen.

print "Launching in:".
from {local countdown is 3.} until countdown = 0 step {set countdown to countdown - 1.} do {
  print "..." + countdown.
  wait 1.
}

// CALCULATE PITCH FUNCTION
lock pitch_angle to 90 - 90*(APOAPSIS / desired_orbit).

// CALCULATE SPEED OF ORBIT - http://wiki.kerbalspaceprogram.com/wiki/Tutorial:_Basic_Orbiting_(Math)
set orbit_speed to 600000 * sqrt(9.807 / (600000 + desired_orbit)).

// LAUNCH AND STAGING
lock THROTTLE to 1.
lock STEERING to heading(90, 90).
SAS on.
set SASMODE to "stabilityassist".
stage.

// TODO: Need to make sure we're not turning like crazy during staging or an explosion occurs
when MAXTHRUST = 0 then {
  lock THROTTLE to 0.
  stage.
  lock THROTTLE to 1.
  preserve.

  print "----".
  print "Activating next stage".
}.

// GUIDANCE
when ALTITUDE > turn_start then {
  lock STEERING to heading(90, pitch_angle).

  print "----".
  print "Reached " + turn_start + "m, starting turn".
}

when APOAPSIS > desired_orbit then {

  // Turn off throttle
  lock THROTTLE to 0.

  print "----".
  print desired_orbit/1000 + "km apoapsis achieved, cutting engines".

  // Calculate additional orbital speed needed
  // TODO: Not sure groundspeed is correct here because the deltaV comes out to high; need orbital speed?
  set additional_delta_v to orbit_speed - GROUNDSPEED.

  print "----".
  print "Current ground speed: " + round(GROUNDSPEED, 0) + "m/s".
  print "Desired orbital speed: " + round(orbit_speed, 0) + "m/s".
  print "Necessary deltaV increase: " + round(additional_delta_v, 0) + "m/s".

  // Create a maneuver node to circularize
  set orbit_maneuver to node(TIME:SECONDS + ETA:APOAPSIS, 0, 0, additional_delta_v).
  add orbit_maneuver.

  print "Maneuver will achieve " + round(orbit_maneuver:ORBIT:PERIAPSIS/1000, 1) + "km periapsis".

  // Lock steering to maneuver point
  unlock STEERING.
  set SASMODE to "maneuver".

  // TODO: Not sure how to determine the expected burn time, then use that for timing this burn
  when orbit_maneuver:ETA < 30 then {
    lock THROTTLE to 1.

    print "----".
    print "30s to apoapsis, circularizing orbit".
  }
}

// TODO: This is lame, need to sort out which apsis I should be looking at
when (PERIAPSIS > 0.95 * desired_orbit and APOAPSIS > 0.95 * desired_orbit) then {
  remove orbit_maneuver.
  lock THROTTLE to 0.
  set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.

  print desired_orbit/1000 + "km orbit achieved, cutting throttle".
}

until APOAPSIS > desired_orbit {
  print "Pitch Angle: " + round(pitch_angle, 0) at (0,23).
  wait 1.
}

until (PERIAPSIS > 0.95 * desired_orbit and APOAPSIS > 0.95 * desired_orbit) {
  print "Circularization mode on" at (0,24).
  wait 1.
}
