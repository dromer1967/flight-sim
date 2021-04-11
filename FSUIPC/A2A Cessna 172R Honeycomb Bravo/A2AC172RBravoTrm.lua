--
-- Library to control the trim of the A2A Cessna 172R using the Honeycomb Bravo trim wheel.
-- Support for both normal and fast trim with configurable delay and speed.
-- by Peter Brand
--
-- Note: This script is intended to be used as a lua module in FSUIPC.
-- Pete & John Dowson @http://www.fsuipc.com/
--

local offsets = {
    ElevatorTrim = 0x0BC0
}
local buttonBitOffsets = {
      TrimDown = 21
    , TrimUp   = 22
}
local trimDelta = 32
local pollrate = 50 -- Polling rate in number of polls per second.

local common = require("A2AC172RBravoCommon")

-- Open the Honeycomb Bravo device
local dev, rd, wrf, wr, init = common.OpenHidDevice()

-- Process Loop
function Poll(Time)

    -- Read data from device
    local data, n = com.readlast(dev, rd)

    if n ~= 0 then
        -- There is data so get the buttons
        local buttons = com.gethidbuttons(dev, data)

        local mask = logic.Shl(1, buttonBitOffsets.TrimDown)
        if logic.And(buttons, mask) ~= 0 then
            ipc.writeSW(offsets.ElevatorTrim, ipc.readSW(offsets.ElevatorTrim) - trimDelta)
        end
        mask = logic.Shl(1, buttonBitOffsets.TrimUp)
        if logic.And(buttons, mask) ~= 0 then
            ipc.writeSW(offsets.ElevatorTrim, ipc.readSW(offsets.ElevatorTrim) + trimDelta)
        end
    end
end

-- Start the main event loop
event.timer(1000/pollrate, "Poll")  -- poll values 'Pollrate' times per second
