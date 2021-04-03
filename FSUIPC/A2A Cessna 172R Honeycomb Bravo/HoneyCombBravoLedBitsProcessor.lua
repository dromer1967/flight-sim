--
-- Library to set the individual LED bits of the Honeycomb Bravo and convert it to a command string which can be send to the device.
-- by Peter Brand
-- Version 0.1
--
-- based on https://github.com/danderio/Honeycomb-Bravo-Lua_scripts/blob/main/HoneycombBravoLEDs.lua
--
-- Note: This script is intended to be used as a lua module within a lua script in FSUIPC.
-- Pete & John Dowson @http://www.fsuipc.com/
--

local bravoLedBitsProcessor = {
      AutoPilot = {
        Bits                = 0x00 -- The bits value for the Auto Pilot LEDs
      , HeadingBitMask      = 0x01
      , NavBitMask          = 0x02
      , AprBitMask          = 0x04
      , RevBitMask          = 0x08
      , AltBitMask          = 0x10
      , VsBitMask           = 0x20
      , IasBitMask          = 0x40
      , ApMasterBitMask     = 0x80
    }
    , Lights1 = {
        Bits                  = 0x00 -- The bits value for the Lights1 LEDs
      , LeftGearGreenBitMask  = 0x01
      , LeftGearRedBitMask    = 0x02
      , NoseGearGreenBitMask  = 0x04
      , NoseGearRedBitMask    = 0x08
      , RightGearGreenBitMask = 0x10
      , RightGearRedBitMask   = 0x20
      , MasterWarningBitMask  = 0x40
      , EngineFireBitMask     = 0x80
    }
    , Lights2 = {
        Bits                   = 0x00 -- The bits value for the Lights2 LEDs
      , LowOilPressureBitMask  = 0x01
      , LowFuelPressureBitMask = 0x02
      , AntiIceBitMask         = 0x04
      , StarterEngagedBitMask  = 0x08
      , ApuBitMask             = 0x10
      , MasterCautionBitMask   = 0x20
      , VacuumBitMask          = 0x40
      , LowHydPressureBitMask  = 0x80
    }
    , Lights3 = {
        Bits                   = 0x00 -- The bits value for the Lights3 LEDs
      , AuxFuelPumpBitMask     = 0x01
      , ParkingBrakeBitMask    = 0x02
      , LowVoltsBitMask        = 0x04
      , DoorBitMask            = 0x08
      }
}

--
-- Functions
--

