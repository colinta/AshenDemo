////
///  Instructions.swift
//

import Ashen


func Instructions(_ lines: [String], screenSize: Size) -> LabelView {
    let allLines = lines + ["Press <Enter> to continue."]
    let initial: ([String], String) = ([], "")
    let (joinedLines, lastLine) = allLines.reduce(initial) { (memo, line) in
        let (lines, buffer) = memo
        if buffer.isEmpty {
            return (lines, line)
        }
        else if buffer.count + line.count + 1 < screenSize.width {
            return (lines, "\(buffer) \(line)")
        }
        else {
            return (lines + [buffer], line)
        }
    }
    let allJoinedLines = joinedLines + [lastLine]
    return LabelView(at: .bottom(), text: allJoinedLines.joined(separator: "\n"))
}
