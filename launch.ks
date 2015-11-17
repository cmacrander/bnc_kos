////////////////////////////////////////
//                                    //
// BASIC LAUNCH                       //
// Tested with: kOS Test Rocket.craft //
//                                    //
////////////////////////////////////////

////// EXPECTED PARAMETERS //////
// desired_orbit: the desired orbit height in km

parameter desired_orbit.
set desired_orbit to desired_orbit*1000.

////// CONFIGURATION //////
// turn_start: altitude to begin gravity turn in m

set turn_start to 500.

////// USEFUL CALCULATIONS //////

// Make the angle of ascent proportional to the distance between
// the current apoapsis and desired orbit, so that all velocity
// is in the x-direction at the moment we hit our apoapsis goal
lock pitch_angle to 90 - 90 * (APOAPSIS / desired_orbit).

// Calculate the speed of the desired orbit
// see http://wiki.kerbalspaceprogram.com/wiki/Tutorial:_Basic_Orbiting_(Math)
set orbit_speed to 600000 * sqrt(9.807 / (600000 + desired_orbit)).

////// COUNTDOWN //////

clearscreen.

print "Launching in:".
from {local countdown is 3.} until countdown = 0 step {set countdown to countdown - 1.} do {
  print "..." + countdown.
  wait 1.
}

////// LAUNCH //////

lock THROTTLE to 1.
lock STEERING to heading(90, 90). // straight up
SAS on.
set SASMODE to "stabilityassist".
stage.

////// STAGING //////

set stage_time to 0.
set activate_stage_wait to false.

// When you run out of fuel, lock the steering to the current
// heading and record the time
when MAXTHRUST = 0 then {
  lock STEERING to FACING:VECTOR.
  set stage_time to TIME:SECONDS.
  set activate_stage_wait to true.

  print "----".
  print "Stage exhuasted, waiting 2 seconds".
}

// Three seconds after running out of fuel activate the next stage,
// to avoid staging during major acceleration or changes in direction
when activate_stage_wait and TIME:SECONDS > (stage_time + 2) then {
  // TODO: this is cheating, I don't how to dynamically record the
  // previous state and then go back to it here
  lock STEERING to heading(90, pitch_angle).
  stage.

  print "----".
  print "Activating next stage".
}

////// ASCENT //////

when ALTITUDE > turn_start then {
  lock STEERING to heading(90, pitch_angle).

  print "----".
  print "Reached " + turn_start + "m, starting turn".
}

////// CIRCULARIZATION //////

when APOAPSIS > desired_orbit then {

  // Turn off throttle
  lock THROTTLE to 0.

  print "----".
  print desired_orbit/1000 + "km apoapsis achieved, cutting engines".

  // Calculate additional orbital speed needed
  // TODO: this calculation isn't quite right, the extra dV is too small
  set additional_delta_v to orbit_speed - VELOCITY:ORBIT:MAG.

  print "----".
  print "Current orbital speed: " + round(VELOCITY:ORBIT:MAG, 0) + "m/s".
  print "Desired orbital speed: " + round(orbit_speed, 0) + "m/s".
  print "Necessary deltaV increase: " + round(additional_delta_v, 0) + "m/s".

  // Create a maneuver node to circularize
  set orbit_maneuver to node(TIME:SECONDS + ETA:APOAPSIS, 0, 0, additional_delta_v).
  add orbit_maneuver.

  print "Maneuver will achieve ...".
  print "   Apoapsis: " + round(orbit_maneuver:ORBIT:APOAPSIS/1000, 1) + "km apoapsis".
  print "   Periapsis: " + round(orbit_maneuver:ORBIT:PERIAPSIS/1000, 1) + "km periapsis".

  // Lock steering to maneuver point
  unlock STEERING.
  set SASMODE to "maneuver".

  // TODO: Not sure how to determine the expected burn time, then use that for timing this burn
  // Tragically, I think I might need to calculate expected acceleration from thrust and
  // mass and fuel flow (i.e. reduction in mass) and all that crap.
  when orbit_maneuver:ETA < 30 then {
    lock THROTTLE to 1.

    print "----".
    print "30s to apoapsis, circularizing orbit".
  }
}

////// END PROGRAM //////

when (APOAPSIS * 0.95) > desired_orbit and (PERIAPSIS * 0.95) > desired_orbit then {
  remove orbit_maneuver.
  lock THROTTLE to 0.
  set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.

  print "----".
  print desired_orbit/1000 + "km orbit achieved, cutting throttle".
}

until (APOAPSIS * 0.95) > desired_orbit and (PERIAPSIS * 0.95) > desired_orbit {
  print "Pitch Angle: " + round(pitch_angle, 1) at (0,25).
}
