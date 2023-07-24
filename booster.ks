set spAlt to 42000.

set TR to addons:TR.

clearScreen.
print "WAITING FOR THE TARGET ALTITUDE".

wait until SHIP:altitude >= spAlt.

clearScreen.
print "MECO".
wait 1.

TR:setTarget(tarGeo).
wait 0.001.

lock throttle to 0.

print "BOOSTER BACK START".

RCS ON.
TOGGLE AG3.
WAIT 2.

boosterTurnBack().

boosterBackBurn().

boosterBackAdject().
