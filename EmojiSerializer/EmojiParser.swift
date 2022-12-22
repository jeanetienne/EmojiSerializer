//
//  EmojiParser.swift
//  EmojiSerializer
//
//  Created by Jean-Étienne Parrot on 19/1/17.
//  Copyright © 2017 Jean-Étienne. All rights reserved.
//

import Foundation

internal class EmojiParser {

    var emojiData = [String: Any]()
    var emojiMetadata = [String: Any]()

    private var emojiRawData: String

    private var inputDateFormatter: DateFormatter {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss ZZZZ"
            dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)

            return dateFormatter
        }
    }
    
    private var outputDateFormatter: ISO8601DateFormatter {
        get {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.timeZone = inputDateFormatter.timeZone

            return dateFormatter
        }
    }
    
    init(fileContent: String) {
        self.emojiRawData = fileContent
    }

    func parse() {
        var currentGroup = ""
        var currentSubgroup = ""
        emojiMetadata["groups"] = [String: [String]]()

        emojiRawData.enumerateLines { (rawLine, _) in
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

            if let trimmedLine = line.trimPrefix("# Date: ") {
                let date = self.parseDate(line: trimmedLine)
                self.emojiMetadata["date"] = date
            } else if let trimmedLine = line.trimPrefix("# group: ") {
                currentGroup = trimmedLine
            } else if let trimmedLine = line.trimPrefix("# subgroup: ") {
                currentSubgroup = trimmedLine
                currentSubgroup = currentSubgroup.replacingOccurrences(of: "-", with: " ").capitalized

                guard var groups = self.emojiMetadata["groups"] as? [String: [String]] else {
                    return
                }

                if var group = groups[currentGroup] {
                    group.append(currentSubgroup)
                    groups[currentGroup] = group
                } else {
                    groups[currentGroup] = [currentSubgroup]
                }

                self.emojiMetadata["groups"] = groups
            } else if line.contains("fully-qualified"),
                let emojiCharacter = self.parseEmojiCharacter(line: line),
                let emojiDescription = self.parseEmojiDescription(line: line, group: currentGroup, subgroup: currentSubgroup) {
                self.emojiData[emojiCharacter] = emojiDescription
            }
        }

        emojiMetadata["count"] = emojiData.count
        emojiMetadata["parsed-at"] = outputDateFormatter.string(from: Date())
    }

    private func parseDate(line: String) -> String? {
        if let date = inputDateFormatter.date(from: line) {
            return outputDateFormatter.string(from: date)
        } else {
            return nil
        }
    }

    private func parseEmojiCharacter(line: String) -> String? {
        guard let rangeOfHash = line.range(of: "# ") else {
                return nil
        }

        let emojiFraction = line.substring(from: rangeOfHash.upperBound)

        if let rangeOfSpace = emojiFraction.range(of: " ") {
            return emojiFraction.substring(to: rangeOfSpace.lowerBound)
        }

        return nil
    }
    
    private func parseEmojiDescription(line: String, group: String, subgroup: String) -> [String: Any]? {
        guard let rangeOfSemicolon = line.range(of: ";"),
            let rangeOfHash = line.range(of: "#") else {
                return nil
        }

        let codePointsString = line.substring(to: rangeOfSemicolon.lowerBound).trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionWithEmoji = line.substring(from: rangeOfHash.upperBound).trimmingCharacters(in: .whitespacesAndNewlines)
        let index = descriptionWithEmoji.characters.index(of: " ")
        let description = descriptionWithEmoji.substring(from: index!).trimmingCharacters(in: .whitespacesAndNewlines)
        let codePoints = codePointsString.components(separatedBy: " ")

        return ["description": description.uppercaseFirstLetter,
                "category": group,
                "subcategory": subgroup,
                "code-points": codePoints] as [String: Any]
    }
    
}

fileprivate extension String {

    var uppercaseFirstLetter: String {

        get {
            let index = self.index(self.startIndex, offsetBy: 1)
            return self.substring(to: index).uppercased() + self.substring(from: index)
        }

    }

    func trimPrefix(_ prefix: String) -> String? {
        return hasPrefix(prefix) ? replacingOccurrences(of: prefix, with: "") : nil
    }

}
