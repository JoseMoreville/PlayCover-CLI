//
//  Logger.swift
//  PlayCover
//
import Foundation

class Log: ObservableObject {

    static let shared = Log()

    func error(_ err: Error) {
        DispatchQueue.main.async {
        }
    }

    func msg(_ msg: String) {
        DispatchQueue.main.async {
            self.log(msg)
        }
    }

    var logdata = "\(ProcessInfo.processInfo.operatingSystemVersionString)\n"

    func log(_ str: String, isError: Bool = false) {
        print(str)
        if isError {
            logdata.append("ERROR: ")
        }
        logdata.append(str)
        logdata.append("\n")
    }

    required init() { }
}
