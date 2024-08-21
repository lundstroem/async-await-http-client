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

class HttpGetParameterBuilder {

    private var parameterCount = 0
    private var params: String = ""

    private func appendDelimiter() {
        params.append(parameterCount == 0 ? "?" : "&")
        parameterCount += 1
    }

    private func urlEncode(_ value: String) -> String {
        let urlEncoded = value.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        return urlEncoded ?? ""
    }

    func append(name: String, double: Double?) {
        guard let double = double else { return }
        appendDelimiter()
        params.append("\(name)=\(double)")
    }

    func append(name: String, int32: Int32?) {
        guard let int32 = int32 else { return }
        appendDelimiter()
        params.append("\(name)=\(int32)")
    }

    func append(name: String, int64: Int64?) {
        guard let int64 = int64 else { return }
        appendDelimiter()
        params.append("\(name)=\(int64)")
    }

    func append(name: String, string: String?) {
        guard let string = string else { return }
        appendDelimiter()
        params.append("\(name)=\(urlEncode(string))")
    }

    func append(name: String, bool: Bool?) {
        guard let bool = bool else { return }
        appendDelimiter()
        params.append("\(name)=\(bool)")
    }

    var parameterString: String {
        params
    }
}
