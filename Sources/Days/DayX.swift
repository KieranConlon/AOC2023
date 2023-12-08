//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class DayX: Day {  
  let dayNum = 0
  let exampleData = ""
  
  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Day\(dayNum)-Pt1 context.
      Day\(dayNum)-Pt1 question?
      """
    ) {
      // solve the challege code goes here
      
      // format the answer as a `String` to be printed to the console
      return "Day\(dayNum)-Pt1 Answer"
    }
  }
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Day\(dayNum)-Pt2 context.
      Day\(dayNum)-Pt2 question?
      """
    ) {
      // solve the challege code goes here
      
      // format the answer as a `String` to be printed to the console
      return "Day\(dayNum)-Pt2 Answer"
    }
  }
}
