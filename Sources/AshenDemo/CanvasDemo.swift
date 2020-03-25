////
///  CanvasDemo.swift
//

import Foundation
import Ashen


struct CanvasDemo: Program {
    enum Message {
        case tick
        case toggleAnimation
        case offset(Float)
        case offsetReset
        case quit
    }

    struct Model {
        var isAnimating: Bool
        var date: Date
        var timeOffset: TimeInterval
    }

    func initial() -> (Model, [Command]) {
        (Model(isAnimating: false, date: Date(), timeOffset: 0), [])
    }

    func update(model: inout Model, message: Message)
        -> Update<Model>
    {
        switch message {
        case .tick:
            model.date = Date()
        case .toggleAnimation:
            model.isAnimating = !model.isAnimating
        case let .offset(dt):
            model.timeOffset += TimeInterval(dt)
        case .offsetReset:
            model.timeOffset = 0
        case .quit:
            return .quit
        }
        return .model(model)
    }

    private func lpad(_ time: Int, as component: NSCalendar.Unit) -> String {
        if component == .hour && time == 0 {
            return "12"
        }
        else if component == .hour && time > 12 {
            return lpad(time - 12, as: .hour)
        }
        else if time < 10 {
            return "0\(time)"
        }
        return "\(time)"
    }

    func render(model: Model, in screenSize: Size) -> Component {
        let date = model.date.addingTimeInterval(model.timeOffset)
        let hour = Float(NSCalendar.current.component(.hour, from: date))
        let minute = Float(NSCalendar.current.component(.minute, from: date))
        let second = Float(NSCalendar.current.component(.second, from: date))
        let totalSeconds = (hour * 3600 + minute * 60 + second)

        let hourRadius: Float = 0.6
        let hourAngle = hour * 2 * Float.pi / 12
        let hourPt = FloatPoint(
            x: hourRadius * cos(Float.pi / 2 - hourAngle),
            y: hourRadius * sin(Float.pi / 2 - hourAngle)
        )
        let minuteRadius: Float = 0.8
        let minuteAngle = minute * 2 * Float.pi / 60
        let minutePt = FloatPoint(
            x: minuteRadius * cos(Float.pi / 2 - minuteAngle),
            y: minuteRadius * sin(Float.pi / 2 - minuteAngle)
        )
        let secondRadius: Float = 1
        let secondAngle = second * 2 * Float.pi / 60
        let secondPt = FloatPoint(
            x: secondRadius * cos(Float.pi / 2 - secondAngle),
            y: secondRadius * sin(Float.pi / 2 - secondAngle)
        )

        let canvasSize = min((screenSize.width - 2) / 2, screenSize.height - 13)
        let timingComponent: Component?
        if model.isAnimating {
            timingComponent = OnNext({ Message.offset(3600) })
        }
        else {
            timingComponent = nil
        }

        let watchFrame = FloatFrame(x: -1, y: -1, width: 2, height: 2)
        let watchDecorations: [CanvasView.Drawable] = [
            .line(FloatPoint(x: watchFrame.minX, y: 0), FloatPoint(x: watchFrame.minX + 0.1, y: 0)),
            .line(FloatPoint(x: watchFrame.maxX, y: 0), FloatPoint(x: watchFrame.maxX - 0.1, y: 0)),
            .line(FloatPoint(x: 0, y: watchFrame.minY), FloatPoint(x: 0, y: watchFrame.minY + 0.1)),
            .line(FloatPoint(x: 0, y: watchFrame.maxY), FloatPoint(x: 0, y: watchFrame.maxY - 0.1)),
        ]

        let timeChars = ["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘",]
        let timeChr = timeChars[Int(totalSeconds * Float(timeChars.count) / 86400)]

        let sinWaveFn: (Float) -> Float = { x in
            0.5 - cos((totalSeconds + x) / 86_400 * 2 * Float.pi) / 2
        }
        let sinWave = CanvasView(
            at: .bottomLeft(),
            size: DesiredSize(width: screenSize.width, height: 10),
            viewport: FloatFrame(x: -43_200, y: -1, width: 86_400, height: 2),
            drawables: [
                .line(FloatPoint(x: 0, y: -1), FloatPoint(x: 0, y: 1)),
                .fn(sinWaveFn),
            ]
        )
        let clock = CanvasView(
            at: .middleCenter(y: -4),
            size: DesiredSize(width: 2 * canvasSize, height: canvasSize),
            viewport: watchFrame,
            drawables: watchDecorations + [
                .border,
                .line(FloatPoint.zero, minutePt),
                .line(FloatPoint.zero, hourPt),
                .line(FloatPoint.zero, secondPt),
            ]
        )
        let components: [Component] = [
            OnKeyPress(.up, { Message.offset(3600) }),
            OnKeyPress(.down, { Message.offset(-3600) }),
            OnKeyPress(.backspace, { Message.offsetReset }),
            OnKeyPress(.enter, { Message.quit }),
            OnKeyPress(.space, { Message.toggleAnimation }),
            OnTick({ _ in Message.tick }, every: 0.1),
            LabelView(
                at: .topLeft(x: 2),
                text:
                    "\(lpad(Int(hour), as: .hour)):\(lpad(Int(minute), as: .minute)):\(lpad(Int(second), as: .second))\(hour >= 12 && hour < 24 ? "pm" : "am")"
            ),
            sinWave,
            clock,
            LabelView(at: .middleCenter(x: canvasSize / 2, y: canvasSize / 4 - 4), text: timeChr),
        ] + (timingComponent.map { [$0] } ?? [])
        return Window(components: components)
    }
}
