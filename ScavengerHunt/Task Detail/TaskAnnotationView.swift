
import UIKit
import MapKit

class TaskAnnotationView: MKAnnotationView {

    static var identifier = "TaskAnnotationView"

    enum Constants {
        static let containerViewHeight: CGFloat = 80
        static let containerViewCornerRadius: CGFloat = 16
        static let imageViewPadding: CGFloat = 4
        static var pointerViewHieght: CGFloat { containerViewHeight / 3 }

        static var pointerViewHeightAfterRotation: CGFloat { pointerViewHieght * sqrt(2) / 2 }
    }

    var imageView = UIImageView()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with image: UIImage?) {
        imageView.image = image ?? UIImage(systemName: "pin.fill")
    }

    private func setupViews() {

        let containerView = UIView()

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = Constants.containerViewCornerRadius

        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight),
            containerView.widthAnchor.constraint(equalToConstant: Constants.containerViewHeight)
        ])

        let pointerView = UIView()
        pointerView.translatesAutoresizingMaskIntoConstraints = false
        pointerView.backgroundColor = .systemBackground
        pointerView.layer.cornerRadius = 4

        containerView.addSubview(pointerView)
        NSLayoutConstraint.activate([
            pointerView.heightAnchor.constraint(equalToConstant: Constants.pointerViewHieght),
            pointerView.widthAnchor.constraint(equalToConstant: Constants.pointerViewHieght),
            pointerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            pointerView.centerYAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
        ])
        let fortyFiveDegreesInRadians = 45 * CGFloat.pi / 180
        pointerView.transform = CGAffineTransform(rotationAngle: fortyFiveDegreesInRadians)


        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.containerViewCornerRadius - Constants.imageViewPadding
        imageView.clipsToBounds = true

        containerView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.imageViewPadding),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.imageViewPadding),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.imageViewPadding),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.imageViewPadding),
        ])
        centerOffset = CGPoint(x: -(Constants.containerViewHeight / 2),
                               y: -Constants.containerViewHeight - Constants.pointerViewHeightAfterRotation)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 5
    }
}
