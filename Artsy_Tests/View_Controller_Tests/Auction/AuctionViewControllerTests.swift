import Quick
import Nimble
import Nimble_Snapshots
import UIKit
import Interstellar
import Forgeries
import OCMock
import Mantle
import ISO8601DateFormatter
@testable
import Artsy

class AuctionViewControllerTests: QuickSpec {
    override func spec() {
        var sale: Sale!
        var saleViewModel: SaleViewModel!
        var dateMock: OCMockObject!

        sharedExamples("auctions view controller registration status") { (context: SharedExampleContext) in
            var horizontalSizeClass: UIUserInterfaceSizeClass!
            var device: ARDeviceType!


            beforeEach {
                let now = NSDate()
                let endTime = now.dateByAddingTimeInterval(3600.9) // 0.9 is to cover the possibility a clock tick happens between this line and the next.
                dateMock = ARTestContext.freezeTime(now)

                sale = try! Sale(dictionary: ["saleID": "the-tada-sale", "name": "The 🎉 Sale", "endDate": endTime], error: Void())
                saleViewModel = SaleViewModel(sale: sale, saleArtworks: [])

                horizontalSizeClass = UIUserInterfaceSizeClass(rawValue: context()["horizontalSizeClass"] as! Int)
                device = ARDeviceType(rawValue: context()["device"] as! Int)
            }

            afterEach {
                dateMock.stopMocking()
            }

            it("looks good without a registration status") {
                let subject = AuctionViewController(saleID: sale.saleID)
                subject.allowAnimations = false
                subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: nil)
                subject.stubHorizontalSizeClass(horizontalSizeClass)

                ARTestContext.useDevice(device) {
                    expect(subject).to( haveValidSnapshot() )
                }
            }

            it("looks good when registereed") {
                let subject = AuctionViewController(saleID: sale.saleID)
                subject.allowAnimations = false
                subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: ArtsyAPISaleRegistrationStatusRegistered)
                subject.stubHorizontalSizeClass(horizontalSizeClass)

                ARTestContext.useDevice(device) {
                    expect(subject).to( haveValidSnapshot() )
                }
            }

            it("looks good when not logged in") {
                let subject = AuctionViewController(saleID: sale.saleID)
                subject.allowAnimations = false
                subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: ArtsyAPISaleRegistrationStatusNotLoggedIn)
                subject.stubHorizontalSizeClass(horizontalSizeClass)

