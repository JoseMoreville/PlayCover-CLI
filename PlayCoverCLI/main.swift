//
//  main.swift
//  PlayCover
//
//  Created by José Elias Moreno villegas on 17/10/22.
//

import Foundation
import ArgumentParser
class PlayInstall {
    func asyncTask(group: DispatchGroup, ipaUrl: URL) {
        print("Installing...", ipaUrl)
        DispatchQueue.main.async(group: group) {
            Installer.install(ipaUrl: ipaUrl, returnCompletion: { _ in
                print("Application Installed!")
                exit(EXIT_SUCCESS)
            })
        }
    }
}

struct PlayCoverCLI: AsyncParsableCommand {
    @Argument()
    var path: String
    func run() throws {
        print("Install Starting")
        guard let ipaUrl = URL(string: path) else { return }
        let playInstall = PlayInstall()
        let group = DispatchGroup()
        playInstall.asyncTask(group: group, ipaUrl: ipaUrl)
        dispatchMain()
    }
}

PlayCoverCLI.main()
