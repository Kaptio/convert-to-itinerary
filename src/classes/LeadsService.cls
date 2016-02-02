/**
* @author Ragnar
* @date 02/02/2016
* @description Services used for the Lead object.
*/

public with sharing class LeadsService
{

	public static void autoConverter(List<SObject> records)
	{

		Map<Id, Lead> leadById = new Map<Id, Lead>((List<Lead>)records);
		List<Lead> personAccountsToConvert = new List<Lead>();

		for(Lead l : (List<Lead>)records)
		{
			if(l.AutoConvertToPersonAccount__c || l.AutoConvertToItinerary__c)
			{
				personAccountsToConvert.add(l);
			}
		}

		List<Database.LeadConvertResult> lcrs = convertToPersonAccountHelper(personAccountsToConvert);
		ChannelMapper cm = new ChannelMapper();
		//Group enquiryQueue = [select Id from Group where DeveloperName = 'OpenEnquiries' and Type = 'Queue' limit 1];

		List<KaptioTravel__Itinerary__c> itinerariesToInsert = new List<KaptioTravel__Itinerary__c>();

		for(Database.LeadConvertResult c : lcrs)
		{
			if( !c.success) continue;

			Lead lead = leadById.get(c.getLeadId());

			if( !lead.AutoConvertToItinerary__c) continue;

			Date startDate = lead.StartDate__c == null ? System.today() : lead.StartDate__c;
			Date endDate = lead.EndDate__c == null ? System.today() : lead.EndDate__c;
			Integer groupSize = lead.GroupSize__c == null ? 0 : Integer.valueOf(lead.GroupSize__c);

			KaptioTravel__Channel__c channel = cm.getInstance(lead.LanguagePreference__c);

			KaptioTravel__AppSettings__c app = KaptioTravel__AppSettings__c.getInstance();
			if(app == null)
			{
				app = new KaptioTravel__AppSettings__c();
				app.KaptioTravel__DefaultDeposit__c = 30;
			}

			KaptioTravel__Itinerary__c itin = new KaptioTravel__Itinerary__c(
				Name = lead.FirstName + ' ' + lead.LastName,
				CurrencyIsoCode = channel.CurrencyIsoCode,
				//OwnerId = enquiryQueue.Id, // otherwise owner is lead creator
				KaptioTravel__Group_Size__c = lead.GroupSize__c,
				KaptioTravel__Start_Date__c = lead.StartDate__c,
				KaptioTravel__End_Date__c = lead.EndDate__c,
				KaptioTravel__Account__c = c.getAccountId(),
				KaptioTravel__Primary_Contact__c = c.getContactId(),
				KaptioTravel__Channel__c = channel.Id,
				KaptioTravel__Description__c = lead.Description,
				KaptioTravel__Deposit_Percent__c = channel.KaptioTravel__DefaultDeposit__c
			);

			itinerariesToInsert.add(itin);
		}

		try
		{
			database.insert(itinerariesToInsert);
		} catch(Exception e)
		{
			throw e;
			// consider exception handling.
		}
	}

	public static void postConversionUpdate(List<SObject> records)
	{

		// A re-query is required as the convertAccountId may be updated in the autoConverter method above.
		Set<Id> leadIds = (new Map<Id,SObject>(records)).keySet();
		List<Lead> leadRecords = [select UpdateExistingPersonAccount__c, LanguagePreference__c, Salutation, FirstName, LastName, Phone,
			MobilePhone, ConvertedAccountId from Lead where Id in:leadIds];

		Set<Id> convertedAccountIds = new Set<Id>();
		for(Lead l : leadRecords)
		{
			if(l.ConvertedAccountId != null && l.UpdateExistingPersonAccount__c)
			{
				convertedAccountIds.add(l.ConvertedAccountId);
			}
		}

		ChannelMapper cm = new ChannelMapper();

		Map<Id, Account> existingAccountsById = new Map<Id, Account>(
			[Select Id From Account Where Id in :convertedAccountIds]);

		List<Account> accountsToUpdate = new List<Account>();
		for(Lead l : leadRecords)
		{
			if(existingAccountsById.containsKey(l.ConvertedAccountId))
			{
				Account a = existingAccountsById.get(l.ConvertedAccountId);
				if(l.Salutation != null) a.Salutation = l.Salutation;
				if(l.FirstName != null) a.FirstName = l.FirstName;
				if(!l.LastName.containsAny('[')) a.LastName = l.LastName;
				if(l.Phone != null) a.Phone = l.Phone;
				if(l.MobilePhone != null) a.PersonMobilePhone = l.MobilePhone;
				accountsToUpdate.add(a);
			}
		}

		try
		{
			database.update(accountsToUpdate);
		} catch(Exception e)
		{
			throw e;
			// consider exception handling.
		}
	}


	//--------------------------------------------------------------
	// Helper Methods
	//--------------------------------------------------------------

	private static List<Database.LeadConvertResult> convertToPersonAccountHelper(List<SObject> records)
	{

		List<Database.LeadConvertResult> output = new List<Database.LeadConvertResult>();
		LeadStatus convertStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1];

		Set<String> emails = new Set<String>();
		for (Lead l : (List<Lead>)records)
		{
			if(l.Email != '')
			{
				emails.add(l.Email);
			}

		}

		List<Account> existingAccounts = [select PersonEmail from Account where PersonEmail IN :emails];
		Map<String, Account> accountByEmail = new Map<String, Account>();
		for(Account a : existingAccounts)
		{
			accountByEmail.put(a.PersonEmail, a);
		}

		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();

		for (Lead lead : (List<Lead>)records)
		{
			if (!lead.isConverted)
			{
				Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(lead.Id);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				lc.setDoNotCreateOpportunity(true);

			if(accountByEmail.containsKey(lead.Email))
			{
				lc.setAccountId(accountByEmail.get(lead.Email).Id);
			}

			leadConverts.add(lc);
			}
		}

		if (!leadConverts.isEmpty())
		{
			try
			{
				output = Database.convertLead(leadConverts);
			} catch(Exception e)
			{
				throw e;
				// consider exception handling.
			}
		}
		return output;
	}
}