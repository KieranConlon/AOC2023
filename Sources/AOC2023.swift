//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation
import ArgumentParser

@main
struct AOC2023: AsyncParsableCommand {
  
  @Argument(help: "AOC day number.")
  var dayNumber: Int
  
  @Option(name: [.short, .long],
          help: "AOC year number.")
  var yearNumber: Int = 2023
  
  @Option(name: [.short, .long],
          help: "Folder containing the AOC input files.")
  var inputFolder: String = "./inputData/"
  
  @Option(name: [.short, .long],
          help: "Override the default AOC input filename prefix.")
  var prefix: String = "inputD"
  
  @Option(name: [.customShort("e"), .customLong("extension")],
          help: "Override the default AOC input/output file extension.")
  var fileExtension: String = ".txt"
  
  @Option(name: [.customShort("x"), .customLong("example-data")],
          help: "Use hard-coded example data instead of the input file.")
  var useExampleData: Bool = false
  
  @Flag(name: [.short, .long],
        help: "Automatically download the input file for the day.  Specify the session cookie using the `--cookie` option")
  var autoDownload: Bool = false
  
  @Option(name: [.short, .long],
          help: "Required when `--auto-download` is enabled.  Set the AOC website session cookie `session=xxx`")
  var cookie: String?
  
  @Option(name: [.short, .long],
          help: "Folder containing the AOC output files.  If specified, the console output will also be saved to file.")
  var ouputFolder: String = "./outputData/"
  
  @Option(name: [.long],
          help: "Be festive, show a Christmas tree in the output.")
  var festive: Bool = true
  
  @Flag(name: [.long],
        help: "Disable ASCII escape characters (and color) in console output.")
  var disableEscapeChars: Bool = false
  
  func validate() throws {
    if autoDownload && cookie == nil {
      throw ValidationError("`--auto-download` option used, please provide AOC website session cookie in the `--cookie` argument, e.g. `--cookie session=xxxx`.")
    }
  }
  
  mutating func run() async throws {
    let folderPath = (inputFolder.last == "/") ? inputFolder : inputFolder + "/"
    let inputFile = "\(folderPath)\(prefix)\(dayNumber)\(fileExtension)"
    
    guard let dayClass = Bundle.main.classNamed("aoc2023.Day\(dayNumber)") as? Day.Type
    else {
      print("  Unable to create class for Day: \(dayNumber) - exiting.")
      return
    }
    let day = dayClass.init()
    
    if autoDownload {
      guard let _ = await downloadInputFile(for: dayNumber, year: yearNumber, cookie: cookie!, saveTo: folderPath, usingPrefix: prefix, fileExtension: fileExtension) else {
        print("  Error downloading input file.")
        return
      }
    }
    
    var rawInput: String
    do {
      rawInput = try String(contentsOfFile: inputFile)
    } catch {
      print("  Error loading input file.  \(error.localizedDescription)")
      return
    }
    
    // A bit of festive fun!
    // Each day, print a Christmas tree that grows bigger each day
    if festive {
      printChristmasTree(height: dayNumber, printEscapeChars: !disableEscapeChars)
      print()
    }
    
    func printPartInfo(_ dayPart: DayPartResponse, partNumber: Int) {
      let questionLines = dayPart.qa.questionByLine
      print("  Part \(partNumber): \(questionLines[0])")
      for line in questionLines.dropFirst() {
        print("          \(line)")
      }
      
      if let answer = dayPart.qa.answer {
        print("  Answer: \(answer)")
      } else {
        print("  Answer: [No answer available]")
      }
      
      print("          ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺")
      print("    Took: \(dayPart.time_ms) ms\n")
    }
    
    print("---+++*** Advent of Code \(yearNumber) ~ Day: \(dayNumber) ***+++---")
    printPartInfo(day.part1(rawInput, useExampleData: useExampleData), partNumber: 1)
    printPartInfo(day.part2(rawInput, useExampleData: useExampleData), partNumber: 2)
    print("---+++*** Advent of Code \(yearNumber) ~ Day: \(dayNumber) ***+++---")
    
  }
}
