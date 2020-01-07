//
//  ViewController.swift
//  mapaBus
//
//  Created by Gaston Rodriguez Agriel on 12/15/19.
//  Copyright © 2019 Gaston Rodriguez Agriel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var txtNroLinea: UITextField!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var botonEstilo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        botonEstilo.layer.cornerRadius = 4
    }
    
    
    @IBAction func btn(_ sender: Any) {
        
        if txtNroLinea.text != "" {
            lblError.text = ""
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MapaStoryBoard") as! MapaViewController
            controller.linea = self.txtNroLinea.text!
            self.navigationController!.pushViewController(controller, animated: true)
        }
        else{
            lblError.text = "Debes introducir un nro de linea"
        }
        
    }
    
}

extension UIViewController{
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
