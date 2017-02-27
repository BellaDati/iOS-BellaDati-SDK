//
//  BellaDatiSDKTests.swift
//  BellaDatiSDKTests
//
//  Created by Martin Trgina on 2/13/17.
//  Copyright © 2017 BellaDati Inc. All rights reserved.
//

import XCTest

@testable import BellaDatiSDK

class BellaDatiSDKTests: XCTestCase {
    
    var reports = Reports()
    var chart = Chart()
    var kpilabel = KpiLabel()
    
    
     // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        
        APIClient.sharedInstance.setAPIClient(scheme:"http",host:"BellaDatiMac.local",port:8082,relativeAccessTokenUrl:"/belladati/oauth/accessToken", oauth_consumer_key:"apikey", x_auth_username:"your.username@belladati.com" ,x_auth_password: "Yourpassword1")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /*This method is automatically called in Reports method download list of reports. But it is important to have right setup
     of credentials via APIClient.sharedInstance.setAPIClient */
    
    func AuthenticateWithBellaDati() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expect = self.expectation(description: "Framework should authenticate with BellaServer")
        
        if (!APIClient.sharedInstance.hasAccessTokenSaved())
        {
            APIClient.sharedInstance.authenticateWithBellaDati(){(error) -> Void in
                print("handlin stuff")
                if let receivedError = error
                {
                    print(receivedError)
                }
                
                expect.fulfill()
                
               
            }
            
            self.waitForExpectations(timeout: 7.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
            }

        }
            
        
        else
        {
            
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be already stored on the device. ")
            print (" I am ready to send requests")
        }
        
        
        
        
    }
    
    func OfReports(){
        
        let expect = self.expectation(description: "Expected number of reports should be downloaded")
        
        
        reports.downloadListOfReports(filter: "JSON CHART REPORT", offset: nil, size: nil) { () -> () in
            
            
            for report in self.reports.reportDetails! {
                
                report.downloadReportDetail(completion: {
                    print(report.name)
                    print("This is name of Chart:" + report.views![0].viewName!)
                    print("This is id of ChartView:" + String(report.views![0].viewId!))
                    self.chart.viewId = report.views![0].viewId!
                    
                    self.chart.downloadOnLineCharts(completion: {
                        
                        print("Color of tooltip is:" + self.chart.tooltip.background)
                        print("Color of chart background is:" + self.chart.bg_color!)
                        
                        expect.fulfill()
                    })
                    
                  

                })
                
                
            }
            
                     }


        self.waitForExpectations(timeout: 7.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
        }
    

    
}
    
    /* On BellaDati server has to exist 1 report named KPILabel Test and has to have 1 View to keep same results for test */
    
    func testOfKpiLabel(){
        
        let expect = self.expectation(description: "Expected number of reports should be downloaded")
        
        
        reports.downloadListOfReports(filter: "KPILabel Test", offset: nil, size: nil) { () -> () in
            
            
            for report in self.reports.reportDetails! {
                
                report.downloadReportDetail(completion: {
                    print(report.name)
                    print("This is name of View:" + report.views![0].viewName!)
                    print("This is id of KPILabelView:" + String(report.views![0].viewId!))
                    self.kpilabel.viewId = report.views![0].viewId!
                    
                    self.kpilabel.downloadOnLineKpiLabel(completion: {
                        
                        print("These are values of KPILabels:")
                        
                        for value in self.kpilabel.values!{
                            
                            print("Number value:"+" "+value.numberValue)
                            print("Caption:"+" "+value.caption)
                            print("Symbol:"+" "+value.symbol)
                            print("Symbol value:"+" "+value.symbolValue)
                            print("Font weight:"+" "+value.fontweight)
                            
                            
                            var backgroundcolor = String(describing: value.backgroundcolor)
                            var color = String(describing: value.backgroundcolor)
                            
                            print("Background UIColor:"+" "+backgroundcolor)
                            print("Color UIColor:"+" "+color)

                            
                        }
                        
                        
                        
                        expect.fulfill()
                    })
                    
                    
                    
                })
                
                
            }
            
        }
        
        
        self.waitForExpectations(timeout: 7.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
        }

        
        
    }
    
    func OfStyleParsing(){
    
        var stylestring = " color:rgb(117, 206, 0);  background-color:rgb(25, 82, 125);  font-weight:bold; "
        
        var stylestring2 = " color: #343434; background-color: #e5e5e5;"
    
        kpilabel.parseValueStyle(style: stylestring2)
    }
    
    func UploadSavedCharts() {
        
        chart.uploadSavedCharts()
        
        print(chart.elements?[0].type)
        print(chart.xAxis!.steps)
        
        XCTAssertEqual(chart.xAxis!.steps!, Double(0))
        
      
        
    }
    
}
