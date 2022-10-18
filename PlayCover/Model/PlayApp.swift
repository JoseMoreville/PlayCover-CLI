//
//  PlayApp.swift
//  PlayCover
//

import Cocoa
import Foundation
import IOKit.pwr_mgt

class PlayApp: BaseApp {
    var searchText: String {
        info.displayName.lowercased().appending(" ").appending(info.bundleName).lowercased()
    }

    func launch() {
        do {
            if prohibitedToPlay {
                container?.clear()
                throw PlayCoverError.appProhibited
            }

            settings.sync()
            if try !Entitlements.areEntitlementsValid(app: self) {
                sign()
            }
            try PlayTools.installPluginInIPA(url)
            if try !PlayTools.isInstalled() {
                Log.shared.error("PlayTools are not installed! Please move PlayCover.app into Applications!")
            } else if try !PlayTools.isValidArch(executable.path) {
                Log.shared.error("The app threw an error during conversion.")
            } else if try !isCodesigned() {
                Log.shared.error("The app is not codesigned! Please open Xcode and accept license agreement.")
            } else {
                runAppExec() // Splitting to reduce complexity
            }
        } catch {
            Log.shared.error(error)
        }
    }

    func runAppExec() {
        let config = NSWorkspace.OpenConfiguration()

        if settings.metalHudEnabled {
            config.environment = ["MTL_HUD_ENABLED": "1"]
        } else {
            config.environment = ["MTL_HUD_ENABLED": "0"]
        }

        NSWorkspace.shared.openApplication(
            at: url,
            configuration: config,
            completionHandler: { runningApp, error in
                guard error == nil else { return }
                if self.settings.settings.disableTimeout {
                    // Yeet into a thread
                    DispatchQueue.global().async {
                        debugPrint("Disabling timeout...")
                        let reason = "PlayCover: " + self.name + " disabled screen timeout" as CFString
                        var assertionID: IOPMAssertionID = 0
                        var success = IOPMAssertionCreateWithName(
                            kIOPMAssertionTypeNoDisplaySleep as CFString,
                            IOPMAssertionLevel(kIOPMAssertionLevelOn),
                            reason,
                            &assertionID)
                        if success == kIOReturnSuccess {
                            while true { // Run a loop until the app closes
                                Thread.sleep(forTimeInterval: 10) // Wait 10s
                                guard
                                    let isFinish = runningApp?.isTerminated,
                                    !isFinish else { break }
                            }
                            success = IOPMAssertionRelease(assertionID)
                            debugPrint("Enabling timeout...")
                        }
                    }
                }
            })
    }

    var name: String {
        if info.displayName.isEmpty {
            return info.bundleName
        } else {
            return info.displayName
        }
    }

    lazy var settings = AppSettings(info, container: container)


    var container: AppContainer?

    func isCodesigned() throws -> Bool {
        try shell.shello("/usr/bin/codesign", "-dv", executable.path).contains("adhoc")
    }

    func showInFinder() {
        URL(fileURLWithPath: url.path).showInFinderAndSelectLastComponent()
    }

    func openAppCache() {
        container?.containerUrl.showInFinderAndSelectLastComponent()
    }

    func deleteApp() {
        do {
            try FileManager.default.delete(at: URL(fileURLWithPath: url.path))
        } catch {
            Log.shared.error(error)
        }
    }

    func sign() {
        do {
            let tmpDir = try FileManager.default.url(for: .itemReplacementDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: URL(fileURLWithPath: "/Users"),
                                                  create: true)
            let tmpEnts = tmpDir
                .appendingPathComponent(ProcessInfo().globallyUniqueString)
                .appendingPathExtension("plist")
            let conf = try Entitlements.composeEntitlements(self)
            try conf.store(tmpEnts)
            shell.signAppWith(executable, entitlements: tmpEnts)
            try FileManager.default.removeItem(at: tmpEnts)
        } catch {
            print(error)
            Log.shared.error(error)
        }
    }

    func largerImage(image imageA: NSImage, compareTo imageB: NSImage?) -> NSImage {
        if imageA.size.height > imageB?.size.height ?? -1 {
            return imageA
        }
        return imageB!
    }

    var prohibitedToPlay: Bool {
        PlayApp.PROHIBITED_APPS.contains(info.bundleIdentifier)
    }

    static let PROHIBITED_APPS = [
        "com.activision.callofduty.shooter",
        "com.ea.ios.apexlegendsmobilefps",
        "com.garena.game.codm",
        "com.tencent.tmgp.cod",
        "com.tencent.ig",
        "com.pubg.newstate",
        "com.tencent.tmgp.pubgmhd",
        "com.dts.freefireth",
        "com.dts.freefiremax"
    ]
}
