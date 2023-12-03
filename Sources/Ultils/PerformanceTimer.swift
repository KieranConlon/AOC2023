//
// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation

struct PerformanceTimer {
  private var timeStart: DispatchTime?
  
  mutating func start() {
    timeStart = DispatchTime.now()
  }
  
  func stop() -> Int {
    guard let startTime = timeStart else { return 0 }
    return Int(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds)
  }
}

