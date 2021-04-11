--
-- Library to control the Annunciator LEDs of the Honeycomb Bravo from the A2A Cessna 172R control variables.
-- by Peter Brand
--
-- Note: This script is intended to be used as a lua module in FSUIPC.
-- Pete & John Dowson @http://www.fsuipc.com/
--

local annunciatorThresholds = {
      MinFsxBusVoltage  =   6.0 -- Volts
    , MinOilTemperature =  38.0 -- Degrees Celcius
    , MaxOilTemperature = 118.0 -- Degrees Celcius
    , MaxOilPressure    = 115.0 -- PSI
    , MaxCht            = 232.0 -- Degrees Celcius
}
local pollrate = 25 -- Polling rate in number of polls per second.
local currentA2aEventsState = {
      IsOnLowOilPressureLight  = false
    , IsOnLowFuelPressureLight = false
    , IsOnVacuumLight          = false
    , IsOnLowVoltsLight        = false
    , IsOnParkingBrake         = false
    , IsOpenDoor               = false
    , IsOpenDoor2              = false
    , IsOnPitotHeatSwitch      = false
    , IsOnEngine1StarterSwitch = false
    , IsOnBattery1Switch       = false
    , IsOnFuelPumpSwitch       = false
    , FSXBusVoltage            = 0.0
    , Engine1OilTemperature    = 0.0
    , Engine1OilPressure       = 0.0
    , Engine1Cht               = 0.0
}
local common = require("A2AC172RBravoCommon")
local bravoLedBitsProcessor = require("HoneyCombBravoLedBitsProcessor")

-- Open the Honeycomb Bravo device
local dev, rd, wrf, wr, init = common.OpenHidDevice()

function CopyA2aEventsState(stateToCopy)
    local newState = {
          IsOnLowOilPressureLight  = stateToCopy.IsOnLowOilPressureLight
        , IsOnLowFuelPressureLight = stateToCopy.IsOnLowFuelPressureLight
        , IsOnVacuumLight          = stateToCopy.IsOnVacuumLight
        , IsOnLowVoltsLight        = stateToCopy.IsOnLowVoltsLight
        , IsOnParkingBrake         = stateToCopy.IsOnParkingBrake
        , IsOpenDoor               = stateToCopy.IsOpenDoor
        , IsOpenDoor2              = stateToCopy.IsOpenDoor2
        , IsOnPitotHeatSwitch      = stateToCopy.IsOnPitotHeatSwitch
        , IsOnEngine1StarterSwitch = stateToCopy.IsOnEngine1StarterSwitch
        , IsOnBattery1Switch       = stateToCopy.IsOnBattery1Switch
        , IsOnFuelPumpSwitch       = stateToCopy.IsOnFuelPumpSwitch
        , FSXBusVoltage            = stateToCopy.FSXBusVoltage
        , Engine1OilTemperature    = stateToCopy.Engine1OilTemperature
        , Engine1OilPressure       = stateToCopy.Engine1OilPressure
        , Engine1Cht               = stateToCopy.Engine1Cht
    }
    return newState
end

function HasA2aEventsStateChanged(currentState, previousState)
    local hasChanged = false

    if currentState.IsOnLowOilPressureLight  ~= previousState.IsOnLowOilPressureLight
    or currentState.IsOnLowFuelPressureLight ~= previousState.IsOnLowFuelPressureLight
    or currentState.IsOnVacuumLight          ~= previousState.IsOnVacuumLight
    or currentState.IsOnLowVoltsLight        ~= previousState.IsOnLowVoltsLight
    or currentState.IsOnParkingBrake         ~= previousState.IsOnParkingBrake
    or currentState.IsOpenDoor               ~= previousState.IsOpenDoor
    or currentState.IsOpenDoor2              ~= previousState.IsOpenDoor2
    or currentState.IsOnPitotHeatSwitch      ~= previousState.IsOnPitotHeatSwitch
    or currentState.IsOnEngine1StarterSwitch ~= previousState.IsOnEngine1StarterSwitch
    or currentState.IsOnBattery1Switch       ~= previousState.IsOnBattery1Switch
    or currentState.IsOnFuelPumpSwitch       ~= previousState.IsOnFuelPumpSwitch
    or currentState.FSXBusVoltage            ~= previousState.FSXBusVoltage
    or currentState.Engine1OilTemperature    ~= previousState.Engine1OilTemperature
    or currentState.Engine1OilPressure       ~= previousState.Engine1OilPressure
    or currentState.Engine1Cht               ~= previousState.Engine1Cht then
        hasChanged = true
    end

    return hasChanged
end

function ClearAnnunicatorLeds()
    -- Read current feature from Bravo device and convert it to the LEDs
    local featureString, n = com.readfeature(dev)
    bravoLedBitsProcessor.SetLedBitsFromFeatureString(featureString)

    -- Clear bits
    bravoLedBitsProcessor.TurnOffMasterWarningLed()
    bravoLedBitsProcessor.TurnOffEngineFireLed()
    bravoLedBitsProcessor.TurnOffLowOilPressureLed()
    bravoLedBitsProcessor.TurnOffLowFuelPressureLed()
    bravoLedBitsProcessor.TurnOffAntiIceLed()
    bravoLedBitsProcessor.TurnOffStarterEngagedLed()
    bravoLedBitsProcessor.TurnOffApuLed()
    bravoLedBitsProcessor.TurnOffMasterCautionLed()
    bravoLedBitsProcessor.TurnOffVacuumLed()
    bravoLedBitsProcessor.TurnOffLowHydPressureLed()
    bravoLedBitsProcessor.TurnOffAuxFuelPumpLed()
    bravoLedBitsProcessor.TurnOffParkingBrakeLed()
    bravoLedBitsProcessor.TurnOffLowVoltsLed()
    bravoLedBitsProcessor.TurnOffDoorLed()

    -- Write to feature
    local commandString = bravoLedBitsProcessor.GetFeatureStringFromLedBits()
    com.writefeature(dev, commandString, wrf)
