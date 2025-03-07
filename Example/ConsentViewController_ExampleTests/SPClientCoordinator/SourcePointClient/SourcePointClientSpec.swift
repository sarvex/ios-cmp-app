//
//  SourcePointClientSpec.swift
//  ConsentViewController_ExampleTests
//
//  Created by Vilas on 29/03/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

// swiftlint:disable force_try function_body_length type_body_length force_unwrapping

@testable import ConsentViewController
import Nimble
import Quick

class SourcePointClientSpec: QuickSpec {
    let propertyId = 123
    let accountId = 1
    let propertyName = try! SPPropertyName("test")
    let authID = "auth id"
    var campaign: SPCampaign { SPCampaign(targetingParams: [:]) }
    var campaigns: SPCampaigns { SPCampaigns(gdpr: campaign) }
    var gdprProfile: SPConsent<SPGDPRConsent> { SPConsent<SPGDPRConsent>(
        consents: SPGDPRConsent.empty(),
        applies: true
    )}
    var profile: SPUserData { SPUserData(gdpr: gdprProfile) }

    func getClient(_ client: MockHttp) -> SourcePointClient {
        SourcePointClient(accountId: accountId, propertyName: propertyName, campaignEnv: .Public, client: client)
    }

    func getMessageRequest(_ client: SourcePointClient, _ targetingParams: SPTargetingParams = [:]) -> Data {
        try! JSONEncoder().encode(
            MessageRequest(
                authId: authID,
                requestUUID: client.requestUUID,
                propertyHref: propertyName,
                accountId: accountId,
                campaignEnv: .Public,
                idfaStatus: .unknown,
                localState: SPJson(),
                consentLanguage: .English,
                campaigns: CampaignsRequest(
                    gdpr: CampaignRequest(
                        groupPmId: nil, targetingParams: targetingParams
                    ),
                    ccpa: nil,
                    ios14: nil
                ),
                pubData: [:]
            ))
    }

