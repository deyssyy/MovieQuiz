import UIKit

class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    func alertPresten(vc: UIViewController, alertModel: AlertModel){
        let alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) {_ in
            self.delegate?.newGame()
            }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
}
