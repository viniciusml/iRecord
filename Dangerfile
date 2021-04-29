
swiftinfo.run './swiftinfo/bin/swiftinfo'

# Generate report
report = xcov.produce_report(
    scheme: 'AudioRecorder',
    workspace: 'AudioRecorder.xcodeproj',
    minimum_coverage_percentage: 75.0,
    derived_data_path: '../build/Build/Products'
)

# Post report
xcov.output_report(report)