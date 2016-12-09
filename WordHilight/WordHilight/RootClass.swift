//
//	RootClass.swift
//
//	Create by romance on 29/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct RootClass{

	var bookId : String!
	var pages : [Page]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		bookId = dictionary["book_id"] as? String
		pages = [Page]()
		if let pagesArray = dictionary["pages"] as? [NSDictionary]{
			for dic in pagesArray{
				let value = Page(fromDictionary: dic)
				pages.append(value)
			}
		}
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if bookId != nil{
			dictionary["book_id"] = bookId
		}
		if pages != nil{
			var dictionaryElements = [NSDictionary]()
			for pagesElement in pages {
				dictionaryElements.append(pagesElement.toDictionary())
			}
			dictionary["pages"] = dictionaryElements
		}
		return dictionary
	}

}
