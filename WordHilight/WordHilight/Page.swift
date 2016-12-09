//
//	Page.swift
//
//	Create by romance on 29/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct Page{

	var pageNumber : String!
	var sections : [Section]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		pageNumber = dictionary["page_number"] as? String
		sections = [Section]()
		if let sectionsArray = dictionary["sections"] as? [NSDictionary]{
			for dic in sectionsArray{
				let value = Section(fromDictionary: dic)
				sections.append(value)
			}
		}
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if pageNumber != nil{
			dictionary["page_number"] = pageNumber
		}
		if sections != nil{
			var dictionaryElements = [NSDictionary]()
			for sectionsElement in sections {
				dictionaryElements.append(sectionsElement.toDictionary())
			}
			dictionary["sections"] = dictionaryElements
		}
		return dictionary
	}

}
