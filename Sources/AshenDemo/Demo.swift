////
///  Demo.swift
//

import Foundation
import Ashen


struct Demo: Program {
    let initialDemo: ActiveDemo
    let spinnerDemo = SpinnersDemo()
    let canvasDemo = CanvasDemo()
    let inputDemo = InputDemo()
    let mouseDemo = MouseDemo()
    let flowLayoutDemo = FlowLayoutDemo()
    let gridLayoutDemo = GridLayoutDemo()
    let colorsDemo = ColorsDemo()
    let httpDemo = HttpCommandDemo()

    enum ActiveDemo {
        case spinner
        case canvas
        case input
        case mouse
        case flowLayout
        case gridLayout
        case colors
        case http
    }

    struct Model {
        var activeDemo: ActiveDemo
        var spinnerModel: SpinnersDemo.ModelType
        var canvasModel: CanvasDemo.ModelType
        var inputModel: InputDemo.ModelType
        var mouseModel: MouseDemo.ModelType
        var flowLayoutModel: FlowLayoutDemo.ModelType
        var gridLayoutModel: GridLayoutDemo.ModelType
        var colorsModel: ColorsDemo.ModelType
        var httpModel: HttpCommandDemo.ModelType
        var log: [String]
    }

    enum Message {
        case quit
        case keypress(KeyEvent)
        case mouse(MouseEvent)
        case resetLog
        case appendLog(String)
        case spinnerMessage(SpinnersDemo.Message)
        case canvasMessage(CanvasDemo.Message)
        case inputMessage(InputDemo.Message)
        case mouseMessage(MouseDemo.Message)
        case flowLayoutMessage(FlowLayoutDemo.Message)
        case gridLayoutMessage(GridLayoutDemo.Message)
        case colorsMessage(ColorsDemo.Message)
        case httpMessage(HttpCommandDemo.Message)
    }

    init(demo: ActiveDemo = .spinner) {
        initialDemo = demo
    }

    func initial() -> (Model, [Command]) {
        let (spinnerModel, _) = spinnerDemo.initial()
        let (canvasModel, _) = canvasDemo.initial()
        let (inputModel, _) = inputDemo.initial()
        let (mouseModel, _) = mouseDemo.initial()
        let (flowLayoutModel, _) = flowLayoutDemo.initial()
        let (gridLayoutModel, _) = gridLayoutDemo.initial()
        let (colorsModel, _) = colorsDemo.initial()
        let (httpModel, _) = httpDemo.initial()

        return (
            Model(
                activeDemo: initialDemo,
                spinnerModel: spinnerModel,
                canvasModel: canvasModel,
                inputModel: inputModel,
                mouseModel: mouseModel,
                flowLayoutModel: flowLayoutModel,
                gridLayoutModel: gridLayoutModel,
                colorsModel: colorsModel,
                httpModel: httpModel,
                log: []
            ), []
        )
    }

    func update(model: inout Model, message: Message)
        -> Update<Model>
    {
        switch message {
        case .quit:
            return .quit
        case let .keypress(key):
            model.log.append("Pressed \(key)")
        case let .mouse(mouse):
            model.log.append("Mouse \(mouse)")
        case .resetLog:
            model.log = []
        case let .appendLog(entry):
            model.log.append(entry)
        case let .spinnerMessage(spinnerMsg):
            let update = spinnerDemo.update(model: &model.spinnerModel, message: spinnerMsg)
            if let (newModel, _) = update.values {
                model.spinnerModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .canvas
            }
        case let .canvasMessage(canvasMsg):
            let update = canvasDemo.update(model: &model.canvasModel, message: canvasMsg)
            if let (newModel, _) = update.values {
                model.canvasModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .input
            }
        case let .inputMessage(inputMsg):
            let update = inputDemo.update(model: &model.inputModel, message: inputMsg)
            if let (newModel, _) = update.values {
                model.inputModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .mouse
            }
        case let .mouseMessage(mouseMsg):
            let update = mouseDemo.update(model: &model.mouseModel, message: mouseMsg)
            if let (newModel, _) = update.values {
                model.mouseModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .flowLayout
            }
        case let .flowLayoutMessage(flowLayoutMsg):
            let update = flowLayoutDemo.update(model: &model.flowLayoutModel, message: flowLayoutMsg)
            if let (newModel, _) = update.values {
                model.flowLayoutModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .gridLayout
            }
        case let .gridLayoutMessage(gridLayoutMsg):
            let update = gridLayoutDemo.update(model: &model.gridLayoutModel, message: gridLayoutMsg)
            if let (newModel, _) = update.values {
                model.gridLayoutModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .colors
            }
        case let .colorsMessage(colorsMsg):
            let update = colorsDemo.update(model: &model.colorsModel, message: colorsMsg)
            if let (newModel, _) = update.values {
                model.colorsModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .http
            }
        case let .httpMessage(httpMsg):
            let update = httpDemo.update(model: &model.httpModel, message: httpMsg)
            if let (newModel, httpCommands) = update.values {
                model.httpModel = newModel
                let commands = httpCommands.map { $0.map { Message.httpMessage($0) } }
                return .update(model, commands)
            }
            else if case .quit = update {
                return .quit
            }
        }

        return .model(model)
    }

