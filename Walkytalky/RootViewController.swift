//
//  RootViewController.swift
//  Walkytalky
//
//  Created by 안덕환 on 12/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var mainContainerView: UIView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "Main":
            guard let vc = segue.destination as? MainViewController else {
                return
            }
            vc.bindViewModel(to: MainViewModel())
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
