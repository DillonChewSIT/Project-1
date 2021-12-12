   {Project: EE-9
 Platform: Parallax Project USB Board
 Revision: 1.4
 Author: Dillon Chew
 Date: 28 Nov 2021
 Log:
   Date: Desc
   26/11/2021: Redid the logic of the main function
   28/11/2021: Modified main function
}


CON
        _clkmode = xtal1 + pll16x           'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        'creating a pause()
        _ConClkFreq = ((_clkmode - xtal1 >> 6) * _xinfreq)
        _Ms_001 = _ConClkFreq / 1_000

        'MotorControl constants
        Forward=1
        Reverse=2
        TurnLeft=3
        TurnRight=4
        Stop=5

        MotSlow=50
        MotFast=80
        'Commcontrol constants
        commForward=1
        commReverse=2
        commLeft=3
        commRight=4
        commStop=5
        sensUltraSafeVal = 400

VAR     'sensor variables
  long  mainToF1Add,mainToF2Add, mainUltra1Add, mainUltra2Add
        'motor variables
  long  control,speed
        'comm variables
  long  decisionMode

OBJ
  Term        : "FullDuplexSerial.spin"
  MotorCon    : "MotorControl.spin"
  SensCon     : "SensorControlV2.spin"
  Com         : "CommControl.spin"

PUB Main | i

    Term.Start(31,30,0,115200)   'initialise terminal
    MotorCon.Start(_Ms_001,@control,@speed)    'initialise motor cog
    SensCon.Start(_Ms_001,@mainToF1Add, @mainToF2Add, @mainUltra1Add, @mainUltra2Add) 'initialise sensor cog
    Com.Start(_Ms_001,@decisionMode)       'initialise comms cog

    'run and get readings



      repeat
        case decisionMode

          1:                                                      'move forward if receiving hex 01 signal and if sensor ranges are clear. Else stop
            if ((mainUltra1Add > sensUltraSafeVal)and (mainToF1Add<250))
                control:= commForward
                speed:=MotFast
            elseif(mainUltra1Add < sensUltraSafeVal or (mainToF1Add > 250))
              control:=Stop

          2:
            if ((mainUltra2Add > sensUltraSafeVal) and (mainToF2Add<250))   'reverse if receiving hex 02 signal and if sensor ranges are clear. Else stop
                control:=commReverse
                speed:=MotFast
            elseif((mainUltra2Add < sensUltraSafeVal) or (mainToF2Add>250))
              control:=Stop

          3:                                                          'turn left if receiving hex 03 signal
                control:=TurnLeft
                speed:=MotFast

          4:                                                          'turn right if receiving hex 04 signal
                control:=TurnRight
                speed:=MotFast

          5:                                                           'stop if receiving hex 05 signal
                control:=Stop

        Term.Str(String(13, "Tof 1 Reading: "))
        Term.Dec(mainToF1Add)
        Term.Str(String(13, "Tof 2 Reading: "))
        Term.Dec(mainToF2Add)
        Term.Str(String(13, "Ultrasonic 1 Readings: "))
        Term.Dec(mainUltra1Add)
        Term.Str(String(13, "Ultrasonic 2 Readings: "))
        Term.Dec(mainUltra2Add)
        Pause(50)
        Term.Tx(0)



PRI Pause (ms) | t
  t := cnt - 1088
  repeat (ms#>0)
    waitcnt (t+=_Ms_001)
  return

DAT
name    byte  "string_data",0