end

function LowOilPressureLightEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnLowOilPressureLight = value > 0
end

function LowFuelLightEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnLowFuelPressureLight = value > 0
end

function VacuumLightEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnVacuumLight = value > 0
end

function LowVoltsLightEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnLowVoltsLight = value > 0
end

function ParkingBrakeOnLightEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnParkingBrake = value > 0
end

function DoorOpenLightEvent(varname, value, userParameter)
    currentA2aEventsState.IsOpenDoor = value > 0
end

function Door2OpenLightEvent(varname, value, userParameter)
    currentA2aEventsState.IsOpenDoor2 = value > 0
end

function PitotHeatSwitchEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnPitotHeatSwitch = value > 0
end

function Engine1StarterSwitchEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnEngine1StarterSwitch = value > 0
end

function Battery1SwitchEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnBattery1Switch = value > 0
end

function FuelPumpSwitchEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnFuelPumpSwitch = value > 0
end

function FSXBusVoltageEvent(varname, value, userParameter)
    currentA2aEventsState.FSXBusVoltage = value
end

function Engine1OilTemperatureEvent(varname, value, userParameter)
    currentA2aEventsState.Engine1OilTemperature = value
end

function Engine1OilPressureEvent(varname, value, userParameter)
    currentA2aEventsState.Engine1OilPressure = value
end

function Engine1ChtEvent(varname, value, userParameter)
    currentA2aEventsState.Engine1Cht = value
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

            -- Set Bravo Annunciator LED bits according to A2A C172 State
            local isMasterOn = (currentState.FSXBusVoltage > annunciatorThresholds.MinFsxBusVoltage and currentState.IsOnBattery1Switch)
            bravoLedBitsProcessor.SetLowOilPressureLed(currentState.IsOnLowOilPressureLight)
            bravoLedBitsProcessor.SetLowFuelPressureLed(currentState.IsOnLowFuelPressureLight)
            bravoLedBitsProcessor.SetVacuumLed(currentState.IsOnVacuumLight)
            bravoLedBitsProcessor.SetLowVoltsLed(currentState.IsOnLowVoltsLight)
            bravoLedBitsProcessor.SetParkingBrakeLed(isMasterOn and currentState.IsOnParkingBrake)
            bravoLedBitsProcessor.SetDoorLed(isMasterOn and (currentState.IsOpenDoor or currentState.IsOpenDoor2))
            bravoLedBitsProcessor.SetAntiIceLed(isMasterOn and currentState.IsOnPitotHeatSwitch)
            bravoLedBitsProcessor.SetStarterEngagedLed(isMasterOn and currentState.IsOnEngine1StarterSwitch)
            bravoLedBitsProcessor.SetAuxFuelPumpLed(isMasterOn and currentState.IsOnFuelPumpSwitch)
            bravoLedBitsProcessor.SetMasterCautionLed(isMasterOn and currentState.Engine1OilTemperature < annunciatorThresholds.MinOilTemperature)
            bravoLedBitsProcessor.SetMasterWarningLed(isMasterOn and (currentState.Engine1OilTemperature > annunciatorThresholds.MaxOilTemperature
                                                                   or currentState.Engine1OilPressure > annunciatorThresholds.MaxOilPressure
                                                                   or currentState.Engine1Cht > annunciatorThresholds.MaxCht))

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

-- Initialise Annunciator LEDs by turning them off
ClearAnnunicatorLeds()

-- Subscribe to events
local lVarPollInterval = 250 -- Milliseconds
event.Lvar("OilPressLight", lVarPollInterval, "LowOilPressureLightEvent")
event.Lvar("FuelLight", lVarPollInterval, "LowFuelLightEvent")
event.Lvar("VacLight", lVarPollInterval, "VacuumLightEvent")
event.Lvar("VoltsLight", lVarPollInterval, "LowVoltsLightEvent")
event.Lvar("ParkingBrakeOn", lVarPollInterval, "ParkingBrakeOnLightEvent")
event.Lvar("DoorOpen", lVarPollInterval, "DoorOpenLightEvent")
event.Lvar("Door2Open", lVarPollInterval, "Door2OpenLightEvent")
event.Lvar("PitotHeatSwitchSave", lVarPollInterval, "PitotHeatSwitchEvent")
event.Lvar("Eng1_StarterSwitch", lVarPollInterval, "Engine1StarterSwitchEvent")
event.Lvar("Battery1Switch", lVarPollInterval, "Battery1SwitchEvent")
event.Lvar("FuelPumpSwitchSave", lVarPollInterval, "FuelPumpSwitchEvent")
event.Lvar("FSXBusVoltage", lVarPollInterval, "FSXBusVoltageEvent")
event.Lvar("Eng1_OilTemp", lVarPollInterval, "Engine1OilTemperatureEvent")
event.Lvar("Eng1_OilPressure", lVarPollInterval, "Engine1OilPressureEvent")
event.Lvar("Eng1_CHT", lVarPollInterval, "Engine1ChtEvent")

-- Start the main event loop
event.timer(1000/pollrate, "Poll")  -- poll values 'Pollrate' times per second
