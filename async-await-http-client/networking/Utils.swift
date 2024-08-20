//
//  Utils.swift
//  async-await-http-client
//
//  Created by user on 2024-08-20.
//

import Foundation

class Utils {

    static func loadResourceFromBundle(name: String, fileEnding: String, filePath: String) -> Data? {

        let completeFilePath = Bundle.main.path(forResource:name, ofType:fileEnding, inDirectory:filePath)

        if let completeFilePath = completeFilePath {
            do {
                let contents = try Data(contentsOf: URL(fileURLWithPath: completeFilePath))
                return contents
            } catch {
                print("contents could not be loaded for: \(completeFilePath)")
            }
        } else {
            print("no file exists at path: \(filePath)/\(name).\(fileEnding)")
        }

        return nil
    }
}
