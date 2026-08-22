TARGET := swift-file-dsl

.PHONY: clean test lint format

clean:
	swift package clean
	rm -rf Artifacts

# MARK: - tests

test: clean Artifacts/$(TARGET).xcresult

Artifacts/$(TARGET).xcresult:
	@swift --version
	@xcodebuild -version
	@xcodebuild -list -quiet
	xcodebuild test \
		-scheme $(TARGET) \
		-destination 'platform=macOS,arch=arm64' \
		-destination 'platform=macOS,arch=arm64,variant=Mac Catalyst' \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
		-disable-concurrent-destination-testing \
		-derivedDataPath DerivedData \
		-resultBundlePath $@ \
		-quiet
	xcrun xccov view --only-targets --report $@

Artifacts/$(TARGET)-macOS.xcresult:
	xcodebuild test -quiet -scheme $(TARGET) -resultBundlePath $@ -destination 'platform=macOS,arch=arm64'
	xcrun xccov view --only-targets --report $@

Artifacts/$(TARGET)-MacCatalyst.xcresult:
	xcodebuild test -quiet -scheme $(TARGET) -resultBundlePath $@ -destination 'platform=macOS,arch=arm64,variant=Mac Catalyst'
	xcrun xccov view --only-targets --report $@

Artifacts/$(TARGET)-iOS.xcresult:
	xcodebuild test -quiet -scheme $(TARGET) -resultBundlePath $@ -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
	xcrun xccov view --only-targets --report $@

# MARK: - format

lint:
	xcrun swift-format lint --recursive --strict ./

format:
	xcrun swift-format --recursive --in-place ./
