import UIKit

protocol AuctionRefineViewControllerDelegate: class {
    func userDidCancel(controller: AuctionRefineViewController)
    func userDidApply(settings: AuctionRefineSettings, controller: AuctionRefineViewController)
}

class AuctionRefineViewController: UIViewController {
    weak var delegate: AuctionRefineViewControllerDelegate?
    var applyButton: UIButton?
    var resetButton: UIButton?
    var sortTableView: UITableView?

    var defaultSettings: AuctionRefineSettings
    var initialSettings: AuctionRefineSettings
    var currentSettings: AuctionRefineSettings {
        didSet {
            // Handle Apply/Clear button enabledness
            let settingsDiffer = currentSettings != initialSettings
            [applyButton, resetButton].forEach { $0?.enabled = settingsDiffer }
        }
    }

    init(defaultSettings: AuctionRefineSettings, initialSettings: AuctionRefineSettings) {
        self.defaultSettings = defaultSettings
        self.initialSettings = initialSettings
        self.currentSettings = initialSettings

        super.init(nibName: nil, bundle: nil)
    }

    // Required by Swift compiler, sadly.
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .whiteColor()
        
        setupViews()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Removes our rounded corners
        presentationController?.presentedView()?.layer.cornerRadius = 0
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: animated ? .Slide : .None)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: animated ? .Slide : .None)
    }
}
