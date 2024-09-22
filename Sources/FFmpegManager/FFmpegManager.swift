//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 7/25/24.
//


import Foundation
import ffmpegkit

public class FFmpegManager: NSObject {
    public static let shared = FFmpegManager()
    
    private var tagsCounter: Int = 0
    private var isInExecute: Bool = false {
        didSet {
            updateScreenController()
        }
    }
    private var ffmpegDispatch = DispatchQueue(label: "FFmpegManager")
    private var waitList: [Int: FFmpegManagerWaitListItem] = [:]
    private var currentTag: Int = -1
    
    func execute(withArguments args: [Any],
                        level: Int = 1000,
                        processTracker: ProcessTracker? = nil,
                        completion: ((_ status: FFmpegStatus, _ tag: Int?) -> Void)? = nil,
                        progress: ((_ currentLength: Int, _ totalLength: Int, _ progress: Float) -> Void)? = nil) {
        execute(withListOfArguments: [args], level: level, processTracker: processTracker, completion: { status, tag, _ in
            completion?(status, tag)
        }, progress: progress)
    }
    
    func execute(withListOfArguments argsList: [[Any]],
                        level: Int = 1000,
                        processTracker: ProcessTracker? = nil,
                        completion: ((_ status: FFmpegStatus, _ tag: Int?, _ index: Int?) -> Void)? = nil,
                        progress: ((_ currentLength: Int, _ totalLength: Int, _ progress: Float) -> Void)? = nil) {
        tagsCounter += 1
        let item = FFmpegManagerWaitListItem()
        item.argsList = argsList
        item.level = level
        item.processTracker = processTracker
        item.completion = completion
        item.progress = progress
        waitList[tagsCounter] = item
        
        if isInExecute {
            completion?(.inWaitList, tagsCounter, nil)
        } else {
            executeNextProcesses()
        }
    }
    
    public func cancel(tag: Int) {
        if let waitListItem = waitList[tag] {
            waitList.removeValue(forKey: tag)
            if currentTag == tag {
                waitListItem.currentSession?.cancel()
            }
        }
    }
    
    public func setFontDirectory(path: String) {
        FFmpegKitConfig.setFontDirectory(path, with: nil)
    }

    public func getMediaInformation(path: String) -> MediaInformationSession {
        return FFprobeKit.getMediaInformation(path)
    }
    
    private func executeNextProcesses() {
        isInExecute = true
        
        if let processes = getHighestLevelProcesses() {
            currentTag = processes.key
            executeNextFFmpeg(processes: processes)
        } else {
            isInExecute = false
            currentTag = -1
        }
    }
    
    private func executeNextFFmpeg(processes: (key: Int, value: FFmpegManagerWaitListItem)) {
        let currentIndex = processes.value.currentIndex
        let args = processes.value.argsList[currentIndex]
        
        processes.value.completion?(.willExecute, processes.key, currentIndex + 1)

        processes.value.currentSession = FFmpegKit.execute(withArgumentsAsync: args, withCompleteCallback: { session in
            self.handleSessionCompletion(session, processes: processes)
        }, withLogCallback: { log in
            self.handleLogCallback(log?.getMessage() ?? "", processes: processes)
        }, withStatisticsCallback: { _ in
            // Handle statistics callback if needed
        }, onDispatchQueue: ffmpegDispatch)
    }
    
    private func handleSessionCompletion(_ session: FFmpegSession?, processes: (key: Int, value: FFmpegManagerWaitListItem)) {
        let currentIndex = processes.value.currentIndex
        if let session = session, ReturnCode.isSuccess(session.getReturnCode()) {
            processes.value.progress?(processes.value.currentLength ?? 1, processes.value.totalLength ?? 1, 1)
            processes.value.completion?(.didSuccess, processes.key, currentIndex + 1)
            processes.value.processTracker?.didSuccess()
        } else {
            processes.value.completion?(.didFail, processes.key, currentIndex + 1)
            processes.value.processTracker?.didFail()
        }
        
        if session?.getState() == .completed && processes.value.currentIndex + 1 < processes.value.argsList.count {
            processes.value.currentIndex += 1
            executeNextFFmpeg(processes: processes)
        } else {
            waitList.removeValue(forKey: processes.key)
            executeNextProcesses()
        }
    }
    
    private func handleLogCallback(_ log: String, processes: (key: Int, value: FFmpegManagerWaitListItem)) {
        if let length = getLengthInSec(from: log) {
            if log.count > 16 {
                processes.value.currentLength = length
            } else if processes.value.totalLength == nil {
                processes.value.totalLength = length
            }
        }
    }
    
    private func getHighestLevelProcesses() -> (key: Int, value: FFmpegManagerWaitListItem)? {
        return waitList.max(by: { $0.value.level < $1.value.level || ($0.value.level == $1.value.level && $0.key > $1.key) })
    }
    
    private func updateScreenController() {
        if isInExecute {
            ScreenController.shared.startKeepScreenActive()
        } else {
            ScreenController.shared.stopKeepScreenActive()
        }
    }
    
    func getLengthInSec(from message: String) -> Int? {
        guard let match = message.regex(pattern: "(time=|^)(?<hours>\\d{2,}):(?<minutes>\\d{2}):(?<seconds>\\d{2})\\.(?<millisec>\\d+)").first else { return nil }
        
        let hoursString        = match.getTag("hours", from: message) ?? "0"
        let minutesString      = match.getTag("minutes", from: message) ?? "0"
        let secondsString      = match.getTag("seconds", from: message) ?? "0"
        let millisecondsString = match.getTag("millisec", from: message) ?? "0"
        
        let hours        = (Int(hoursString)        ?? 0) * 60 * 60 * 100
        let minutes      = (Int(minutesString)      ?? 0) * 60 * 100
        let seconds      = (Int(secondsString)      ?? 0) * 100
        let milliseconds = (Int(millisecondsString) ?? 0)
        
        return milliseconds + seconds + minutes + hours
    }
}

public extension NSTextCheckingResult {
    func getTag(_ name: String, from text: String) -> String? {
        if let range = Range(self.range(withName: name), in: text) {
            return String(text[range])
        }
        return nil
    }
}
