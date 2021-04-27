import SwiftInfoCore
import Foundation

FileUtils.buildLogFilePath = "./build/build_log"
FileUtils.testLogFilePath = "./build/tests_log/AudioRecorder-CI.log"

let projectInfo = ProjectInfo(xcodeproj: "AudioRecorder.xcodeproj",
                              target: "AudioRecorder",
                              configuration: "Release")

let api = SwiftInfo(projectInfo: projectInfo)

let output = api.extract(TotalTestDurationProvider.self)      +
             api.extract(TestCountProvider.self)              +
             api.extract(CodeCoverageProvider.self)           +
             api.extract(LongestTestDurationProvider.self)

//api.sendToSlack(output: output, webhookUrl: "slackUrlHere")
api.print(output: output)

api.save(output: output)