                ARTestContext.useDevice(device) {
                    expect(subject).to( haveValidSnapshot() )
                }
            }

            it("looks good when not registered") {
                let subject = AuctionViewController(saleID: sale.saleID)
                subject.allowAnimations = false
                subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: ArtsyAPISaleRegistrationStatusNotRegistered)
                subject.stubHorizontalSizeClass(horizontalSizeClass)

                ARTestContext.useDevice(device) {
                    expect(subject).to( haveValidSnapshot() )
                }
            }

            it("looks good when sorting by Artist A-Z") {
                let subject = AuctionViewController(saleID: sale.saleID)
                subject.allowAnimations = false
                subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: ArtsyAPISaleRegistrationStatusRegistered)

                // Need to use the device when stubbing to use proper screen size.
                ARTestContext.useDevice(device) {
                    subject.stubHorizontalSizeClass(horizontalSizeClass)
                    subject.loadViewProgrammatically() // We need to load the view so it has a view model before calling defaultRefineSettings()
                    subject.refineSettings = subject.defaultRefineSettings().settingsWithOrdering(.ArtistAlphabetical)
                    expect(subject).to( haveValidSnapshot() )
                }

            }

            it("looks good when filtering based on price") {
                let subject = AuctionViewController(saleID: sale.saleID)
                subject.allowAnimations = false
                subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: ArtsyAPISaleRegistrationStatusRegistered)

                // Need to use the device when stubbing to use proper screen size.
                ARTestContext.useDevice(device) {
                    subject.stubHorizontalSizeClass(horizontalSizeClass)
                    subject.loadViewProgrammatically() // We need to load the view so it has a view model before calling defaultRefineSettings()
                    subject.refineSettings = subject.defaultRefineSettings().settingsWithRange((min: 1000, max: 1000_000))
                    expect(subject).to( haveValidSnapshot() )
                }

            }

            it("looks good when sorting by Artist A-Z and filtering based on price") {
                let subject = AuctionViewController(saleID: sale.saleID)
                subject.allowAnimations = false
                subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: ArtsyAPISaleRegistrationStatusRegistered)

                // Need to use the device when stubbing to use proper screen size.
                ARTestContext.useDevice(device) {
                    subject.stubHorizontalSizeClass(horizontalSizeClass)
                    subject.loadViewProgrammatically() // We need to load the view so it has a view model before calling defaultRefineSettings()
                    subject.refineSettings = subject.defaultRefineSettings().settingsWithOrdering(.ArtistAlphabetical).settingsWithRange((min: 1000, max: 1000_000))
                    expect(subject).to( haveValidSnapshot() )
                }
            }

            describe("sorting") {
                var subject: AuctionViewController!

                beforeEach {
                    saleViewModel = SaleViewModel(sale: sale, saleArtworks: [
                        test_saleArtworkWithLotNumber(1, artistName: "Ash", bidCount: 0, highestBidCents: 100_00),
                        test_saleArtworkWithLotNumber(2, artistName: "Orta", bidCount: 4, highestBidCents: 1000_00),
                        test_saleArtworkWithLotNumber(3, artistName: "Sarah", bidCount: 2, highestBidCents: 50_00),
                        test_saleArtworkWithLotNumber(4, artistName: "Eloy", bidCount: 17, highestBidCents: 1000_000_00),
                        test_saleArtworkWithLotNumber(5, artistName: "Maxim", bidCount: 6, highestBidCents: 5011_00),
                    ])

                    subject = AuctionViewController(saleID: sale.saleID)
                    subject.allowAnimations = false
                    subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: ArtsyAPISaleRegistrationStatusRegistered)
                }

                it("sorts by lot number") {
                    // Need to use the device when stubbing to use proper screen size.
                    ARTestContext.useDevice(device) {
                        subject.stubHorizontalSizeClass(horizontalSizeClass)
                        subject.loadViewProgrammatically() // We need to load the view so it has a view model before calling defaultRefineSettings()
                        subject.refineSettings = subject.defaultRefineSettings().settingsWithOrdering(.LotNumber)
                        expect(subject).to( haveValidSnapshot() )
                    }
                }

                it("sorts by artist name") {
                    // Need to use the device when stubbing to use proper screen size.
                    ARTestContext.useDevice(device) {
                        subject.stubHorizontalSizeClass(horizontalSizeClass)
                        subject.loadViewProgrammatically() // We need to load the view so it has a view model before calling defaultRefineSettings()
                        subject.refineSettings = subject.defaultRefineSettings().settingsWithOrdering(.ArtistAlphabetical)
                        expect(subject).to( haveValidSnapshot() )
                    }
                }

                it("sorts by most bids") {
                    // Need to use the device when stubbing to use proper screen size.
                    ARTestContext.useDevice(device) {
                        subject.stubHorizontalSizeClass(horizontalSizeClass)
                        subject.loadViewProgrammatically() // We need to load the view so it has a view model before calling defaultRefineSettings()
                        subject.refineSettings = subject.defaultRefineSettings().settingsWithOrdering(.MostBids)
                        expect(subject).to( haveValidSnapshot() )
                    }
                }

                it("sorts by least bids") {
                    // Need to use the device when stubbing to use proper screen size.
                    ARTestContext.useDevice(device) {
                        subject.stubHorizontalSizeClass(horizontalSizeClass)
                        subject.loadViewProgrammatically() // We need to load the view so it has a view model before calling defaultRefineSettings()
                        subject.refineSettings = subject.defaultRefineSettings().settingsWithOrdering(.LeastBids)
                        expect(subject).to( haveValidSnapshot() )
                    }
                }
                
                it("sorts by highest bid") {
                    // Need to use the device when stubbing to use proper screen size.
                    ARTestContext.useDevice(device) {
                        subject.stubHorizontalSizeClass(horizontalSizeClass)
                        subject.loadViewProgrammatically() // We need to load the view so it has a view model before calling defaultRefineSettings()
                        subject.refineSettings = subject.defaultRefineSettings().settingsWithOrdering(.HighestCurrentBid)
                        expect(subject).to( haveValidSnapshot() )
                    }
                }
                
                it("sorts by lowest bid") {
                    // Need to use the device when stubbing to use proper screen size.
                    ARTestContext.useDevice(device) {
                        subject.stubHorizontalSizeClass(horizontalSizeClass)
                        subject.loadViewProgrammatically() // We need to load the view so it has a view model before calling defaultRefineSettings()
                        subject.refineSettings = subject.defaultRefineSettings().settingsWithOrdering(.LowestCurrentBid)
                        expect(subject).to( haveValidSnapshot() )
                    }
                }
            }
        }


        describe("regular horizontal size class ") {
            itBehavesLike("auctions view controller registration status") {
                return ["horizontalSizeClass": UIUserInterfaceSizeClass.Regular.rawValue, "device": ARDeviceType.Pad.rawValue] as NSDictionary
            }
        }

        describe("compact horizontal size class") {
            itBehavesLike("auctions view controller registration status") {
                return ["horizontalSizeClass": UIUserInterfaceSizeClass.Compact.rawValue, "device": ARDeviceType.Phone6.rawValue] as NSDictionary
            }
        }


        it("handles showing information for upcoming auctions with no sale artworks") {
            let exact_now = ISO8601DateFormatter().dateFromString("2025-11-24T10:00:00+00:00")!
            let start = exact_now.dateByAddingTimeInterval(3600.9)
            let end = exact_now.dateByAddingTimeInterval(3700.9)
            dateMock = ARTestContext.freezeTime(exact_now)

            sale = try! Sale(dictionary: [
                "saleID": "the-tada-sale", "name": "The 🎉 Sale",
                "saleDescription": "This is a description",
                "startDate": start, "endDate": end], error: Void())
            saleViewModel = SaleViewModel(sale: sale, saleArtworks: [])

            let subject = AuctionViewController(saleID: sale.saleID)
            subject.allowAnimations = false
            subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: nil)

            expect(subject).to( haveValidSnapshot() )

            dateMock.stopMocking()
        }

        it("looking correct when an auction is closed") {
            let exact_now_past = ISO8601DateFormatter().dateFromString("2015-11-24T10:00:00+00:00")!
            let start = exact_now_past.dateByAddingTimeInterval(3600.9)
            let end = exact_now_past.dateByAddingTimeInterval(3700.9)

            sale = try! Sale(dictionary: [
                "saleID": "the-tada-sale", "name": "The 🎉 Sale",
                "saleDescription": "This is a description",
                "startDate": start, "endDate": end], error: Void())
            saleViewModel = SaleViewModel(sale: sale, saleArtworks: [])

            let subject = AuctionViewController(saleID: sale.saleID)
            subject.allowAnimations = false
            subject.networkModel = Test_AuctionNetworkModel(saleViewModel: saleViewModel, registrationStatus: nil)

            expect(subject).to( haveValidSnapshot() )
        }

    }
}

