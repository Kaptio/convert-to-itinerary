/**
* @author Ragnar
* @date 15/08/2015
* @description Test Suite for LeadsServie
*/

@isTest
private with sharing class LeadsServiceTestSuite {

	@isTest
	private static void autoConvertToPersonAccountTestCase1() {

		/*
			Auto Convert To Person Account Test Case 1: Ensures that account is inserted if AutoConvertToPersonAccount__c is true.
		*/

		Lead firstLead = new Lead(FirstName = 'Ragnar', LastName = 'Fjölnisson', Email = 'ragnar@kaptio.com',
			AutoConvertToPersonAccount__c = true);
		insert firstLead;

		System.assertEquals(1, [select Count() from Account limit 2]);

	}

	@isTest
	private static void autoConvertToItineraryTestCase1() {

		/*
			Auto Convert To Itinerary Test Case 1: Ensures that account is inserted if AutoConvertToItinerary__c is true.
		*/

		Lead firstLead = new Lead(FirstName = 'Ragnar', LastName = 'Fjölnisson', Email = 'ragnar@kaptio.com',
			AutoConvertToItinerary__c = true);
		// we are missing properties to ensure creation of Itinerary - this test will fail unless amended.
		insert firstLead;

		System.assertEquals(1, [select Count() from KaptioTravel__Itinerary__c limit 2]);

	}

	@isTest private static void postConversionUpdateTestCase1(){

		/*
			PostConversionUpdate Test Case 1: Ensures that values on account are updated for existing account lead conversion
		*/

		RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer'
			AND SObjectType = 'Account' limit 1];

		Account a = new Account(LastName = 'Fgolnisson', Phone = '4781073', RecordType = personAccountRecordType, PersonEmail =
			'ragnar@kaptio.com');
		insert a;

		Lead lead = new Lead(FirstName = 'Ragnar', LastName = 'Fjölnisson', Email = 'ragnar@kaptio.com', Phone = null,
			AutoConvertToPersonAccount__c = true, UpdateExistingPersonAccount__c = true);
		insert Lead;

		a = [select FirstName, LastName, Phone from Account where Id =: a.Id limit 1];

		System.assertEquals('Fjölnisson', a.LastName, 'Name should have changed');
		System.assertEquals('4781073', a.Phone, 'Phone number should be same, as the converted lead had null');

	}

	@isTest private static void postConversionUpdateTestCase2(){

		/*
			PostConversionUpdate Test Case 2: Ensures that values on account are not updated if name is not provided.
		*/

		RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer'
			AND SObjectType = 'Account' limit 1];

		Account a = new Account(LastName = 'Fgolnisson', Phone = '4781073', RecordType = personAccountRecordType, PersonEmail =
			'ragnar@kaptio.com');
		insert a;

		Lead lead = new Lead(FirstName = 'Johnny', LastName = '[not provided]', Email = 'ragnar@kaptio.com', Phone = null,
			AutoConvertToPersonAccount__c = true, UpdateExistingPersonAccount__c = true);
		insert Lead;

		a = [select FirstName, LastName, Phone from Account where Id =: a.Id limit 1];

		System.assertEquals('Fgolnisson', a.LastName, 'Name should not have changed');
		System.assertEquals('Johnny', a.FirstName, 'Name should match');

	}


}