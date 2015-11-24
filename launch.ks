////////////////////////////////////////
//                                    //
// BASIC LAUNCH                       //
// Tested with: kOS Test Rocket.craft //
//                                    //
////////////////////////////////////////

@lazyglobal off.

////// IMPORTS //////

run orbit.

////// EXPECTED PARAMETERS //////
// desired_orbit: the desired orbit height in km

parameter desired_orbit.
parameter inclination.

local desired_orbit to desired_orbit*1000.

////// CONFIGURATION //////
// turn_start: altitude to begin gravity turn in m

local turn_start to 500.

////// USEFUL CALCULATIONS //////

// Make the angle of ascent proportional to the distance between
// the current apoapsis and desired orbit, so that all velocity
// is in the x-direction at the moment we hit our apoapsis goal
lock pitch_angle to 90 - 90 * (APOAPSIS / desired_orbit).

// Calculate the speed of the desired orbit
// see http://wiki.kerbalspaceprogram.com/wiki/Tutorial:_Basic_Orbiting_(Math)
local orbit_speed to 600000 * sqrt(9.807 / (600000 + desired_orbit)).

////// COUNTDOWN //////

clearscreen.

print "Launching in:".
from {local countdown is 3.} until countdown = 0 step {set countdown to countdown - 1.} do {
  print "..." + countdown.
  wait 1.
}

////// LAUNCH //////

lock THROTTLE to 1.
lock STEERING to heading(inclination, 90). // straight up
SAS on.
set SASMODE to "stabilityassist".
stage.

////// STAGING //////

local stage_time to 0.
local activate_stage_wait to false.

// When you run out of fuel, lock the steering to the current
// heading and record the time
when MAXTHRUST = 0 then {
  lock STEERING to FACING:VECTOR.
  set stage_time to TIME:SECONDS.
  set activate_stage_wait to true.

  print "----".
  if (STAGE:NUMBER = 0) {
    print "Stage exhausted. No more stages!".
  } else {
    print "Stage exhausted, waiting 2 seconds".
  }
}

// Three seconds after running out of fuel activate the next stage,
// to avoid staging during major acceleration or changes in direction
when activate_stage_wait and TIME:SECONDS > (stage_time + 2) then {
  // TODO: this is cheating, I don't how to dynamically record the
  // previous state and then go back to it here
  lock STEERING to heading(inclination, pitch_angle).
  stage.

  print "----".
  print "Activating next stage".
}

////// ASCENT //////

when ALTITUDE > turn_start then {
  lock STEERING to heading(inclination, pitch_angle).

  print "----".
  print "Reached " + turn_start + "m, starting turn".
}

////// CIRCULARIZATION //////

wait until APOAPSIS > desired_orbit.

print "----".
print "Desired Apoapsis reached, circularizing.".

lock THROTTLE to 0.
unlock STEERING.
SAS on.
set SASMODE to "stabilityassist".
local align_time to 20.
orbit_alter_apsis("periapsis", desired_orbit, align_time).

////// END PROGRAM //////

until (APOAPSIS * 0.95) > desired_orbit and (PERIAPSIS * 0.95) > desired_orbit {
  print "Pitch Angle: " + round(pitch_angle, 1) at (0,25).
}
