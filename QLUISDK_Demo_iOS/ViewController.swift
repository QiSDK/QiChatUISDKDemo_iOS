import UIKit
import TeneasyChatSDKUI_iOS
import TeneasyChatSDK_iOS
import SnapKit

class ViewController: UIViewController, LineDetectDelegate {
    
    private var selectedTheme: ChatTheme = ChatTheme.presets[0]
    private let gradientLayer = CAGradientLayer()
    
    private lazy var settingBtn: UIButton = {
        let btn = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
            btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config), for: .normal)
        } else {
            btn.setTitle("设置", for: .normal)
        }
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(settingClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var themeScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    let titleLabel = UILabel()
    
    private lazy var themeStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 15
        sv.alignment = .center
        return sv
    }()
    
    private lazy var supportBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("联系客服", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)

        // 添加阴影
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowRadius = 8
        return btn
    }()

    private lazy var backupBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("备用客服", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1.5
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(backupClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var statusLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.textColor = .white.withAlphaComponent(0.8)
        lb.numberOfLines = 0
        return lb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "客服 Demo"
        setupUI()
        updateThemeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        readConfigAndCheckLine()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupUI() {
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(settingBtn)
        settingBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(40)
        }
        
        
        titleLabel.text = "选择主题"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.left.equalToSuperview().offset(20)
        }
        
        view.addSubview(themeScrollView)
        themeScrollView.addSubview(themeStackView)
        
        themeScrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        themeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }
        
        for (index, theme) in ChatTheme.presets.enumerated() {
            let container = UIView()
            let themeBtn = UIButton()
            themeBtn.layer.cornerRadius = 30
            themeBtn.layer.masksToBounds = true
            themeBtn.backgroundColor = theme.gradientEndColor
            themeBtn.tag = index
            themeBtn.addTarget(self, action: #selector(themeSelected(_:)), for: .touchUpInside)
            
            container.addSubview(themeBtn)
            themeBtn.snp.makeConstraints { make in
                make.width.height.equalTo(60)
                make.center.equalToSuperview()
            }
            
            container.snp.makeConstraints { make in
                make.width.height.equalTo(70)
            }
            
            themeStackView.addArrangedSubview(container)
        }
        
        view.addSubview(backupBtn)
        backupBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.width.equalTo(220)
            make.height.equalTo(50)
        }

        view.addSubview(supportBtn)
        supportBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(backupBtn.snp.top).offset(-12)
            make.width.equalTo(220)
            make.height.equalTo(56)
        }

        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.bottom.equalTo(supportBtn.snp.top).offset(-24)
        }
    }
    
    private func updateThemeUI() {
        gradientLayer.colors = [selectedTheme.gradientStartColor.cgColor, selectedTheme.gradientEndColor.cgColor]
        gradientLayer.startPoint = selectedTheme.gradientDirection.startPoint
        gradientLayer.endPoint = selectedTheme.gradientDirection.endPoint
        
        supportBtn.backgroundColor = selectedTheme.tintColor
        supportBtn.layer.shadowColor = selectedTheme.tintColor.cgColor

        backupBtn.setTitleColor(selectedTheme.tintColor, for: .normal)
        backupBtn.layer.borderColor = selectedTheme.tintColor.cgColor

        settingBtn.tintColor = .white
        
        for (index, subview) in themeStackView.arrangedSubviews.enumerated() {
            if let container = subview as? UIView, let btn = container.subviews.first as? UIButton {
                if index == ChatTheme.presets.firstIndex(where: { $0.tintColor == selectedTheme.tintColor }) {
                    btn.layer.borderWidth = 3
                    btn.layer.borderColor = UIColor.white.cgColor
                    btn.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                } else {
                    btn.layer.borderWidth = 0
                    btn.transform = .identity
                }
            }
        }
    }
    
    @objc private func themeSelected(_ sender: UIButton) {
        selectedTheme = ChatTheme.presets[sender.tag]
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.updateThemeUI()
        } completion: { _ in }
        titleLabel.backgroundColor = selectedTheme.leftBubbleColor
        titleLabel.textColor = selectedTheme.leftBubbleTextColor
        settingBtn.tintColor = selectedTheme.tintColor
    }
    
    @objc private func settingClick() {
        let vc = SettingViewController(theme: selectedTheme)
        vc.callBack = {
            self.readConfigAndCheckLine()
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @objc private func buttonClick() {
        let vc = KeFuViewController(consultId: 1, theme: selectedTheme)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func backupClick() {
        let cert = UserDefaults.standard.string(forKey: PARAM_CERT) ?? ""
        let userId = UserDefaults.standard.integer(forKey: PARAM_USER_ID)
        let merchantId = UserDefaults.standard.integer(forKey: PARAM_MERCHANT_ID)
        let userName = UserDefaults.standard.string(forKey: PARAM_USERNAME) ?? ""
        let userType = UserDefaults.standard.integer(forKey: "PARAM_USERTYPE")
        let xToken = UserDefaults.standard.string(forKey: PARAM_XTOKEN) ?? ""
        let themeIndex = ChatTheme.presets.firstIndex(where: { $0.tintColor == selectedTheme.tintColor }) ?? 0

        var items: [URLQueryItem] = [
            URLQueryItem(name: "cert", value: cert),
            URLQueryItem(name: "userId", value: "\(userId)"),
            URLQueryItem(name: "merchantId", value: "\(merchantId)"),
            URLQueryItem(name: "userName", value: userName),
            URLQueryItem(name: "userType", value: "\(userType)"),
            URLQueryItem(name: "themeIndex", value: "\(themeIndex)"),
        ]
        if !xToken.isEmpty {
            items.append(URLQueryItem(name: "xToken", value: xToken))
        }

        var components = URLComponents()
        components.scheme = "juhekefu"
        components.host = "open"
        components.queryItems = items

        guard let deepLink = components.url else {
            openBackupWebUrl(params: items)
            return
        }

        UIApplication.shared.open(deepLink, options: [:]) { [weak self] success in
            if !success {
                self?.openBackupWebUrl(params: items)
            }
        }
    }

    private func openBackupWebUrl(params: [URLQueryItem]) {
        let webUrl = (UserDefaults.standard.string(forKey: "PARAM_BACKUP_WEB_URL") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !webUrl.isEmpty, var components = URLComponents(string: webUrl) else {
            showToast("未安装客服中心 App，且未配置备用网页")
            return
        }
        var merged = components.queryItems ?? []
        merged.append(contentsOf: params)
        components.queryItems = merged
        guard let url = components.url else {
            showToast("打开备用网页失败")
            return
        }
        UIApplication.shared.open(url, options: [:]) { [weak self] success in
            if !success {
                self?.showToast("打开备用网页失败")
            }
        }
    }

    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
    
    private func readConfigAndCheckLine() {
        let lines = UserDefaults.standard.string(forKey: PARAM_LINES) ?? ""
        let merchantId = UserDefaults.standard.integer(forKey: PARAM_MERCHANT_ID)
        let userId = Int32(UserDefaults.standard.integer(forKey: PARAM_USER_ID))
        
        if lines.isEmpty || merchantId == 0 || userId == 0 {
            statusLabel.text = "* 请点击右上角设置参数 *"
            supportBtn.isEnabled = false
            supportBtn.alpha = 0.5
            return
        }
        
        statusLabel.text = "正在检测线路..."
        let lineLB = LineDetectLib(lines, delegate: self, tenantId: merchantId)
        lineLB.getLine()
    }
    
    func useTheLine(line: String) {
        statusLabel.text = "当前可用线路: \(line)"
        UserDefaults.standard.set(line, forKey: PARAM_DOMAIN)
        supportBtn.isEnabled = true
        supportBtn.alpha = 1.0
        
        GlobalChatManager.shared.initializeGlobalChat()
        GlobalChatManager.shared.connectIfNeeded()
    }
    
    func lineError(error: TeneasyChatSDK_iOS.Result) {
        statusLabel.text = "线路检测失败: \(error.Message)"
        supportBtn.isEnabled = false
        supportBtn.alpha = 0.5
    }
}
