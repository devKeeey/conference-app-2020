import ios_combined
import Nuke
import RxCocoa
import RxSwift
import UIKit

final class SessionDetailViewController: UIViewController {
    var session: Session!

    // MARK: Private

    private let disposeBag = DisposeBag()

    // MARK: Outlets

    @IBOutlet private weak var headerSection: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeRoomLabel: UILabel!
    @IBOutlet private weak var categoryContainer: UIStackView!

    @IBOutlet private weak var descriptionSection: UIView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var readMoreButton: UIButton!

    @IBOutlet private weak var audienceSection: UIView!
    @IBOutlet private weak var intendedAudienceLabel: UILabel!

    @IBOutlet weak var speakersSection: UIView!
    @IBOutlet weak var speakersContainer: UIStackView!

    // MARK: Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        loadSession(session)
    }
}

// MARK: - Private functions

private extension SessionDetailViewController {
    func loadSession(_ session: Session) {
        titleLabel.text = session.title.ja
        dateLabel.text = session.startDayText
        timeRoomLabel.text = session.timeRoomText
        descriptionLabel.text = session.desc
        readMoreButton.isHidden = !descriptionLabel.isTruncated

        switch session {
        case let speech as SpeechSession:
            loadSpeechSession(speech)
        case let service as ServiceSession:
            loadServiceSession(service)
        default: break
        }
        print(session)
    }

    func loadSpeechSession(_ session: SpeechSession) {
        if let intendedAudience = session.intendedAudience {
            intendedAudienceLabel.text = intendedAudience
        } else {
            audienceSection.isHidden = true
        }
        if session.speakers.isEmpty {
            speakersSection.isHidden = true
        } else {
            session.speakers.forEach(addSpeaker(_:))
        }
    }

    func loadServiceSession(_ session: ServiceSession) {
        [
            descriptionSection,
            audienceSection,
            speakersSection,
        ]
        .compactMap { $0 }
        .forEach { $0?.isHidden = true }
    }

    func addSpeaker(_ speaker: Speaker) {
        let iconImageView = SpeakerIconImageView()
        if let imageUrl = speaker.imageUrl.flatMap(URL.init) {
            let options = ImageLoadingOptions(transition: .fadeIn(duration: 0.3))
            Nuke.loadImage(with: imageUrl, options: options, into: iconImageView)
        }

        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 14, weight: .light)
        nameLabel.textColor = UIColor(hex: "00B5E2")
        nameLabel.text = speaker.name
        let speakerContainer = UIStackView(arrangedSubviews: [iconImageView, nameLabel])
        speakerContainer.spacing = 16.0
        [iconImageView, nameLabel, speakerContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        speakersContainer.addArrangedSubview(speakerContainer)

        NSLayoutConstraint.activate(
            iconImageView.heightAnchor.constraint(equalToConstant: 60)
        )
    }
}

// MARK: Bind

private extension SessionDetailViewController {
    func bind() {
        disposeBag.insert(
            readMoreButton.rx.tap
                .bind(onNext: { [readMoreButton, descriptionLabel] in
                    descriptionLabel?.numberOfLines = 0
                    readMoreButton?.isHidden = true
                })
        )
    }
}
