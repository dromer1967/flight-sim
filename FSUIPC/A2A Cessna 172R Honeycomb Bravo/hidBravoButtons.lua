-- Demonstration of com library HID joystick reading capabilities
-- You can run this with FSUIPC 4.704, 3.992 or WideClient 6.88,
-- or any later versions

-- Set the Vendor and Product names to suit your device.
-- You can have a different Lua running for each device, but be sure
-- that the aes have different names - or else change the offsets
-- used when writing changes to fSUIPC

-- Get the correct names (substrings will do) from FSUIPC or Wideclient
-- logging. Or use "hidscanner.exe".
-- If the names cannot identify uniquely, use the hexadecimal VID and PID values.

Vendor = 0x294B
Product = 0x1901
Device = 0  -- Multiple devices of the same name need increasing Device numbers.

-- Logging on or off (to see when numbers you are getting)
Logging = true

-- Polling rate in number of polls per second
Pollrate = 25

--------------------------------------------------------
-- First, we need to get the device
Report = 0  -- I *think* all joystick types use Inmput Report 0

dev, rd, wrf, wr, init = com.openhid(Vendor, Product, Device, Report)

if dev == 0 then
   ipc.log("Could not open BRAVO HID")
   ipc.exit()
end

buttons = {}

--PrevData = ""

-- Up to 64 buttons = 2 x 32 bit words, only the last 32 are used
prevbuttons = { 0, 0 }

-- Okay: the Polling routine is caled on a time event, set at the end
------------------------------------------------------------------------
function Poll(time)
  -- We use "readlast" so the values we use are the most up-to-date
  CurrentData, n, discards = com.readlast(dev, rd)

  -- Uncomment this part to log the numbers of discards
  --if Logging and (discards ~= 0) then
  --   ipc.log("Discarded " .. discards)
  --end

  -- Extract values we need
	if n ~= 0 then
		-- Now handle the buttons, 64 of them, only the last 32 are used
		buttons[1], buttons[2] = com.GetHidButtons(dev, CurrentData)

		-- check for changes   
		fbutton = false
		if buttons[2] ~= prevbuttons[2] then
			fbutton = true -- flag change for logging
			prevbuttons[2] = buttons[2]
			-- Send to FSUIPC as a set of 32 virtual buttons
			-- i.e. DWORD offsets 3340 onwards (3340 = ALPHA, 3344 = BRAVO)
			ipc.writeUD(0x3344, buttons[2])
		end
	end
	 
	if Logging and fbutton then
		 -- log in hexadecimal
		 ipc.log(string.format("BRAVO Buttons= %X %X", buttons[1], buttons[2]))
	end
 end

------------------------------------------------------------------------

if init then
   -- Deal with initial values, if supplied (some joysticks don't)
   ipc.log("BRAVO init seen!")
   Poll(0)
end

if Pollrate == 0 then
   -- Ouch. Mustn't divide by zero!
   Pollrate = 25
end

event.timer(1000/Pollrate, "Poll")  -- poll values 'Pollrate' times per second
