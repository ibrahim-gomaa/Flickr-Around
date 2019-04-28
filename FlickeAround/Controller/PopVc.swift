//
//  PopVc.swift
//  FlickeAround
//
//  Created by ibrahim on 4/25/19.
//  Copyright © 2019 ibrahim. All rights reserved.
//

import UIKit

class PopVc: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var imageName: UILabel!
    
    var passedImage: UIImage!
    var passedName: String!
    
    func initData (forImage image: UIImage){
        self.passedImage = image
    }
    
    func initName (forImageName name: String){
        self.passedName = name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        imageName.text = passedName
        addswipe()
    }
    
    func addswipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipescreen))
        swipe.delegate = self
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
    }
    
    @objc func swipescreen(){
        dismiss(animated: true, completion: nil)
    }

}
