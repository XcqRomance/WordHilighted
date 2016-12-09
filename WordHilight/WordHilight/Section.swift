//
//	Section.swift
//
//	Create by romance on 29/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct Section{

	var audioFilename : String!
	var sectionSequence : String!
	var text : String!
	var words : [Word]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		audioFilename = dictionary["audio_filename"] as? String
		sectionSequence = dictionary["section_sequence"] as? String
		text = dictionary["text"] as? String
		words = [Word]()
		if let wordsArray = dictionary["words"] as? [NSDictionary]{
			for dic in wordsArray{
				let value = Word(fromDictionary: dic)
				words.append(value)
			}
		}
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if audioFilename != nil{
			dictionary["audio_filename"] = audioFilename
		}
		if sectionSequence != nil{
			dictionary["section_sequence"] = sectionSequence
		}
		if text != nil{
			dictionary["text"] = text
		}
		if words != nil{
			var dictionaryElements = [NSDictionary]()
			for wordsElement in words {
				dictionaryElements.append(wordsElement.toDictionary())
			}
			dictionary["words"] = dictionaryElements
		}
		return dictionary
	}

}
