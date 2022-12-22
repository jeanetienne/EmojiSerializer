//
//  Tools.swift
//  EmojiSpeaker
//
//  Created by Jean-Étienne Parrot on 9/1/17.
//  Copyright © 2017 Jean-Étienne. All rights reserved.
//

import Foundation

func retrieveEmojiList(url: URL) -> String {
    var emojiListString = ""
    let semaphore = DispatchSemaphore(value: 0)
    let ephemeralSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    let task = ephemeralSession.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        emojiListString = String(data: data!, encoding: .utf8)!
        semaphore.signal()
    }
    task.resume()
    semaphore.wait()

    return emojiListString
}

func write(propertyList: Any, atPath path: URL) throws {
    let propertyListData = try PropertyListSerialization.data(fromPropertyList: propertyList,
                                                              format: .xml,
                                                              options: 0)
    try propertyListData.write(to: path,
                               options: .atomic)
}
