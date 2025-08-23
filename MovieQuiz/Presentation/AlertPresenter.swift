import UIKit

final class AlertPresenter {
    func alertPresten(vc: UIViewController, alertModel: AlertModel){
        let alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) {_ in alertModel.completion()
            }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
}
