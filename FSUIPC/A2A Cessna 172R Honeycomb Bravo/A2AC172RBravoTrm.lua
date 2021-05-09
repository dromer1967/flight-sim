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
local trimDownButtonMask = logic.Shl(1, buttonBitOffsets.TrimDown)
local trimUpButtonMask = logic.Shl(1, buttonBitOffsets.TrimUp)
local trimDelta = 16
local trimDeltaLarge = 128
local pollInterval = 10 -- Polling interval in milliseconds.
local fastTimeLimit = 30
local lastTimeTrimDown = nil
local lastTimeTrimUp = nil
local previousButtons = 0

local common = require("A2AC172RBravoCommon")

-- Open the Honeycomb Bravo device
local dev, rd, wrf, wr, init = common.OpenHidDevice()

-- Process Loop
function Poll(Time)
    local elapsedTime = ipc.elapsedtime()

    -- Read data from device
    local data, n = com.readlast(dev, rd)

    if n ~= 0 then
        -- There is data so get the buttons
        local buttons = com.gethidbuttons(dev, data)
        local buttonDifferences = logic.Xor(buttons, previousButtons)
        previousButtons = buttons

        if buttonDifferences ~= 0 then

            local delta = trimDelta
            if logic.And(buttonDifferences, trimDownButtonMask) ~= 0 then
                if (lastTimeTrimDown ~= nil) and ((elapsedTime - lastTimeTrimDown) < fastTimeLimit) then
                    delta = trimDeltaLarge
                end
                lastTimeTrimDown = elapsedTime
                ipc.writeSW(offsets.ElevatorTrim, ipc.readSW(offsets.ElevatorTrim) - delta)
            end
            if logic.And(buttonDifferences, trimUpButtonMask) ~= 0 then
                if (lastTimeTrimUp ~= nil) and ((elapsedTime - lastTimeTrimUp) < fastTimeLimit) then
                    delta = trimDeltaLarge
                end
                lastTimeTrimUp = elapsedTime
                ipc.writeSW(offsets.ElevatorTrim, ipc.readSW(offsets.ElevatorTrim) + delta)
            end

        end

    end
end

function Terminate()
    if dev ~= 0 then
        com.close(dev)
    end
end

-- Subscribe to events
event.terminate("Terminate")

-- Start the main event loop
event.timer(pollInterval, "Poll")
