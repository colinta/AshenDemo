////
///  Demo.swift
//

import Foundation
import Ashen


struct Demo: Program {
    let initialDemo: ActiveDemo
    let spinnerProgram = SpinnersDemo()
    let canvasProgram = CanvasDemo()
    let inputProgram = InputDemo()
    let mouseProgram = MouseDemo()
    let flowLayoutProgram = FlowLayoutDemo()
    let gridLayoutProgram = GridLayoutDemo()
    let httpCommandProgram = HttpCommandDemo()

    enum ActiveDemo {
        case spinner
        case canvas
        case input
        case mouse
        case flowLayout
        case gridLayout
        case httpCommand
    }

    struct Model {
        var activeDemo: ActiveDemo
        var spinnerModel: SpinnersDemo.ModelType
        var canvasModel: CanvasDemo.ModelType
        var inputModel: InputDemo.ModelType
        var mouseModel: MouseDemo.ModelType
        var flowLayoutModel: FlowLayoutDemo.ModelType
        var gridLayoutModel: GridLayoutDemo.ModelType
        var httpCommandModel: HttpCommandDemo.ModelType
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
        case httpCommandMessage(HttpCommandDemo.Message)
    }

    init(demo: ActiveDemo = .spinner) {
        initialDemo = demo
    }

    func initial() -> (Model, [Command]) {
        let (spinnerModel, _) = spinnerProgram.initial()
        let (canvasModel, _) = canvasProgram.initial()
        let (inputModel, _) = inputProgram.initial()
        let (mouseModel, _) = mouseProgram.initial()
        let (flowLayoutModel, _) = flowLayoutProgram.initial()
        let (gridLayoutModel, _) = gridLayoutProgram.initial()
        let (httpCommandModel, _) = httpCommandProgram.initial()

        return (
            Model(
                activeDemo: initialDemo,
                spinnerModel: spinnerModel,
                canvasModel: canvasModel,
                inputModel: inputModel,
                mouseModel: mouseModel,
                flowLayoutModel: flowLayoutModel,
                gridLayoutModel: gridLayoutModel,
                httpCommandModel: httpCommandModel,
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
            let update = spinnerProgram.update(model: &model.spinnerModel, message: spinnerMsg)
            if let newModel = update.model {
                model.spinnerModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .canvas
            }
        case let .canvasMessage(canvasMsg):
            let update = canvasProgram.update(model: &model.canvasModel, message: canvasMsg)
            if let newModel = update.model {
                model.canvasModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .input
            }
        case let .inputMessage(inputMsg):
            let update = inputProgram.update(model: &model.inputModel, message: inputMsg)
            if let newModel = update.model {
                model.inputModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .mouse
            }
        case let .mouseMessage(mouseMsg):
            let update = mouseProgram.update(model: &model.mouseModel, message: mouseMsg)
            if let newModel = update.model {
                model.mouseModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .flowLayout
            }
        case let .flowLayoutMessage(flowLayoutMsg):
            let update = flowLayoutProgram.update(model: &model.flowLayoutModel, message: flowLayoutMsg)
            if let newModel = update.model {
                model.flowLayoutModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .gridLayout
            }
        case let .gridLayoutMessage(gridLayoutMsg):
            let update = gridLayoutProgram.update(model: &model.gridLayoutModel, message: gridLayoutMsg)
            if let newModel = update.model {
                model.gridLayoutModel = newModel
            }
            else if case .quit = update {
                model.log = []
                model.activeDemo = .httpCommand
            }
        case let .httpCommandMessage(httpCommandMsg):
            let update = httpCommandProgram.update(model: &model.httpCommandModel, message: httpCommandMsg)
            if let model = update.model, let commands = update.commands {
                model.httpCommandModel = newModel
                (newModel, httpCommandCommands, state)
                let commands = httpCommandCommands.map { $0.map { Message.httpCommandMessage($0) } }
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
                spinnerProgram
                .render(model: model.spinnerModel, in: boxSize)
                .map { (msg: SpinnersDemo.Message) -> Demo.Message in
                    Demo.Message.spinnerMessage(msg)
                }
        case .canvas:
            title = "Canvas Demo"
            demo =
                canvasProgram
                .render(model: model.canvasModel, in: boxSize)
                .map { (msg: CanvasDemo.Message) -> Demo.Message in
                    Demo.Message.canvasMessage(msg)
                }
        case .input:
            title = "InputView Demo"
            demo =
                inputProgram
                .render(model: model.inputModel, in: boxSize)
                .map { (msg: InputDemo.Message) -> Demo.Message in
                    Demo.Message.inputMessage(msg)
                }
        case .mouse:
            title = "MouseView Demo"
            demo =
                mouseProgram
                .render(model: model.mouseModel, in: boxSize)
                .map { (msg: MouseDemo.Message) -> Demo.Message in
                    Demo.Message.mouseMessage(msg)
                }
        case .flowLayout:
            title = "FlowLayout Demo"
            demo =
                flowLayoutProgram
                .render(model: model.flowLayoutModel, in: boxSize)
                .map { (msg: FlowLayoutDemo.Message) -> Demo.Message in
                    Demo.Message.flowLayoutMessage(msg)
                }
        case .gridLayout:
            title = "GridLayout Demo"
            demo =
                gridLayoutProgram
                .render(model: model.gridLayoutModel, in: boxSize)
                .map { (msg: GridLayoutDemo.Message) -> Demo.Message in
                    Demo.Message.gridLayoutMessage(msg)
                }
        case .httpCommand:
            title = "HttpCommand Demo"
            demo =
                httpCommandProgram
                .render(model: model.httpCommandModel, in: boxSize)
                .map { (msg: HttpCommandDemo.Message) -> Demo.Message in
                    Demo.Message.httpCommandMessage(msg)
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
