////////////////////////////////////////////
//                                        //
// LOG DATA TO DETERMINE DRAG COEFFICIENT //
// Tested with: kOS Test Rocket.craft     //
//                                        //
////////////////////////////////////////////

clearscreen.

////// CREATE LOG FILE WITH HEADER //////

log "time,altitude,pressure,air_speed,ground_speed,surface_speed" to vt_log.txt.

////// BEGIN LOGGING //////

until RCS {
  log TIME:SECONDS + "," + ALTITUDE + "," + SHIP:DYNAMICPRESSURE + "," + AIRSPEED + "," + GROUNDSPEED + "," + VERTICALSPEED to vt_log.txt.
  print "Logging data at " + round(TIME:SECONDS, 2) at (0, 0).
  wait 0.2.
}
