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

### File Management Notes

+ Chris foolishly named a file "orbit.ks", but `ORBIT` is a reserved global, which causes all kinds of confusion when executing `RUN orbit` or `COPY orbit TO 1`. This file should be renamed, and similar collisions should be avoided.
+ Chris writes excessively verbose code, and his files maxed out the probe's storage.
    - You can use minify_ks.py to do a little bit of space saving. It works a whole lot better than `COMPILE`.
    - But you have to `RENAME` all the minified files back to their original names once they're on your craft's CPU or else the imports won't work.
    - This is generally super annoying.
