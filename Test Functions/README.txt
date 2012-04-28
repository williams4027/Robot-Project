HANDY BOARD SHAFT ENCODER ROUTINE DOCUMENTATION (QUICK VERSION)

For a shaft encoder in an analog port on the Handy Board (2 through 6), 
load *either* sencdr?.icb or fencdr?.icb.  E.g., load either "sencdr2.icb" 
or "fencdr2.icb".

Include these libraries with a "#use sencdr?.icb" statement at the
beginning of a program.

The "s" versions stand for "slow"; the "f" versions stand for "fast." 
The S versions update at 250 Hz; the F versions, at 1000 Hz.  Use the 
S versions unless you are losing counts, since they take up less CPU 
time.

For any given routine, four globals are defined within IC.  The 
following example assumes "sencdr2.icb" has been loaded (there is no 
difference in the global definitions for the S and F versions):

encoder2_counts    a running count of the encoder clicks

encoder2_velocity  a successive differences velocity measure, 
  calculated every 64 milliseconds
  
encoder2_low_threshold  the lower limit at which point the count is 
  increased; default is 50

encoder2_high_threshold  the higher limit at which point the count is 
  increased; default is 200
  
Depending on the performance of your shaft encoder sensor, the 
encoder thresholds may need to be changed.  To change them, simply 
assign them a new value; e.g. ``encoder2_low_threshold= 75;''.  The 
default value is restored on system reset, so this assignment 
statement needs to run each time the board is restarted.



Fred Martin
January 23, 1997

Modified:
Pat Wensing
April 18, 2008

