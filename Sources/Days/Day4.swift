//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day4: Day {
  var scratchCardCollection = ScratchCardCollection("")
  
  let exampleData = """
      Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
      Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
      Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
      Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
      Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
      Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
      """
  
  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Take a seat in the large pile of colorful cards.
      How many points are they worth in total?
      """
    ) {
      
      scratchCardCollection = ScratchCardCollection(useExampleData ? exampleData : input)
      
      return "\(scratchCardCollection.totalScore)"
    }
  }
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Process all of the original and copied scratchcards until no more scratchcards are won.
      Including the original set of scratchcards, how many total scratchcards do you end up with?
      """
    ) {
      
      scratchCardCollection.determineCardCopies()
      
      let copies = scratchCardCollection.totalCardCopies

      return "\(copies)"
    }
  }
}

class ScratchCard {
  var gameID: Int
  var winningNumbers: Set<Int>
  var gameNumbers: Set<Int>
  var matchedNumbers: Set<Int> {
    self.winningNumbers.intersection(self.gameNumbers)
  }
  var score: Int {
    let n = matchedNumbers.count
    return n > 0 ? Int(pow(2, Double(n-1))) : 0
  }
  var numMatchNumbers: Int {
    matchedNumbers.count
  }
  var copies: Int = 1
  
  init(_ input: String) {
    let cardData = input.components(separatedBy: " | ")
    let gameData = cardData[0].components(separatedBy: ": ")
    let regexPattern = #"Card\s*(?<cardID>\d{1,3})"#
    var captures: [String: Any] = ["cardID": Int.self]
    let _ = try! getNamedCaptureData(from: gameData[0], usingRegEx: regexPattern, forCaptures: &captures)
    self.gameID = captures["cardID"] as! Int
    self.winningNumbers = Set(rawDataAsArray(gameData[1], delim: .space) { Int($0) })
    self.gameNumbers = Set(rawDataAsArray(cardData[1], delim: .space) { Int($0) })
  }
}

struct ScratchCardCollection {
  var cards: [ScratchCard]
  var totalScore: Int {
    cards.reduce(0) { $0 + $1.score }
  }
  var totalCardCopies: Int {
    cards.reduce(0) { $0 + $1.copies }
  }
  
  mutating func determineCardCopies() {
    for card in self.cards {
      //print("card: \(card.gameID) has \(card.numMatchNumbers) matched numbers and \(card.copies) copies")

      let currentCard = card.gameID
      let numMatchNumbers = card.numMatchNumbers
      
      for _ in 1...card.copies {
        //print("processing card \(card.gameID)")
        for i in currentCard..<(currentCard + numMatchNumbers) {
          if i < self.cards.count {
            self.cards[i].copies += 1
          }
        }
      }
    }
  }
  
  init(_ input: String) {
    if input != "" {
      self.cards = rawDataAsArray(input, delim: .newline) { ScratchCard($0) }
    } else {
      self.cards = [ScratchCard]()
    }

  }
}
