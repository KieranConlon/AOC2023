//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

let ESC = "\u{001B}"

func printChristmasTree(height: Int, printEscapeChars: Bool) {
  // The tree's height is the AOC day number, although is clamped between 3...25
  let treeHeightRange = 3...25
  let h = min(max(height, treeHeightRange.lowerBound), treeHeightRange.upperBound)
  
  // Clear the terminal screen
  if printEscapeChars {
    print("\(ESC)[2J")
  }
  
  printTree(h, printColor: printEscapeChars)
  printTreeTrunk(h, printColor: printEscapeChars)
}



//
// MARK: private functions
//

let RESET = "\(ESC)[0m"

fileprivate func printTree(_ h: Int, printColor: Bool) {
  var start = 1
  var stop = 0
  var diff = 3
  
  while stop < h + 1 {
    stop = start + diff
    triangle(f: start, n: stop, toth: h, printColor: printColor)
    diff += 1
    start = stop - 2
  }
}

fileprivate func triangle(f: Int, n: Int, toth: Int, printColor: Bool) {
  var k = 2 * toth - 2
  
  for _ in 0..<f - 1 {
    k -= 1
  }
  
  // number of rows
  for i in f - 1..<n {
    // space handler
    for _ in 0..<k {
      print(" ", terminator: "")
    }
    
    // decrementing k after each loop
    k -= 1
    
    // number of columns, printing stars
    for _ in 0...i {
      printLeaf(printColor: printColor)
    }
    
    print()
  }
}

fileprivate func printLeaf(printColor: Bool) {
  enum ASCIIColors: String {
    case red     = "[0;31m"
    case yellow  = "[0;33m"
    case blue    = "[0;34m"
    case magenta = "[0;35m"
    case cyan    = "[0;36m"
    case white   = "[0;37m"
    
    static var random: String {
      let allColors: [ASCIIColors] = [
        .red, .yellow, .blue, .magenta, .cyan, .white
      ]
      return "\u{001B}\(allColors.randomElement()!.rawValue)"
    }
  }
  
  let leafGreen = "\(ESC)[0;32m"
  let leafDecorations: [Character] = [".", "+", "o", "$", "@", "~", "§"]
  
  // Print some random leaf decorations
  let randomness = 5
  if Int.random(in: 0..<randomness) == 1 {
    if printColor {
      print("\(ASCIIColors.random)\(leafDecorations.randomElement()!) ", terminator: "\(RESET)")
    } else {
      print("\(leafDecorations.randomElement()!) ", terminator: "")
    }
  } else {
    if printColor {
      print("\(leafGreen)* ", terminator: "\(RESET)")
    } else {
      print("* ", terminator: "")
    }
  }
}

fileprivate func printTreeTrunk(_ n: Int, printColor: Bool) {
  let k = 2 * n - 4
  
  for _ in 1...(Int(n/5) + 1) {
    // space handler
    for _ in 0..<k {
      print(" ", terminator: "")
    }
    
    for _ in 1...5 {
      if printColor {
        print("\(ESC)[38;5;172m#", terminator: "\(RESET)")
      } else {
        print("#", terminator: "")
      }
    }
    
    print()
  }
}