    override func spec() {
        var client: SourcePointClient!
        var httpClient: MockHttp!
        var mockedResponse: Data?

        beforeSuite {
            // changing AsyncDefaults make the test suite pass in CI due to slow CI environment
            AsyncDefaults.timeout = .seconds(20)
            AsyncDefaults.pollInterval = .milliseconds(100)
        }

        afterSuite {
            // changing AsyncDefaults back to defaults after suite is done
            AsyncDefaults.timeout = .seconds(1)
            AsyncDefaults.pollInterval = .milliseconds(10)
        }

        describe("statics") {
            it("CUSTOM_CONSENT_URL") {
                let expectedUrl  = URL(string: "https://cdn.privacy-mgmt.com/wrapper/tcfv2/v1/gdpr/custom-consent?env=prod&inApp=true&scriptType=ios&scriptVersion=\(SPConsentManager.VERSION)")!.absoluteURL
                expect(Constants.Urls.CUSTOM_CONSENT_URL.absoluteURL).to(equal(expectedUrl))
            }

            it("DELETE_CUSTOM_CONSENT_URL") {
                let expectedUrl = URL(string: "https://cdn.privacy-mgmt.com/consent/tcfv2/consent/v3/custom?scriptType=ios&scriptVersion=\(SPConsentManager.VERSION)")!.absoluteURL
                expect(Constants.Urls.DELETE_CUSTOM_CONSENT_URL.absoluteURL) == expectedUrl
            }
        }

        describe("SourcePointClient") {
            beforeEach {
                mockedResponse = "{\"url\": \"https://notice.sp-prod.net/?message_id=59706\"}".data(using: .utf8)
                httpClient = MockHttp(success: mockedResponse)
                client = self.getClient(httpClient)
            }

            describe("getMessages") {
                it("calls GET on the http client with the right URL") {
                    client.getMessages(MessagesRequest(
                        body: MessagesRequest.Body(
                            propertyHref: self.propertyName,
                            accountId: self.accountId,
                            campaigns: MessagesRequest.Body.Campaigns(),
                            consentLanguage: .BrowserDefault,
                            campaignEnv: nil,
                            idfaStatus: nil
                        ),
                        metadata: nil,
                        localState: MessagesRequest.LocalState(localState: SPJson()),
                        nonKeyedLocalState: MessagesRequest.NonKeyedLocalState(nonKeyedLocalState: SPJson())
                    )) { _ in }
                    expect(httpClient.getWasCalledWithUrl).toEventually(contain("/v2/messages"))
                }
            }

            describe("postAction") {
                describe("gdpr") {
                    it("calls post on the http client with the right url") {
                        client.postGDPRAction(
                            actionType: .AcceptAll,
                            body: .init(
                                authId: nil,
                                uuid: nil,
                                messageId: nil,
                                consentAllRef: nil,
                                vendorListId: nil,
                                pubData: [:],
                                pmSaveAndExitVariables: nil,
                                sendPVData: true,
                                propertyId: 0,
                                sampleRate: 1,
                                idfaStatus: nil,
                                granularStatus: .init()
                            )
                        ) { _ in }
                        expect(httpClient.postWasCalledWithUrl) == "https://cdn.privacy-mgmt.com/wrapper/v2/choice/gdpr/11?env=prod"
                    }

                    it("calls POST on the http client with the right body") {
                        let body = GDPRChoiceBody(
                            authId: nil,
                            uuid: nil,
                            messageId: nil,
                            consentAllRef: nil,
                            vendorListId: nil,
                            pubData: [:],
                            pmSaveAndExitVariables: nil,
                            sendPVData: true,
                            propertyId: 0,
                            sampleRate: 1,
                            idfaStatus: nil,
                            granularStatus: .init()
                        )
                        client.postGDPRAction(
                            actionType: .AcceptAll,
                            body: body
                        ) { _ in }
                        let encoded = try JSONEncoder().encode(body)
                        expect(httpClient.postWasCalledWithBody!).to(equal(encoded))
                    }
                }

                describe("ccpa") {
                    it("calls post on the http client with the right url") {
                        client.postCCPAAction(
                            actionType: .AcceptAll,
                            body: .init(
                                authId: nil,
                                uuid: nil,
                                messageId: "",
                                pubData: [:],
                                pmSaveAndExitVariables: nil,
                                sendPVData: true,
                                propertyId: 1,
                                sampleRate: 1
                            )
                        ) { _ in }
                        expect(httpClient.postWasCalledWithUrl) == "https://cdn.privacy-mgmt.com/wrapper/v2/choice/ccpa/11?env=prod"
                    }

                    it("calls POST on the http client with the right body") {
                        let body = CCPAChoiceBody(
                            authId: nil,
                            uuid: nil,
                            messageId: "",
                            pubData: [:],
                            pmSaveAndExitVariables: nil,
                            sendPVData: true,
                            propertyId: 1,
                            sampleRate: 1
                        )
                        client.postCCPAAction(
                            actionType: .AcceptAll,
                            body: body
                        ) { _ in }
                        let encoded = try JSONEncoder().encode(body)
                        expect(httpClient.postWasCalledWithBody!).to(equal(encoded))
                    }
                }
            }

            describe("customConsent") {
                it("makes a POST to SourcePointClient.CUSTOM_CONSENT_URL") {
                    let http = MockHttp()
                    self.getClient(http).customConsentGDPR(toConsentUUID: "", vendors: [], categories: [], legIntCategories: [], propertyId: self.propertyId) { _ in }
                    expect(http.postWasCalledWithUrl).toEventually(equal(Constants.Urls.CUSTOM_CONSENT_URL.absoluteURL.absoluteString))
                }

                it("makes a POST with the correct body") {
                    let http = MockHttp()
                    self.getClient(http).customConsentGDPR(toConsentUUID: "uuid", vendors: [], categories: [], legIntCategories: [], propertyId: self.propertyId) { _ in }
                    let parsedRequest = try? JSONSerialization.jsonObject(with: http.postWasCalledWithBody!) as? [String: Any]
                    expect((parsedRequest?["consentUUID"] as? String)) == "uuid"
                    expect((parsedRequest?["vendors"] as? [String])) == []
                    expect((parsedRequest?["categories"] as? [String])) == []
                    expect((parsedRequest?["legIntCategories"] as? [String])) == []
                    expect((parsedRequest?["propertyId"] as? Int)) == self.propertyId
                }

                context("on success") {
                    beforeEach {
                        client = self.getClient(MockHttp(success: """
                        {
                            "vendors": ["aVendor"],
                            "categories": ["aCategory"],
                            "legIntCategories": ["aLegIntInterest"],
                            "specialFeatures": ["aSpecialFeature"],
                            "grants": {
                                "vendorId": {
                                    "vendorGrant": true,
                                    "purposeGrants": {
                                        "purposeId": true
                                    }
                                }
                            }
                        }
                        """.data(using: .utf8)!))
                    }

                    it("calls the completion handler with a CustomConsentResponse") {
                        waitUntil { done in
                            client.customConsentGDPR(toConsentUUID: "uuid", vendors: [], categories: [], legIntCategories: [], propertyId: self.propertyId) { result in
                                switch result {
                                case .success(let response):
                                    expect(response) == AddOrDeleteCustomConsentResponse(
                                        grants: [
                                            "vendorId": SPGDPRVendorGrant(granted: true, purposeGrants: ["purposeId": true])
                                        ])
                                    done()
                                case .failure(let error): fail(error.debugDescription)
                                }
                            }
                        }
                    }
                }

                context("on failure") {
                    beforeEach {
                        client = self.getClient(MockHttp(error: SPError()))
                    }

                    it("calls the completion handler with an SPError") {
                        waitUntil { done in
                            client.customConsentGDPR(toConsentUUID: "uuid", vendors: [], categories: [], legIntCategories: [], propertyId: self.propertyId) { result in
                                switch result {
                                case .success: fail("expected to fail but it succeeded")

                                case .failure(let error):
                                    expect(error).to(beAKindOf(SPError.self))
                                    done()
                                }
                            }
                        }
                    }
                }

                describe("metrics") {
                    it("makes a POST to https://cdn.privacy-mgmt.com/wrapper/metrics/v1/custom-metrics with correct body") {
                        let http = MockHttp()
                        let error = SPError()
                        self.getClient(http).errorMetrics(
                            error,
                            propertyId: self.propertyId,
                            sdkVersion: "1.2.3",
                            OSVersion: "11.0",
                            deviceFamily: "iPhone 11 pro",
                            campaignType: .gdpr
                        )
                        let parsedRequest = try? JSONSerialization.jsonObject(with: http.postWasCalledWithBody!) as? [String: Any]
                        let expectedUrl = "https://cdn.privacy-mgmt.com/wrapper/metrics/v1/custom-metrics?scriptType=ios&scriptVersion=\(SPConsentManager.VERSION)"
                        expect(http.postWasCalledWithUrl) == expectedUrl
                        expect((parsedRequest?["code"] as? String)) == error.spCode
                        expect((parsedRequest?["accountId"] as? String)) == "\(self.accountId)"
                        expect((parsedRequest?["propertyId"] as? String)) == "\(self.propertyId)"
                        expect((parsedRequest?["propertyHref"] as? String)) == "https://test"
                        expect((parsedRequest?["description"] as? String)) == error.description
                        expect((parsedRequest?["scriptVersion"] as? String)) == "1.2.3"
                        expect((parsedRequest?["sdkOSVersion"] as? String)) == "11.0"
                        expect((parsedRequest?["deviceFamily"] as? String)) == "iPhone 11 pro"
                        expect((parsedRequest?["legislation"] as? String)) == "GDPR"
                    }
                }
            }

            describe("deleteCustomConsent") {
                it("constructsCorrectURL") {
                    expect(client.deleteCustomConsentUrl(Constants.Urls.DELETE_CUSTOM_CONSENT_URL, self.propertyId, "yo").absoluteString).to(
                        equal("https://cdn.privacy-mgmt.com/consent/tcfv2/consent/v3/custom/\(self.propertyId)?consentUUID=yo"))
                }

                it("makes a DELETE with the correct body") {
                    let http = MockHttp()
                    self.getClient(http).deleteCustomConsentGDPR(toConsentUUID: "uuid", vendors: [], categories: [], legIntCategories: [], propertyId: self.propertyId) { _ in }
                    let parsedRequest = try? JSONSerialization.jsonObject(with: http.deleteWasCalledWithBody!) as? [String: Any]
                    expect((parsedRequest?["vendors"] as? [String])) == []
                    expect((parsedRequest?["categories"] as? [String])) == []
                    expect((parsedRequest?["legIntCategories"] as? [String])) == []
                }

                context("on success") {
                    beforeEach {
                        client = self.getClient(MockHttp(success: """
                        {
                            "vendors": ["aVendor"],
                            "categories": ["aCategory"],
                            "legIntCategories": ["aLegIntInterest"],
                            "specialFeatures": ["aSpecialFeature"],
                            "grants": {
                                "vendorId": {
                                    "vendorGrant": false,
                                    "purposeGrants": {
                                        "purposeId": false
                                    }
                                }
                            }
                        }
                        """.data(using: .utf8)!))
                    }

                    it("calls the completion handler with a DeleteCustomConsentResponse") {
                        waitUntil { done in
                            client.deleteCustomConsentGDPR(toConsentUUID: "uuid", vendors: [], categories: [], legIntCategories: [], propertyId: self.propertyId) { result in
                                switch result {
                                case .success(let response):
                                    expect(response) == AddOrDeleteCustomConsentResponse(grants: [
                                            "vendorId": SPGDPRVendorGrant(
                                                granted: false,
                                                purposeGrants: ["purposeId": false]
                                            )
                                        ])
                                    done()
                                case .failure: fail()
                                }
                            }
                        }
                    }
                }

                context("on failure") {
                    beforeEach {
                        client = self.getClient(MockHttp(error: SPError()))
                    }

                    it("calls the completion handler with an InvalidResponseDeleteCustomError") {
                        waitUntil { done in
                            client.deleteCustomConsentGDPR(toConsentUUID: "uuid", vendors: [], categories: [], legIntCategories: [], propertyId: self.propertyId) { result in
                                switch result {
                                case .success: fail("expected call to fail but it succeeded")

                                case .failure(let error):
                                    expect(error).to(beAKindOf(
                                        InvalidResponseDeleteCustomError.self)
                                    )
                                    done()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
