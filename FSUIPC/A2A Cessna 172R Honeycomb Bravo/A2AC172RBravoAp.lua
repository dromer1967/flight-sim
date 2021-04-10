--
-- Library to control the AutoPilot of the A2A Cessna 172R from the Honeycomb Bravo and partly vice versa.
-- by Peter Brand
-- Version 0.1
--
-- Note: This script is intended to be used as a lua module in FSUIPC.
-- Pete & John Dowson @http://www.fsuipc.com/
--

local a2aAircraftNameStart = "A2A Cessna 172R"
local isActiveAircraftA2AC172R = false
local p3dControlIds = {
      Vor1ObiDec    = 65662
    , Vor1ObiInc    = 65663
    , HeadingBugInc = 65879
    , HeadingBugDec = 65880
}
local offsets = {
      AircraftName          = 0x3D00
    , AutoPilotMasterSwitch = 0x07BC
}
local buttons = {
      AutoPilotHdg       = 0
    , AutoPilotNav       = 1
    , AutoPilotApr       = 2
    , AutoPilotRev       = 3
    , AutoPilotAlt       = 4
    , AutoPilotVs        = 5
    , AutoPilotIas       = 6
    , AutoPilotMaster    = 7
    , AutoPilotIncrease  = 12
    , AutoPilotDecrease  = 13
    , AutoPilotSelectIas = 16
    , AutoPilotSelectCrs = 17
    , AutoPilotSelectHdg = 18
    , AutoPilotSelectVs  = 19
    , AutoPilotSelectAlt = 20
}
local apModeSelect = {
      None = 0
    , Ias = 1
    , Crs = 2
    , Hdg = 3
    , Vs  = 4
    , Alt = 5
}
local currentApModeSelect = apModeSelect.None
local honeycombBravoDevice = {
      Vendor  = 0x294B -- Honeycomb Bravo vendor id
    , Product = 0x1901 -- Honeycomb Bravo product id
    , Number  = 0      -- Multiple devices of the same name need increasing Device numbers
    , Report  = 0      -- I *think* all joystick types use Input Report 0
}
local pollrate = 25 -- Polling rate in number of polls per second.
local currentA2aEventsState = {
      IsApMasterEnabled = false
    , IsApNavEnabled = false
    , IsApHeadingEnabled = false
    , IsApAltEnabled = false
    , IsApAprEnabled = false
    , IsApRevEnabled = false
}
local bravoLedBitsProcessor = require("HoneyCombBravoLedBitsProcessor")

-- Open the Honeycomb Bravo device
local dev, rd, wrf, wr, init = com.openhid(honeycombBravoDevice.Vendor, honeycombBravoDevice.Product, honeycombBravoDevice.Number, honeycombBravoDevice.Report)

-- Check if device is opened
if dev == 0 then
    ipc.log("A2AC172RBravo: Could not open HID!")
    ipc.exit()
end

function CopyA2aEventsState(stateToCopy)
    local newState = {
        IsApMasterEnabled = stateToCopy.IsApMasterEnabled
    }
    return newState
end

function HasA2aEventsStateChanged(currentState, previousState)
    local hasChanged = false

    if currentState.IsApMasterEnabled ~= previousState.IsApMasterEnabled then
        hasChanged = true
    end

    return hasChanged
end

function ClearAutoPilotLeds()
    -- Read current feature from Bravo device and convert it to the LEDs
    local featureString, n = com.readfeature(dev)
    bravoLedBitsProcessor.SetLedBitsFromFeatureString(featureString)

    -- Clear bits
    bravoLedBitsProcessor.TurnOffAutoPilotHeadingLed()
    bravoLedBitsProcessor.TurnOffAutoPilotNavLed()
    bravoLedBitsProcessor.TurnOffAutoPilotAprLed()
    bravoLedBitsProcessor.TurnOffAutoPilotRevLed()
    bravoLedBitsProcessor.TurnOffAutoPilotAltLed()
    bravoLedBitsProcessor.TurnOffAutoPilotVsLed()
    bravoLedBitsProcessor.TurnOffAutoPilotIasLed()
    bravoLedBitsProcessor.TurnOffAutoPilotMasterLed()

    -- Write to feature
    local commandString = bravoLedBitsProcessor.GetFeatureStringFromLedBits()
    com.writefeature(dev, commandString, wrf)
end

