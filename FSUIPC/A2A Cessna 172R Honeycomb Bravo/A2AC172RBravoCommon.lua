--
-- Common functionality for the A2AC172Bravo lua plugins.
-- by Peter Brand
--
-- Note: This script is intended to be used as a lua module in FSUIPC.
-- Pete & John Dowson @http://www.fsuipc.com/
--

--
-- Update the following variables to the correct value
--
local configurableSettings = {
    HoneycombBravoJoystickNumber = 0 -- As found in fsuipc.ini
}
--
-- End of configurable variables
--

local a2aC172RBravoCommon = {
      IsActiveAircraftA2AC172R     = false
    , HoneycombBravoJoystickNumber = configurableSettings.HoneycombBravoJoystickNumber
}

local a2aAircraftNameStart = "A2A Cessna 172R"
local aircraftNameOffset = 0x3D00
local honeycombBravoDevice = {
    Vendor  = 0x294B -- Honeycomb Bravo vendor id
  , Product = 0x1901 -- Honeycomb Bravo product id
  , Number  = 0      -- Multiple devices of the same name need increasing Device numbers
  , Report  = 0      -- Report 0 is used
}

--
-- Functions
--

function AircraftNameEvent(offset, value)
    a2aC172RBravoCommon.IsActiveAircraftA2AC172R = value:sub(1, #a2aAircraftNameStart) == a2aAircraftNameStart
end

function a2aC172RBravoCommon.OpenHidDevice()

    -- Open the Honeycomb Bravo device
    local dev, rd, wrf, wr, init = com.openhid(honeycombBravoDevice.Vendor, honeycombBravoDevice.Product, honeycombBravoDevice.Number, honeycombBravoDevice.Report)

    -- Check if device is opened
    if dev == 0 then
        ipc.log("A2AC172RBravo: Could not open HID!")
        ipc.exit()
    end

    -- Initialise device if applicable
    if init then
        -- Deal with initial values, if supplied (some joysticks don't)
        ipc.log("A2AC172RBravo: Init Seen!")
        Poll(0)
    end

    return dev, rd, wrf, wr, init
end


--
-- Initialisation Code
--

-- Subscribe to events
event.offset(aircraftNameOffset, "STR", 0, "AircraftNameEvent")

return a2aC172RBravoCommon