function bravoLedBitsProcessor.SetLedBitsFromFeatureString(featureString)
    ipc.log("FeatureString is '" .. featureString .. "' with length " .. #featureString)
    if #featureString == 5 then
        -- featureString consists of five bytes. The first is the Report ID and skipped.
        bravoLedBitsProcessor.AutoPilot.Bits = string.byte(featureString:sub(2, 2))
        bravoLedBitsProcessor.Lights1.Bits = string.byte(featureString:sub(3, 3))
        bravoLedBitsProcessor.Lights2.Bits = string.byte(featureString:sub(4, 4))
        bravoLedBitsProcessor.Lights3.Bits = string.byte(featureString:sub(5, 5))
    else
        bravoLedBitsProcessor.AutoPilot.Bits = 0x00
        bravoLedBitsProcessor.Lights1.Bits = 0x00
        bravoLedBitsProcessor.Lights2.Bits = 0x00
        bravoLedBitsProcessor.Lights3.Bits = 0x00
    end
    ipc.log("Feature to bits =  " .. bravoLedBitsProcessor.AutoPilot.Bits .. bravoLedBitsProcessor.Lights1.Bits .. bravoLedBitsProcessor.Lights2.Bits .. bravoLedBitsProcessor.Lights3.Bits)
end

function bravoLedBitsProcessor.GetFeatureStringFromLedBits()
    ipc.log("Feature from bits" .. bravoLedBitsProcessor.AutoPilot.Bits .. bravoLedBitsProcessor.Lights1.Bits .. bravoLedBitsProcessor.Lights2.Bits .. bravoLedBitsProcessor.Lights3.Bits)
    local commandString = string.char(0)
                       .. string.char(bravoLedBitsProcessor.AutoPilot.Bits)
                       .. string.char(bravoLedBitsProcessor.Lights1.Bits)
                       .. string.char(bravoLedBitsProcessor.Lights2.Bits)
                       .. string.char(bravoLedBitsProcessor.Lights3.Bits)
    return commandString
end

-- Auto Pilot LEDs

function bravoLedBitsProcessor.SetAutoPilotHeadingLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAutoPilotHeadingLed()
    else
        bravoLedBitsProcessor.TurnOffAutoPilotHeadingLed()
    end
end

function bravoLedBitsProcessor.TurnOnAutoPilotHeadingLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.Or(bravoLedBitsProcessor.AutoPilot.Bits, bravoLedBitsProcessor.AutoPilot.HeadingBitMask)
end

function bravoLedBitsProcessor.TurnOffAutoPilotHeadingLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.And(bravoLedBitsProcessor.AutoPilot.Bits, logic.Not(bravoLedBitsProcessor.AutoPilot.HeadingBitMask))
end

function bravoLedBitsProcessor.SetAutoPilotNavLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAutoPilotNavLed()
    else
        bravoLedBitsProcessor.TurnOffAutoPilotNavLed()
    end
end

function bravoLedBitsProcessor.TurnOnAutoPilotNavLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.Or(bravoLedBitsProcessor.AutoPilot.Bits, bravoLedBitsProcessor.AutoPilot.NavBitMask)
end

function bravoLedBitsProcessor.TurnOffAutoPilotNavLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.And(bravoLedBitsProcessor.AutoPilot.Bits, logic.Not(bravoLedBitsProcessor.AutoPilot.NavBitMask))
end

function bravoLedBitsProcessor.SetAutoPilotAprLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAutoPilotAprLed()
    else
        bravoLedBitsProcessor.TurnOffAutoPilotAprLed()
    end
end

function bravoLedBitsProcessor.TurnOnAutoPilotAprLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.Or(bravoLedBitsProcessor.AutoPilot.Bits, bravoLedBitsProcessor.AutoPilot.AprBitMask)
end

function bravoLedBitsProcessor.TurnOffAutoPilotAprLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.And(bravoLedBitsProcessor.AutoPilot.Bits, logic.Not(bravoLedBitsProcessor.AutoPilot.AprBitMask))
end

function bravoLedBitsProcessor.SetAutoPilotRevLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAutoPilotRevLed()
    else
        bravoLedBitsProcessor.TurnOffAutoPilotRevLed()
    end
end

function bravoLedBitsProcessor.TurnOnAutoPilotRevLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.Or(bravoLedBitsProcessor.AutoPilot.Bits, bravoLedBitsProcessor.AutoPilot.RevBitMask)
end

function bravoLedBitsProcessor.TurnOffAutoPilotRevLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.And(bravoLedBitsProcessor.AutoPilot.Bits, logic.Not(bravoLedBitsProcessor.AutoPilot.RevBitMask))
end

function bravoLedBitsProcessor.SetAutoPilotAltLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAutoPilotAltLed()
    else
        bravoLedBitsProcessor.TurnOffAutoPilotAltLed()
    end
end

function bravoLedBitsProcessor.TurnOnAutoPilotAltLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.Or(bravoLedBitsProcessor.AutoPilot.Bits, bravoLedBitsProcessor.AutoPilot.AltBitMask)
end

function bravoLedBitsProcessor.TurnOffAutoPilotAltLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.And(bravoLedBitsProcessor.AutoPilot.Bits, logic.Not(bravoLedBitsProcessor.AutoPilot.AltBitMask))
end

function bravoLedBitsProcessor.SetAutoPilotVsLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAutoPilotVsLed()
    else
        bravoLedBitsProcessor.TurnOffAutoPilotVsLed()
    end
end

function bravoLedBitsProcessor.TurnOnAutoPilotVsLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.Or(bravoLedBitsProcessor.AutoPilot.Bits, bravoLedBitsProcessor.AutoPilot.VsBitMask)
end

function bravoLedBitsProcessor.TurnOffAutoPilotVsLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.And(bravoLedBitsProcessor.AutoPilot.Bits, logic.Not(bravoLedBitsProcessor.AutoPilot.VsBitMask))
end

function bravoLedBitsProcessor.SetAutoPilotIasLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAutoPilotIasLed()
    else
        bravoLedBitsProcessor.TurnOffAutoPilotIasLed()
    end
end

function bravoLedBitsProcessor.TurnOnAutoPilotIasLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.Or(bravoLedBitsProcessor.AutoPilot.Bits, bravoLedBitsProcessor.AutoPilot.IasBitMask)
end

function bravoLedBitsProcessor.TurnOffAutoPilotIasLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.And(bravoLedBitsProcessor.AutoPilot.Bits, logic.Not(bravoLedBitsProcessor.AutoPilot.IasBitMask))
end

function bravoLedBitsProcessor.SetAutoPilotMasterLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAutoPilotMasterLed()
    else
        bravoLedBitsProcessor.TurnOffAutoPilotMasterLed()
    end
end

function bravoLedBitsProcessor.TurnOnAutoPilotMasterLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.Or(bravoLedBitsProcessor.AutoPilot.Bits, bravoLedBitsProcessor.AutoPilot.ApMasterBitMask)
end

function bravoLedBitsProcessor.TurnOffAutoPilotMasterLed()
    bravoLedBitsProcessor.AutoPilot.Bits = logic.And(bravoLedBitsProcessor.AutoPilot.Bits, logic.Not(bravoLedBitsProcessor.AutoPilot.ApMasterBitMask))
end

-- First set of lights

function bravoLedBitsProcessor.SetLeftGearGreenLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnLeftGearGreenLed()
    else
        bravoLedBitsProcessor.TurnOffLeftGearGreenLed()
    end
end

function bravoLedBitsProcessor.TurnOnLeftGearGreenLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.Or(bravoLedBitsProcessor.Lights1.Bits, bravoLedBitsProcessor.Lights1.LeftGearGreenBitMask)
end

function bravoLedBitsProcessor.TurnOffLeftGearGreenLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.And(bravoLedBitsProcessor.Lights1.Bits, logic.Not(bravoLedBitsProcessor.Lights1.LeftGearGreenBitMask))
end

function bravoLedBitsProcessor.SetLeftGearRedLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnLeftGearRedLed()
    else
        bravoLedBitsProcessor.TurnOffLeftGearRedLed()
    end
end

function bravoLedBitsProcessor.TurnOnLeftGearRedLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.Or(bravoLedBitsProcessor.Lights1.Bits, bravoLedBitsProcessor.Lights1.LeftGearRedBitMask)
end

function bravoLedBitsProcessor.TurnOffLeftGearRedLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.And(bravoLedBitsProcessor.Lights1.Bits, logic.Not(bravoLedBitsProcessor.Lights1.LeftGearRedBitMask))
end

function bravoLedBitsProcessor.SetNoseGearGreenLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnNoseGearGreenLed()
    else
        bravoLedBitsProcessor.TurnOffNoseGearGreenLed()
    end
end

function bravoLedBitsProcessor.TurnOnNoseGearGreenLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.Or(bravoLedBitsProcessor.Lights1.Bits, bravoLedBitsProcessor.Lights1.NoseGearGreenBitMask)
end

function bravoLedBitsProcessor.TurnOffNoseGearGreenLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.And(bravoLedBitsProcessor.Lights1.Bits, logic.Not(bravoLedBitsProcessor.Lights1.NoseGearGreenBitMask))
end

function bravoLedBitsProcessor.SetNoseGearRedLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnNoseGearRedLed()
    else
        bravoLedBitsProcessor.TurnOffNoseGearRedLed()
    end
end

function bravoLedBitsProcessor.TurnOnNoseGearRedLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.Or(bravoLedBitsProcessor.Lights1.Bits, bravoLedBitsProcessor.Lights1.NoseGearRedBitMask)
end

function bravoLedBitsProcessor.TurnOffNoseGearRedLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.And(bravoLedBitsProcessor.Lights1.Bits, logic.Not(bravoLedBitsProcessor.Lights1.NoseGearRedBitMask))
end

function bravoLedBitsProcessor.SetRightGearGreenLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnRightGearGreenLed()
    else
        bravoLedBitsProcessor.TurnOffRightGearGreenLed()
    end
end

function bravoLedBitsProcessor.TurnOnRightGearGreenLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.Or(bravoLedBitsProcessor.Lights1.Bits, bravoLedBitsProcessor.Lights1.RightGearGreenBitMask)
end

function bravoLedBitsProcessor.TurnOffRightGearGreenLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.And(bravoLedBitsProcessor.Lights1.Bits, logic.Not(bravoLedBitsProcessor.Lights1.RightGearGreenBitMask))
end

function bravoLedBitsProcessor.SetRightGearRedLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnRightGearRedLed()
    else
        bravoLedBitsProcessor.TurnOffRightGearRedLed()
    end
end

function bravoLedBitsProcessor.TurnOnRightGearRedLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.Or(bravoLedBitsProcessor.Lights1.Bits, bravoLedBitsProcessor.Lights1.RightGearRedBitMask)
end

function bravoLedBitsProcessor.TurnOffRightGearRedLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.And(bravoLedBitsProcessor.Lights1.Bits, logic.Not(bravoLedBitsProcessor.Lights1.RightGearRedBitMask))
end

function bravoLedBitsProcessor.SetMasterWarningLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnMasterWarningLed()
    else
        bravoLedBitsProcessor.TurnOffMasterWarningLed()
    end
end

function bravoLedBitsProcessor.TurnOnMasterWarningLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.Or(bravoLedBitsProcessor.Lights1.Bits, bravoLedBitsProcessor.Lights1.MasterWarningBitMask)
end

function bravoLedBitsProcessor.TurnOffMasterWarningLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.And(bravoLedBitsProcessor.Lights1.Bits, logic.Not(bravoLedBitsProcessor.Lights1.MasterWarningBitMask))
end

function bravoLedBitsProcessor.SetEngineFireLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnEngineFireLed()
    else
        bravoLedBitsProcessor.TurnOffEngineFireLed()
    end
end

function bravoLedBitsProcessor.TurnOnEngineFireLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.Or(bravoLedBitsProcessor.Lights1.Bits, bravoLedBitsProcessor.Lights1.EngineFireBitMask)
end

function bravoLedBitsProcessor.TurnOffEngineFireLed()
    bravoLedBitsProcessor.Lights1.Bits = logic.And(bravoLedBitsProcessor.Lights1.Bits, logic.Not(bravoLedBitsProcessor.Lights1.EngineFireBitMask))
end

-- Second set of lights

function bravoLedBitsProcessor.SetLowOilPressureLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnLowOilPressureLed()
    else
        bravoLedBitsProcessor.TurnOffLowOilPressureLed()
    end
end

function bravoLedBitsProcessor.TurnOnLowOilPressureLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.Or(bravoLedBitsProcessor.Lights2.Bits, bravoLedBitsProcessor.Lights2.LowOilPressureBitMask)
end

function bravoLedBitsProcessor.TurnOffLowOilPressureLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.And(bravoLedBitsProcessor.Lights2.Bits, logic.Not(bravoLedBitsProcessor.Lights2.LowOilPressureBitMask))
end

function bravoLedBitsProcessor.SetLowFuelPressureLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnLowFuelPressureLed()
    else
        bravoLedBitsProcessor.TurnOffLowFuelPressureLed()
    end
end

function bravoLedBitsProcessor.TurnOnLowFuelPressureLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.Or(bravoLedBitsProcessor.Lights2.Bits, bravoLedBitsProcessor.Lights2.LowFuelPressureBitMask)
end

function bravoLedBitsProcessor.TurnOffLowFuelPressureLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.And(bravoLedBitsProcessor.Lights2.Bits, logic.Not(bravoLedBitsProcessor.Lights2.LowFuelPressureBitMask))
end

function bravoLedBitsProcessor.SetAntiIceLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAntiIceLed()
    else
        bravoLedBitsProcessor.TurnOffAntiIceLed()
    end
end

function bravoLedBitsProcessor.TurnOnAntiIceLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.Or(bravoLedBitsProcessor.Lights2.Bits, bravoLedBitsProcessor.Lights2.AntiIceBitMask)
end

function bravoLedBitsProcessor.TurnOffAntiIceLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.And(bravoLedBitsProcessor.Lights2.Bits, logic.Not(bravoLedBitsProcessor.Lights2.AntiIceBitMask))
end

function bravoLedBitsProcessor.SetStarterEngagedLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnStarterEngagedLed()
    else
        bravoLedBitsProcessor.TurnOffStarterEngagedLed()
    end
end

function bravoLedBitsProcessor.TurnOnStarterEngagedLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.Or(bravoLedBitsProcessor.Lights2.Bits, bravoLedBitsProcessor.Lights2.StarterEngagedBitMask)
end

function bravoLedBitsProcessor.TurnOffStarterEngagedLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.And(bravoLedBitsProcessor.Lights2.Bits, logic.Not(bravoLedBitsProcessor.Lights2.StarterEngagedBitMask))
end

function bravoLedBitsProcessor.SetApuLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnApuLed()
    else
        bravoLedBitsProcessor.TurnOffApuLed()
    end
end

function bravoLedBitsProcessor.TurnOnApuLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.Or(bravoLedBitsProcessor.Lights2.Bits, bravoLedBitsProcessor.Lights2.ApuBitMask)
end

function bravoLedBitsProcessor.TurnOffApuLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.And(bravoLedBitsProcessor.Lights2.Bits, logic.Not(bravoLedBitsProcessor.Lights2.ApuBitMask))
end

function bravoLedBitsProcessor.SetMasterCautionLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnMasterCautionLed()
    else
        bravoLedBitsProcessor.TurnOffMasterCautionLed()
    end
end

function bravoLedBitsProcessor.TurnOnMasterCautionLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.Or(bravoLedBitsProcessor.Lights2.Bits, bravoLedBitsProcessor.Lights2.MasterCautionBitMask)
end

function bravoLedBitsProcessor.TurnOffMasterCautionLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.And(bravoLedBitsProcessor.Lights2.Bits, logic.Not(bravoLedBitsProcessor.Lights2.MasterCautionBitMask))
end

function bravoLedBitsProcessor.SetVacuumLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnVacuumLed()
    else
        bravoLedBitsProcessor.TurnOffVacuumLed()
    end
end

function bravoLedBitsProcessor.TurnOnVacuumLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.Or(bravoLedBitsProcessor.Lights2.Bits, bravoLedBitsProcessor.Lights2.VacuumBitMask)
end

function bravoLedBitsProcessor.TurnOffVacuumLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.And(bravoLedBitsProcessor.Lights2.Bits, logic.Not(bravoLedBitsProcessor.Lights2.VacuumBitMask))
end

function bravoLedBitsProcessor.SetLowHydPressureLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnLowHydPressureLed()
    else
        bravoLedBitsProcessor.TurnOffLowHydPressureLed()
    end
end

function bravoLedBitsProcessor.TurnOnLowHydPressureLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.Or(bravoLedBitsProcessor.Lights2.Bits, bravoLedBitsProcessor.Lights2.LowHydPressureBitMask)
end

function bravoLedBitsProcessor.TurnOffLowHydPressureLed()
    bravoLedBitsProcessor.Lights2.Bits = logic.And(bravoLedBitsProcessor.Lights2.Bits, logic.Not(bravoLedBitsProcessor.Lights2.LowHydPressureBitMask))
end

-- Third set of lights

function bravoLedBitsProcessor.SetAuxFuelPumpLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnAuxFuelPumpLed()
    else
        bravoLedBitsProcessor.TurnOffAuxFuelPumpLed()
    end
end

function bravoLedBitsProcessor.TurnOnAuxFuelPumpLed()
    bravoLedBitsProcessor.Lights3.Bits = logic.Or(bravoLedBitsProcessor.Lights3.Bits, bravoLedBitsProcessor.Lights3.AuxFuelPumpBitMask)
end

function bravoLedBitsProcessor.TurnOffAuxFuelPumpLed()
    bravoLedBitsProcessor.Lights3.Bits = logic.And(bravoLedBitsProcessor.Lights3.Bits, logic.Not(bravoLedBitsProcessor.Lights3.AuxFuelPumpBitMask))
end

function bravoLedBitsProcessor.SetParkingBrakeLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnParkingBrakeLed()
    else
        bravoLedBitsProcessor.TurnOffParkingBrakeLed()
    end
end

function bravoLedBitsProcessor.TurnOnParkingBrakeLed()
    bravoLedBitsProcessor.Lights3.Bits = logic.Or(bravoLedBitsProcessor.Lights3.Bits, bravoLedBitsProcessor.Lights3.ParkingBrakeBitMask)
end

function bravoLedBitsProcessor.TurnOffParkingBrakeLed()
    bravoLedBitsProcessor.Lights3.Bits = logic.And(bravoLedBitsProcessor.Lights3.Bits, logic.Not(bravoLedBitsProcessor.Lights3.ParkingBrakeBitMask))
end

function bravoLedBitsProcessor.SetLowVoltsLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnLowVoltsLed()
    else
        bravoLedBitsProcessor.TurnOffLowVoltsLed()
    end
end

function bravoLedBitsProcessor.TurnOnLowVoltsLed()
    bravoLedBitsProcessor.Lights3.Bits = logic.Or(bravoLedBitsProcessor.Lights3.Bits, bravoLedBitsProcessor.Lights3.LowVoltsBitMask)
end

function bravoLedBitsProcessor.TurnOffLowVoltsLed()
    bravoLedBitsProcessor.Lights3.Bits = logic.And(bravoLedBitsProcessor.Lights3.Bits, logic.Not(bravoLedBitsProcessor.Lights3.LowVoltsBitMask))
end

function bravoLedBitsProcessor.SetDoorLed(turnOn)
    if turnOn then
        bravoLedBitsProcessor.TurnOnDoorLed()
    else
        bravoLedBitsProcessor.TurnOffDoorLed()
    end
end

function bravoLedBitsProcessor.TurnOnDoorLed()
    bravoLedBitsProcessor.Lights3.Bits = logic.Or(bravoLedBitsProcessor.Lights3.Bits, bravoLedBitsProcessor.Lights3.DoorBitMask)
end

function bravoLedBitsProcessor.TurnOffDoorLed()
    bravoLedBitsProcessor.Lights3.Bits = logic.And(bravoLedBitsProcessor.Lights3.Bits, logic.Not(bravoLedBitsProcessor.Lights3.DoorBitMask))
end

return bravoLedBitsProcessor