function AircraftNameEvent(offset, value)
    isActiveAircraftA2AC172R = value:sub(1, #a2aAircraftNameStart) == a2aAircraftNameStart
end

function AutoPilotMasterSwitchEvent(offset, value)
    currentA2aEventsState.IsApMasterEnabled = value > 0
end

function AutoPilotHdgButtonEvent(joynum, button, downup)
    if downup == 1 then -- Pressed
        ipc.writeLvar("kap140_hdg_button", 1)
        ipc.writeLvar("kap140_hdg", 1)
    elseif downup == 0 then -- Released
        ipc.writeLvar("kap140_hdg_button", 0)
    end
end

function AutoPilotNavButtonEvent(joynum, button, downup)
    if downup == 1 then -- Pressed
        ipc.writeLvar("kap140_nav_button", 1)
        ipc.writeLvar("kap140_nav", 1)
    elseif downup == 0 then -- Released
        ipc.writeLvar("kap140_nav_button", 0)
    end
end

function AutoPilotAprButtonEvent(joynum, button, downup)
    if downup == 1 then -- Pressed
        ipc.writeLvar("kap140_apr_button", 1)
        ipc.writeLvar("kap140_apr", 1)
    elseif downup == 0 then -- Released
        ipc.writeLvar("kap140_apr_button", 0)
    end
end

function AutoPilotRevButtonEvent(joynum, button, downup)
    if downup == 1 then -- Pressed
        ipc.writeLvar("kap140_rev_button", 1)
        ipc.writeLvar("kap140_rev", 1)
    elseif downup == 0 then -- Released
        ipc.writeLvar("kap140_rev_button", 0)
    end
end

function AutoPilotAltButtonEvent(joynum, button, downup)
    if downup == 1 then -- Pressed
        ipc.writeLvar("kap140_alt_button", 1)
        ipc.writeLvar("kap140_alt", 1)
    elseif downup == 0 then -- Released
        ipc.writeLvar("kap140_alt_button", 0)
    end
end

function AutoPilotVsButtonEvent(joynum, button, downup)
    if downup == 1 then -- Pressed
        ipc.writeLvar("kap140_arm_button", 1)
        ipc.writeLvar("kap140_arm", 1)
    elseif downup == 0 then -- Released
        ipc.writeLvar("kap140_arm_button", 0)
    end
end

function AutoPilotIasButtonEvent(joynum, button, downup)
    if downup == 1 then -- Pressed
        ipc.writeLvar("kap140_baro_button", 1)
        ipc.writeLvar("kap140_baro", 1)
    elseif downup == 0 then -- Released
        ipc.writeLvar("kap140_baro_button", 0)
    end
end

function AutoPilotMasterButtonEvent(joynum, button, downup)
    if downup == 1 then -- Pressed
        ipc.writeLvar("kap140_ap_button", 1)
        ipc.writeLvar("kap140_ap", 1)
    elseif downup == 0 then -- Released
        ipc.writeLvar("kap140_ap_button", 0)
    end
end

function AutoPilotIncreaseButtonEvent(joynum, button, downup)
    if  currentApModeSelect == apModeSelect.Alt then
        ipc.writeLvar("kap140_InnerKnob", 1)
    elseif  currentApModeSelect == apModeSelect.Vs then
        ipc.writeLvar("kap140_up_button", 1)
        ipc.writeLvar("kap140_up", 1)
        ipc.sleep(50)
        ipc.writeLvar("kap140_up_button", 0)
    elseif  currentApModeSelect == apModeSelect.Hdg then
        ipc.control(p3dControlIds.HeadingBugInc)
    elseif  currentApModeSelect == apModeSelect.Crs then
        ipc.control(p3dControlIds.Vor1ObiInc)
    elseif currentApModeSelect == apModeSelect.Ias then -- Used for Baro
        ipc.writeLvar("kap140_InnerKnob", 1)
    end
end

function AutoPilotDecreaseButtonEvent(joynum, button, downup)
    if  currentApModeSelect == apModeSelect.Alt then
        ipc.writeLvar("kap140_InnerKnob", -1)
    elseif  currentApModeSelect == apModeSelect.Vs then
        ipc.writeLvar("kap140_dn_button", 1)
        ipc.writeLvar("kap140_dn", 1)
        ipc.sleep(50)
        ipc.writeLvar("kap140_dn_button", 0)
    elseif  currentApModeSelect == apModeSelect.Hdg then
        ipc.control(p3dControlIds.HeadingBugDec)
    elseif  currentApModeSelect == apModeSelect.Crs then
        ipc.control(p3dControlIds.Vor1ObiDec)
    elseif currentApModeSelect == apModeSelect.Ias then -- Used for Baro
        ipc.writeLvar("kap140_InnerKnob", -1)
    end
end

function AutoPilotSelectIasButtonEvent(joynum, button, downup)
    currentApModeSelect = apModeSelect.Ias
end

function AutoPilotSelectCrsButtonEvent(joynum, button, downup)
    currentApModeSelect = apModeSelect.Crs
end

function AutoPilotSelectHdgButtonEvent(joynum, button, downup)
    currentApModeSelect = apModeSelect.Hdg
end

function AutoPilotSelectVsButtonEvent(joynum, button, downup)
    currentApModeSelect = apModeSelect.Vs
end

function AutoPilotSelectAltButtonEvent(joynum, button, downup)
    currentApModeSelect = apModeSelect.Alt
end

-- Initialise previous state
local previousA2aEventsState = CopyA2aEventsState(currentA2aEventsState)

-- Process Loop
function Poll(time)

    -- Only process when the A2A C172R is the active aircraft
    if isActiveAircraftA2AC172R then

        -- Copy current state to a variable to ensure that it does not change during the processing of it
        local currentState = CopyA2aEventsState(currentA2aEventsState)

        -- Compare current with previous state to see if there is something to process
        if HasA2aEventsStateChanged(currentState, previousA2aEventsState) then
            -- Read current feature from Bravo device and convert it to the LEDs
            local featureString, n = com.readfeature(dev)
            bravoLedBitsProcessor.SetLedBitsFromFeatureString(featureString)

            -- Set Bravo LED bits according to A2A C172 State
            bravoLedBitsProcessor.SetAutoPilotMasterLed(currentState.IsApMasterEnabled)

            -- Write LEDs to Bravo device
            local commandString = bravoLedBitsProcessor.GetFeatureStringFromLedBits()
            com.writefeature(dev, commandString, wrf)

            -- Save state for next run
            previousA2aEventsState = CopyA2aEventsState(currentState)
        end
        
    end
end

--
-- Initialise program
--

-- Initialise device if applicable
if init then
    -- Deal with initial values, if supplied (some joysticks don't)
    ipc.log("A2AC172RBravo: Init Seen!")
    Poll(0)
end

-- Initialise Autopilot LEDs by turning them off
ClearAutoPilotLeds()

-- Subscribe to events
local lVarPollInterval = 250 -- Milliseconds
event.offset(offsets.AircraftName, "STR", 0, "AircraftNameEvent")
event.offset(offsets.AutoPilotMasterSwitch, "UD", 0, "AutoPilotMasterSwitchEvent")

event.button(0, buttons.AutoPilotHdg, 3, "AutoPilotHdgButtonEvent")
event.button(0, buttons.AutoPilotNav, 3, "AutoPilotNavButtonEvent")
event.button(0, buttons.AutoPilotApr, 3, "AutoPilotAprButtonEvent")
event.button(0, buttons.AutoPilotRev, 3, "AutoPilotRevButtonEvent")
event.button(0, buttons.AutoPilotAlt, 3, "AutoPilotAltButtonEvent")
event.button(0, buttons.AutoPilotVs, 3, "AutoPilotVsButtonEvent")
event.button(0, buttons.AutoPilotIas, 3, "AutoPilotIasButtonEvent")
event.button(0, buttons.AutoPilotMaster, 3, "AutoPilotMasterButtonEvent")
event.button(0, buttons.AutoPilotIncrease, 1, "AutoPilotIncreaseButtonEvent")
event.button(0, buttons.AutoPilotDecrease, 1, "AutoPilotDecreaseButtonEvent")
event.button(0, buttons.AutoPilotSelectIas, 1, "AutoPilotSelectIasButtonEvent")
event.button(0, buttons.AutoPilotSelectCrs, 1, "AutoPilotSelectCrsButtonEvent")
event.button(0, buttons.AutoPilotSelectHdg, 1, "AutoPilotSelectHdgButtonEvent")
event.button(0, buttons.AutoPilotSelectVs, 1, "AutoPilotSelectVsButtonEvent")
event.button(0, buttons.AutoPilotSelectAlt, 1, "AutoPilotSelectAltButtonEvent")

-- Initialse all LEDs by turning them off
local commandString = bravoLedBitsProcessor.GetFeatureStringFromLedBits()
com.writefeature(dev, commandString, wrf)

if pollrate == 0 then
    -- Ouch. Mustn't divide by zero!
    pollrate = 25
end
-- Start the main event loop
event.timer(1000/pollrate, "Poll")  -- poll values 'Pollrate' times per second
