import UIKit
import MapKit
import PhotosUI

class TaskDetailViewController: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet private weak var completedImageView: UIImageView!
    @IBOutlet private weak var completedLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var attachPhotoButton: UIButton!
    @IBOutlet weak var viewPhotoButton: UIButton!
    @IBOutlet private weak var mapView: MKMapView!
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(TaskAnnotationView.self, forAnnotationViewWithReuseIdentifier: TaskAnnotationView.identifier)
        mapView.delegate = self
        mapView.layer.cornerRadius = 12
        
        updateUI()
        updateMapView()
    }
    
    private func updateUI() {
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        
        let completedImage = UIImage(systemName: task.isComplete ? "circle.inset.filled" : "circle")
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedLabel.text = task.isComplete ? "Complete" : "Incomplete"
        
        let color: UIColor = task.isComplete ? .systemBlue : .tertiaryLabel
        completedImageView.tintColor = color
        completedLabel.textColor = color
        
        mapView.isHidden = !task.isComplete
        attachPhotoButton.isHidden = task.isComplete
        viewPhotoButton.isHidden = !task.isComplete
    }
    
    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    DispatchQueue.main.async {
                        self?.presentGoToSettingsAlert()
                    }
                }
            }
        } else {
            presentImagePicker()
        }
    }
    
    private func presentImagePicker() {
        let alertController = UIAlertController(title: "Choose Photo", message: "Select a photo from the library or take a new photo", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            config.filter = .images
            config.preferredAssetRepresentationMode = .current
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            self?.present(picker, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
    
    
    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(for: NSError(domain: "Camera not available", code: 0, userInfo: nil))
            return
        }
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera
        cameraPicker.delegate = self
        present(cameraPicker, animated: true)
    }
    
    func updateMapView() {
        guard let imageLocation = task.imageLocation else { return }
        let coordinate = imageLocation.coordinate
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController(
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
    
    // Implement PHPickerViewControllerDelegate Method - Required for Photo Picker
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(for: error)
                }
                return
            }
            
            guard let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                self?.task.image = image // This will automatically mark isComplete as true
                self?.updateUI()
                
                // Optionally, you can add location data
                if let assetId = result.assetIdentifier {
                    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject
                    if let location = asset?.location {
                        self?.task.imageLocation = location
                        self?.updateMapView()
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            task.image = image // This will automatically mark isComplete as true
            updateUI()
            
            // If you want to manually set location when taking a photo with the camera
            let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            task.imageLocation = location
            updateMapView()
        }
    }
}
