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
        return (Model(
            activeInput: 0,
            firstInput: "Press enter to exit, tab to switch inputs",
            secondInput: ""
            ), [])
    }

    func update(model: inout Model, message: Message)
        -> (Model, [Command], LoopState)
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
            return (model, [], .quit)
        }
        return (model, [], .continue)
    }

    func render(model: Model, in screenSize: Size) -> Component {
        let firstInput = InputView(
            at: .topLeft(x: 1, y: 1),
            text: model.firstInput,
            isFirstResponder: model.activeInput == 0,
            onChange: { text in
                return Message.onChange(0, text)
            },
            onClick: {
                debug("=============== \(#file) line \(#line) ===============")
                return Message.focusFirst },
            onEnter: {
                return Message.quit
            })
        let secondInput = InputView(
            at: .topLeft(x: 1, y: 3),
            text: model.secondInput,
            isFirstResponder: model.activeInput == 1,
            isMultiline: true,
            onChange: { model in
                return Message.onChange(1, model)
            },
            onClick: {
                debug("=============== \(#file) line \(#line) ===============")
                return Message.focusSecond }
            )
        return Window(components: [
            firstInput,
            secondInput,
            OnKeyPress(.tab, { return Message.nextInput }),
            OnKeyPress(.backtab, { return Message.prevInput }),
        ])
    }
}
