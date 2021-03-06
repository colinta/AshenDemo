////
///  GridLayoutDemo.swift
//

import Darwin
import Ashen


struct GridLayoutDemo: Program {
    enum Message {
        case quit
        case randomize
    }

    struct Model {
        var rows: [(weight: Float, columns: [(weight: Float, bg: String)])]

        init() {
            let strings = [".", "%", "`", ",", "$", "#", "@", ":", "'", "?",]
            let rowCount = 2 + Int(arc4random_uniform(UInt32(4)))
            rows = (0..<rowCount).map { _ in
                let weight: Float = 1 + 5 * Float(drand48())
                let colCount = 2 + Int(arc4random_uniform(UInt32(4)))
                return (
                    weight: weight,
                    columns: (0..<colCount).map { _ in
                        let weight: Float = 1 + 5 * Float(drand48())
                        let index = Int(arc4random_uniform(UInt32(strings.count)))
                        return (weight: weight, bg: strings[index])
                    }
                )
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
            return .model(Model())
        }
    }

    func render(model: Model, in screenSize: Size) -> Component {
        let gridSize = Size(width: screenSize.width, height: screenSize.height - 1)
        return Window(components: [
            Instructions([
                "Press <Tab> to randomize the content.",
            ], screenSize: screenSize),
            OnKeyPress(.enter, { Message.quit }),
            OnKeyPress(.tab, { Message.randomize }),
            GridLayout(
                at: .topLeft(y: 1),
                size: gridSize,
                rows: model.rows.flatMap { row -> [GridLayout.Row] in
                    let b = Box(background: "-")
                    return [
                        .row(
                            weight: .relative(row.weight),
                            row.columns.flatMap { col -> [GridLayout.Column] in
                                [
                                    .column(weight: .relative(col.weight), Box(background: col.bg)),
                                    .column(weight: .fixed(1), Box(background: "|"))
                                ]
                            }
                        ),
                        .row(weight: .fixed(1), [b]),
                    ]
                }
            ),
        ])
    }
}
