//
//  ViewController.swift
//  Bluetooth
//
//  Created by Marcelo De Souza on 2016-08-25.
//  Copyright © 2016 Marcelo de Souza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var connectionStatus: UILabel!
	@IBOutlet weak var sendDataButton: UIButton!
	@IBOutlet weak var console: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Watch Bluetooth connection
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(connectionChanged(_:)), name: BLEServiceChangedStatusNotification, object: nil)
		// Start the Bluetooth discovery process
		btDiscoverySharedInstance
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: BLEServiceChangedStatusNotification, object: nil)
	}

	func connectionChanged(notification: NSNotification) {
		// Connection status changed. Indicate on GUI.
		let userInfo = notification.userInfo as! [String: Bool]
		dispatch_async(dispatch_get_main_queue(), {
			// Set image based on connection status
			if let isConnected: Bool = userInfo["isConnected"] {
				if isConnected {
					self.connectionStatus.text = "Connection Status: Connected"
				} else {
					self.connectionStatus.text = "Connection Status: Disconnected"
				}
			}
		});
	}

	@IBAction func sendDataAction(sender: UIButton) {
        guard let service = btDiscoverySharedInstance.bleService else {
            return
        }
        service.writePosition(0xaa)
	}
}

