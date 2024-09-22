//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 7/25/24.
//

import Foundation

public class ProcessTracker {
    var progress: Float?
    
    func update(to progress: Float) {
        self.progress = progress
        // Implement update logic
    }
    
    func didSuccess() {
        // Implement success logic
    }
    
    func didFail() {
        // Implement fail logic
    }
}

