import Foundation

enum CustomizedAboutAppsLayout: Hashable, Sendable {
    case automatic

    func groups<Element>(for elements: [Element]) -> [[Element]] {
        guard !elements.isEmpty else { return [] }

        var groups: [[Element]] = []
        var startIndex: Int = .zero
        var rowIndex: Int = .zero
        let rows = automaticRows(for: elements.count)

        while startIndex < elements.count {
            let columnCount = rows[min(rowIndex, rows.count - 1)]
            let endIndex = min(startIndex + columnCount, elements.count)
            groups.append(Array(elements[startIndex ..< endIndex]))
            startIndex = endIndex
            rowIndex += 1
        }

        return groups
    }

    private func automaticRows(for elementCount: Int) -> [Int] {
        switch elementCount {
        case 1 ... 3: [elementCount]
        case 4: [2, 2]
        default: [3, 3]
        }
    }
}