class Test_AuctionNetworkModel: AuctionNetworkModelType {
    let saleViewModel: SaleViewModel
    var registrationStatus: ArtsyAPISaleRegistrationStatus?

    init(saleViewModel: SaleViewModel, registrationStatus: ArtsyAPISaleRegistrationStatus?) {
        self.saleViewModel = saleViewModel
        self.registrationStatus = registrationStatus
    }

    func fetch() -> Signal<SaleViewModel> {
        return Signal(saleViewModel)
    }
}


func test_saleArtworkWithLotNumber(lotNumber: Int, artistName: String, bidCount: Int, highestBidCents: Int) -> SaleArtwork {

    let artistJSON: NSDictionary = [
        "id": "artist_id",
        "name": artistName
    ]
    let imagesJSON: NSArray = [
        [
            "id": "image_1_id",
            "is_default": true,
            "image_url": "http://example.com/:version.jpg",
            "image_versions": ["large"],
            "aspect_ratio": 1.5
        ]
    ]
    let artworkJSON: NSDictionary = [
        "id": "artwork_id",
        "artist": artistJSON,
        "title": "roly poly",
        "images": imagesJSON,
    ]
    let saleArtwork = SaleArtwork(JSON:
        [
            "id": "sale",
            "artwork": artworkJSON,
            "lot_number": lotNumber,
            "bidder_positions_count": bidCount,
            "low_estimate_cents": 1_000_000_00,
            "highest_bid": ["id": "bid-id", "amount_cents": highestBidCents],
            "opening_bid_cents": 100_00
        ]
    )

    return saleArtwork
}

