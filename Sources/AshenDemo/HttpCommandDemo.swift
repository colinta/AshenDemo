////
///  HttpCommandDemo.swift
//

import Foundation
import Ashen


struct HttpCommandDemo: Program {
    struct Error: Swift.Error {}

    enum Message {
        case quit
        case sendRequest
        case abort
        case received(Http.HttpResult)
    }

    struct Model {
        var requestSent: Bool
        var http: Http?
        var result: Result<String>?
    }

    func initial() -> (Model, [Command]) {
        (Model(requestSent: false, http: nil, result: nil), [])
    }

    func update(model: inout Model, message: Message)
        -> Update<Model>
    {
        switch message {
        case .sendRequest:
            let cmd = Http.get(
                url: URL(string: "http://www.gutenberg.org/cache/epub/1661/pg1661.txt")!
            )
            { result in
                Message.received(result)
            }
            model.http = cmd
            model.requestSent = true
            return .update(model, [cmd])
        case .quit:
            return .quit
        case let .received(result):
            model.http = nil
            model.result = result.map { statusCode, headers, data in
                if let str = String(data: data, encoding: .utf8) {
                    return str
                }
                throw Error()
            }
        case .abort:
            if let http = model.http {
                http.cancel()
            }
            model.http = nil
        }
        return .model(model)
    }

    func render(model: Model, in screenSize: Size) -> Component {
        guard model.requestSent
        else { return OnNext({ Message.sendRequest }) }

        let content: Component
        if case let .some(.ok(string)) = model.result {
            content = LabelView(at: .topLeft(), text: string)
        }
        else if case let .some(.fail(error)) = model.result {
            content = LabelView(at: .topLeft(), text: "\(error)")
        }
        else if model.http == nil {
            content = LabelView(at: .topLeft(), text: "Aborted.")
        }
        else {
            content = SpinnerView(at: .middleCenter())
        }

        return Window(
            components: [
                OnKeyPress(.enter, { Message.quit }),
            ] + [content]
        )
    }
}
