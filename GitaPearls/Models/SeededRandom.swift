import Foundation

struct SeededRandom {
    private var state: UInt64
    
    init(seed: Int) {
        var seed = UInt64(bitPattern: Int64(seed))
        seed = seed &+ 0x9E3779B97F4A7C15
        var z = seed
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        state = z ^ (z >> 31)
    }
    
    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
    
    mutating func nextInt(in range: Range<Int>) -> Int {
        let rangeWidth = UInt64(range.upperBound - range.lowerBound)
        let random = next() % rangeWidth
        return range.lowerBound + Int(random)
    }
    
    mutating func randomInt(in range: ClosedRange<Int>) -> Int {
        let count = range.upperBound - range.lowerBound + 1
        let random = next() % UInt64(count)
        return range.lowerBound + Int(random)
    }
    
    mutating func randomInt(in range: Range<Int>) -> Int {
        return nextInt(in: range)
    }
}
