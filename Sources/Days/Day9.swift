//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day9: Day {
  let dayNum = 0
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
      let oasisData = OasisDataLogger(useExampleData ? exampleData : input)
      
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
      let oasisData = OasisDataLogger(useExampleData ? exampleData : input)
      
      return "\(oasisData.prevElement)"
    }
  }
}


struct OasisDataLogger {
  var topLevelData = [[Int]]()
  var data: [DifferenceArray]
  var nextElement: Int {
    var val = 0
    for i in 0..<topLevelData.count {
      val += topLevelData[i].last! + data[i].nextElement
    }
    return val
  }
  var prevElement: Int {
    var val = 0
    for i in 0..<topLevelData.count {
      let tmp = topLevelData[i].first! - data[i].prevElement
      //print(tmp)
      val += tmp
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
    if isFinalDiff { return 0
    } else {
      guard let v1 = data.last,
            let v2 = diffs?.nextElement else { return 0 }
      return v1 + v2
    }
  }
  var prevElement: Int {
    if isFinalDiff { return 0
    } else {
      guard let v1 = data.first,
            let v2 = diffs?.prevElement else { return 0 }
      return v1 - v2
    }
  }
  var isFinalDiff: Bool
  
  init(_ parentData: [Int]) {
    var _diffData = [Int]()
    zip(parentData, parentData.dropFirst()).forEach { (current, next) in
      _diffData.append(next - current)
    }
    self.data = _diffData
    self.isFinalDiff = (_diffData.count == 1 || Set(_diffData) == [0])
    if !isFinalDiff {
      diffs = DifferenceArray(self.data)
    }
  }
}
