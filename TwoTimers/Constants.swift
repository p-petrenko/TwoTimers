//
//  Constants.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 24.03.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import Foundation

struct Constants {
    
    struct TimeConstants {
        static let SecInHour:Int = 3600
        static let SecInMinute:Int = 60
    }
    
    // MARK: - Countdown timer constants
    
    struct KeysUsedInCountdownTimer {
        // hr, min, sec Core Data keys
        static let HoursForStart = "selectedHours"
        static let MinutesForStart = "selectedMinutes"
        static let SecondsForStart = "selectedSeconds"

        static let SoundOnOff = "Sound can be on or off"
    }

    struct CountdownNotificationKeys {
        static let TabToStopwatch = "Key for RunVC to know when I open StopwatchVC"
        static let TabBackToCountdown = "Key for RunVC to know when view is appearing after being in Stopwatch tab"
        
        static let TabToCountdown = "Key for RunVC to know when I open CountdownVC"
        static let TabBackToStopwatch = "Key for Stopwatch to know when view is appearing after being in Countdown tab"
    }

    // MARK: - Stopwatch timer constants
    
    struct KeysUsedInStopwatch {
        // Core Data keys
        static let SplitDateAndTime = "Date and Time on user device Array"
        static let SplitIntervalTimeResult = "Split Interval Results Array"
        static let SplitEventName = "Array of names of split result, modifies if result saved"
        static let Saved = "Saved Boolean"
        static let Current = "Current Boolean"
        static let TimeOfResultSaving = "TimeOfResultSaving"
        static let PositionOfSavedResult = "PositionOfSavedResult"
        
        static let TimeKeeperKey = "Save Last Used time of main label in Stopwatch"
        static let SplitTimeKeeperKey = "Save Last Used time of split label in Stopwatch"
        static let SleepMode = "Remember value of sleepModeOff variable"
    }
    
    struct StopwatchNotificationKey {
        static let WhenPencilButtonPressed = "Press Pencil button and do actions"
        static let WhenSaveButtonPressed = "Press Floppy Disk button and do actions"
    }
    
    struct KeyForSaveButtonUserInfo {
        static let DeviceDateAndTime = "cell date+time for saving"
        static let TimeInterval = "cell time interval for saving"
    }
    
    struct StringsForAlert {
        static let SaveResultQuestion = NSLocalizedString("Save result?", comment: "ask if user wants to save result")
        static let EnterName = NSLocalizedString("Enter a name of result", comment: "Ask user to enter the result name")
        
        static let RenameTitle = NSLocalizedString("Result Name", comment: "rename the result")
        static let CancelActionButton = NSLocalizedString("Cancel", comment: "Cancel action button")
    }
    // MARK: - Application constants
    struct TimersKeys {
        static let FirstRunKey = "First Run of the Application"
    }
    
    
    // MARK: - Sound constants
    
    struct KeysForMelodies {
        static let SimpleSound = NSLocalizedString("simple sound 1", comment: "")
        static let SimpleSound2 = NSLocalizedString("simple sound 2", comment: "")
        static let Drums1 = NSLocalizedString("drums 1", comment: "")
        static let Drums2 = NSLocalizedString("drums 2", comment: "")
        static let FretlessBass = NSLocalizedString("fretless bass", comment: "")
        static let Piano1 = NSLocalizedString("piano 1", comment: "")
        static let Piano2 = NSLocalizedString("piano 2", comment: "")
        static let Piano3 = NSLocalizedString("piano 3", comment: "")
        static let Piano4 = NSLocalizedString("piano 4", comment: "")
        static let Piano5 = NSLocalizedString("piano 5", comment: "")
        static let PianoSynth = NSLocalizedString("synthesizer", comment: "")
        static let ElectroSound1 = NSLocalizedString("electrosound 1", comment: "")
        static let ElectroSound2 = NSLocalizedString("electrosound 2", comment: "")
        static let ElectroSound3 = NSLocalizedString("electrosound 3", comment: "")
        static let ElectroSound4 = NSLocalizedString("electrosound 4", comment: "")
        static let AnxiousViolin = NSLocalizedString("electrosound 5", comment: "")
        static let BottleSound = NSLocalizedString("lullaby", comment: "")
        static let SeagullsAndFoghorn = NSLocalizedString("seagulls and foghorn", comment: "")
        static let Wobble = NSLocalizedString("wobble", comment: "")
        static let SleighBells = NSLocalizedString("sleigh bells", comment: "")
    }
    
