////
///  MouseDemo.swift
//

import Ashen

typealias Drawable = (x: Int, y: Int, c: String)

struct MouseDemo: Program {
    enum Message {
        case onMouse(MouseEvent)
        case setBrush(String)
        case quit
    }

    struct Model {
        var drawables: [Drawable] = []
        var brush: String = "█"
    }

    func initial() -> (Model, [Command]) {
        (Model(), [])
    }

    func update(model: inout Model, message: Message)
        -> Update<Model>
    {
        switch message {
        case let .onMouse(mouse):
            guard mouse.button == .left else { break }
            let oldDrawables = model.drawables.filter { $0.x != mouse.x || $0.y != mouse.y }
            if model.brush == " " {
                model.drawables = oldDrawables
            }
            else {
                model.drawables = oldDrawables + [(x: mouse.x, y: mouse.y, c: model.brush)]
            }
            log("drawables: \(model.drawables.count)")
        case let .setBrush(brush):
            model.brush = brush
        case .quit:
            return .quit
        }
        return .model(model)
    }

    func render(model: Model, in screenSize: Size) -> Component {
        let brushes = ["█", "▓", "▒", "░", " "]
        let buttonSize = Size(width: 5, height: 3)
        let brushButtons = brushes.map { brush in
            Button(
                onClick: { Message.setBrush(brush) },
                content: Box(
                    size: DesiredSize(buttonSize),
                    border: model.brush == brush ? .bold : .single,
                    components: [LabelView(text: String(repeating: brush, count: buttonSize.width))]
                )
            )
        }

        let canvasY = 4
        let instructions = Instructions([
            "Click the patterns at the top to change the brush",
            "Click and drag to draw.",
        ], screenSize: screenSize)
        return Window(components: [
            instructions,
            FlowLayout.horizontal(
                size: DesiredSize(width: .max, height: buttonSize.height + 1),
                components: brushButtons
            ),
            Box(
                at: .topRight(x: -5, y: 1),
                size: DesiredSize(width: 10, height: 3),
                border: .single,
                label: "Brush",
                components: [
                    LabelView(text: String(repeating: model.brush, count: 8))
                ]
            ),
            Box(
                at: .topLeft(x: 0, y: canvasY),
                size: DesiredSize(width: screenSize.width, height: screenSize.height - canvasY - instructions.linesHeight),
                border: .single,
                components: [MouseCanvas(model.drawables, onMouse: Message.onMouse)]
            ),
            OnKeyPress(.enter, { Message.quit }),
        ])
    }
}

class MouseCanvas: ComponentView {
    let drawable: [Drawable]
    var onMouse: OnMouseHandler

    public init(_ drawable: [Drawable], onMouse: @escaping OnMouseHandler) {
        self.drawable = drawable
        self.onMouse = onMouse
        super.init()
    }

    override public func desiredSize() -> DesiredSize {
        DesiredSize(width: .max, height: .max)
    }

    override public func messages(for event: Event) -> [AnyMessage] {
        guard
            case let .mouse(mouse) = event,
            mouse.component == self
        else { return [] }
        return [onMouse(mouse)]
    }

    override public func map<T, U>(_ mapper: @escaping (T) -> U) -> Self {
        let component = self
        let myHandler = self.onMouse
        let onMouse: OnMouseHandler = { key in
            return mapper(myHandler(key) as! T)
        }
        component.onMouse = onMouse
        return component
    }

    override public func render(to buffer: Buffer, in rect: Rect) {
        buffer.claimMouse(rect: rect, component: self)

        for d in drawable.reversed() {
            buffer.write(d.c, x: d.x, y: d.y)
        }
    }
}
