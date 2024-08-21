//
//  AstronomyPicturesUITests.swift
//  AstronomyPicturesUITests
//
//  Created by Pooja on 19/08/2024.
//

import XCTest

final class AstronomyPicturesUITests: XCTestCase {

	var app: XCUIApplication!
	
	override func setUp() {
		super.setUp()
		app = XCUIApplication()
		continueAfterFailure = false
	}
	override func tearDown() {
		app = nil
		super.tearDown()
	}

    func testPictureOfTheDayView() throws {
        // UI tests must launch the application that they test.
		app.launch()
		// Use the XCUIElementQuery to locate the title Text
		let titleText = app.staticTexts["APODTitle"]
		// Check if the title text is visible
		XCTAssertTrue(titleText.waitForExistence(timeout: 5))
		
		let dateText = app.staticTexts["Date"]
		XCTAssertTrue(dateText.exists)
		
		let description = app.staticTexts["APODExplanation"]
		XCTAssertTrue(dateText.exists)
    }

	func testDatePicker() throws {
		app.launch()
		let calendarButton = app.navigationBars["NASA APOD"].buttons["Calendar"]
		XCTAssertTrue(calendarButton.waitForExistence(timeout: 10))
		calendarButton.tap()
		
		let datePickerView = app.datePickers["Select Date"]
		XCTAssertTrue(datePickerView.exists)
		app.datePickers["Select Date"].collectionViews/*@START_MENU_TOKEN@*/.staticTexts["17"]/*[[".buttons[\"Saturday 17 August\"].staticTexts[\"17\"]",".staticTexts[\"17\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		Thread.sleep(forTimeInterval: 1)
		XCTAssertFalse(datePickerView.exists)
	}
}
