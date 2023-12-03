//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day1: Day {
  var calibrationDocument = CalibrationDocument(calibrationData: [])
  
  var exampleData = """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """
  
  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Consider your entire calibration document.
      What is the sum of all of the calibration values?
      """
    ) {
      calibrationDocument.calibrationData = rawDataAsArray(useExampleData ? exampleData : input, delim: .newline) { CalibrationItem($0) }
      return "\(calibrationDocument.calibrationDataSum())"
    }
  }
  
  var exampleDataPt2 = """
    5two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      What is the sum of all of the calibration values?
      """
    ) {
      calibrationDocument.calibrationData = rawDataAsArray(useExampleData ? exampleDataPt2 : input, delim: .newline) { CalibrationItem(fromMixedLetterNumbers: $0) }
      return "\(calibrationDocument.calibrationDataSum())"
    }
  }
}

struct CalibrationItem {
  var item: Int
  
  init?(_ contents: String) {
    
    guard let value1 = contents.first(where: \.isNumber)?.wholeNumberValue,
          let value2 = contents.reversed().first(where: \.isNumber)?.wholeNumberValue else {
      return nil
    }
    
    self.item = value1 * 10 + value2
  }
  
  init?(fromMixedLetterNumbers contents: String) {
    func getIntegerStr(regexPattern: String, isReversed: Bool = false) -> String? {
      var capture: [String: Any] = ["value": String.self]

      do {
        if try !getNamedCaptureData(from: isReversed ? String(contents.reversed()) : contents, usingRegEx: regexPattern, forCaptures: &capture) {
          return nil
        }
      } catch {
        return nil
      }
      
      guard let numberStr = capture["value"] as? String else {
        return nil
      }
      
      return numberStr
    }
    
    var regexPattern = #"(?<value>one|two|three|four|five|six|seven|eight|nine|zero|\d).*$"#
    guard let numberStr = getIntegerStr(regexPattern: regexPattern) else {
      return nil
    }
    
    var value1: Int

    if let directNumber = Int(numberStr) {
      value1 = directNumber
    } else {
      let numberedWords = ["zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9]
      value1 = numberedWords[numberStr.lowercased()]!
    }
    
    
    regexPattern = #"(?<value>eno|owt|eerht|ruof|evif|xis|neves|thgie|enin|orez|\d).*$"#
    guard let numberStr = getIntegerStr(regexPattern: regexPattern, isReversed: true) else {
      return nil
    }
    
    var value2: Int

    if let directNumber = Int(numberStr) {
      value2 = directNumber
    } else {
      let numberedWords = ["orez": 0, "eno": 1, "owt": 2, "eerht": 3, "ruof": 4, "evif": 5, "xis": 6, "neves": 7, "thgie": 8, "enin": 9]
      value2 = numberedWords[numberStr.lowercased()]!
    }

    self.item = value1 * 10 + value2
  }
}

struct CalibrationDocument {
  var calibrationData: [CalibrationItem]
  
  func calibrationDataSum() -> Int {
    return calibrationData.reduce(0) { $0 + $1.item }
  }
}
