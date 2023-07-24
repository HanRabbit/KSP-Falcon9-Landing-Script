set maxVal to 100000.
set spAlt to 33000.

clearScreen.

sas off.

lock throttle to 1.
clearScreen.

wait 2.
stage.

lock steering to heading(90, 90).
wait 2.

// wait until ship:airspeed >= 80.   
lock steering to gravityTurn(maxVal).

print "Gravity steering...".

wait until SHIP:altitude >= spAlt - 2000.
Kuniverse:TimeWarp:CancelWarp().

wait until SHIP:altitude >= spAlt.

lock throttle to 0.

wait 1.
stage.
wait 1.

// kuniverse:forcesetactivevessel(vessel("F9-firststage")).

wait 2.
lock throttle to 1.

wait until SHIP:OBT:APOAPSIS > 100000.

lock Throttle to 0.
Lock Steering to ship:PROGRADE.

wait until Ship:Altitude > 70001. 
Lock Throttle to 0.5. 

wait until Ship:Apoapsis > maxVal. 
Lock Throttle to 0. 

wait 1.
//下面是设计变轨规划
Set EtaTime to ETA:Apoapsis. //要变轨的是远点，采集到远点的时间
Set V1 to
(vcrs(Ship:Body:Position,Ship:Velocity:Orbit):Mag)/(Kerbin:Radius+Ship:Apoapsis).
//用角动量守恒来算远点速度
Set V2 to Sqrt (Constant():G*Kerbin:Mass/(Kerbin:Radius+Ship:Apoapsis)).
//用天体公式GM=V2R算出远点圆轨道的速度
Set MyNode to Node (Time:Seconds+EtaTime,0,0,V2-V1).
//生成一个变轨规划，四个参数分别为：几秒后、径向法向切向DV
add MyNode. //将变轨计划加入飞行计划
//下面是执行变轨规划
Set Nd to MyNode. //读取下一个变轨计划的信息
Set MaxAcc to Ship:MaxThrust/Ship:Mass.
//计算加速度，这里忽略了质量会随着燃料燃烧而减少这件事
Set BurnDuration to Nd:Deltav:Mag/MaxAcc. //计算变轨需要的持续工作时间
wait until Nd:ETA<=(BurnDuration/2 + 40).
//等到工作时间的一半+40秒再执行后面的，40秒是为了留时间调姿
Set Np to Nd:Deltav.
Lock Steering to Np.
//只读取刚计算好值，因为机动过程中Nd的数据会变，而只读取初值的话误差能接受
wait until Nd:ETA<=(BurnDuration/2).
//等到工作时间的一半，这时候姿态对准喷射方向了，就等点火了
Set Done to FALSE. //已完成变轨的标记，用于跳出循环
Lock throttle to 1.//开始加速
wait until ship:PERIAPSIS>10000.//等到近点露出地面
until Done
set halfT to 0.5*ship:orbit:period. //轨道周期的一半
set halfTV to VelocityAt(ship, Time:seconds+halfT).

set halfTVV to halfTV:orbit:Mag.
//一半周期后的速度，也就是轨道对过的速度
//圆轨开始时，自己是速度较小的远点，对过是速度较大的近点
//圆轨过程中，远点和近点差距缩小，直到圆轨道就相等了
set delta to halfTVV-ship:Velocity:orbit:Mag. //飞船和对过的速度差
set safe to 0.3*ship:Maxthrust/ship:mass. //速度差不大
if delta < safe{lock throttle to 0.15. } //如果速度差不大就慢慢加速
if delta < 0 {
lock throttle to 0.
Set Done to TRUE.}//如果速度大小倒错就加好了
wait 0.001.
wait 1.
unLock Steering.
unLock Throttle. //解绑姿态和节流阀锁定
remove Nd. //移除变轨计划
//为了以防万一，将节流阀设为0，这可以避免放开节流阀后节流阀异常
Set Ship:Control:PilotMainThrottle to 0.
SAS ON. //把SAS打开，这样kOS程序结束之后火箭不会乱转。