////
///  InputDemo.swift
//

import Ashen

struct InputDemo: Program {
    enum Message {
        case onChange(Int, String)
        case quit
        case nextInput
        case prevInput
        case focusFirst
        case focusSecond
    }

    struct Model {
        var activeInput: Int
        var firstInput: String
        var secondInput: String
    }

    func initial() -> (Model, [Command]) {
        (
            Model(
                activeInput: 0,
                firstInput: "",
                secondInput: ""
            ), []
        )
    }

    func update(model: inout Model, message: Message)
        -> Update<Model>
    {
        switch message {
        case .nextInput:
            model.activeInput = (model.activeInput + 1) % 2
        case .prevInput:
            model.activeInput = (model.activeInput - 1) % 2
        case .focusFirst:
            model.activeInput = 0
        case .focusSecond:
            model.activeInput = 1
        case let .onChange(index, text):
            if index == 0 {
                model.firstInput = text
            }
            else {
                model.secondInput = text
            }
        case .quit:
            return .quit
        }
        return .model(model)
    }

    func render(model: Model, in screenSize: Size) -> Component {
        let firstInput = InputView(
            at: .topLeft(x: 1, y: 1),
            text: model.firstInput,
            isFirstResponder: model.activeInput == 0,
            onChange: { text in
                Message.onChange(0, text)
            },
            onClick: {
                Message.focusFirst
            },
            onEnter: {
                Message.quit
            }
        )
        let secondInput = InputView(
            at: .topLeft(x: 1, y: 3),
            text: model.secondInput,
            isFirstResponder: model.activeInput == 1,
            isMultiline: true,
            onChange: { model in
                Message.onChange(1, model)
            },
            onClick: {
                Message.focusSecond
            }
        )
        return Window(components: [
            firstInput,
            secondInput,
            OnKeyPress(.tab, { Message.nextInput }),
            OnKeyPress(.backtab, { Message.prevInput }),
            Instructions([
                "Press tab to switch inputs.",
                "The first input is single line,",
                "The second input is multiline.",
                "Try using Shift+Arrow to make selections."
            ], screenSize: screenSize),
        ])
    }
}
