////
///  SpinnersDemo.swift
//

import Ashen

struct SpinnersDemo: Program {
    enum Message {
        case quit
        case toggle
        case nextForegroundColor
        case prevForegroundColor
        case nextBackgroundColor
        case prevBackgroundColor
    }

    struct Model {
        var isAnimating: Bool
        var foreground: Color
        var background: Color
    }

    let spinners: [SpinnerView.Model]

    init() {
        self.spinners = (0..<SpinnerView.Model.availableSpinners).map { i in
            SpinnerView.Model(spinner: i)
        }
    }

    func initial() -> (Model, [Command]) {
        (
            Model(
                isAnimating: true,
                foreground: .any(0),
                background: .any(0)
            ), []
        )
    }

    func update(model: inout Model, message: Message)
        -> Update<Model>
    {
        switch message {
        case .toggle:
            model.isAnimating = !model.isAnimating
        case .nextForegroundColor:
            model.foreground = nextColor(model.foreground)
        case .prevForegroundColor:
            model.foreground = prevColor(model.foreground)
        case .nextBackgroundColor:
            model.background = nextColor(model.background)
        case .prevBackgroundColor:
            model.background = prevColor(model.background)
        case .quit:
            return .quit
        }
        return .model(model)
    }

    func render(model: Model, in screenSize: Size) -> Component {
        let spinners = self.spinners.enumerated().map { (i, spinnerModel) -> Component in
            SpinnerView(
                at: .middleCenter(x: 2 * i - (self.spinners.count + 1) / 2),
                model: spinnerModel,
                foreground: model.foreground,
                background: model.background,
                isAnimating: model.isAnimating
            )
        }
        let wideSpinner = SpinnerView(
            at: .middleCenter(y: 1),
            model: SpinnerView.Model.width(20),
            foreground: model.foreground,
            background: model.background,
            isAnimating: model.isAnimating
        )

        var color: AttrSize = 0
        let colors =
            [
                1, 16, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
                6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 24,
            ].map { (numColors: AttrSize) -> Component in
                let chars: [LabelView] = (0..<numColors).map { row in
                    LabelView(
                        at: .topLeft(),
                        size: DesiredSize(width: 4, height: 1),
                        text: Text(
                            String(format: " %02X ", color + row),
                            [.background(.any(color + row))]
                        )
                    )
                }
                color += numColors
                return FlowLayout.vertical(
                    size: DesiredSize(width: 4, height: .literal(chars.count)),
                    components: chars
                )
            }

        let line1 = "Press ↓↑ to change background colors,"
        let line2 = "and ←→ to change foreground colors."
        let line3 = "Press <Enter> to continue."
        let instructions: LabelView
        if screenSize.width > line1.count + line2.count + line3.count {
            instructions = LabelView(at: .bottom(), text: "\(line1) \(line2) \(line3)")
        }
        else if screenSize.width > line1.count + line2.count {
            instructions = LabelView(at: .bottom(), text: "\(line1) \(line2)\n\(line3)")
        }
        else {
            instructions = LabelView(at: .bottom(), text: "\(line1)\n\(line2)\n\(line3)")
        }
        return Window(
            components: spinners + [
                wideSpinner, instructions,
                FlowLayout(at: .topLeft(y: 1), components: colors),
                OnKeyPress(.enter, { Message.quit }),
                OnKeyPress(.space, { Message.toggle }),
                OnKeyPress(.up, { Message.nextBackgroundColor }),
                OnKeyPress(.down, { Message.prevBackgroundColor }),
                OnKeyPress(.right, { Message.nextForegroundColor }),
                OnKeyPress(.left, { Message.prevForegroundColor }),
            ]
        )
    }

    private func nextColor(_ c: Color) -> Color {
        switch c {
        case let .any(color):
            return .any((color &+ 1) % 0x0100)
        default:
            return .any(0)
        }
    }

    private func prevColor(_ c: Color) -> Color {
        switch c {
        case let .any(color):
            return .any((color &- 1) % 0x0100)
        default:
            return .any(0)
        }
    }
}
