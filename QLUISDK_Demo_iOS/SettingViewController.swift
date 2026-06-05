//
//  SettingViewController.swift
//  Alamofire
//
//  Created by Xiao Fu on 2024/5/17.
//
//  设置页面控制器 - 布局与 Flutter 版 BWSettingViewController 保持一致
import SnapKit
import UIKit
import TeneasyChatSDKUI_iOS

typealias DissmissedCallback = () -> ()

class SettingViewController: UIViewController {

    // MARK: - Theme

    private let theme: ChatTheme

    // MARK: - 输入控件

    private let linesTextField = UITextField()
    private let certTextView = UITextView()
    private let merchantIdTextField = UITextField()
    private let userIdTextField = UITextField()
    private let userNameTextField = UITextField()
    private let imgBaseUrlTextField = UITextField()
    private let maxSessionMinsTextField = UITextField()
    private let backupWebUrlTextField = UITextField()
    private let userTypeButton = UIButton(type: .custom)
    private var selectedUserType: Int = 1

    // MARK: - 容器

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let submitButton = UIButton(type: .system)

    var callBack: DissmissedCallback?

    // MARK: - Init

    init(theme: ChatTheme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        self.theme = .default
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        loadUserDefaults()
        registerKeyboardNotifications()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callBack?()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI

    private func setupUI() {
        setupNavigationBar()
        setupScrollView()
        setupFields()
        setupSubmitButton()
    }

    private func setupNavigationBar() {
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        } else {
            closeButton.setTitle("✕", for: .normal)
            closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
        closeButton.tintColor = theme.tintColor
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        titleLabel.text = "Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton)
            make.centerX.equalToSuperview()
        }

        let separator = UIView()
        separator.backgroundColor = .separator
        view.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = true
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    }

