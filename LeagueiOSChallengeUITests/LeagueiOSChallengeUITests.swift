//
//  LeagueiOSChallengeUITests.swift
//  LeagueiOSChallengeUITests
//
//  Created by AceGreen on 2025-02-18.
//

import XCTest
import SwiftUI
@testable import LeagueiOSChallenge

final class LeagueiOSChallengeUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testLoginFlow() throws {
        // Test login fields exist
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]

        XCTAssertTrue(usernameField.exists)
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(loginButton.exists)

        // Test login with valid credentials
        usernameField.tap()
        usernameField.typeText("testuser1")
        passwordField.tap()
        passwordField.typeText("testPass")
        loginButton.tap()

        // Verify navigation to post list
        let postsNavBar = app.navigationBars["Posts"]
        XCTAssertTrue(postsNavBar.waitForExistence(timeout: 5))
    }

    @MainActor
    func testGuestFlow() throws {
        // Test guest login
        let guestButton = app.buttons["Continue as guest"]
        XCTAssertTrue(guestButton.exists)
        guestButton.tap()

        // Verify navigation to post list
        let postsNavBar = app.navigationBars["Posts"]
        XCTAssertTrue(postsNavBar.waitForExistence(timeout: 5))

        // Test exit flow
        let exitButton = app.buttons["Exit"]
        exitButton.tap()

        // Verify thank you alert
        let alert = app.alerts["Thank You!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        // Dismiss alert and verify return to login
        alert.buttons["OK"].tap()
        XCTAssertTrue(app.buttons["Continue as guest"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testPostListInteractions() throws {
        // Continue as guest
        app.buttons["Continue as guest"].tap()
        
        // Wait for posts list
        let postsList = app.collectionViews["PostsList"]
        XCTAssertTrue(postsList.waitForExistence(timeout: 5))
        
        // Find and tap the first post cell
        let postCell = app.staticTexts["PostCell"].firstMatch
        XCTAssertTrue(postCell.waitForExistence(timeout: 2))
        postCell.tap()
        
        // Add a small delay to allow for async operations
        Thread.sleep(forTimeInterval: 1.0)
        
        // Look for the UserInfoView
        let userInfoView = app.scrollViews["UserInfoView"]
        XCTAssertTrue(userInfoView.waitForExistence(timeout: 5))
    }

    @MainActor
    func testUserInformationValidation() throws {
        // Continue as guest
        app.buttons["Continue as guest"].tap()
        
        // Wait for posts list
        let postsList = app.collectionViews["PostsList"]
        XCTAssertTrue(postsList.waitForExistence(timeout: 5))
        
        // Find and tap the first post cell
        let postCell = app.staticTexts["PostCell"].firstMatch
        XCTAssertTrue(postCell.waitForExistence(timeout: 2))
        postCell.tap()
        
        // Add a small delay to allow for async operations
        Thread.sleep(forTimeInterval: 1.0)
        
        // Look for the UserInfoView
        let userInfoView = app.scrollViews["UserInfoView"]
        XCTAssertTrue(userInfoView.waitForExistence(timeout: 5))
        // Verify warning icon exists
        let warningIcon = app.images.matching(identifier: "InfoRow").element(matching: .image, identifier: "InfoRow")
        XCTAssertTrue(warningIcon.exists, "Warning icon should be visible for invalid email")
    }

    private func printElementTree(_ element: XCUIElement, level: Int = 0) {
        let indent = String(repeating: "  ", count: level)
        print("\(indent)Type: \(element.elementType.rawValue)")
        print("\(indent)Identifier: \(element.identifier)")
        print("\(indent)Label: \(element.label)")
        print("\(indent)Value: \(String(describing: element.value))")
        print("\(indent)Enabled: \(element.isEnabled)")
        print("\(indent)Frame: \(element.frame)")

        let children = element.children(matching: .any)
        for i in 0..<children.count {
            printElementTree(children.element(boundBy: i), level: level + 1)
        }
    }
}