    struct MelodyFileNames {
        static let SimpleSoundFileName = "pipi"
        static let SimpleSound2FileName = "pipipi"
        static let Drums1FileName = "rhythmical_drums1"
        static let Drums2FileName = "rhythmical_drums2"
        static let FretlessBassFileName = "anxious_fretless_bass"
        static let Piano1FileName = "piano"
        static let Piano2FileName = "piano2"
        static let Piano3FileName = "piano3"
        static let Piano4FileName = "piano4"
        static let Piano5FileName = "piano5"
        static let PianoSynthFileName = "piano_synth"
        static let ElectroSound1FileName = "electronic_sound2"
        static let ElectroSound2FileName = "electronic_sound3"
        static let ElectroSound3FileName = "electronic_sound4"
        static let ElectroSound4FileName = "electronic_sound6"
        static let AnxiousViolinFileName = "anxious_violin"
        static let BottleSoundFileName = "bottle_sound"
        static let SeagullsAndFoghornFileName = "seagulls_and_foghorn"
        static let WobbleFileName = "wobble"
        static let SleighBellsFileName  = "sleigh_bells"
    }
    
    struct DefaultKeys {
        static let AudioKeyForChosenMelody = "Number of Chosen Melody in List Of Melodies"
    }
    
    static let arrayOfFancyMelodyNames = [
        KeysForMelodies.SimpleSound , // 0
        KeysForMelodies.SimpleSound2 , // 1
        KeysForMelodies.Drums1 , // 2
        KeysForMelodies.Drums2 , // 3
        KeysForMelodies.FretlessBass , // 4
        KeysForMelodies.Piano1 , // 5
        KeysForMelodies.Piano2 , // 6
        KeysForMelodies.Piano3 , // 7
        KeysForMelodies.Piano4 , // 8
        KeysForMelodies.Piano5 , //9
        KeysForMelodies.PianoSynth , //10
        KeysForMelodies.ElectroSound1 , //11
        KeysForMelodies.ElectroSound2 , //12
        KeysForMelodies.ElectroSound3 , //13
        KeysForMelodies.ElectroSound4 , //14
        KeysForMelodies.AnxiousViolin ,//15
        KeysForMelodies.Wobble , // 16
        KeysForMelodies.BottleSound , // 17
        KeysForMelodies.SeagullsAndFoghorn , // 18
        KeysForMelodies.SleighBells  // 19
    ]
    
    static let arrayOfFileNames = [
        MelodyFileNames.SimpleSoundFileName ,
        MelodyFileNames.SimpleSound2FileName ,
        MelodyFileNames.Drums1FileName ,
        MelodyFileNames.Drums2FileName ,
        MelodyFileNames.FretlessBassFileName ,
        MelodyFileNames.Piano1FileName ,
        MelodyFileNames.Piano2FileName ,
        MelodyFileNames.Piano3FileName ,
        MelodyFileNames.Piano4FileName ,
        MelodyFileNames.Piano5FileName ,
        MelodyFileNames.PianoSynthFileName ,
        MelodyFileNames.ElectroSound1FileName ,
        MelodyFileNames.ElectroSound2FileName ,
        MelodyFileNames.ElectroSound3FileName ,
        MelodyFileNames.ElectroSound4FileName ,
        MelodyFileNames.AnxiousViolinFileName ,
        MelodyFileNames.WobbleFileName ,
        MelodyFileNames.BottleSoundFileName ,
        MelodyFileNames.SeagullsAndFoghornFileName ,
        MelodyFileNames.SleighBellsFileName
        
    ]

    
}