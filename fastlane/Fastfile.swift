// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    
    func buildAndTestLane() {
        desc("Builds and runs tests")
        
        scan(
            scheme: .some("CI"),
            device: "iPhone 12 Pro",
            codeCoverage: true,
            buildlogPath: "./build/tests_log",
            sdk: "iphonesimulator",
            xcargs: "ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO"
        )
        
        // Build the app without archiving, copying the raw logs to the project folder
        echo(message: "🔴🟢 LaneMessage: Making Directory 🔴🟢")
        sh(command: "mkdir -p ./build", errorCallback: logError)
        sh(command: "touch ./build/build_log", errorCallback: logError)
        
        echo(message: "🔴🟢 LaneMessage: Running Command 🔴🟢")
        // Run the CocoaPods version of SwiftInfo
        sh(command: "xcodebuild -workspace ./AudioRecorder.xcworkspace -scheme AudioRecorder 2>&1 | tee ./build/build_log", errorCallback: logError)
        
        echo(message: "🔴🟢 LaneMessage: Commiting 🔴🟢")
        // Commit and push SwiftInfo's output
        sh(command: "git add ../SwiftInfo-output/SwiftInfoOutput.json", errorCallback: logError)
        sh(command: "git commit -m \"[ci skip] Updating SwiftInfo Output JSON\"", errorCallback: logError)
        pushToGitRemote()
    }
    
    func logError(_ error: String) {
        echo(message: "🔴🟢 LaneError: \(error) 🔴🟢")
    }
}

// TODO: MAKE SH WORK
// https://docs.fastlane.tools/actions/sh/
//xcodebuild clean build test -project Pokedex.xcodeproj -derivedDataPath Build/ -enableCodeCoverage=YES -scheme "CI" -sdk iphonesimulator -destination "platform=iOS Simulator,OS=14.2,name=iPhone 12 Pro" ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO
