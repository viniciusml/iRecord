import SwiftInfoCore
import Foundation

FileUtils.buildLogFilePath = "./build/build_log"
FileUtils.testLogFilePath = "./build/tests_log/AudioRecorder-CI.log"

let projectInfo = ProjectInfo(xcodeproj: "AudioRecorder.xcodeproj",
                              target: "AudioRecorder",
                              configuration: "Release")

let api = SwiftInfo(projectInfo: projectInfo)

let output = api.extract(WarningCountProvider.self) +
             api.extract(TestCountProvider.self) +
             api.extract(TargetCountProvider.self, args: .init(mode: .complainOnRemovals)) +
             api.extract(CodeCoverageProvider.self, args: .init(targets: ["AudioRecorder"])) +
             api.extract(LinesOfCodeProvider.self, args: .init(targets: ["AudioRecorder"]))

api.print(output: output)

api.save(output: output)