    func render(model: Model, in screenSize: Size) -> Component {
        let logHeight = max(0, min(10, screenSize.height - 30))
        let labelHeight = 1
        var components: [Component] = []

        let title: String
        let demo: Component
        let boxSize = Size(
            width: screenSize.width,
            height: screenSize.height - logHeight - labelHeight
        )
        switch model.activeDemo {
        case .spinner:
            title = "SpinnerView Demo"
            demo =
                spinnerDemo
                .render(model: model.spinnerModel, in: boxSize)
                .map { (msg: SpinnersDemo.Message) -> Demo.Message in
                    Demo.Message.spinnerMessage(msg)
                }
        case .canvas:
            title = "Canvas Demo"
            demo =
                canvasDemo
                .render(model: model.canvasModel, in: boxSize)
                .map { (msg: CanvasDemo.Message) -> Demo.Message in
                    Demo.Message.canvasMessage(msg)
                }
        case .input:
            title = "InputView Demo"
            demo =
                inputDemo
                .render(model: model.inputModel, in: boxSize)
                .map { (msg: InputDemo.Message) -> Demo.Message in
                    Demo.Message.inputMessage(msg)
                }
        case .mouse:
            title = "MouseView Demo"
            demo =
                mouseDemo
                .render(model: model.mouseModel, in: boxSize)
                .map { (msg: MouseDemo.Message) -> Demo.Message in
                    Demo.Message.mouseMessage(msg)
                }
        case .flowLayout:
            title = "FlowLayout Demo"
            demo =
                flowLayoutDemo
                .render(model: model.flowLayoutModel, in: boxSize)
                .map { (msg: FlowLayoutDemo.Message) -> Demo.Message in
                    Demo.Message.flowLayoutMessage(msg)
                }
        case .gridLayout:
            title = "GridLayout Demo"
            demo =
                gridLayoutDemo
                .render(model: model.gridLayoutModel, in: boxSize)
                .map { (msg: GridLayoutDemo.Message) -> Demo.Message in
                    Demo.Message.gridLayoutMessage(msg)
                }
        case .colors:
            title = "Colors Demo"
            demo =
                colorsDemo
                .render(model: model.colorsModel, in: boxSize)
                .map { (msg: ColorsDemo.Message) -> Demo.Message in
                    Demo.Message.colorsMessage(msg)
                }
        case .http:
            title = "HttpCommand Demo"
            demo =
                httpDemo
                .render(model: model.httpModel, in: boxSize)
                .map { (msg: HttpCommandDemo.Message) -> Demo.Message in
                    Demo.Message.httpMessage(msg)
                }
        }

        let demoBox = Box(
            at: .topLeft(x: 0, y: labelHeight),
            size: DesiredSize(boxSize),
            components: [demo]
        )

        components.append(OnMouse({ mouse in Demo.Message.mouse(mouse) }))
        components.append(demoBox)
        components.append(LabelView(at: .topCenter(y: 0), text: Text(title, [.underline, .bold])))
        components.append(
            OnKeyPress({ key in Demo.Message.keypress(key) }, except: [.ctrl(.k)])
        )
        components.append(OnKeyPress({ _ in Demo.Message.resetLog }, only: [.ctrl(.k)]))
        components.append(OnDebug(Message.appendLog))
        components.append(
            Box(
                at: .bottomLeft(x: 10),
                size: DesiredSize(width: screenSize.width - 20, height: logHeight),
                border: .single,
                components: [
                    LogView(at: .topLeft(x: 1, y: 0), entries: model.log)
                ]
            )
        )

        return Window(components: components)
    }
}
