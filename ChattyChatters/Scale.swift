//
//  Scale.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 22/06/2023.
//

import UIKit

struct Scale {
    var windowHeight: CGFloat
    
    func getRegisterVCNameFieldTop() -> CGFloat {
        if windowHeight > 900 {
            return 100
        } else {
            return 50
        }
    }
    
    func getRegisterVCFieldsYForKeyboard() -> CGFloat {
        if windowHeight > 900 {
            return 50
        } else if windowHeight < 700 {
            return -100
        } else {
            return 0
        }
    }
    
    func getRegisterVCContinueButtonBottom() -> CGFloat {
        if windowHeight < 700 {
            return 25
        } else {
            return 75
        }
    }
    
    func getRegisterVCButtonYForKeyboard() -> CGFloat {
        if windowHeight < 700 {
            return 0
        } else {
            return 90
        }
    }
}
