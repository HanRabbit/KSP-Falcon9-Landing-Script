clearScreen.
print "This is FALCON9 STAGE 2".
print "Press Key 0 to start".
wait until AG10.
AG10 off.

runPath("0:/lib/falcon_lib.ks").
runPath("0:/second_stage.ks").