////
///  main.swift
//

import Darwin
import Ashen

let args = Swift.CommandLine.arguments
let cmd: String = (args.count > 1 ? args[1] : "demo")

let app = App(program: Demo(), screen: TermboxScreen())
do {
    try app.run()
    exit(EX_OK)
} catch {
    exit(EX_IOERR)
}
