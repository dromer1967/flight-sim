--
-- Library to control the AutoPilot of the A2A Cessna 172R from the Honeycomb Bravo and partly vice versa.
-- by Peter Brand
--
-- Note: This script is intended to be used as a lua module in FSUIPC.
-- Pete & John Dowson @http://www.fsuipc.com/
--

local p3dControlIds = {
      Vor1ObiDec    = 65662
    , Vor1ObiInc    = 65663
    , HeadingBugInc = 65879
    , HeadingBugDec = 65880
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
local apModeSelector = {
      None = 0
    , Ias  = 1
    , Crs  = 2
    , Hdg  = 3
    , Vs   = 4
    , Alt  = 5
}
local kap140LateralMode = {
      Off  = 0
    , Roll = 1
    , Hdg  = 2
    , Nav  = 3
    , Apr  = 4
    , Rev  = 5
    , Gs   = 6 -- Glide Scope
}
local kap140VerticalMode = {
      Off = 0
    , Vs  = 1
    , Alt = 2
    , Gs  = 3 -- Glide Scope
}
local currentApModeSelector = apModeSelector.None
local pollrate = 20 -- Polling rate in number of polls per second.
local currentA2aEventsState = {
      IsApMasterEnabled  = false
    , Kap140LateralMode  = kap140LateralMode.Off
    , Kap140VerticalMode = kap140VerticalMode.Off
}
local common = require("A2AC172RBravoCommon")
local bravoLedBitsProcessor = require("HoneyCombBravoLedBitsProcessor")

-- Open the Honeycomb Bravo device
local dev, rd, wrf, wr, init = common.OpenHidDevice()

function CopyA2aEventsState(stateToCopy)
    local newState = {
          IsApMasterEnabled  = stateToCopy.IsApMasterEnabled
        , Kap140LateralMode  = stateToCopy.Kap140LateralMode
        , Kap140VerticalMode = stateToCopy.Kap140VerticalMode
    }
    return newState
end

function HasA2aEventsStateChanged(currentState, previousState)
    local hasChanged = false

    if currentState.IsApMasterEnabled  ~= previousState.IsApMasterEnabled
    or currentState.Kap140LateralMode ~= previousState.Kap140LateralMode
    or currentState.Kap140VerticalMode ~= previousState.Kap140VerticalMode then
        hasChanged = true
    end

    return hasChanged
end

function ClearAutoPilotLeds()
    -- Read current feature from Bravo device and convert it to the LEDs
    local featureString, n = com.readfeature(dev)
    bravoLedBitsProcessor.SetLedBitsFromFeatureString(featureString)

    -- Clear bits
    bravoLedBitsProcessor.TurnOffAutoPilotHdgLed()
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

function Kap140IsAPflagEvent(varname, value, userParameter)
    currentA2aEventsState.IsApMasterEnabled = value > 0
end

function Kap140ActiveLateralModeEvent(varname, value, userParameter)
    currentA2aEventsState.Kap140LateralMode = value
end

function Kap140ActiveVerticalModeEvent(varname, value, userParameter)
    currentA2aEventsState.Kap140VerticalMode = value
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
    if  currentApModeSelector == apModeSelector.Alt then
        ipc.writeLvar("kap140_InnerKnob", 1)
    elseif  currentApModeSelector == apModeSelector.Vs then
        ipc.writeLvar("kap140_up_button", 1)
        ipc.writeLvar("kap140_up", 1)
        ipc.sleep(50)
        ipc.writeLvar("kap140_up_button", 0)
    elseif  currentApModeSelector == apModeSelector.Hdg then
        ipc.control(p3dControlIds.HeadingBugInc)
    elseif  currentApModeSelector == apModeSelector.Crs then
        ipc.control(p3dControlIds.Vor1ObiInc)
    elseif currentApModeSelector == apModeSelector.Ias then -- Used for Baro
        ipc.writeLvar("kap140_InnerKnob", 1)
    end
end

function AutoPilotDecreaseButtonEvent(joynum, button, downup)
    if  currentApModeSelector == apModeSelector.Alt then
        ipc.writeLvar("kap140_InnerKnob", -1)
    elseif  currentApModeSelector == apModeSelector.Vs then
        ipc.writeLvar("kap140_dn_button", 1)
        ipc.writeLvar("kap140_dn", 1)
        ipc.sleep(50)
        ipc.writeLvar("kap140_dn_button", 0)
    elseif  currentApModeSelector == apModeSelector.Hdg then
        ipc.control(p3dControlIds.HeadingBugDec)
    elseif  currentApModeSelector == apModeSelector.Crs then
        ipc.control(p3dControlIds.Vor1ObiDec)
    elseif currentApModeSelector == apModeSelector.Ias then -- Used for Baro
        ipc.writeLvar("kap140_InnerKnob", -1)
    end
end

function AutoPilotSelectIasButtonEvent(joynum, button, downup)
    currentApModeSelector = apModeSelector.Ias
end

function AutoPilotSelectCrsButtonEvent(joynum, button, downup)
    currentApModeSelector = apModeSelector.Crs
end

function AutoPilotSelectHdgButtonEvent(joynum, button, downup)
    currentApModeSelector = apModeSelector.Hdg
end

function AutoPilotSelectVsButtonEvent(joynum, button, downup)
    currentApModeSelector = apModeSelector.Vs
end

function AutoPilotSelectAltButtonEvent(joynum, button, downup)
    currentApModeSelector = apModeSelector.Alt
end

-- Initialise previous state
local previousA2aEventsState = CopyA2aEventsState(currentA2aEventsState)

-- Process Loop
function Poll(time)

    -- Only process when the A2A C172R is the active aircraft
    if common.IsActiveAircraftA2AC172R then

        -- Copy current state to a variable to ensure that it does not change during the processing of it
        local currentState = CopyA2aEventsState(currentA2aEventsState)

        -- Compare current with previous state to see if there is something to process
        if HasA2aEventsStateChanged(currentState, previousA2aEventsState) then
            -- Read current feature from Bravo device and convert it to the LEDs
            local featureString, n = com.readfeature(dev)
            bravoLedBitsProcessor.SetLedBitsFromFeatureString(featureString)

            local isApMasterEnabled = currentState.IsApMasterEnabled
            local isApHdgEnabled    = false
            local isApNavEnabled    = false
            local isApAprEnabled    = false
            local isApRevEnabled    = false
            local isApAltEnabled    = false
            local isApVsEnabled     = false
            local isApIasEnabled    = false

            if currentState.Kap140LateralMode == kap140LateralMode.Off then
                -- Do nothing. No LEDs to turn on.
            elseif currentState.Kap140LateralMode == kap140LateralMode.Roll then
                -- Do nothing. There is no indicator available for this.
            elseif currentState.Kap140LateralMode == kap140LateralMode.Hdg then
                isApHdgEnabled = true
            elseif currentState.Kap140LateralMode == kap140LateralMode.Nav then
                isApNavEnabled = true
            elseif currentState.Kap140LateralMode == kap140LateralMode.Apr then
                isApAprEnabled = true
            elseif currentState.Kap140LateralMode == kap140LateralMode.Rev then
                isApRevEnabled = true
            elseif currentState.Kap140LateralMode == kap140LateralMode.Gs then
                isApAprEnabled = true
            end

            if currentState.Kap140VerticalMode == kap140VerticalMode.Off then
                -- Do nothing. No LEDs to turn on.
            elseif currentState.Kap140VerticalMode == kap140VerticalMode.Vs then
                isApVsEnabled = true
            elseif currentState.Kap140VerticalMode == kap140VerticalMode.Alt then
                isApAltEnabled = true
            elseif currentState.Kap140VerticalMode == kap140VerticalMode.Gs then
                isApVsEnabled = true
            end

            -- Set Bravo LED bits according to A2A C172 State
            bravoLedBitsProcessor.SetAutoPilotMasterLed(isApMasterEnabled)
            bravoLedBitsProcessor.SetAutoPilotHdgLed(isApHdgEnabled)
            bravoLedBitsProcessor.SetAutoPilotNavLed(isApNavEnabled)
            bravoLedBitsProcessor.SetAutoPilotAprLed(isApAprEnabled)
            bravoLedBitsProcessor.SetAutoPilotRevLed(isApRevEnabled)
            bravoLedBitsProcessor.SetAutoPilotAltLed(isApAltEnabled)
            bravoLedBitsProcessor.SetAutoPilotVsLed(isApVsEnabled)
            bravoLedBitsProcessor.SetAutoPilotIasLed(isApIasEnabled)

            -- Write LEDs to Bravo device
            local commandString = bravoLedBitsProcessor.GetFeatureStringFromLedBits()
            com.writefeature(dev, commandString, wrf)

            -- Save state for next run
            previousA2aEventsState = CopyA2aEventsState(currentState)
        end
        
    end
end

function Terminate()
    if dev ~= 0 then
        com.close(dev)
    end
end

--
-- Initialise program
--

-- Initialise Autopilot LEDs by turning them off
ClearAutoPilotLeds()

-- Subscribe to LVar events
event.terminate("Terminate")

local lVarPollInterval = 250 -- Milliseconds
event.Lvar("kap140_isAPflag", lVarPollInterval, "Kap140IsAPflagEvent")
event.Lvar("kap140_activeLateral", lVarPollInterval, "Kap140ActiveLateralModeEvent")
event.Lvar("kap140_activeVertical", lVarPollInterval, "Kap140ActiveVerticalModeEvent")

-- Subscribe to Buttons Events
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotHdg, 3, "AutoPilotHdgButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotNav, 3, "AutoPilotNavButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotApr, 3, "AutoPilotAprButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotRev, 3, "AutoPilotRevButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotAlt, 3, "AutoPilotAltButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotVs, 3, "AutoPilotVsButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotIas, 3, "AutoPilotIasButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotMaster, 3, "AutoPilotMasterButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotIncrease, 1, "AutoPilotIncreaseButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotDecrease, 1, "AutoPilotDecreaseButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotSelectIas, 1, "AutoPilotSelectIasButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotSelectCrs, 1, "AutoPilotSelectCrsButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotSelectHdg, 1, "AutoPilotSelectHdgButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotSelectVs, 1, "AutoPilotSelectVsButtonEvent")
event.button(common.HoneycombBravoJoystickNumber, buttons.AutoPilotSelectAlt, 1, "AutoPilotSelectAltButtonEvent")

-- Start the main event loop
event.timer(1000/pollrate, "Poll")  -- poll values 'Pollrate' times per second
