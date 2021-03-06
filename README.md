# bnc_kos

Code suggestions from [the kOS design patterns page](http://ksp-kos.github.io/KOS_DOC/tutorials/designpatterns.html).

### Major Control Blocks

+ `WAIT UNTIL condition` - stop the script from executing, wait until something is true, then do it
+ `WHEN condition THEN` - keep executing the script, keep checking if something is true in the background, then do it when true
+ `UNTIL condition` - keep checking if something is true in the background and keep doing something until it is true

### Code Construction Notes

+ `WHEN condition THEN` are expected to complete inside a single physics tick, so don't wait in them, or do major looping in them
+ Never put an `UNTIL condition` inside of a `WHEN condition THEN`
+ Avoid having tons of conditions being checked at the same time; one way to do this is to next `WHEN condition THEN` statements inside of each other as much as possible
+ `WHEN` triggers don't fire if the program has ended! The program ends if there are no more waits.
+ Beware the combination of `lock STEERING` and SAS. These are independent inputs to the controls and they fight each other. So if you leave steering locked on some vector, and then turn on stability assist, your craft will act like it's insane. To fix this, remove the undesirable input, either `unlock STEERING.` or `SAS off.`.
