//
//  AppDelegate.swift
//  RPFX
//
//  Created by Vincent Liu on 17/4/20.
//  Copyright © 2020 Vincent Liu. All rights reserved.
//

import Cocoa
import SwiftUI
import SwordRPC

// MARK: - AppDelegate
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var rpc: SwordRPC?
    var startDate: Date?
    
    // MARK: beginTimer
    func beginTimer() {
        DispatchQueue.global(qos: .background).async {
            while(true) {
                sleep(UInt32(refreshInterval))
                self.updateStatus()
            }
        }
    }
    
    // MARK: updateStatus
    func updateStatus() {
        var p = RichPresence()
        
        let fn = getActiveFilename()
        let ws = getActiveWorkspace()
        
        // determine file type
        if fn != nil {
            p.details = "Editing \(fn!)"
            
            if let fileExt = getFileExt(fn!), discordRPImageKeys.contains(fileExt) {
                p.assets.largeImage = fileExt
            } else {
                p.assets.largeImage = discordRPImageKeyDefault
            }
        }
        
        // determine workspace type
        if ws != nil {
            if ws != "Untitled" {
                
                p.state = "in \(withoutFileExt(ws!))"
            }
        }
        
        // Xcode was just launched?
        if fn == nil && ws == nil {
            p.assets.largeImage = discordRPImageKeyXcode
            p.details = "No file open"
        }
        
        p.timestamps.start = startDate!
        p.timestamps.end = nil
        rpc!.setPresence(p)
    }
    
    // MARK: initRPC
    func initRPC() {
        rpc = SwordRPC.init(appId: discordClientId)
        rpc?.delegate = self
        self.rpc?.connect()
    }
    
    // MARK: deinitRPC
    func deinitRPC() {
        self.rpc!.setPresence(RichPresence())
        self.rpc = nil
    }
    
    // MARK: applicationDidFinishLaunching
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let openApps = NSWorkspace.shared.runningApplications
        var xcodeOpen = openApps.filter({$0.bundleIdentifier == xcodeBundleId}).count > 0
        var discordOpen = openApps.filter({$0.bundleIdentifier == discordBundleId}).count > 0
        
        if xcodeOpen && discordOpen {
            initRPC()
        }
        
        let notifCenter = NSWorkspace.shared.notificationCenter
        
        // run on Discord/Xcode launch
        notifCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil, using: { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                let appName = app.bundleIdentifier
                if appName == xcodeBundleId {
                    xcodeOpen = true
                }
                if appName == discordBundleId {
                    discordOpen = true
                }
                if xcodeOpen && discordOpen {
                    self.initRPC()
                }
            }
        })
        
        // run on Discord/Xcode close
        notifCenter.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: nil, using: { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                let appName = app.bundleIdentifier
                if appName == xcodeBundleId {
                    xcodeOpen = false
                    self.deinitRPC()
                }
                if appName == discordBundleId {
                    discordOpen = false
                    self.deinitRPC()
                }
            }
        })
    }
    
    // MARK: applicationWillTerminate
    func applicationWillTerminate(_ aNotification: Notification) {
        deinitRPC()
    }
}

// MARK: - SwordRPCDelegate
extension AppDelegate: SwordRPCDelegate {
    func swordRPCDidConnect(_ rpc: SwordRPC) {
        startDate = Date()
        beginTimer()
    }
    
    func swordRPCDidDisconnect(_ rpc: SwordRPC, code: Int?, message msg: String?) {
    }
    
    func swordRPCDidReceiveError(_ rpc: SwordRPC, code: Int, message msg: String) {
    }
}
