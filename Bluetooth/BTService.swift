//
//  BTService.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 10/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */

let BLEServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
let WriteCharUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
let ReadCharUUID = CBUUID(string: "b4520103-a308-4e56-8a52-536c2ad07147")
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate {

	// MARK: Properties

	var peripheral: CBPeripheral?
	var writeCharacteristic: CBCharacteristic?
	var readCharacteristic: CBCharacteristic?

	// MARK: Initializers

	init(initWithPeripheral peripheral: CBPeripheral) {
		super.init()
		self.peripheral = peripheral
		self.peripheral?.delegate = self
	}

	deinit {
		self.reset()
	}

	// MARK: Bluetooth methods

	/**
     Discovery devices
     */
	func startDiscoveringServices() {
		self.peripheral?.discoverServices([BLEServiceUUID])
	}

	/**
     Reset bluetooth configuration
     */
	func reset() {
		if peripheral != nil {
			peripheral = nil
		}
		// Deallocating therefore send notification
		self.sendBTServiceNotificationWithIsBluetoothConnected(false)
	}

	/**
     Write to the device
     - parameter value: value
     */
	func writePosition(value: UInt8) {
		// See if characteristic has been discovered before writing to it
		if let writeCharacteristic = self.writeCharacteristic {
			// Need a mutable var to pass to writeValue function
			var charValue = value
			for data in chunkData(NSData(bytes: &charValue, length: sizeof(UInt8))) {
				self.peripheral?.writeValue(data, forCharacteristic: writeCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
			}
		}
	}

	// Mark: - CBPeripheralDelegate

	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		let uuidsForBTService: [CBUUID] = [WriteCharUUID, ReadCharUUID]
		if (peripheral != self.peripheral) {
			// Wrong Peripheral
			return
		}
		if (error != nil) {
			return
		}
		if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
			// No Services
			return
		}
		for service in peripheral.services! {
			if service.UUID == BLEServiceUUID {
				peripheral.discoverCharacteristics(uuidsForBTService, forService: service)
			}
		}
	}

	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
		if (peripheral != self.peripheral) {
			// Wrong Peripheral
			return
		}
		if (error != nil) {
			return
		}
		if let characteristics = service.characteristics {
			for characteristic in characteristics {
				if characteristic.UUID == ReadCharUUID {
					self.readCharacteristic = (characteristic)
					peripheral.setNotifyValue(true, forCharacteristic: characteristic)
				}
				else if characteristic.UUID == WriteCharUUID {
					self.writeCharacteristic = (characteristic)
				}
			}
			// Send notification that Bluetooth is connected and all required characteristics are discovered
			self.sendBTServiceNotificationWithIsBluetoothConnected(true)
		}
	}

	// Mark: - Private

	/**
     Chunk data to be able to fit on the packet
     - parameter data: full data packet
     - returns: array of data
     */
	private func chunkData(data: NSData) -> [NSData] {
		let length = data.length
		var offset = 0
		var array: [NSData] = []
		repeat {
			let thisChunkSize = ((length - offset) > 20) ? 20 : (length - offset)
			array.append(data.subdataWithRange(NSRange(location: offset, length: thisChunkSize)))
			offset += thisChunkSize
		} while (offset < length)
		return array
	}

	func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
		let connectionDetails = ["isConnected": isBluetoothConnected]
		NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
	}
}