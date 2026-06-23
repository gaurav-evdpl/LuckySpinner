import XCTest
import SwiftUI
@testable import LuckySpinner

final class LuckySpinnerTests: XCTestCase {

    // MARK: Config defaults

    func testDefaultConfigValues() {
        let config = LuckySpinnerConfig.default

        XCTAssertEqual(config.wheelSize, 300)
        XCTAssertEqual(config.spinDuration, 3)
        XCTAssertEqual(config.extraSpins, 5)
        XCTAssertTrue(config.showsConfetti)
        XCTAssertEqual(config.buttonCornerRadius, 14)
        XCTAssertEqual(config.selectedText, "Selected")
        XCTAssertFalse(config.colors.isEmpty)
    }

    func testCustomConfigValues() {
        let config = LuckySpinnerConfig(
            wheelSize: 320,
            spinDuration: 2,
            extraSpins: 6,
            showsConfetti: false,
            buttonCornerRadius: 16,
            selectedText: "Winner",
            colors: [.red, .blue]
        )

        XCTAssertEqual(config.wheelSize, 320)
        XCTAssertEqual(config.spinDuration, 2)
        XCTAssertEqual(config.extraSpins, 6)
        XCTAssertFalse(config.showsConfetti)
        XCTAssertEqual(config.buttonCornerRadius, 16)
        XCTAssertEqual(config.selectedText, "Winner")
        XCTAssertEqual(config.colors.count, 2)
    }

    // MARK: Theme

    func testThemesAreNonEmpty() {
        XCTAssertFalse(LuckySpinnerTheme.classic.isEmpty)
        XCTAssertFalse(LuckySpinnerTheme.pastel.isEmpty)
        XCTAssertFalse(LuckySpinnerTheme.ocean.isEmpty)
    }

    // MARK: Target rotation math

    func testTargetRotationAddsAtLeastExtraSpins() {
        let result = LuckySpinnerView.targetRotation(
            currentRotation: 0,
            selectedIndex: 0,
            count: 4,
            extraSpins: 5
        )
        // Must include at least the extra full spins.
        XCTAssertGreaterThanOrEqual(result, 5 * 360)
    }

    func testTargetRotationLandsSelectedSliceUnderPointer() {
        let count = 6
        let extraSpins = 3
        let anglePerItem = 360.0 / Double(count)

        for index in 0..<count {
            let result = LuckySpinnerView.targetRotation(
                currentRotation: 0,
                selectedIndex: index,
                count: count,
                extraSpins: extraSpins
            )

            // After rotating, the chosen slice center should sit at the top (0°/360°).
            let sliceCenter = anglePerItem * Double(index) + anglePerItem / 2
            let finalPosition = (sliceCenter + result).truncatingRemainder(dividingBy: 360)
            let normalized = (finalPosition + 360).truncatingRemainder(dividingBy: 360)

            // Allow a tiny floating-point tolerance; should be ~0 or ~360.
            let distanceFromTop = min(normalized, 360 - normalized)
            XCTAssertLessThan(distanceFromTop, 0.001,
                              "Slice \(index) did not land under the pointer (got \(normalized)°)")
        }
    }

    func testTargetRotationAlwaysMovesForward() {
        let current = 123.0
        let result = LuckySpinnerView.targetRotation(
            currentRotation: current,
            selectedIndex: 2,
            count: 8,
            extraSpins: 4
        )
        XCTAssertGreaterThan(result, current)
    }

    func testTargetRotationWithZeroCountIsSafe() {
        let result = LuckySpinnerView.targetRotation(
            currentRotation: 42,
            selectedIndex: 0,
            count: 0,
            extraSpins: 5
        )
        // With no slices it should simply return the current rotation unchanged.
        XCTAssertEqual(result, 42)
    }

    // MARK: Empty names handling

    func testEmptyNamesProducesAView() {
        // The view should construct fine with an empty list (it shows the empty state).
        let view = LuckySpinnerView(names: [])
        XCTAssertNotNil(view.body)
    }

    func testViewBuildsWithNames() {
        let view = LuckySpinnerView(
            names: ["A", "B", "C"],
            title: "Test",
            buttonTitle: "Go"
        )
        XCTAssertNotNil(view.body)
    }
}