    private func setupFields() {
        styleField(linesTextField, keyboard: .URL)
        styleTextView(certTextView)
        styleField(merchantIdTextField, keyboard: .numberPad)
        styleField(userIdTextField, keyboard: .numberPad)
        styleField(userNameTextField, keyboard: .default)
        styleField(imgBaseUrlTextField, keyboard: .URL)
        styleField(maxSessionMinsTextField, keyboard: .numberPad)
        styleField(backupWebUrlTextField, keyboard: .URL)
        styleUserTypeButton()

        let fields: [UIView] = [
            makeFieldRow(label: "Lines", input: linesTextField, height: 44),
            makeFieldRow(label: "Cert", input: certTextView, height: 90),
            makeFieldRow(label: "Merchant Id", input: merchantIdTextField, height: 44),
            makeFieldRow(label: "User Id", input: userIdTextField, height: 44),
            makeFieldRow(label: "User Name", input: userNameTextField, height: 44),
            makeFieldRow(label: "Image Base URL", input: imgBaseUrlTextField, height: 44),
            makeFieldRow(label: "Max Session Mins", input: maxSessionMinsTextField, height: 44),
            makeFieldRow(label: "Backup Web URL", input: backupWebUrlTextField, height: 44),
            makeFieldRow(label: "User Type", input: userTypeButton, height: 44),
        ]

        let stack = UIStackView(arrangedSubviews: fields)
        stack.axis = .vertical
        stack.spacing = 20
        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-120)
        }
    }

    private func setupSubmitButton() {
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        submitButton.backgroundColor = theme.tintColor
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
    }

    // MARK: - 构造器

    private func makeFieldRow(label labelText: String, input: UIView, height: CGFloat) -> UIView {
        let container = UIView()

        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .label
        container.addSubview(label)

        let card = UIView()
        card.backgroundColor = .clear
        card.layer.cornerRadius = 4
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray3.cgColor
        container.addSubview(card)

        card.addSubview(input)

        label.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        card.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(height)
        }
        input.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }
        return container
    }

    // MARK: - 控件样式

    private func styleField(_ tf: UITextField, keyboard: UIKeyboardType) {
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = .label
        tf.tintColor = theme.tintColor
        tf.keyboardType = keyboard
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.clearButtonMode = .whileEditing
        tf.backgroundColor = .clear
    }

    private func styleTextView(_ tv: UITextView) {
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textColor = .label
        tv.tintColor = theme.tintColor
        tv.backgroundColor = .clear
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
    }

    private func styleUserTypeButton() {
        userTypeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        userTypeButton.setTitleColor(.label, for: .normal)
        userTypeButton.contentHorizontalAlignment = .left
        userTypeButton.addTarget(self, action: #selector(userTypeButtonTapped), for: .touchUpInside)

        let chevron = UIImageView()
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            chevron.image = UIImage(systemName: "chevron.down", withConfiguration: config)
        }
        chevron.tintColor = .secondaryLabel
        userTypeButton.addSubview(chevron)
        chevron.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.height.equalTo(14)
        }
        updateUserTypeButtonTitle()
    }

    // MARK: - 加载/保存

    private func loadUserDefaults() {
        let a_lines = UserDefaults.standard.string(forKey: PARAM_LINES) ?? ""
        let a_cert = UserDefaults.standard.string(forKey: PARAM_CERT) ?? ""
        let a_merchantId = UserDefaults.standard.integer(forKey: PARAM_MERCHANT_ID)
        let a_userId = UserDefaults.standard.integer(forKey: PARAM_USER_ID)
        let a_imgUrl = UserDefaults.standard.string(forKey: PARAM_ImageBaseURL) ?? ""
        let a_userName = UserDefaults.standard.string(forKey: PARAM_USERNAME) ?? ""
        let a_maxSessionMins = UserDefaults.standard.integer(forKey: PARAM_MAXSESSIONMINS)
        let a_userType = UserDefaults.standard.integer(forKey: "PARAM_USERTYPE")
        let a_backupWebUrl = UserDefaults.standard.string(forKey: "PARAM_BACKUP_WEB_URL") ?? ""

        linesTextField.text = a_lines.isEmpty ? lines : a_lines
        certTextView.text = a_cert.isEmpty ? cert : a_cert
        merchantIdTextField.text = "\(a_merchantId > 0 ? a_merchantId : merchantId)"
        userIdTextField.text = "\(a_userId > 0 ? Int32(a_userId) : userId)"
        userNameTextField.text = a_userName.isEmpty ? userName : a_userName
        imgBaseUrlTextField.text = a_imgUrl.isEmpty ? baseUrlImage : a_imgUrl
        maxSessionMinsTextField.text = "\(a_maxSessionMins > 0 ? a_maxSessionMins : maxSessionMinus)"
        backupWebUrlTextField.text = a_backupWebUrl

        selectedUserType = a_userType > 0 ? a_userType : 1
        updateUserTypeButtonTitle()
        userType = selectedUserType
    }

    @objc private func submitButtonTapped() {
        lines = (linesTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        cert = (certTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        merchantId = Int((merchantIdTextField.text ?? "0").trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        userId = Int32((userIdTextField.text ?? "0").trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        baseUrlImage = imgBaseUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        userName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        maxSessionMinus = Int((maxSessionMinsTextField.text ?? "1992883").trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let backupWebUrl = (backupWebUrlTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if lines.isEmpty || cert.isEmpty || merchantId == 0 || userId == 0 || baseUrlImage.isEmpty {
            let alert = UIAlertController(title: "输入错误", message: "请确保所有必填字段都已填写", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }

        UserDefaults.standard.set(lines, forKey: PARAM_LINES)
        UserDefaults.standard.set(cert, forKey: PARAM_CERT)
        UserDefaults.standard.set(merchantId, forKey: PARAM_MERCHANT_ID)
        UserDefaults.standard.set(userId, forKey: PARAM_USER_ID)
        UserDefaults.standard.set("", forKey: PARAM_XTOKEN)
        UserDefaults.standard.set(baseUrlImage, forKey: PARAM_ImageBaseURL)
        UserDefaults.standard.set(userName, forKey: PARAM_USERNAME)
        UserDefaults.standard.set(maxSessionMinus, forKey: PARAM_MAXSESSIONMINS)
        UserDefaults.standard.set(selectedUserType, forKey: "PARAM_USERTYPE")
        UserDefaults.standard.set(backupWebUrl, forKey: "PARAM_BACKUP_WEB_URL")

        userType = selectedUserType
        GlobalChatManager.shared.stopGlobalChat()
        dismiss(animated: true)
    }

    // MARK: - 事件

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func userTypeButtonTapped() {
        let alertController = UIAlertController(title: "选择用户类型", message: nil, preferredStyle: .actionSheet)
        let userTypes = [(1, "官方会员"), (2, "邀请好友"), (3, "合营会员")]

        for (typeValue, typeName) in userTypes {
            let action = UIAlertAction(title: "\(typeValue)-\(typeName)", style: .default) { [weak self] _ in
                self?.selectedUserType = typeValue
                self?.updateUserTypeButtonTitle()
            }
            if typeValue == selectedUserType {
                action.setValue(theme.tintColor, forKey: "titleTextColor")
            }
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))

        if let popover = alertController.popoverPresentationController {
            popover.sourceView = userTypeButton
            popover.sourceRect = userTypeButton.bounds
        }
        present(alertController, animated: true)
    }

    private func updateUserTypeButtonTitle() {
        userTypeButton.setTitle("\(selectedUserType)-\(getUserTypeName(for: selectedUserType))", for: .normal)
    }

    private func getUserTypeName(for type: Int) -> String {
        switch type {
        case 1: return "官方会员"
        case 2: return "邀请好友"
        case 3: return "合营会员"
        default: return "官方会员"
        }
    }

    // MARK: - 键盘

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = frame.height - view.safeAreaInsets.bottom + 20
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
}
