//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

final class Day2: Day {
  var cubeGuessingCompetition = CubeGuessingCompetition(totalCubes: [:], cubeGuessingGame: [])
  let exampleData = """
      Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
      Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
      Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
      Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
      Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
      """
  
  func part1(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      Determine which games would have been possible 
       if the bag had been loaded with only
       12 red cubes,
       13 green cubes, and
       14 blue cubes.
      What is the sum of the IDs of those games?
      """
    ) {
      cubeGuessingCompetition.totalCubes = [.red: 12, .green: 13, .blue: 14]
      cubeGuessingCompetition.cubeGuessingGame = rawDataAsArray(useExampleData ? exampleData : input, delim: .newline) { CubeGuessingGame($0) }

      let sumGameIDs = cubeGuessingCompetition.validGameIDs().reduce(0) { $0 + $1 }
      return "\(sumGameIDs)"
    }
  }
  
  func part2(_ input: String, useExampleData: Bool) -> DayPartResponse {
    executeChallenge(question:
      """
      For each game, find the minimum set of cubes that must have been present.
      What is the sum of the power of these sets?
      """
    ) {
      
      let powersetCubes = cubeGuessingCompetition.cubeGuessingGame.map { game in
        (game.maxCubes[.red] ?? 0) * (game.maxCubes[.green] ?? 0) * (game.maxCubes[.blue] ?? 0)
      }
      
      let powerSum = powersetCubes.reduce(0, +)
      
      return "\(powerSum)"
    }
  }
}

enum CubeColor: String {
  case red = "red"
  case blue = "blue"
  case green = "green"
}

struct CubeCollection {
  var cubes: [CubeColor: Int]
  
  init(_ content: String) {
    let cubeInfo = content.components(separatedBy: " ")
    self.cubes = [CubeColor(rawValue: cubeInfo[1])!: Int(cubeInfo[0])!]
  }
}

struct CubeGuessingRound {
  var cubeCollection: [CubeCollection]
  var maxCubes: [CubeColor: Int] {
    var r = 0; var g = 0; var b = 0
    for collection in cubeCollection {
      if let numRed = collection.cubes[.red] {
        r = max(r, numRed)
      }
      if let numGreen = collection.cubes[.green] {
        g = max(g, numGreen)
      }
      if let numBlue = collection.cubes[.blue] {
        b = max(b, numBlue)
      }
    }
    return [.red: r, .green: g, .blue: b]
  }
  
  init(_ content: String) {
    self.cubeCollection = rawDataAsArray(content, delim: .commaSpace) {
      CubeCollection( $0 )
    }
  }
}

struct CubeGuessingGame {
  var gameID: Int
  var rounds: [CubeGuessingRound]
  var maxCubes: [CubeColor: Int] {
    var r = 0; var g = 0; var b = 0
    for round in rounds {
      let maxCubes = round.maxCubes
      if let numRed = maxCubes[.red] {
        r = max(r, numRed)
      }
      if let numGreen = maxCubes[.green] {
        g = max(g, numGreen)
      }
      if let numBlue = maxCubes[.blue] {
        b = max(b, numBlue)
      }
    }
    return [.red: r, .green: g, .blue: b]
  }
  
  init(_ contents: String) {
    let game = contents.components(separatedBy: ": ")
    
    self.gameID = Int(game[0].components(separatedBy: " ")[1])!
    self.rounds = rawDataAsArray(game[1], delim: .semicolonSpace) {
      CubeGuessingRound( $0 )
    }
  }
}

struct CubeGuessingCompetition {
  var totalCubes: [CubeColor: Int]
  var cubeGuessingGame: [CubeGuessingGame]
  
  init(totalCubes: [CubeColor : Int], cubeGuessingGame: [CubeGuessingGame]) {
    self.totalCubes = totalCubes
    self.cubeGuessingGame = cubeGuessingGame
  }
  
  func validGameIDs() -> [Int] {
    var validGames = [Int]()
    for game in cubeGuessingGame {
      if (game.maxCubes[.red]! <= totalCubes[.red]!) &&
         (game.maxCubes[.green]! <= totalCubes[.green]!) &&
         (game.maxCubes[.blue]! <= totalCubes[.blue]!) {
        validGames.append(game.gameID)
      }
    }
    return validGames
  }
}
