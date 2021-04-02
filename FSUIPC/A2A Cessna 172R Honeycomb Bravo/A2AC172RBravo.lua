--
-- Library to control the LEDs of the Honeycomb Bravo from the A2A Cessna 172R control variables.
-- by Peter Brand
-- Version 0.1
--
-- Note: This script is intended to be used as a lua module in FSUIPC.
-- Pete & John Dowson @http://www.fsuipc.com/
--

local offsets = {
    AircraftName = 0x3D00
}
local honeycombBravoDevice = {
      Vendor  = 0x294B -- Honeycomb Bravo vendor id
    , Product = 0x1901 -- Honeycomb Bravo product id
    , Number  = 0      -- Multiple devices of the same name need increasing Device numbers
    , Report  = 0      -- I *think* all joystick types use Input Report 0
}
local pollrate = 25 -- Polling rate in number of polls per second.
local isActiveAircraftA2AC172R = false
local currentA2aEventsState = {
    IsOnLowOilPressureLight = false
  , IsOnLowFuelPressureLight = false
  , IsOnVacuumLight = false
  , IsOnLowVoltsLight = false
  , IsOnParkingBrake = false
  , IsOpenDoor = false
  , IsOpenDoor2 = false
  , IsOnPitotHeatSwitch = false
  , IsOnEng1StarterSwitch = false
  , IsOnBattery1Switch = false
  , IsOnFuelPumpSwitch = false
  , FSXBusVoltage = 0.0
  , Eng1OilTemp = 0.0
  , Eng1OilPressure = 0.0
  , Eng1Cht = 0.0
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
          IsOnLowOilPressureLight  = stateToCopy.IsOnLowOilPressureLight
        , IsOnLowFuelPressureLight = stateToCopy.IsOnLowFuelPressureLight
        , IsOnVacuumLight          = stateToCopy.IsOnVacuumLight
        , IsOnLowVoltsLight        = stateToCopy.IsOnLowVoltsLight
        , IsOnParkingBrake         = stateToCopy.IsOnParkingBrake
        , IsOpenDoor               = stateToCopy.IsOpenDoor
        , IsOpenDoor2              = stateToCopy.IsOpenDoor2
        , IsOnPitotHeatSwitch      = stateToCopy.IsOnPitotHeatSwitch
        , IsOnEng1StarterSwitch    = stateToCopy.IsOnEng1StarterSwitch
        , IsOnBattery1Switch       = stateToCopy.IsOnBattery1Switch
        , IsOnFuelPumpSwitch       = stateToCopy.IsOnFuelPumpSwitch
        , FSXBusVoltage            = stateToCopy.FSXBusVoltage
        , Eng1OilTemp              = stateToCopy.Eng1OilTemp
        , Eng1OilPressure          = stateToCopy.Eng1OilPressure
        , Eng1Cht                  = stateToCopy.Eng1Cht
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
    or currentState.IsOnEng1StarterSwitch    ~= previousState.IsOnEng1StarterSwitch
    or currentState.IsOnBattery1Switch       ~= previousState.IsOnBattery1Switch
    or currentState.IsOnFuelPumpSwitch       ~= previousState.IsOnFuelPumpSwitch
    or currentState.FSXBusVoltage            ~= previousState.FSXBusVoltage
    or currentState.Eng1OilTemp              ~= previousState.Eng1OilTemp
    or currentState.Eng1OilPressure          ~= previousState.Eng1OilPressure
    or currentState.Eng1Cht                  ~= previousState.Eng1Cht then
        hasChanged = true
    end

    return hasChanged
end

function AircraftNameEvent(offset, value)
    local a2aAircraftName = "A2A Cessna 172R"
    isActiveAircraftA2AC172R = value:sub(1, #a2aAircraftName) == a2aAircraftName
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

function Eng1StarterSwitchEvent(varname, value, userParameter)
    currentA2aEventsState.IsOnEng1StarterSwitch = value > 0
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

function Eng1OilTempEvent(varname, value, userParameter)
    currentA2aEventsState.Eng1OilTemp = value
end

function Eng1OilPressureEvent(varname, value, userParameter)
    currentA2aEventsState.Eng1OilPressure = value
end

function Eng1ChtEvent(varname, value, userParameter)
    currentA2aEventsState.Eng1Cht = value
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
            bravoLedBitsProcessor.SetLowOilPressureLed(currentState.IsOnLowOilPressureLight)
            bravoLedBitsProcessor.SetLowFuelPressureLed(currentState.IsOnLowFuelPressureLight)
            bravoLedBitsProcessor.SetVacuumLed(currentState.IsOnVacuumLight)
            bravoLedBitsProcessor.SetLowVoltsLed(currentState.IsOnLowVoltsLight)
            local isMasterOn = (currentState.FSXBusVoltage > 6.0 and currentState.IsOnBattery1Switch)
            bravoLedBitsProcessor.SetParkingBrakeLed(isMasterOn and currentState.IsOnParkingBrake)
            bravoLedBitsProcessor.SetDoorLed(isMasterOn and (currentState.IsOpenDoor or currentState.IsOpenDoor2))
            bravoLedBitsProcessor.SetAntiIceLed(isMasterOn and currentState.IsOnPitotHeatSwitch)
            bravoLedBitsProcessor.SetStarterEngagedLed(isMasterOn and currentState.IsOnEng1StarterSwitch)
            bravoLedBitsProcessor.SetAuxFuelPumpLed(isMasterOn and currentState.IsOnFuelPumpSwitch)
            bravoLedBitsProcessor.SetMasterCautionLed(isMasterOn and currentState.Eng1OilTemp < 38.0)
            bravoLedBitsProcessor.SetMasterWarningLed(isMasterOn and (currentState.Eng1OilTemp > 118 or currentState.Eng1OilPressure > 115 or currentState.Eng1Cht > 232))

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

-- Subscribe to events
local lVarPollInterval = 250 -- Milliseconds
event.offset(offsets.AircraftName, "STR", 0, "AircraftNameEvent")
event.Lvar("OilPressLight", lVarPollInterval, "LowOilPressureLightEvent")
event.Lvar("FuelLight", lVarPollInterval, "LowFuelLightEvent")
event.Lvar("VacLight", lVarPollInterval, "VacuumLightEvent")
event.Lvar("VoltsLight", lVarPollInterval, "LowVoltsLightEvent")
event.Lvar("ParkingBrakeOn", lVarPollInterval, "ParkingBrakeOnLightEvent")
event.Lvar("DoorOpen", lVarPollInterval, "DoorOpenLightEvent")
event.Lvar("Door2Open", lVarPollInterval, "Door2OpenLightEvent")
event.Lvar("PitotHeatSwitchSave", lVarPollInterval, "PitotHeatSwitchEvent")
event.Lvar("Eng1_StarterSwitch", lVarPollInterval, "Eng1StarterSwitchEvent")
event.Lvar("Battery1Switch", lVarPollInterval, "Battery1SwitchEvent")
event.Lvar("FuelPumpSwitchSave", lVarPollInterval, "FuelPumpSwitchEvent")
event.Lvar("FSXBusVoltage", lVarPollInterval, "FSXBusVoltageEvent")
event.Lvar("Eng1_OilTemp", lVarPollInterval, "Eng1OilTempEvent")
event.Lvar("Eng1_OilPressure", lVarPollInterval, "Eng1OilPressureEvent")
event.Lvar("Eng1_CHT", lVarPollInterval, "Eng1ChtEvent")

-- Initialse all LEDs by turning them off
local commandString = bravoLedBitsProcessor.GetFeatureStringFromLedBits()
com.writefeature(dev, commandString, wrf)

if pollrate == 0 then
    -- Ouch. Mustn't divide by zero!
    pollrate = 25
end
-- Start the main event loop
event.timer(1000/pollrate, "Poll")  -- poll values 'Pollrate' times per second
