//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
// 

import Foundation

struct QuestionAnswer {
  var question: String
  var questionByLine: [String] {
    let lines = question.components(separatedBy: "\n")
    return lines.count > 0 ? lines : [""]
  }
  var answer: String?
}

struct DayPartResponse {
  var qa: QuestionAnswer
  var time_ns: Int
  var time_ms: Double  {
    get {
      Double(time_ns) / 1000000.0
    }
  }
}

func executeChallenge(question: String, answer: () -> String) -> DayPartResponse {
  var timer = PerformanceTimer()
  timer.start()
  let qa = QuestionAnswer(question: question, answer: answer())
  return DayPartResponse(qa: qa, time_ns: timer.stop())
}

protocol Day: AnyObject {
  var exampleData: String { get }
  init()
  
  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse
}
