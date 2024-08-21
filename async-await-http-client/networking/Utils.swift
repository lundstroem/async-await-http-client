/*

 MIT License

 Copyright (c) 2024 Harry Lundström

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 */

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
