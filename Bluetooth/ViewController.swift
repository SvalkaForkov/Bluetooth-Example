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
	private var isConnected = false

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
			self.isConnected = userInfo["isConnected"] ?? false
			if self.isConnected {
				self.connectionStatus.text = "Connection Status: Connected"
			} else {
				self.connectionStatus.text = "Connection Status: Disconnected"
			}

		})
	}

	@IBAction func sendDataAction(sender: UIButton) {
		guard let service = btDiscoverySharedInstance.bleService else {
			showFailAlert()
			return
		}
		if isConnected {
			service.writePosition(0xaa)
		} else {
			showFailAlert()
		}
	}

	func showFailAlert() {
		let alert = UIAlertController(title: "Error", message: "You need to be connect to be able to write something", preferredStyle: .Alert)
		let ok = UIAlertAction(title: "Ok", style: .Default) { (action) in
			alert.dismissViewControllerAnimated(true, completion: nil)
		}
		alert.addAction(ok)
		self.presentViewController(alert, animated: true, completion: nil)
	}
}

