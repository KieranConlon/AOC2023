//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day7: Day {
  let dayNum = 7
  let exampleData = """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    """
  
  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Find the rank of every hand in your set.
      What are the total winnings?
      """
    ) {
      var hands1 = [Hand]()
      let deals = (useExampleData ? exampleData : input).components(separatedBy: "\n")
      for deal in deals {
        hands1.append(Hand(deal, useWildcard: false))
      }
      
      let rankedHands = hands1.sorted(by: <)
      
//      var tmpWinnings = 0
//      for (i, hand) in rankedHands.enumerated() {
//        tmpWinnings += hand.bid * (i+1)
//        print("idx: \(i) \(hand) \(hand.strength) rank=\(i+1) bid=\(hand.bid)  cumulative winnings=\(tmpWinnings)")
//      }
//      
      let winnings = rankedHands.enumerated().reduce(0) { result, handTuple in
        let (i, hand) = handTuple
        return result + hand.bid * (i + 1)
      }
      
      return "\(winnings)"
    }
  }
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Day\(dayNum)-Pt2 context.
      Day\(dayNum)-Pt2 question?
      """
    ) {
      print("-------------------------")
      var hands2 = [Hand]()
      let deals = (useExampleData ? exampleData : input).components(separatedBy: "\n")
      for deal in deals {
        hands2.append(Hand(deal, useWildcard: true))
      }
      
      let rankedHands = hands2.sorted(by: <)
      
//      var tmpWinnings = 0
//      for (i, hand) in rankedHands.enumerated() {
//        tmpWinnings += hand.bid * (i+1)
//        print("idx: \(i) \(hand) \(hand.strength) rank=\(i+1) bid=\(hand.bid)  cumulative winnings=\(tmpWinnings)")
//      }
      
      let winnings = rankedHands.enumerated().reduce(0) { result, handTuple in
        let (i, hand) = handTuple
        return result + hand.bid * (i + 1)
      }
      
      return "\(winnings)"
    }
  }
}

enum CardSymbol: Character {
  case ace = "A", king = "K", queen = "Q", jack = "J"
  case ten = "T", nine = "9", eight = "8", seven = "7", six = "6"
  case five = "5", four = "4", three = "3", two = "2"
}

struct Card: Comparable, Hashable {
  var symbol: CardSymbol
  var useWildcard: Bool
  var rank: Int {
    switch symbol {
    case .ace: return 13
    case .king: return 12
    case .queen: return 11
    case .jack: return useWildcard ? 1 : 10
    case .ten: return useWildcard ? 10 : 9
    case .nine: return useWildcard ? 9 : 8
    case .eight: return useWildcard ? 8 : 7
    case .seven: return useWildcard ? 7 : 6
    case .six: return useWildcard ? 6 : 5
    case .five: return useWildcard ? 5 : 4
    case .four: return useWildcard ? 4 : 3
    case .three: return useWildcard ? 3 : 2
    case .two: return useWildcard ? 2 : 1
    }
  }
  
  static func < (lhs: Card, rhs: Card) -> Bool {
    lhs.rank < rhs.rank
  }
  
  static func == (lhs: Card, rhs: Card) -> Bool {
    lhs.rank == rhs.rank
  }
}

enum HandType: Int {
  case fiveKind = 7
  case fourKind = 6
  case fullHouse = 5
  case threeKind = 4
  case twoPair = 3
  case onePair = 2
  case highCard = 1
}

struct Hand {
  var cards: [Card]
  var bid: Int
  var useWildcard: Bool
  var strength: HandType {
    useWildcard ? calcHandStrengthWithWildcard() : calcHandStrength(for: self.cards)
  }
  
  private func calcHandStrengthWithWildcard() -> HandType {
    let symbolsInHand = Set(cards.compactMap { $0.symbol != .jack ? $0.symbol : nil })
    
    let wildcardIdx = cards.indices.filter { cards[$0].symbol == .jack }
    
    return calcBestHandWithWildcard(at: wildcardIdx, using: symbolsInHand, cardsInHand: cards)
  }
  
  private func calcBestHandWithWildcard(at indices: [Int], using symbols: Set<CardSymbol>, cardsInHand: [Card]) -> HandType {
    guard let idx = indices.first else {
      return calcHandStrength(for: cardsInHand)
    }
    
    var bestHand: HandType = .highCard
    
    /// For the edge case where all 5 cards are `.jack`, then there will be no other symbols to check
    /// in this case, the hand is a `.fiveKind`
    if symbols.count == 0 {
      bestHand = .fiveKind
      return bestHand
    }
    
    for symbol in symbols {
      var tmpHand = cardsInHand
      tmpHand[idx] = Card(symbol: symbol, useWildcard: useWildcard)
      
      let tmpHandStrength = calcBestHandWithWildcard(at: Array(indices.dropFirst()), using: symbols, cardsInHand: tmpHand)
      if tmpHandStrength.rawValue > bestHand.rawValue {
        bestHand = tmpHandStrength
      }
    }
    return bestHand
  }
  
  private func calcHandStrength(for cardsInHand: [Card]) -> HandType {
    let counts = Dictionary<Character, Int>( cardsInHand.map { ($0.symbol.rawValue, 1) }, uniquingKeysWith: +)
    let uniqueCounts = Set(counts.values)
    
    switch (counts, uniqueCounts) {
    case let (_, uc) where uc.contains(5):
      return .fiveKind
    case let (_, uc) where uc.contains(4):
      return .fourKind
    case let (_, uc) where uc.contains(3) && uc.contains(2):
      return .fullHouse
    case let (_, uc) where uc.contains(3):
      return .threeKind
    case let (c, uc) where uc.count == 2 && c.count == 3:
      return .twoPair
    case let (c, uc) where uc.contains(2) && c.count == 4:
      return .onePair
    default:
      return .highCard
    }
  }
  
  init(_ input: String, useWildcard: Bool) {
    self.cards = [Card]()
    self.useWildcard = useWildcard
    let handData = input.components(separatedBy: " ")
    for c in handData[0] {
      self.cards.append(Card(symbol: CardSymbol(rawValue: c)!, useWildcard: useWildcard))
    }
    self.bid = Int(handData[1])!
  }
}

extension Hand: Comparable {
  static func == (lhs: Hand, rhs: Hand) -> Bool {
    if lhs.strength == rhs.strength {
      for (leftCard, rightCard) in zip(lhs.cards, rhs.cards) {
        if leftCard.rank != rightCard.rank {
          return false
        }
      }
      return true // All cards are the same, in the same order.
    }
    return lhs.strength == rhs.strength
  }
  
  static func < (lhs: Hand, rhs: Hand) -> Bool {
    if lhs.strength == rhs.strength {
      for (leftCard, rightCard) in zip(lhs.cards, rhs.cards) {
        if leftCard.rank != rightCard.rank {
          return leftCard.rank < rightCard.rank
        }
      }
      return false // All cards are the same, in the same order.
    }
    return lhs.strength.rawValue < rhs.strength.rawValue
  }
}

extension Hand: CustomStringConvertible {
  var description: String {
    cards.reduce("") { result, card in
      result + String(card.symbol.rawValue)
    }
  }
}
