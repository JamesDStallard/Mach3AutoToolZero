'--------------------------------------------------------------------------------------------------------------------
' AutoToolZero Script for Mach3
' (c) James D Stallard 2017
'
'--------------------------------------------------------------------------------------------------------------------
' Notes:
' Script converts mm to inches automatically by reading your machine's native unit settings irrespective of G20/G21
' You MUST configure the following variables:
'	intTouchPlateThickness
'	MUST BE SET IN MM
'
' All other variables can be left at their defaults
' The script allows you to run a metric and imperial units setup on the same machine, but in different Mach3 profiles
' without having to edit intTouchPlateThickness each time you switch units
'
'--------------------------------------------------------------------------------------------------------------------

intTouchPlateThickness	= 19.2													' Set touchplate/puck thickness in mm

intUnits				= GetSetupUnits()										' Autoconvert script from metric to imperial
If intUnits				= 0 Then intConversionFactor = 1						' Units are mm
If intUnits				= 1 Then intConversionFactor = 25.4						' Units are in

intStartProbeDelay		= 2														' Set the amount of time in seconds you need between hitting the auto tool zero button and the probe action actually starting. Default 2
																				' Set to 0 if you place the touchplate/puck before hitting auto tool zero
intProbeMaxTravel		= Round(120 / intConversionFactor,3)					' Maximum probe travel distance before giving up in mm if metric, inches if imperial. Default 120
																				' Set to something around 20% less than your Z axis travel distance
intProbeFeedRate		= Round(200 / intConversionFactor,3)					' Probing action and retract feed rate in mm per minute if metric, inches per minute is imperial. Default 200
intZRetractHeight		= Round(25 / intConversionFactor,3)						' The distance from the work that the tool will be retracted in mm if metric, inches if imperial. Default 50
																				' MUST be greater than the value of intTouchPlateThickness or the tool will crash into the touchplate/puck
																				' MUST be less than the distance from the RefHome Z or the mill will hit the Z limit switch before completing the action and new sero will be inaccurate
intTouchPlateThickness	= Round(intTouchPlateThickness / intConversionFactor,3)	' Convert touchplate/puck thickness to native units

intCurrentFeed			= GetOemDRO(818)										' Get current feedrate

intCurrentAbsInc		= GetOemLED(48)											' Get current G90/G91 state
intCurrentGMode			= GetOemDRO(819)										' Get current G0/G1 state

If GetOemLed(825)		= 0 Then												' Check to see if the probe is already grounded
	DoButton(24)																' RefHome the Z axis to provide an absolute start point
	Code "(Ref homing Z axis...)"												' Status bar message
	
	While IsMoving()															' Wait while RefHome completes
	Wend
	
	Code "G4 P" & intStartProbeDelay											' Dwell to set touchplate/puck in place
	Code "G90 G31 Z-" & intProbeMaxTravel & " F" & intProbeFeedRate				' Execute probe action
	Code "(Probing Z axis...)"													' Status bar message
	
	While IsMoving()															' Wait while probe action completes
	Wend
	
	intZProbePos		= GetVar(2002)											' get the point the tool hit the touchplate/puck 
	Code "G0 Z" & intZProbePos													' Return to that point. There is always a small amount of overrun, touchplate/puck material should be softer than the tool!
	
	While IsMoving ()															' Wait while tool retracts to hit point
	Wend
	
	Call SetDro (2, intTouchPlateThickness)										' Set the DRO to the touchplate/puck thickness so MACH3 knows where the new zero is
	Sleep 200																	' Wait for DRO to update
	Code "G1 Z" & intZRetractHeight & " F" & 4 * intProbeFeedRate				' Retract the tool at the end of the probe action
	Code "(Retracting " & intZRetractHeight & "...)"							' Status bar message

	While IsMoving ()															' Wait while tool retracts to hit point
	Wend
	
	Code "(Z axis is zeroed. Tool at " & intZRetractHeight & ")"				' Status bar message
	Code "F" & intCurrentFeed													' Reinstate prior feed rate
Else
	Code "(Touchplate/Puck is grounded, check connections)"						' Status bar message
End If

If intCurrentAbsInc		= 0 Then Code "G91"										' Reinstate G91 state
If intCurrentGMode		= 0 Then Code "G0"										' Reinstate G0 state     
 

