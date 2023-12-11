//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day9: Day {
  var oasisData = OasisDataLogger("")
  let exampleData = """
      0 3 6 9 12 15
      1 3 6 10 15 21
      10 13 16 21 30 45
      """
  
  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Analyze your OASIS report and extrapolate the next value for each history.
      What is the sum of these extrapolated values?
      """
    ) {
      oasisData = OasisDataLogger(useExampleData ? exampleData : input)
      return "\(oasisData.nextElement)"
    }
  }
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Analyze your OASIS report again, this time extrapolating the previous value for each history.
      What is the sum of these extrapolated values?
      """
    ) {
      return "\(oasisData.prevElement)"
    }
  }
}


struct OasisDataLogger {
  var topLevelData = [[Int]]()
  var data: [DifferenceArray]
  var nextElement: Int {
    var val = 0
    for (i, array) in topLevelData.enumerated() {
      val += (array.last ?? 0) + data[i].nextElement
    }
    return val
  }
  var prevElement: Int {
    var val = 0
    
    for (i, array) in topLevelData.enumerated() {
      val += (array.first ?? 0) - data[i].prevElement
    }
    return val
  }
  
  init(_ Input: String) {
    self.data =  [DifferenceArray]()
    let rawArray = rawDataAsArray(Input, delim: .newline) { $0 }
    
    for d in rawArray {
      self.topLevelData.append(rawDataAsArray(d, delim: .space) { Int($0) } )
      self.data.append(DifferenceArray(rawDataAsArray(d, delim: .space) {Int($0)} ))
    }

  }
}

class DifferenceArray {
    var data: [Int]
    var diffs: DifferenceArray?
    var nextElement: Int {
        guard !isFinalDiff, let v1 = data.last else { return 0 }
        return v1 + (diffs?.nextElement ?? 0)
    }
    var prevElement: Int {
        guard !isFinalDiff, let v1 = data.first else { return 0 }
        return v1 - (diffs?.prevElement ?? 0)
    }
    var isFinalDiff: Bool

    init(_ parentData: [Int]) {
        self.data = zip(parentData, parentData.dropFirst()).map { $1 - $0 }
        self.isFinalDiff = (data.count == 1 || Set(data) == [0])
        if !isFinalDiff {
            diffs = DifferenceArray(self.data)
        }
    }
}
