import Foundation

public struct CustomizedAboutAppsLayout: Hashable, Sendable {
    public static let oneByOne = Self(rows: [1])
    public static let oneByTwo = Self(rows: [2])
    public static let oneByThree = Self(rows: [3])
    public static let oneByThreePlusTwoByOne = Self(rows: [3, 1, 1])
    public static let oneByThreePlusTwoByTwo = Self(rows: [3, 2, 2])
    public static let oneByThreePlusTwoByThree = Self(rows: [3, 3, 3])

    public let rows: [Int]

    public init(rows: [Int]) {
        let validRows = rows.filter { $0 > 0 }
        self.rows = validRows.isEmpty ? [1] : validRows
    }

    public func groups<Element>(for elements: [Element]) -> [[Element]] {
        guard !elements.isEmpty else { return [] }

        var groups: [[Element]] = []
        var startIndex = 0
        var rowIndex = 0

        while startIndex < elements.count {
            let columnCount = rows[min(rowIndex, rows.count - 1)]
            let endIndex = min(startIndex + columnCount, elements.count)
            groups.append(Array(elements[startIndex ..< endIndex]))
            startIndex = endIndex
            rowIndex += 1
        }

        return groups
    }
}
