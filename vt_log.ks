///////////////////////////////////////////////////
//                                               //
// LOG DATA TO DETERMINE DRAG COEFFICIENT        //
// Tested with: kOS Test Rocket.craft            //
// (upside down, with barometer and thermometer) //
//                                               //
// Make sure vt_log.txt is empty before run      //
// Make sure altitude > 50m before run           //
// Use SAS prograde lock during descent          //
//                                               //
///////////////////////////////////////////////////

clearscreen.

////// CREATE LOG FILE WITH HEADER //////

log "TIME:SECONDS,ALTITUDE,AIRSPEED,SHIP:SENSORS:PRES,SHIP:SENSORS:TEMP" to vt_log.txt.

////// BEGIN LOGGING //////

until ALTITUDE < 50 {
  log TIME:SECONDS + "," + ALTITUDE + "," + AIRSPEED + "," + SHIP:SENSORS:PRES + "," + SHIP:SENSORS:TEMP to vt_log.txt.
  print "Logging data at " + round(TIME:SECONDS, 2) at (0, 0).
  wait 0.2.
}
