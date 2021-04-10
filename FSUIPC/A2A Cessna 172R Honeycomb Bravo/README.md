# Honeycomb Bravo Throttle Quadrant with the A2A Cessna 172R

LUA scripts to support (parts of) the Honeycomb Bravo Throttle Quadrant in the A2A Cessna 172R.

**Requires FSUIPC!**
(Only tested in P3D V5.1 HF1)

#### Releases
* 0.2
  * Auto pilot buttons are supported
  * Only the AutoPilot Master LED is supported
  * Other Autopilot LEDs are not supported because the A2A 172 doesn't have state to indicate which mode is active
* 0.1
  * First version with annunciator LEDs

#### Currently supported:
* Annunciator lights
  * Master Caution is on when Oil Temperature < 38 degrees Celcius
  * Master Warning is on when Oil Temperature > 118 degrees Celcius or Oil Pressure > 115 psi or Cht > 232 degrees Celcius
  * Most LEDs will only be active when Bus Voltage > 6 and Battery is switched on
* Auto pilot buttons
  * Only the AutoPilot On/Off LED is supported
  * Vs Button is used for ARM
  * Ias button is used for the Barometer
  * When the selection switch is on Ias it can be used to adjust the barometer
* Support in fsuipc for Bravo buttons > 32

#### Usage:
* Copy the following files to your FSUIPC folder (where fsuipc.dll is located)
  * A2AC172RBravoAnn.lua
  * A2AC172RBravoAp.lua
  * HoneyCombBravoLedBitsProcessor.lua
  * hidBravoButtons.lua (support for buttons > 32)
* Modify fsuipc.ini and add the following parts:

```
[Auto]
1=Lua hidBravoButtons
2=Lua A2AC172RBravoAnn
3=Lua A2AC172RBravoAp

[LuaFiles]
1=hidBravoButtons
2=A2AC172RBravoAnn
3=A2AC172RBravoAp
```
