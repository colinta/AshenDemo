////
///  FlowLayoutDemo.swift
//

import Darwin
import Ashen


struct FlowLayoutDemo: Program {
    enum Message {
        case quit
        case randomize
    }

    struct Model {
        var orientation: FlowLayout.Orientation
        var direction: FlowLayout.Direction
        var strings: [String]

        init() {
            if Int(arc4random_uniform(UInt32(2))) == 0 {
                orientation = .vertical
            }
            else {
                orientation = .horizontal
            }

            if Int(arc4random_uniform(UInt32(2))) == 0 {
                direction = .ltr
            }
            else {
                direction = .rtl
            }

            strings = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ12345678910".map { chr in
                let count = 3 + Int(arc4random_uniform(UInt32(10)))
                let row = String(repeating: chr, count: count)
                return Array<String>(repeating: row, count: count).joined(separator: "\n")
            }
        }
    }

    func initial() -> (Model, [Command]) {
        (Model(), [])
    }

    func update(model: inout Model, message: Message)
        -> Update<Model>
    {
        switch message {
        case .quit:
            return .quit
        case .randomize:
            model = Model()
            return .model(model)
        }
    }

    func render(model: Model, in screenSize: Size) -> Component {
        let labels = model.strings.map { text in
            LabelView(text: text)
        }
        return Window(components: [
            Instructions([
                "Press <Tab> to randomize the content.",
            ], screenSize: screenSize),
            LabelView(at: .topLeft(), text: "\(model.orientation)  ---  \(model.direction)"),
            OnKeyPress(.enter, { Message.quit }),
            OnKeyPress(.tab, { Message.randomize }),
            FlowLayout(
                at: .topLeft(y: 1),
                size: DesiredSize(width: screenSize.width, height: screenSize.height - 1),
                orientation: model.orientation,
                direction: model.direction,
                components: labels
            ),
        ])
    }
}
