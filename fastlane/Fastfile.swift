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
            derivedDataPath: "Build/",
            sdk: "iphonesimulator",
            xcargs: "ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO"
        )
    }
}

//xcodebuild clean build test -project Pokedex.xcodeproj -derivedDataPath Build/ -enableCodeCoverage=YES -scheme "CI" -sdk iphonesimulator -destination "platform=iOS Simulator,OS=14.2,name=iPhone 12 Pro" ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO

/*
 default_platform :ios
 
 platform :ios do
 desc "Submits a new beta build to TestFlight"
 lane :beta do
 # Run Tests, copying the raw logs to the project folder
 scan(
 scheme: "SwiftInfoExample",
 buildlog_path: "./build/tests_log"
 )
 
 # Build the app without archiving, copying the raw logs to the project folder
 sh("mkdir -p ./build")
 sh("touch ./build/build_log")
 sh("xcodebuild -workspace ./SwiftInfoExample.xcworkspace -scheme SwiftInfoExample 2>&1 | tee ./build/build_log")
 end
 end
 */
