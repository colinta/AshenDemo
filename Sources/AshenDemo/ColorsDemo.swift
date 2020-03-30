////
///  ColorsDemo.swift
//

import Ashen


struct ColorsDemo: Program {
    enum Message {
        case quit
        case color(AttrSize)
    }

    struct Model {
        var color: AttrSize? = nil
    }

    func initial() -> (Model, [Command]) {
        (Model(), [])
    }

    func update(model: inout Model, message: Message)
        -> Update<Model>
    {
        switch message {
        case let .color(color):
            model.color = color
            return .model(model)
        case .quit:
            return .quit
        }
    }

    private func Color(row: Int, col: Int, color: AttrSize) -> Component {
        Clickable(LabelView(at: .topLeft(x: col * 2, y: (row * 2)), text: Text("  \n  ", [.background(.any(AttrSize(color)))]))) { Message.color(color) }
    }

    func render(model: Model, in screenSize: Size) -> Component {
        var components: [Component] = [OnKeyPress(.enter, { Message.quit })]
        var color: AttrSize = 0
        for col in 0..<2 {
            for row in 0..<8 {
                components.append(Color(row: row, col: col, color: color))
                color += 1
            }
        }
        for col in 2..<42 {
            for row in 0..<6 {
                components.append(Color(row: row, col: col, color: color))
                color += 1
            }
        }
        if let color = model.color {
            components.append(LabelView(at: .topLeft(x: 4, y: 12), text: Text("Selected color: \(color)")))
            components.append(LabelView(at: .topLeft(x: 4, y: 13), text: Text("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()-<>[]{}.", [.foreground(.any(color))])))
            components.append(LabelView(at: .topLeft(x: 4, y: 14), text: Text("                                                                                ", [.background(.any(color))])))
            components.append(LabelView(at: .topLeft(x: 4, y: 15), text: Text("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()-<>[]{}.", [.foreground(.any(color)), .reverse])))
        }
        components.append(Instructions([
            "Click on the color you like.",
        ], screenSize: screenSize))
        return Window(components: components)
    }
}
