# Honeycomb Bravo Throttle Quadrant with the A2A Cessna 172R

LUA scripts to support (part of) the Honeycomb Bravo Throttle Quadrant in the A2A Cessna 172R.

**Requires FSUIPC!**
(Only tested in P3D V5.1 HF1)

#### Currently supported:
* Annunciator lights
* Support in fsuipc for Bravo buttons > 32

#### Usage:
* Copy the following files  to your FSUIPC folder (where fsuipc.dll is located).
  * A2AC172RBravo.lua
  * HoneyCombBravoLedBitsProcessor.lua
  * hidBravoButtons.lua (support for buttons > 32)
* Modify fsuipc.ini and add the following parts:

```
[Auto]
1=Lua hidBravoButtons
2=Lua A2AC172RBravo

[LuaFiles]
1=hidBravoButtons
2=A2AC172RBravo
```
