//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

func downloadInputFile(for day: Int, year: Int, cookie: String,
                       saveTo folder: String, usingPrefix filePrefix: String, fileExtension: String) async -> String? {
  
  let downloadTask = Task { () -> String? in
    guard let url = URL(string: "https://adventofcode.com/\(year)/day/\(day)/input") else {
      return nil
    }
    
    var request = URLRequest(url: url)
    request.addValue(cookie, forHTTPHeaderField: "Cookie")
    
    guard let (data, _) = try? await URLSession.shared.data(for: request) else {
      return nil
    }
    
    if let str = String(data: data, encoding: .utf8) {
      return str
    } else {
      return nil
    }
  }
  
  let result = await downloadTask.result
  
  do {
    guard let str = try result.get() else {
      return nil
    }
    let destination = "\(folder)\(filePrefix)\(day)\(fileExtension)"
    try str.write(toFile: destination, atomically: true, encoding: .utf8)
    return str
  } catch {
    return nil
  }
  
}

enum SeparatorToken: String {
  case dblNewline = "\n\n"
  case newline = "\n"
  case space = " "
  case comma = ","
  case tab = "\t"
  case pipe = "|"
  case commaSpace = ", "
  case semicolonSpace = "; "
}

func rawDataAsArray<T>(_ raw: String, delim: SeparatorToken, convert: (String) -> T?) -> [T] {
  let components = raw.components(separatedBy: delim.rawValue)
  return components.compactMap(convert)
}

func getNamedCaptureData(from text: String, usingRegEx pattern: String, forCaptures captures: inout [String: Any]) throws -> Bool {
  let regex = try! NSRegularExpression(pattern: pattern, options: [])
  let range = NSRange(text.startIndex..., in: text)
  guard let match = regex.firstMatch(in: text, options: [], range: range) else {
    return false
  }
  
  for (captureName, captureType) in captures {
    let matchRange = match.range(withName: captureName)
    if matchRange.location != NSNotFound {
      let captureString = (text as NSString).substring(with: matchRange)
      switch captureType {
      case is Int.Type:
        captures[captureName] = Int(captureString)
      case is Double.Type:
        captures[captureName] = Double(captureString)
      default:  // String
        captures[captureName] = captureString
      }
    }
  }
  
  return true
}

