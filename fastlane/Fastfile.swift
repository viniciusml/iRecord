// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
	func customLane() {
	desc("Description of what the lane does")
		// add actions here: https://docs.fastlane.tools/actions
        
	}
}


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
 
 # Archive the app, copying the raw logs to the project folder
 #gym(
 #     workspace: "SwiftInfoExample.xcworkspace",
 #     scheme: "SwiftInfoExample",
 #     buildlog_path: "./build/build_log",
 #   output_directory: "build",
 #   # This is so you can run this with automatic provisioning
 #   xcargs: "-allowProvisioningUpdates",
 # )
 
 # Uncomment me if copying this to a real project
 # Run SwiftInfo
 # sh("../Pods/SwiftInfo/swiftinfo")
 
 # Commit and push SwiftInfo's result
 # sh("git add ../SwiftInfo-output/SwiftInfoOutput.json")
 # sh("git commit -m \"[ci skip] Updating SwiftInfo Output JSON\"")
 # push_to_git_remote
 end
 end
 */
