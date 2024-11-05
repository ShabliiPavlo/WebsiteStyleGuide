//
//  SignUpViewController.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 04.11.2024.
//

import UIKit

class SignUpViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameAlert: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailAlert: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneAlert: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var positionTableView: UITableView!
    @IBOutlet weak var uploadPhotoView: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var uploadAlert: UILabel!
    @IBOutlet weak var selectPosLabel: UILabel!
    
    // MARK: - Properties
    
    let positions = ["Frontend developer", "Backend developer", "Designer", "QA"]
    var selectedIndex: Int? = 0
    var selectedPhotoData: Data?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideAlerts()
        setupTextFieldDelegates()
    }
    
    // MARK: - Setup Methods
    
    private func setupTextFieldDelegates() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
    }
    
    private func setupUI() {
        setupUploadPhotoView()
        setupTableView()
        setupFonts()
    }
    
    private func setupUploadPhotoView() {
        uploadPhotoView.backgroundColor = .white
        uploadPhotoView.layer.borderColor = UIColor.gray.cgColor
        uploadPhotoView.layer.borderWidth = 1.0
        uploadPhotoView.layer.cornerRadius = 8.0
    }
    
    private func setupTableView() {
        positionTableView.register(UINib(nibName: "SignUpTableViewCell", bundle: nil), forCellReuseIdentifier: "SignUpTableViewCell")
        positionTableView.tableFooterView = UIView(frame: .zero)
        positionTableView.separatorStyle = .none
    }
    
    private func setupFonts() {
        if let currentPlaceholderText = nameTextField.placeholder {
            nameTextField.attributedPlaceholder = NSAttributedString(
                string: currentPlaceholderText,
                attributes: [.font: UIFont.nunitoSansRegular(.body2), .foregroundColor: UIColor.lightGray]
            )
        }
        
        if let currentPlaceholderText = emailTextField.placeholder {
            emailTextField.attributedPlaceholder = NSAttributedString(
                string: currentPlaceholderText,
                attributes: [.font: UIFont.nunitoSansRegular(.body2), .foregroundColor: UIColor.lightGray]
            )
        }
        
        if let currentPlaceholderText = phoneTextField.placeholder {
            phoneTextField.attributedPlaceholder = NSAttributedString(
                string: currentPlaceholderText,
                attributes: [.font: UIFont.nunitoSansRegular(.body2), .foregroundColor: UIColor.lightGray]
            )
        }

        uploadButton.titleLabel?.font = UIFont.nunitoSansRegular(.body2)
        
        selectPosLabel.font = UIFont.nunitoSansRegular(.body2)
    }

    // MARK: - Action Methods
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        presentPhotoSourceOptions()
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard validateInputFields() else { return }
        performRegistration()
    }
    
    @objc private func radioButtonPressed(_ sender: UIButton) {
        selectedIndex = sender.tag
        positionTableView.reloadData()
    }
    
    // MARK: - Helper Methods
    
    private func presentPhotoSourceOptions() {
        let alertController = UIAlertController(title: "Choose how you want to add a photo", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.openImagePicker(sourceType: .camera)
        })
        
        alertController.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("Source type not available.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func validateInputFields() -> Bool {
        var isValid = true
        
        // Name validation
        if nameTextField.text?.isEmpty ?? true {
            nameAlert.isHidden = false
            isValid = false
        } else {
            nameAlert.isHidden = true
        }
        
        // Email validation
        if let email = emailTextField.text, isValidEmail(email) {
            emailAlert.isHidden = true
        } else {
            emailAlert.isHidden = false
            isValid = false
        }
        
        // Phone validation
        if let phone = phoneTextField.text, isValidPhoneNumber(phone) {
            phoneAlert.isHidden = true
            phoneLabel.isHidden = false
        } else {
            phoneAlert.isHidden = false
            phoneLabel.isHidden = true
            isValid = false
        }
        
        // Photo validation
        if selectedPhotoData == nil {
            uploadAlert.isHidden = false
            isValid = false
        } else {
            uploadAlert.isHidden = true
        }
        
        return isValid
    }
    
    private func performRegistration() {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let phone = phoneTextField.text,
              let photoData = selectedPhotoData,
              let positionId = selectedIndex else {
            return
        }
        
        NetworkManager.shared.registerUser(name: name, email: email, phone: phone, positionId: positionId + 1, photoData: photoData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigateToGotItViewController()
                case .failure(let error):
                    self?.handleRegistrationError(error)
                }
            }
        }
    }
    
    private func handleRegistrationError(_ error: Error) {
        if let nsError = error as NSError? {
            print(nsError.code)
            if nsError.code == 409 {
                navigateToTryAgainViewController()
            } else {
                print(error.localizedDescription)
            }
        }
    }
    
    private func navigateToGotItViewController() {
        if let gotItVC = storyboard?.instantiateViewController(withIdentifier: "GotItViewController") as? GotItViewController {
            gotItVC.modalPresentationStyle = .fullScreen
            present(gotItVC, animated: true, completion: nil)
        }
    }
    
    private func navigateToTryAgainViewController() {
        if let tryAgainVC = storyboard?.instantiateViewController(withIdentifier: "TryAgainViewController") as? TryAgainViewController {
            tryAgainVC.modalPresentationStyle = .fullScreen
            present(tryAgainVC, animated: true, completion: nil)
        }
    }
    
    private func hideAlerts() {
        nameAlert.isHidden = true
        emailAlert.isHidden = true
        phoneAlert.isHidden = true
        uploadAlert.isHidden = true
    }
}

// MARK: - Validation Methods

extension SignUpViewController {
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^\\+38\\d{10}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phoneNumber)
    }
}

// MARK: - UIImagePickerControllerDelegate Methods

extension SignUpViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedPhotoData = editedImage.jpegData(compressionQuality: 0.8)
            uploadLabel.text = "Photo selected"
            uploadAlert.isHidden = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SignUpViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return positions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableViewCell") as! SignUpTableViewCell
        cell.label.text = positions[indexPath.row]
        cell.selectionStyle = .none
        
        if indexPath.row == selectedIndex {
            cell.button.setImage(UIImage(named: "radioON"), for: .normal)
        } else {
            cell.button.setImage(UIImage(named: "radioOf"), for: .normal)
        }
        
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(radioButtonPressed(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
