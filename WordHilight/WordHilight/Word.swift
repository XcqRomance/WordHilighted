//
//	Word.swift
//
//	Create by romance on 29/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct Word{

	var boundingboxHeight : String!
	var boundingboxLeft : String!
	var boundingboxTop : String!
	var boundingboxWidth : String!
	var cueEndMs : String!
	var cueStartMs : String!
	var wordSequence : String!
	var wordText : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		boundingboxHeight = dictionary["boundingbox_height"] as? String
		boundingboxLeft = dictionary["boundingbox_left"] as? String
		boundingboxTop = dictionary["boundingbox_top"] as? String
		boundingboxWidth = dictionary["boundingbox_width"] as? String
		cueEndMs = dictionary["cue_end_ms"] as? String
		cueStartMs = dictionary["cue_start_ms"] as? String
		wordSequence = dictionary["word_sequence"] as? String
		wordText = dictionary["word_text"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if boundingboxHeight != nil{
			dictionary["boundingbox_height"] = boundingboxHeight
		}
		if boundingboxLeft != nil{
			dictionary["boundingbox_left"] = boundingboxLeft
		}
		if boundingboxTop != nil{
			dictionary["boundingbox_top"] = boundingboxTop
		}
		if boundingboxWidth != nil{
			dictionary["boundingbox_width"] = boundingboxWidth
		}
		if cueEndMs != nil{
			dictionary["cue_end_ms"] = cueEndMs
		}
		if cueStartMs != nil{
			dictionary["cue_start_ms"] = cueStartMs
		}
		if wordSequence != nil{
			dictionary["word_sequence"] = wordSequence
		}
		if wordText != nil{
			dictionary["word_text"] = wordText
		}
		return dictionary
	}

}
