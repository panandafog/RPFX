//
//  Constants.swift
//  RPFX
//
//  Created by Vincent Liu on 18/4/20.
//  Copyright © 2020 Vincent Liu. All rights reserved.
//

import Foundation


// Used to register for notifs when Xcode opens/closes
let xcodeBundleId = "com.apple.dt.Xcode"
let discordBundleId = "com.hnc.Discord"

// How often we check Xcode for a status update
let refreshInterval = 5 // seconds

// The following constants are for use with the Discord App

let discordClientId = "700358131481444403"

// Discord image keys of supported file types
let discordRPImageKeys = [
    "swift",
    "playground",
    "storyboard",
    "xcodeproj",
    "h",
    "m",
    "cpp",
    "c",
]

// Fallback for unsupported file types
let discordRPImageKeyDefault = "file"

// Xcode application icon
let discordRPImageKeyXcode = "xcode"

