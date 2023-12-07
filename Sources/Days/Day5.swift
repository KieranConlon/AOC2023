//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day5: Day {
  var farm: Farm = Farm("")
  let exampleData = """
      seeds: 79 14 55 13
      
      seed-to-soil map:
      50 98 2
      52 50 48
      
      soil-to-fertilizer map:
      0 15 37
      37 52 2
      39 0 15
      
      fertilizer-to-water map:
      49 53 8
      0 11 42
      42 0 7
      57 7 4
      
      water-to-light map:
      88 18 7
      18 25 70
      
      light-to-temperature map:
      45 77 23
      81 45 19
      68 64 13
      
      temperature-to-humidity map:
      0 69 1
      1 0 69
      
      humidity-to-location map:
      60 56 37
      56 93 4
      """
  
  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      The gardener and his team want to get started as soon as possible, so they'd like to know the closest location that needs a seed.
      Using these maps, find the lowest location number that corresponds to any of the initial seeds.
      To do this, you'll need to convert each seed number through other categories until you can find its corresponding location number.
      What is the lowest location number that corresponds to any of the initial seed numbers?
      """
    ) {
      farm = Farm(useExampleData ? exampleData : input)
      farm.findFinalLocationsForSeeds()
      var closestLocation: SeedNum
      closestLocation = farm.seeds.reduce(SeedNum.max) { result, destination in
        let v = min(destination.destinations[.location]!, result)
        return v
      }
      return "\(closestLocation)"
    }
  }
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Consider all of the initial seed numbers listed in the ranges on the first line of the almanac.
      What is the lowest location number that corresponds to any of the initial seed numbers?
      """
    ) {

//      farm.findFinalLocationsForSeedRanges()
//      var closestLocation: SeedNum
//      closestLocation = farm.seedRanges.reduce(SeedNum.max) { result, destination in
//        let v = min(destination.destinations[.location]!, result)
//        return v
//      }
//      return "\(closestLocation)"
      return "*** Need to do some more work for pt2! ***"
    }
  }
}

enum CategoryType: String {
  case seed
  case soil
  case fertilizer
  case water
  case light
  case temperature
  case humidity
  case location
}

typealias SeedNum = Int64

struct Category {
  private (set) var start: SeedNum
  private (set) var span: SeedNum
  var range: ClosedRange<SeedNum> { start...(start+span-1) }
  
  init(start: SeedNum, span: SeedNum) {
    self.start = start
    self.span = span
  }
  
  func contains(_ val: SeedNum) -> Bool { return range.contains(val)}
}

struct CategoryMovement {
  var source: Category
  var destination: Category
  
  init?(_ input: String) {
    if input == "" { return nil }
    let values = rawDataAsArray(input, delim: .space) { SeedNum($0) }
    self.destination = Category(start: values[0], span: values[2])
    self.source = Category(start: values[1], span: values[2])
  }
  
  func sourceContains(_ val: SeedNum) -> Bool { source.contains(val) }
  func destinationContains(_ val: SeedNum) -> Bool { destination.contains(val) }
  
  func getDestination(forSource src: SeedNum) -> SeedNum {
    if !sourceContains(src) { return src }
    let offset = src - source.start
    return destination.start + offset
  }
}

struct Map {
  let name: String
  let sourceType: CategoryType
  let destinationType: CategoryType
  var categoryMovements: [CategoryMovement]
  
  init?(_ input: String) {
    let mappingData = rawDataAsArray(input, delim: .colon) { String($0) }
    self.name = mappingData[0]
    self.categoryMovements = rawDataAsArray(mappingData[1], delim: .newline) { CategoryMovement($0) }
    
    
    let regexPattern = #"^(?<src>.*)-to-(?<dest>.*) map"#
    var captures: [String: Any] = ["src": String.self, "dest": String.self]
    do {
      if try !getNamedCaptureData(from: mappingData[0], usingRegEx: regexPattern, forCaptures: &captures) {
        return nil
      }
    } catch {
      return nil
    }
    
    guard let src = captures["src"] as? String else {
      return nil
    }
    self.sourceType = CategoryType(rawValue: src)!
    
    guard let dest = captures["dest"] as? String else {
      return nil
    }
    self.destinationType = CategoryType(rawValue: dest)!
  }
  
  func getDestination(forSource src: SeedNum) -> (num: SeedNum, destination: CategoryType) {
    for map in categoryMovements {
      if map.sourceContains(src) {
        return (num: map.getDestination(forSource: src), destination: self.destinationType)
      }
    }
    return (num: src, destination: self.destinationType)
  }
}

struct Seed {
  var number: SeedNum
  var sourceType: CategoryType = .seed
  var destinations = [CategoryType: SeedNum]()
}

struct Farm {
  var seeds: [Seed]
  var seedRanges: [Seed]
  var maps: [Map]
  
  init(_ input: String) {
    if input == "" {
      self.seeds = [Seed]()
      self.seedRanges = [Seed]()
      self.maps = [Map]()
    } else {
      let farmData = input.components(separatedBy: "\n\n")
      
      let seedData = farmData.first!.components(separatedBy: ": ")
      self.seeds = rawDataAsArray(seedData[1], delim: .space) { Seed(number: SeedNum($0)!) }
      
      self.seedRanges = [Seed]()
//      for range in 0..<(seeds.count / 2) {
//        let start = self.seeds[2*range].number
//        let stop  = start + self.seeds[2*range + 1].number
//        for seedNum in start..<stop {
//          self.seedRanges.append(Seed(number: seedNum))
//        }
//      }
      self.maps = farmData.dropFirst().compactMap { Map($0) }
    }
  }
  
  private func getMap(forSource src: CategoryType) -> Map? {
    return maps.first { $0.sourceType == src }
  }
  
  mutating func findFinalLocationsForSeeds() {
    for i in 0..<seeds.count {
      var destintation = seeds[i].sourceType
      var source = seeds[i].sourceType
      var sourceVal = seeds[i].number
      var destinationVal : SeedNum
      while destintation != .location {
        let map = getMap(forSource: source)!
        (destinationVal, destintation) = map.getDestination(forSource: sourceVal)
        seeds[i].destinations[destintation] = destinationVal
        source = destintation
        sourceVal = destinationVal
      }
    }
  }
  
  mutating func findFinalLocationsForSeedRanges() {
    for i in 0..<seedRanges.count {
      var destintation = seedRanges[i].sourceType
      var source = seedRanges[i].sourceType
      var sourceVal = seedRanges[i].number
      var destinationVal : SeedNum
      while destintation != .location {
        let map = getMap(forSource: source)!
        (destinationVal, destintation) = map.getDestination(forSource: sourceVal)
        seedRanges[i].destinations[destintation] = destinationVal
        source = destintation
        sourceVal = destinationVal
      }
    }
  }
}
