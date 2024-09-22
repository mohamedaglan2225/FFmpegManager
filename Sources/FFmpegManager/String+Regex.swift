//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 7/25/24.
//

import Foundation

extension String {
    func regex(pattern: String) -> [NSTextCheckingResult] {
        let regex = try! NSRegularExpression(pattern: pattern)
        return regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
    }

    func getTag(_ tag: String, from message: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "(?<=\(tag)=)[^\\s]+")
        let range = NSRange(message.startIndex..., in: message)
        if let match = regex.firstMatch(in: message, range: range) {
            return String(message[Range(match.range, in: message)!])
        }
        return nil
    }
}

