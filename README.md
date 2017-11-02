# Mach3AutoToolZero
(c) James D. Stallard 2017

A custom button script for Artsoft Mach3 that allows for Automatic Tool Zeroing in the Z Axis

# Notes
Script converts mm to inches automatically by reading your machine's native unit settings irrespective of G20/G21

 You MUST configure the following variables:
 
	intTouchPlateThickness
	
	MUST BE SET IN MM

All other variables can be left at their defaults or tuned to suit

The script allows you to run a metric and imperial units setup on the same machine (common in Europe), but in different Mach3 profiles without having to edit intTouchPlateThickness each time you switch units
