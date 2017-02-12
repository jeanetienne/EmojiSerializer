//
//  main.swift
//  EmojiSerializer
//
//  Created by Jean-Étienne Parrot on 14/1/17.
//  Copyright © 2017 Jean-Étienne. All rights reserved.
//

import Foundation

let emojiList = retrieveEmojiList(url: URL(string: "http://unicode.org/Public/emoji/latest/emoji-test.txt")!)
let emojiParser = EmojiParser(fileContent: emojiList)
emojiParser.parse()

let fileManager = FileManager()
let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
let emojiDataURL = documentsDirectoryURL.appendingPathComponent("emoji-data.plist")
let emojiMetadataURL = documentsDirectoryURL.appendingPathComponent("emoji-metadata.plist")

try write(propertylist: emojiParser.emojiData, atPath: emojiDataURL)
try write(propertylist: emojiParser.emojiMetadata, atPath: emojiMetadataURL)

print("✅ Done!")
