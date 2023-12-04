//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day3: Day {
  var engineSchematic = EngineSchematic("")
  
  let exampleData = """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """
  
  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      The engine schematic (your puzzle input) consists of a visual representation of the engine.
      There are lots of numbers and symbols you don't really understand, but apparently any number
      adjacent to a symbol, even diagonally, is a "part number" and should be included in your sum.
      (Periods (.) do not count as a symbol.)
      What is the sum of all of the part numbers in the engine schematic?
      """
    ) {
      engineSchematic = EngineSchematic(useExampleData ? exampleData : input)
      
      // pre-scan the schematic to find all the possible symbols
      engineSchematic.scanPartSymbols()
      
      // scan the schematic to find all the part numbers and check if they are adjacent to a symbol
      engineSchematic.updateComponentList()
      
      // Our list of part numbers that are adjacent to a symbol will have partType = .real
      var sumPartNums = 0
      for component in engineSchematic.components {
        if component.partType == .real { sumPartNums += component.partNumber}
      }
      
      return "\(sumPartNums)"
    }
  }
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      The missing part wasn't the only issue - one of the gears in the engine is wrong. 
      A gear is any * symbol that is adjacent to exactly two part numbers.
      Its gear ratio is the result of multiplying those two numbers together.
      This time, you need to find the gear ratio of every gear and add them all up so
      that the engineer can figure out which gear needs to be replaced.
      What is the sum of all of the gear ratios in your engine schematic?
      """
    ) {
      // By adding a `gears` dictionary to `engineSchematic` we can track how many gears are linked to parts.
      // Add up the gear.gearRatio values.
      //  Any gear that has only 0 or 1 linked part will return a gearRatio of 0 so adding all gearRatios is safe.
      var sumGearRatios = 0
      for (_, gear) in engineSchematic.gears {
        sumGearRatios += gear.gearRatio
      }
      return "\(sumGearRatios)"
    }
  }
}

enum PartType {
  case real
  case pseudo
  case unknown
}

struct EngineComponent {
  var partNumber: Int
  var partType: PartType
  var location: (x: Int, y: Int, dx: Int)
}

struct GearLocation: Hashable {
  var x: Int
  var y: Int
}

struct Gear {
  var linkedPartNums = [Int]()
  var gearRatio: Int {
    // If linkedPartNums has >1 parts then multiple the partNums
    //   otherwise return 0
    if linkedPartNums.count > 1 {
      return linkedPartNums.reduce(1, *)
    } else {
      return 0
    }
  }
}

struct EngineSchematic {
  var diagram: [String]
  var schematicDimensions: (width: Int, height: Int) {
    !diagram.isEmpty ? (width: diagram[0].count, height: diagram.count) : (width: 0, height: 0)
  }
  var components = [EngineComponent]()
  var partSymbols = Set<Character>()
  var gears = [GearLocation: Gear]()
  
  init(_ input: String) {
    self.diagram = rawDataAsArray(input, delim: .newline) { String($0) }
  }
  
  mutating func scanPartSymbols() {
    let regexPattern = #"([^\d|.|\n])"#
    let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
    for line in diagram {
      let range = NSRange(line.startIndex..., in: line)
      let matches = regex.matches(in: line, options: [], range: range)
      for match in matches {
        let matchRange = match.range
        if matchRange.location != NSNotFound {
          let char = Character((line as NSString).substring(with: matchRange))
          partSymbols.insert(char)
        }
      }
    }
  }
  
  mutating func updateComponentList() {
    self.components = [EngineComponent]()
    let regexPattern = #"(\d{1,6})"#
    let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
    var y = 0
    for line in diagram {
      let range = NSRange(line.startIndex..., in: line)
      let matches = regex.matches(in: line, options: [], range: range)
      for match in matches {
        let matchRange = match.range
        if matchRange.location != NSNotFound {
          let partNum = Int((line as NSString).substring(with: matchRange))!
          var component = EngineComponent(partNumber: partNum, partType: .unknown, location: (x: matchRange.lowerBound, y: y,
                                                                                      dx: matchRange.length))
          let type = determineComponentType(component)
          component.partType = type
          self.components.append(component)
        }
      }
      y += 1
    }
  }
  
  mutating func determineComponentType(_ component: EngineComponent) -> PartType  {
    var searchCells = [(x: Int, y: Int)]()
    
    let rangeX = component.location.x-1 ... component.location.x+component.location.dx
    let rangeY = component.location.y-1 ... component.location.y+1
    
    let schematicDimsX = 0..<self.schematicDimensions.width
    let schematicDimsY = 0..<self.schematicDimensions.height
    
    // populate a list of cells to search for symbols
    for _y in rangeY {
      for _x in rangeX {
        // if line is on the schematic
        if schematicDimsY.contains(_y) {
          
          if _y != component.location.y {   // if line is above or below the part number
            if schematicDimsX.contains(_x) { searchCells.append((x: _x, y: _y)) }
          } else {                          // if line is on the part number line
            if _x == rangeX.lowerBound || _x == rangeX.upperBound {
              if schematicDimsX.contains(_x) { searchCells.append((x: _x, y: _y)) }
            }
          }
        }
      }
    }
    
    // Initially assume every part is a .pseudo part
    // if any of the search cells contain a symbol, then set the part's type to .real
    //
    // Updated for Pt2.
    // When checking the search cells, if the cell contain a gear "*", add the current
    //   part number to array for the gear at this location.
    var type: PartType = .pseudo
    for cell in searchCells {
      let line = diagram[cell.y]
      let c = line[line.index(line.startIndex, offsetBy: cell.x)]
      if partSymbols.contains(c) {
        type = .real
        
        if c == "*" {
          let locn = GearLocation(x: cell.x, y: cell.y)
                   
          if gears[locn] == nil {
            gears[locn] = Gear()
          }
          gears[locn]!.linkedPartNums.append(component.partNumber)
        }
      }
    }
    return type
  }
}
