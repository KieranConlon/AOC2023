//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day6: Day {
  let exampleData = """
      Time:      7  15   30
      Distance:  9  40  200
      """
  let inputTimes = [63,78,94,68]
  let inputDists = [411,1274,2047,1035]

  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Determine the number of ways you could beat the record in each race.
      What do you get if you multiply these numbers together?
      """
    ) {
      
      ///
      /// Given that:   `s = ut`
      ///   s = distance travelled
      ///   u = speed
      ///   t = race moving time
      ///
      ///   heldTime = h
      ///   timeMoving = t - h
      ///   speed = u = th
      ///   The winning races are when: `s < h * ( t - h )`
      ///
      ///   expand & rearranging: `-h^2 + th - s > 0`
      ///
      ///   so, solve the inequality to find the lower and upper bounds for `h`

      let race1 = solveInequality(time: 63, distance: 411)
      let race2 = solveInequality(time: 78, distance: 1274)
      let race3 = solveInequality(time: 94, distance: 2047)
      let race4 = solveInequality(time: 68, distance: 1035)

      let race1Count = Int(race1.upperBound.rounded(.down)) - Int(race1.lowerBound.rounded(.up)) + 1
      let race2Count = Int(race2.upperBound.rounded(.down)) - Int(race2.lowerBound.rounded(.up)) + 1
      let race3Count = Int(race3.upperBound.rounded(.down)) - Int(race3.lowerBound.rounded(.up)) + 1
      let race4Count = Int(race4.upperBound.rounded(.down)) - Int(race4.lowerBound.rounded(.up)) + 1

      return "\(race1Count * race2Count * race3Count * race4Count)"

    }
  }
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      There's really only one race - ignore the spaces between the numbers on each line.
      How many ways can you beat the record in this one much longer race?
      """
    ) {

      let race = solveInequality(time: 63789468, distance: 411_127_420_471_035)
     
      let raceCount = Int(race.upperBound.rounded(.down)) - Int(race.lowerBound.rounded(.up)) + 1
      return "\(raceCount)"
    }
  }
}

func solveInequality(time t: Int, distance s: Int) -> Range<Double> {
  let a: Double = -1
  let b: Double = Double(t)
  let c: Double = Double(-s)
  let vSmall = 1e-12
  
  let discriminant = b*b - 4*a*c
  
  let root1 = (-b + sqrt(discriminant)) / (2*a) + vSmall
  let root2 = (-b - sqrt(discriminant)) / (2*a) - vSmall
  
  return min(root1, root2)..<max(root1, root2)
}

