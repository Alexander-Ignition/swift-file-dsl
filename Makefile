TARGET := swift-file-dsl

.PHONY: clean test lint format

clean:
	swift package clean
	rm -rf Artifacts

# MARK: - format

lint:
	xcrun swift-format lint --recursive --strict ./

format:
	xcrun swift-format --recursive --in-place ./

# MARK: - tests

XCODE_TEST = xcodebuild test -quiet -scheme $(TARGET) -resultBundlePath $@

Artifacts/$(TARGET)-macOS.xcresult:
	$(XCODE_TEST) -destination 'platform=macOS,arch=arm64'

Artifacts/$(TARGET)-MacCatalyst.xcresult:
	$(XCODE_TEST) -destination 'platform=macOS,arch=arm64,variant=Mac Catalyst'

Artifacts/$(TARGET)-iOS.xcresult:
	$(XCODE_TEST) -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

test:
	$(MAKE) Artifacts/$(TARGET)-macOS.xcresult
	$(MAKE) Artifacts/$(TARGET)-MacCatalyst.xcresult
	$(MAKE) Artifacts/$(TARGET)-iOS.xcresult
	$(MAKE) Artifacts/$(TARGET).xcresult

Artifacts/$(TARGET).xcresult: $(wildcard Artifacts/$(TARGET)-*.xcresult)
	rm -rf $@
	xcrun xcresulttool merge $^ --output-path $@
	xcrun xccov view --only-targets --report $@
ifeq ($(GITHUB_ACTIONS),true)
	@echo "### 📊 Code coverage ($(TARGET))" >> $$GITHUB_STEP_SUMMARY
	@echo "\`\`\`text" >> $$GITHUB_STEP_SUMMARY
	@xcrun xccov view --only-targets --report $@ >> $$GITHUB_STEP_SUMMARY
	@echo "\`\`\`" >> $$GITHUB_STEP_SUMMARY
endif

# MARK: - zip

Artifacts/$(TARGET)-%.xcresult.zip: Artifacts/$(TARGET)-%.xcresult
	cd Artifacts && zip -q -r $(notdir $<).zip $(notdir $<)
	rm -rf $<

Artifacts/$(TARGET).xcresult.zip:
	ls Artifacts
	unzip -q "Artifacts/$(TARGET)-*.zip" -d Artifacts
	$(MAKE) Artifacts/$(TARGET).xcresult
	cd Artifacts && zip -q -r $(TARGET).xcresult.zip $(TARGET).xcresult
