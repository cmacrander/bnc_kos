//////////////////////////////////////
//                                  //
// TEST TO DETERMINE HOW TO WAIT    //
// AFTER A CONDITION HAS BEEN MET   //
// Tested with: kOS Test Unit.craft //
//                                  //
//////////////////////////////////////

clearscreen.

set rcs_pressed_once to false.
set first_trigger_done to false.
set first_trigger_time to 0.

when RCS then {
  set rcs_pressed_once to true.
  set first_trigger_done to true.
  set first_trigger_time to TIME:SECONDS.

  print "RCS activated, first condition triggered".
  print "   Time: " + round(TIME:SECONDS, 2).
  print "   first_trigger_time: " + round(first_trigger_time, 2).
}

when first_trigger_done and TIME:SECONDS > (first_trigger_time + 3) then {
  print "Second condition triggered".
  print "   Time: " + round(TIME:SECONDS, 2).
}

until RCS = false and rcs_pressed_once {
  print "Program running" at (0, 20).
}
