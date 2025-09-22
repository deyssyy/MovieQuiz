import UIKit

final class AlertPresenter {
    static func alertPresten(vc: UIViewController, alertModel: AlertModel){
        let alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) {_ in alertModel.completion()
            }
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "alert_id"
        vc.present(alert, animated: true, completion: nil)
    }
}
