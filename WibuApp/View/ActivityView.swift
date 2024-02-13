//
//  ActivityView.swift
//  WibuApp
//
//  Created by Pande Adhistanaya on 13/02/24.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    var activityItem: Array<Any>
    var applicationActivities: Array<UIActivity>? = nil
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIActivityViewController(activityItems: activityItem, applicationActivities: applicationActivities)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
