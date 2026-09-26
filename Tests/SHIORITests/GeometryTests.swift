import XCTest
import AppKit
@testable import SHIORI

final class GeometryTests: XCTestCase {
    @MainActor
    func testDetachedNotesGroupPersistAndReattachOnNegativeDisplay() throws {
        let suite = "tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let settings = SettingsStore(defaults: defaults)
        let screen = NSRect(x: -1440, y: -100, width: 1440, height: 900)
        settings.dockDetached("first", at: NSPoint(x: -1400, y: 100), displayID: 7, screen: screen)
        settings.dockDetached("second", at: NSPoint(x: -1400, y: 130), displayID: 7, screen: screen)
        XCTAssertEqual(settings.detachedGroups.count, 1)
        XCTAssertEqual(settings.detachedGroups.first?.edge, "left")
        XCTAssertEqual(Set(settings.detachedGroups[0].noteIDs), Set(["first", "second"]))
        settings.dockDetached("third", at: NSPoint(x: -20, y: 600), displayID: 7, screen: screen)
        XCTAssertEqual(settings.detachedGroups.count, 2)
        let reopened = SettingsStore(defaults: defaults)
        XCTAssertEqual(reopened.detachedGroups, settings.detachedGroups)
        reopened.dockDetached("second", at: NSPoint(x: -2, y: 350), displayID: 7, screen: screen, allowMain: true)
        XCTAssertNil(reopened.detachedGroup(for: "second"))
        XCTAssertEqual(reopened.detachedGroup(for: "first")?.noteIDs, ["first"])
        XCTAssertEqual(reopened.detachedGroup(for: "third")?.edge, "right")
    }

    @MainActor
    func testInvalidDetachedPlacementPreservesExistingGroup() throws {
        let suite = "tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let settings = SettingsStore(defaults: defaults)
        let screen = NSRect(x: 0, y: 0, width: 1000, height: 800)
        settings.dockDetached("note", at: NSPoint(x: 10, y: 200), displayID: 1, screen: screen)
        let original = settings.detachedGroups
        settings.dockDetached("note", at: NSPoint(x: CGFloat.nan, y: 200), displayID: 1, screen: screen)
        settings.dockDetached("note", at: .zero, displayID: 1, screen: .zero)
        XCTAssertEqual(settings.detachedGroups, original)
    }

    @MainActor
    func testCompactModePersistsAndFanStaysAnchoredToBothEdges() throws {
        let suite = "tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let settings = SettingsStore(defaults: defaults)
        XCTAssertFalse(settings.compactMode)
        settings.compactMode = true
        XCTAssertTrue(SettingsStore(defaults: defaults).compactMode)
        for left in [false, true] {
            XCTAssertEqual(CompactFanGeometry.angle(index: 0, count: 1, left: left), 0)
            for index in 0..<CompactFanGeometry.capacity {
                let angle = CompactFanGeometry.angle(index: index, count: CompactFanGeometry.capacity, left: left)
                XCTAssertLessThanOrEqual(abs(angle), 32)
                XCTAssertEqual(angle, -CompactFanGeometry.angle(index: index, count: CompactFanGeometry.capacity, left: !left))
                let rect = NSRect(x: left ? -72 : 148, y: 162, width: 224, height: 76)
                let pivot = NSPoint(x: left ? rect.minX : rect.maxX, y: rect.midY)
                XCTAssertEqual(pivot.x, left ? -72 : CompactFanGeometry.panelWidth + 72)
                let transform = AffineTransform(translationByX: pivot.x, byY: pivot.y)
                var rotation = transform
                rotation.rotate(byDegrees: angle)
                rotation.translate(x: -pivot.x, y: -pivot.y)
                for corner in [NSPoint(x: rect.minX, y: rect.minY), NSPoint(x: rect.minX, y: rect.maxY), NSPoint(x: rect.maxX, y: rect.minY), NSPoint(x: rect.maxX, y: rect.maxY)] {
                    let point = rotation.transform(corner)
                    XCTAssertTrue((0...CompactFanGeometry.panelHeight).contains(point.y))
                    // The hinge side is clipped at the edge; the outer tips remain on screen.
                    if left { XCTAssertLessThan(point.x, CompactFanGeometry.panelWidth) }
                    else { XCTAssertGreaterThan(point.x, 0) }
                }
            }
        }
    }

    func testClampsDisconnectedAndNegativeDisplays() {
        let screens = [NSRect(x: -1440, y: -100, width: 1440, height: 900), NSRect(x: 0, y: 0, width: 1920, height: 1080)]
        let left = WindowGeometry.clamp(NSRect(x: -1500, y: -200, width: 360, height: 400), to: screens)
        XCTAssertEqual(left.origin, NSPoint(x: -1440, y: -100))
        let recovered = WindowGeometry.clamp(NSRect(x: 5000, y: 3000, width: 3000, height: 2000), to: [screens[1]])
        XCTAssertEqual(recovered, screens[1])
    }
    @MainActor func testPreferencesAreIsolatedAndGeometryRoundTrips() {
        let name = "app.shiori.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let settings = SettingsStore(defaults: defaults)
        XCTAssertTrue(settings.acrossSpaces)
        XCTAssertFalse(settings.fullscreen)
        let frame = NSRect(x: -400, y: 300, width: 360, height: 400)
        settings.saveFrame(frame, id: "note", display: "42")
        XCTAssertEqual(settings.frame(id: "note"), frame)
        settings.edge = "left"
        XCTAssertEqual(SettingsStore(defaults: defaults).edge, "left")
        settings.resetPositions()
        XCTAssertNil(settings.frame(id: "note"))
    }
}
