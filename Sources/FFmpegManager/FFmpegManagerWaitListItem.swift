//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 7/25/24.
//

import Foundation
import ffmpegkit

public class FFmpegManagerWaitListItem {
    public var argsList: [[Any]] = []
    public var currentIndex: Int = 0
    public var level: Int = 0
    public var completion: ((_ status: FFmpegStatus, _ tag: Int?, _ index: Int?) -> Void)?
    public var progress: ((_ currentLength: Int, _ totalLength: Int, _ progress: Float) -> Void)?
    
    var currentSession: FFmpegSession?
     var processTracker: ProcessTracker? {
        didSet {
            if let processTracker = processTracker {
                currentProcessTrackerValue = processTracker.progress ?? 0
            }
        }
    }
    fileprivate var currentProcessTrackerValue: Float = 0
     var totalLength: Int?
     var currentLength: Int? {
        didSet {
            updateProgress()
        }
    }
    
    private func updateProgress() {
        guard let current = currentLength, let total = totalLength else { return }
        let floatCurrent = Float(current)
        let floatTotal = Float(total)
        let currentProgress = min((floatCurrent / floatTotal), 1)
        let remainingProgress = 1 - currentProcessTrackerValue
        let oneProcessLength = remainingProgress / Float(argsList.count)
        let totalDoneProcessLength = oneProcessLength * Float(currentIndex)
        let totalProgress = currentProgress * oneProcessLength + totalDoneProcessLength + currentProcessTrackerValue
        processTracker?.update(to: totalProgress)
        progress?(current, total, totalProgress)
    }
}

