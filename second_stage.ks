set mH to 100 * 10 ^ 3.     // 最大上升高度
set H0 to 30.               // 重力转向高度
set spAlt to 42000.         // MECO 高度

clearScreen.

SAS OFF.

lock throttle to 1.
wait 2.

STAGE.

lock steering to heading(90, 90).
wait 10.

lock steering to GravityTurn(mH, H0).

print "GRAVITY TURNING".

wait until SHIP:altitude >= spAlt - 2000.

lock throttle to 0.
wait 2.

STAGE.

wait 2.

lock throttle to 1.

wait until SHIP:altitude >= mH.
