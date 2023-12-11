//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day8: Day {
  let dayNum = 8
  var desertMap = DesertMap("")
  let exampleData = """
      LLR
      
      AAA = (BBB, BBB)
      BBB = (AAA, ZZZ)
      ZZZ = (ZZZ, ZZZ)
      """
  let exampleData2 = """
      LR

      11A = (11B, XXX)
      11B = (XXX, 11Z)
      11Z = (11B, XXX)
      22A = (22B, XXX)
      22B = (22C, 22C)
      22C = (22Z, 22Z)
      22Z = (22B, 22B)
      XXX = (XXX, XXX)
      """
  

  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Starting at AAA, follow the left/right instructions.
      How many steps are required to reach ZZZ?
      """
    ) {
      
      desertMap = DesertMap(useExampleData ? exampleData : input)
      let stepsToExit = desertMap!.countSteps(startAt: "AAA", endAt: "ZZZ")
      print("Num steps: \(stepsToExit)")

      return "\(stepsToExit)"
    }
  }
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Simultaneously start on every node that ends with A.
      How many steps does it take before you're only on nodes that end with Z?
      """
    ) {
      
      desertMap = DesertMap(useExampleData ? exampleData2 : input)
      print(desertMap!.ghostNodes)
      //let stepsToExit = desertMap!.countGhostSteps()
      
      return "Need to refactor pt2.  Brute force takes too long."
    }
  }
}

enum DesertMapDirection: Character {
  case L = "L"
  case R = "R"
}

extension DesertMapDirection: CustomStringConvertible {
  var description: String {
    "\(self.rawValue)"
  }
}

class DesertMapNode {
  var id: String
  var turnLeft: String
  var turnRight: String
  
  init?(_ input: String) {
    var nodeInfo: [String: Any] = ["nodeID": String.self, "leftID": String.self, "rightID": String.self]
    let regexPattern = #"(?<nodeID>\w{3}) = \((?<leftID>\w{3}), (?<rightID>\w{3})\)"#
    do {
      if try getNamedCaptureData(from: input, usingRegEx: regexPattern, forCaptures: &nodeInfo) {
        self.id = nodeInfo["nodeID"] as! String
        self.turnLeft = nodeInfo["leftID"] as! String
        self.turnRight = nodeInfo["rightID"] as! String
      } else {
        return nil
      }
    } catch {
      return nil
    }
  }
}

extension DesertMapNode: Hashable {
  static func == (lhs: DesertMapNode, rhs: DesertMapNode) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension DesertMapNode: CustomStringConvertible {
  var description: String {
    "\(id): [L: \(turnLeft)  R: \(turnRight)]"
  }
}

struct DesertMap {
  var directions: [DesertMapDirection]
  var nodes: [String: DesertMapNode] = [:]
  var ghostNodes = [DesertMapNode]()
  
  init?(_ input: String) {
    if input == "" { return nil }
    
    let mapData = input.components(separatedBy: "\n\n")
    self.directions = mapData[0].map { DesertMapDirection(rawValue: $0)! }
    let tmpnodes: [DesertMapNode] = rawDataAsArray(mapData[1], delim: .newline) { DesertMapNode($0) }
    
    for tmpnode in tmpnodes {
      nodes[tmpnode.id] = tmpnode
      
      if tmpnode.id.hasSuffix("A") {
        ghostNodes.append(tmpnode)
      }
    }
  }
  
  func countSteps(startAt: String, endAt: String) -> Int {
    var stepsToExit = 0
    var found = false
    var currentNode = nodes[startAt]
    var nextNode: DesertMapNode
    
    while !found {
      let dir = directions[stepsToExit % directions.count]
    
      switch dir {
      case .L: 
        nextNode = nodes[currentNode!.turnLeft]!
      case .R:
        nextNode = nodes[currentNode!.turnRight]!
      }
      found = nextNode.id == endAt
      currentNode = nextNode
      stepsToExit += 1
    }
    return stepsToExit
  }
  
  func countGhostSteps() -> Int {
    var stepsToExit = 0
    var found = false
    var currentGhostNodes = ghostNodes
    var nextGhostNodes = ghostNodes

    print("From: \(currentGhostNodes)")
    
    while !found {
      let dir = directions[stepsToExit % directions.count]
      switch dir {
      case .L:
        var idx = 0
        for n in currentGhostNodes {
          nextGhostNodes[idx] = nodes[n.turnLeft]!
          idx += 1
        }
      case .R:
        var idx = 0
        for n in currentGhostNodes {
          nextGhostNodes[idx] = nodes[n.turnRight]!
          idx += 1
        }
      }
      let endNodes = Set(nextGhostNodes.map { node in
        String(node.id.suffix(1))
      })
      
      if endNodes.count == 1 {
        print("At step: \(stepsToExit) - \(endNodes)")
      }
      found = endNodes == ["Z"]
      currentGhostNodes = nextGhostNodes
      stepsToExit += 1
    }
    
    return stepsToExit
  }
  
}
